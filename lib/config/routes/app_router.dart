import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/booking/presentation/pages/home_page.dart';
import '../../injection_container.dart';

/// Route names
class Routes {
  Routes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String booking = '/booking';
  static const String tripTracking = '/trip/:tripId';
  static const String tripHistory = '/history';
  static const String tripDetails = '/history/:tripId';
  static const String wallet = '/wallet';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Driver routes
  static const String driverHome = '/driver';
  static const String driverEarnings = '/driver/earnings';
  static const String driverTrips = '/driver/trips';
}

/// App router configuration
class AppRouter {
  final AuthBloc _authBloc;

  AppRouter({AuthBloc? authBloc}) : _authBloc = authBloc ?? sl<AuthBloc>();

  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: Routes.splash,
    refreshListenable: GoRouterRefreshStream(_authBloc.stream),
    redirect: _redirect,
    routes: _routes,
    errorBuilder: _errorBuilder,
  );

  /// Handle route redirects based on auth state
  String? _redirect(BuildContext context, GoRouterState state) {
    final authState = _authBloc.state;
    final isAuthRoute = state.matchedLocation == Routes.login ||
        state.matchedLocation == Routes.register;
    final isSplash = state.matchedLocation == Routes.splash;

    debugPrint('[Router] Redirect check: location=${state.matchedLocation}, authStatus=${authState.status}');

    // If checking auth status, stay on splash
    if (authState.status == AuthStatus.unknown || authState.status == AuthStatus.loading) {
      debugPrint('[Router] Auth unknown/loading, staying on splash');
      return isSplash ? null : Routes.splash;
    }

    // If authenticated, redirect from auth routes to home
    if (authState.isAuthenticated) {
      if (isAuthRoute || isSplash) {
        // Redirect based on user type
        if (authState.user?.isDriver ?? false) {
          debugPrint('[Router] Authenticated driver, redirecting to driverHome');
          return Routes.driverHome;
        }
        debugPrint('[Router] Authenticated passenger, redirecting to home');
        return Routes.home;
      }
      return null;
    }

    // If not authenticated, redirect to login (except auth routes)
    if (!authState.isAuthenticated && !isAuthRoute && !isSplash) {
      debugPrint('[Router] Not authenticated, redirecting to login');
      return Routes.login;
    }

    // Not authenticated but on splash - redirect to login
    if (!authState.isAuthenticated && isSplash) {
      debugPrint('[Router] Not authenticated on splash, redirecting to login');
      return Routes.login;
    }

    debugPrint('[Router] No redirect needed');
    return null;
  }

  /// Route definitions
  List<RouteBase> get _routes => [
        // Splash
        GoRoute(
          path: Routes.splash,
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),

        // Auth routes
        GoRoute(
          path: Routes.login,
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: Routes.register,
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),

        // Passenger routes
        GoRoute(
          path: Routes.home,
          name: 'home',
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'booking',
              name: 'booking',
              builder: (context, state) => const Placeholder(), // TODO: BookingPage
            ),
          ],
        ),
        GoRoute(
          path: Routes.tripTracking,
          name: 'tripTracking',
          builder: (context, state) {
            final tripId = state.pathParameters['tripId']!;
            return Placeholder(key: ValueKey(tripId)); // TODO: TripTrackingPage
          },
        ),
        GoRoute(
          path: Routes.tripHistory,
          name: 'tripHistory',
          builder: (context, state) => const Placeholder(), // TODO: TripHistoryPage
        ),
        GoRoute(
          path: Routes.wallet,
          name: 'wallet',
          builder: (context, state) => const Placeholder(), // TODO: WalletPage
        ),
        GoRoute(
          path: Routes.profile,
          name: 'profile',
          builder: (context, state) => const Placeholder(), // TODO: ProfilePage
        ),
        GoRoute(
          path: Routes.settings,
          name: 'settings',
          builder: (context, state) => const Placeholder(), // TODO: SettingsPage
        ),

        // Driver routes
        GoRoute(
          path: Routes.driverHome,
          name: 'driverHome',
          builder: (context, state) => const Placeholder(), // TODO: DriverHomePage
        ),
        GoRoute(
          path: Routes.driverEarnings,
          name: 'driverEarnings',
          builder: (context, state) => const Placeholder(), // TODO: DriverEarningsPage
        ),
        GoRoute(
          path: Routes.driverTrips,
          name: 'driverTrips',
          builder: (context, state) => const Placeholder(), // TODO: DriverTripsPage
        ),
      ];

  /// Error page builder
  Widget _errorBuilder(BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.matchedLocation}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(Routes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// GoRouter refresh notifier that listens to a stream
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    debugPrint('[GoRouterRefreshStream] Created, notifying listeners');
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      debugPrint('[GoRouterRefreshStream] Stream event received, notifying listeners');
      notifyListeners();
    });
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
