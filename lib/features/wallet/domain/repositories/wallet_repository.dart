import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/wallet.dart';

/// Abstract wallet repository
abstract class WalletRepository {
  /// Get user's wallet
  Future<Either<Failure, Wallet>> getWallet();

  /// Stream wallet balance changes
  Stream<Either<Failure, Wallet>> streamWallet();

  /// Get wallet transactions
  Future<Either<Failure, List<WalletTransaction>>> getTransactions({
    int page = 1,
    int limit = 20,
    TransactionType? typeFilter,
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Top up wallet
  Future<Either<Failure, WalletTransaction>> topUp({
    required double amount,
    required String paymentMethodId,
  });

  /// Withdraw from wallet (driver)
  Future<Either<Failure, WalletTransaction>> withdraw({
    required double amount,
    required String bankAccountId,
  });

  /// Get payment methods
  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods();

  /// Add payment method
  Future<Either<Failure, PaymentMethod>> addPaymentMethod({
    required String stripePaymentMethodId,
    bool setAsDefault = false,
  });

  /// Remove payment method
  Future<Either<Failure, void>> removePaymentMethod(String paymentMethodId);

  /// Set default payment method
  Future<Either<Failure, void>> setDefaultPaymentMethod(String paymentMethodId);

  /// Process trip payment
  Future<Either<Failure, WalletTransaction>> processPayment({
    required String tripId,
    required double amount,
    required PaymentMethodType paymentType,
    String? paymentMethodId,
  });

  /// Request refund
  Future<Either<Failure, WalletTransaction>> requestRefund({
    required String tripId,
    required String reason,
  });
}
