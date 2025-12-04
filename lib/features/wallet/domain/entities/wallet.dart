import 'package:equatable/equatable.dart';

/// Wallet type enum
enum WalletType {
  passenger,
  driver,
  tenant,
}

/// Transaction type enum
enum TransactionType {
  topUp,
  ridePayment,
  tripEarning,
  commission,
  withdrawal,
  refund,
  promoCredit,
  incentiveBonus,
  cashSettlement,
  penalty,
  transfer,
}

/// Transaction status enum
enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
  refunded,
}

/// Wallet entity
class Wallet extends Equatable {
  final String id;
  final String ownerId;
  final WalletType type;
  final double balance;
  final double pendingBalance; // Funds on hold
  final String currency;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Wallet({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.balance,
    this.pendingBalance = 0.0,
    this.currency = 'USD',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Available balance (total - pending)
  double get availableBalance => balance - pendingBalance;

  /// Check if wallet has sufficient funds
  bool hasSufficientFunds(double amount) => availableBalance >= amount;

  Wallet copyWith({
    String? id,
    String? ownerId,
    WalletType? type,
    double? balance,
    double? pendingBalance,
    String? currency,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        type,
        balance,
        pendingBalance,
        currency,
        isActive,
        createdAt,
        updatedAt,
      ];
}

/// Wallet transaction entity
class WalletTransaction extends Equatable {
  final String id;
  final String walletId;
  final TransactionType type;
  final double amount;
  final double balanceAfter;
  final String? referenceId; // Trip ID, Payout ID, etc.
  final String description;
  final TransactionStatus status;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? completedAt;

  const WalletTransaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.referenceId,
    required this.description,
    required this.status,
    this.metadata,
    required this.createdAt,
    this.completedAt,
  });

  /// Check if transaction is credit (adds to balance)
  bool get isCredit =>
      type == TransactionType.topUp ||
      type == TransactionType.tripEarning ||
      type == TransactionType.refund ||
      type == TransactionType.promoCredit ||
      type == TransactionType.incentiveBonus;

  /// Check if transaction is debit (subtracts from balance)
  bool get isDebit =>
      type == TransactionType.ridePayment ||
      type == TransactionType.withdrawal ||
      type == TransactionType.commission ||
      type == TransactionType.penalty ||
      type == TransactionType.cashSettlement;

  @override
  List<Object?> get props => [
        id,
        walletId,
        type,
        amount,
        balanceAfter,
        referenceId,
        description,
        status,
        metadata,
        createdAt,
        completedAt,
      ];
}

/// Payment method entity
class PaymentMethod extends Equatable {
  final String id;
  final String userId;
  final PaymentMethodType type;
  final String? last4;
  final String? brand; // Visa, Mastercard, etc.
  final String? expiryMonth;
  final String? expiryYear;
  final bool isDefault;
  final String? stripePaymentMethodId;
  final DateTime createdAt;

  const PaymentMethod({
    required this.id,
    required this.userId,
    required this.type,
    this.last4,
    this.brand,
    this.expiryMonth,
    this.expiryYear,
    this.isDefault = false,
    this.stripePaymentMethodId,
    required this.createdAt,
  });

  /// Get display name for the payment method
  String get displayName {
    switch (type) {
      case PaymentMethodType.card:
        return '${brand ?? 'Card'} •••• ${last4 ?? '****'}';
      case PaymentMethodType.bankAccount:
        return 'Bank Account •••• ${last4 ?? '****'}';
      case PaymentMethodType.wallet:
        return 'Wallet Balance';
      case PaymentMethodType.cash:
        return 'Cash';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        last4,
        brand,
        expiryMonth,
        expiryYear,
        isDefault,
        stripePaymentMethodId,
        createdAt,
      ];
}

/// Payment method type
enum PaymentMethodType {
  card,
  bankAccount,
  wallet,
  cash,
}
