import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../core/constants/app_constants.dart';
import '../../core/data/datasources/datasource_interface.dart';
import '../../core/error/exceptions.dart';

/// Firebase implementation of AuthDataSource
class FirebaseAuthDataSource implements AuthDataSource {
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSource({
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> initialize() async {
    // Firebase is initialized in main.dart
  }

  @override
  Future<void> dispose() async {
    // No cleanup needed for Firebase
  }

  @override
  AuthUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;

    return AuthUser(
      id: user.uid,
      email: user.email,
      phone: user.phoneNumber,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return AuthUser(
        id: user.uid,
        email: user.email,
        phone: user.phoneNumber,
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
    });
  }

  @override
  Future<AuthResponse> login(String identifier, String password) async {
    try {
      // Determine if identifier is email or phone
      final isEmail = identifier.contains('@');

      fb.UserCredential credential;

      if (isEmail) {
        credential = await _auth.signInWithEmailAndPassword(
          email: identifier,
          password: password,
        );
      } else {
        // For phone login, we need to use a custom approach
        // First, find the user by phone in Firestore
        final userDoc = await _firestore
            .collection(FirestoreCollections.users)
            .where('phone', isEqualTo: identifier)
            .limit(1)
            .get();

        if (userDoc.docs.isEmpty) {
          throw const AuthException(
            message: 'No account found with this phone number',
            code: 'USER_NOT_FOUND',
          );
        }

        // Get email from user doc and login with that
        final email = userDoc.docs.first.data()['email'] as String?;
        if (email == null) {
          throw const AuthException(
            message: 'Account configuration error',
            code: 'MISSING_EMAIL',
          );
        }

        credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      final user = credential.user!;
      final token = await user.getIdToken();

      // Get additional user data from Firestore
      final userDoc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .get();

      final userData = userDoc.data();

      return AuthResponse(
        user: AuthUser(
          id: user.uid,
          email: user.email,
          phone: userData?['phone'] as String? ?? user.phoneNumber,
          displayName: userData?['fullName'] as String? ?? user.displayName,
          photoUrl: userData?['avatarUrl'] as String? ?? user.photoURL,
        ),
        token: token!,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      // Create Firebase auth user with email
      final email = request.email ?? '${request.phone}@rideshare.local';

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: request.password,
      );

      final user = credential.user!;

      // Update display name
      await user.updateDisplayName(request.fullName);

      // Create user document in Firestore
      await _firestore.collection(FirestoreCollections.users).doc(user.uid).set({
        'id': user.uid,
        'tenantId': request.tenantId,
        'userType': request.userType,
        'phone': request.phone,
        'email': request.email,
        'fullName': request.fullName,
        'avatarUrl': null,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If registering as driver, create driver profile
      if (request.userType == 'driver') {
        await _firestore.collection(FirestoreCollections.drivers).doc(user.uid).set({
          'userId': user.uid,
          'tenantId': request.tenantId,
          'isVerified': false,
          'isOnline': false,
          'driverStatus': 'offline',
          'averageRating': 5.0,
          'totalTrips': 0,
          'totalEarnings': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Create wallet for user
      await _firestore.collection(FirestoreCollections.wallets).doc(user.uid).set({
        'id': user.uid,
        'ownerId': user.uid,
        'type': request.userType,
        'balance': 0.0,
        'pendingBalance': 0.0,
        'currency': 'USD',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final token = await user.getIdToken();

      return AuthResponse(
        user: AuthUser(
          id: user.uid,
          email: request.email,
          phone: request.phone,
          displayName: request.fullName,
        ),
        token: token!,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  @override
  Future<void> sendOtp(String phone) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (credential) async {
          // Auto-verification on Android
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          throw _mapFirebaseAuthException(e);
        },
        codeSent: (verificationId, resendToken) {
          // Store verification ID for later use
          // This would typically be handled by a state management solution
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on fb.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  @override
  Future<AuthResponse> verifyOtp(String phone, String otp) async {
    // This is a simplified implementation
    // In production, you'd need to store the verificationId from sendOtp
    throw UnimplementedError('OTP verification requires verificationId storage');
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<String?> refreshToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    return await user.getIdToken(true);
  }

  /// Map Firebase auth exceptions to our custom exceptions
  AuthException _mapFirebaseAuthException(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException.userNotFound();
      case 'wrong-password':
        return AuthException.invalidCredentials();
      case 'email-already-in-use':
        return const AuthException(
          message: 'An account with this email already exists',
          code: 'EMAIL_ALREADY_IN_USE',
        );
      case 'weak-password':
        return const AuthException(
          message: 'Password is too weak',
          code: 'WEAK_PASSWORD',
        );
      case 'invalid-email':
        return const AuthException(
          message: 'Invalid email address',
          code: 'INVALID_EMAIL',
        );
      case 'user-disabled':
        return const AuthException(
          message: 'This account has been disabled',
          code: 'USER_DISABLED',
        );
      case 'too-many-requests':
        return const AuthException(
          message: 'Too many attempts. Please try again later.',
          code: 'TOO_MANY_REQUESTS',
        );
      default:
        return AuthException(
          message: e.message ?? 'Authentication error',
          code: e.code,
          originalError: e,
        );
    }
  }
}
