import 'dart:async';

import '../../features/wallet/domain/entities/wallet.dart';
import 'mock_data.dart';

/// Mock implementation of Wallet data source for testing
class MockWalletDataSource {
  final Map<String, Wallet> _wallets = {};
  final List<WalletTransaction> _transactions = [];
  final List<PaymentMethod> _paymentMethods = [];
  final Map<String, StreamController<Wallet>> _walletStreams = {};

  // Simulated delay for realistic API behavior
  static const _delay = Duration(milliseconds: 500);

  MockWalletDataSource() {
    // Initialize with mock data
    for (final wallet in MockData.wallets) {
      _wallets[wallet.ownerId] = wallet;
    }
    _transactions.addAll(MockData.transactions);
    _paymentMethods.addAll(MockData.paymentMethods);
  }

  /// Get wallet for user
  Future<Wallet?> getWallet(String userId) async {
    await Future.delayed(_delay);
    return _wallets[userId];
  }

  /// Stream wallet updates
  Stream<Wallet> streamWallet(String userId) {
    if (!_walletStreams.containsKey(userId)) {
      _walletStreams[userId] = StreamController<Wallet>.broadcast();

      // Emit current state
      final wallet = _wallets[userId];
      if (wallet != null) {
        Future.microtask(() => _walletStreams[userId]?.add(wallet));
      }
    }
    return _walletStreams[userId]!.stream;
  }

  void _notifyWalletUpdate(String userId) {
    final wallet = _wallets[userId];
    if (wallet != null && _walletStreams.containsKey(userId)) {
      _walletStreams[userId]!.add(wallet);
    }
  }

  /// Get transaction history
  Future<List<WalletTransaction>> getTransactions({
    required String walletId,
    int limit = 20,
    String? lastTransactionId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(_delay);

    var transactions = _transactions.where((t) => t.walletId == walletId).toList();

    if (type != null) {
      transactions = transactions.where((t) => t.type == type).toList();
    }

    if (startDate != null) {
      transactions = transactions.where((t) => t.createdAt.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      transactions = transactions.where((t) => t.createdAt.isBefore(endDate)).toList();
    }

    // Sort by date descending
    transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Handle pagination
    if (lastTransactionId != null) {
      final lastIndex = transactions.indexWhere((t) => t.id == lastTransactionId);
      if (lastIndex != -1) {
        transactions = transactions.sublist(lastIndex + 1);
      }
    }

    return transactions.take(limit).toList();
  }

  /// Top up wallet
  Future<WalletTransaction> topUp({
    required String userId,
    required double amount,
    required String paymentMethodId,
  }) async {
    await Future.delayed(_delay);

    final wallet = _wallets[userId];
    if (wallet == null) {
      throw Exception('Wallet not found');
    }

    final newBalance = wallet.balance + amount;
    final updatedWallet = wallet.copyWith(
      balance: newBalance,
      updatedAt: DateTime.now(),
    );
    _wallets[userId] = updatedWallet;

    final transaction = WalletTransaction(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      walletId: wallet.id,
      type: TransactionType.topUp,
      amount: amount,
      balanceAfter: newBalance,
      description: 'Wallet top-up',
      status: TransactionStatus.completed,
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
    );

    _transactions.insert(0, transaction);
    _notifyWalletUpdate(userId);

    return transaction;
  }

  /// Withdraw from wallet (driver)
  Future<WalletTransaction> withdraw({
    required String userId,
    required double amount,
    required String paymentMethodId,
  }) async {
    await Future.delayed(_delay);

    final wallet = _wallets[userId];
    if (wallet == null) {
      throw Exception('Wallet not found');
    }

    if (!wallet.hasSufficientFunds(amount)) {
      throw Exception('Insufficient funds');
    }

    final newBalance = wallet.balance - amount;
    final updatedWallet = wallet.copyWith(
      balance: newBalance,
      updatedAt: DateTime.now(),
    );
    _wallets[userId] = updatedWallet;

    final transaction = WalletTransaction(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      walletId: wallet.id,
      type: TransactionType.withdrawal,
      amount: -amount,
      balanceAfter: newBalance,
      description: 'Withdrawal to bank account',
      status: TransactionStatus.pending,
      createdAt: DateTime.now(),
    );

    _transactions.insert(0, transaction);
    _notifyWalletUpdate(userId);

    // Simulate withdrawal completion after delay
    Future.delayed(const Duration(seconds: 2), () {
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = WalletTransaction(
          id: transaction.id,
          walletId: transaction.walletId,
          type: transaction.type,
          amount: transaction.amount,
          balanceAfter: transaction.balanceAfter,
          description: transaction.description,
          status: TransactionStatus.completed,
          createdAt: transaction.createdAt,
          completedAt: DateTime.now(),
        );
      }
    });

    return transaction;
  }

  /// Get payment methods for user
  Future<List<PaymentMethod>> getPaymentMethods(String userId) async {
    await Future.delayed(_delay);
    return _paymentMethods.where((pm) => pm.userId == userId).toList();
  }

  /// Add payment method
  Future<PaymentMethod> addPaymentMethod({
    required String userId,
    required PaymentMethodType type,
    String? cardNumber,
    String? expiryMonth,
    String? expiryYear,
    String? cvv,
  }) async {
    await Future.delayed(_delay);

    String? last4;
    String? brand;

    if (type == PaymentMethodType.card && cardNumber != null) {
      last4 = cardNumber.substring(cardNumber.length - 4);
      // Simple brand detection
      if (cardNumber.startsWith('4')) {
        brand = 'Visa';
      } else if (cardNumber.startsWith('5')) {
        brand = 'Mastercard';
      } else if (cardNumber.startsWith('3')) {
        brand = 'Amex';
      } else {
        brand = 'Card';
      }
    }

    final paymentMethod = PaymentMethod(
      id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: type,
      last4: last4,
      brand: brand,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      isDefault: _paymentMethods.where((pm) => pm.userId == userId).isEmpty,
      stripePaymentMethodId: 'pm_mock_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );

    _paymentMethods.add(paymentMethod);

    return paymentMethod;
  }

  /// Remove payment method
  Future<void> removePaymentMethod(String paymentMethodId) async {
    await Future.delayed(_delay);
    _paymentMethods.removeWhere((pm) => pm.id == paymentMethodId);
  }

  /// Set default payment method
  Future<void> setDefaultPaymentMethod({
    required String userId,
    required String paymentMethodId,
  }) async {
    await Future.delayed(_delay);

    // Remove default from current
    for (int i = 0; i < _paymentMethods.length; i++) {
      if (_paymentMethods[i].userId == userId && _paymentMethods[i].isDefault) {
        _paymentMethods[i] = PaymentMethod(
          id: _paymentMethods[i].id,
          userId: _paymentMethods[i].userId,
          type: _paymentMethods[i].type,
          last4: _paymentMethods[i].last4,
          brand: _paymentMethods[i].brand,
          expiryMonth: _paymentMethods[i].expiryMonth,
          expiryYear: _paymentMethods[i].expiryYear,
          isDefault: false,
          stripePaymentMethodId: _paymentMethods[i].stripePaymentMethodId,
          createdAt: _paymentMethods[i].createdAt,
        );
      }
    }

    // Set new default
    final index = _paymentMethods.indexWhere((pm) => pm.id == paymentMethodId);
    if (index != -1) {
      final pm = _paymentMethods[index];
      _paymentMethods[index] = PaymentMethod(
        id: pm.id,
        userId: pm.userId,
        type: pm.type,
        last4: pm.last4,
        brand: pm.brand,
        expiryMonth: pm.expiryMonth,
        expiryYear: pm.expiryYear,
        isDefault: true,
        stripePaymentMethodId: pm.stripePaymentMethodId,
        createdAt: pm.createdAt,
      );
    }
  }

  /// Process payment for a trip
  Future<WalletTransaction> processPayment({
    required String userId,
    required String tripId,
    required double amount,
    required PaymentMethodType paymentMethod,
  }) async {
    await Future.delayed(_delay);

    final wallet = _wallets[userId];
    if (wallet == null) {
      throw Exception('Wallet not found');
    }

    double newBalance = wallet.balance;

    // If paying with wallet, deduct from balance
    if (paymentMethod == PaymentMethodType.wallet) {
      if (!wallet.hasSufficientFunds(amount)) {
        throw Exception('Insufficient wallet balance');
      }
      newBalance = wallet.balance - amount;
    }

    final updatedWallet = wallet.copyWith(
      balance: newBalance,
      updatedAt: DateTime.now(),
    );
    _wallets[userId] = updatedWallet;

    final transaction = WalletTransaction(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      walletId: wallet.id,
      type: TransactionType.ridePayment,
      amount: -amount,
      balanceAfter: newBalance,
      referenceId: tripId,
      description: 'Ride payment',
      status: TransactionStatus.completed,
      metadata: {'payment_method': paymentMethod.name},
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
    );

    _transactions.insert(0, transaction);
    _notifyWalletUpdate(userId);

    return transaction;
  }

  /// Add trip earnings to driver wallet
  Future<WalletTransaction> addTripEarnings({
    required String driverId,
    required String tripId,
    required double amount,
    required double commissionRate,
  }) async {
    await Future.delayed(_delay);

    final wallet = _wallets[driverId];
    if (wallet == null) {
      // Create wallet if doesn't exist
      final newWallet = Wallet(
        id: 'wallet_$driverId',
        ownerId: driverId,
        type: WalletType.driver,
        balance: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _wallets[driverId] = newWallet;
    }

    final currentWallet = _wallets[driverId]!;
    final commission = amount * commissionRate;
    final netEarnings = amount - commission;
    final newBalance = currentWallet.balance + netEarnings;

    final updatedWallet = currentWallet.copyWith(
      balance: newBalance,
      updatedAt: DateTime.now(),
    );
    _wallets[driverId] = updatedWallet;

    // Create earning transaction
    final earningTxn = WalletTransaction(
      id: 'txn_earn_${DateTime.now().millisecondsSinceEpoch}',
      walletId: currentWallet.id,
      type: TransactionType.tripEarning,
      amount: amount,
      balanceAfter: currentWallet.balance + amount,
      referenceId: tripId,
      description: 'Trip earnings',
      status: TransactionStatus.completed,
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
    );
    _transactions.insert(0, earningTxn);

    // Create commission transaction
    final commissionTxn = WalletTransaction(
      id: 'txn_comm_${DateTime.now().millisecondsSinceEpoch}',
      walletId: currentWallet.id,
      type: TransactionType.commission,
      amount: -commission,
      balanceAfter: newBalance,
      referenceId: tripId,
      description: 'Platform commission (${(commissionRate * 100).toInt()}%)',
      status: TransactionStatus.completed,
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
    );
    _transactions.insert(0, commissionTxn);

    _notifyWalletUpdate(driverId);

    return earningTxn;
  }

  /// Request refund
  Future<WalletTransaction> requestRefund({
    required String userId,
    required String tripId,
    required double amount,
    required String reason,
  }) async {
    await Future.delayed(_delay);

    final wallet = _wallets[userId];
    if (wallet == null) {
      throw Exception('Wallet not found');
    }

    final newBalance = wallet.balance + amount;
    final updatedWallet = wallet.copyWith(
      balance: newBalance,
      updatedAt: DateTime.now(),
    );
    _wallets[userId] = updatedWallet;

    final transaction = WalletTransaction(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      walletId: wallet.id,
      type: TransactionType.refund,
      amount: amount,
      balanceAfter: newBalance,
      referenceId: tripId,
      description: 'Refund: $reason',
      status: TransactionStatus.completed,
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
    );

    _transactions.insert(0, transaction);
    _notifyWalletUpdate(userId);

    return transaction;
  }

  /// Get wallet statistics (for driver dashboard)
  Future<Map<String, dynamic>> getWalletStats(String userId) async {
    await Future.delayed(_delay);

    final wallet = _wallets[userId];
    if (wallet == null) {
      return {};
    }

    final userTransactions = _transactions.where((t) => t.walletId == wallet.id).toList();
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    double todayEarnings = 0;
    double weekEarnings = 0;
    double monthEarnings = 0;
    int todayTrips = 0;
    int weekTrips = 0;
    int monthTrips = 0;

    for (final txn in userTransactions) {
      if (txn.type == TransactionType.tripEarning) {
        if (txn.createdAt.isAfter(todayStart)) {
          todayEarnings += txn.amount;
          todayTrips++;
        }
        if (txn.createdAt.isAfter(weekStart)) {
          weekEarnings += txn.amount;
          weekTrips++;
        }
        if (txn.createdAt.isAfter(monthStart)) {
          monthEarnings += txn.amount;
          monthTrips++;
        }
      }
    }

    return {
      'balance': wallet.balance,
      'pendingBalance': wallet.pendingBalance,
      'todayEarnings': todayEarnings,
      'weekEarnings': weekEarnings,
      'monthEarnings': monthEarnings,
      'todayTrips': todayTrips,
      'weekTrips': weekTrips,
      'monthTrips': monthTrips,
    };
  }

  void dispose() {
    for (final controller in _walletStreams.values) {
      controller.close();
    }
    _walletStreams.clear();
  }
}
