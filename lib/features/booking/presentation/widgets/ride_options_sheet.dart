import 'package:flutter/material.dart';

import '../../../../config/themes/app_theme.dart';
import '../../../../core/mock/mock_data.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/vehicle.dart';

/// Bottom sheet for selecting ride options and confirming booking
class RideOptionsSheet extends StatefulWidget {
  final Location pickup;
  final Location dropoff;
  final Function(VehicleType, PaymentMethod) onConfirm;

  const RideOptionsSheet({
    super.key,
    required this.pickup,
    required this.dropoff,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required Location pickup,
    required Location dropoff,
    required Function(VehicleType, PaymentMethod) onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RideOptionsSheet(
        pickup: pickup,
        dropoff: dropoff,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<RideOptionsSheet> createState() => _RideOptionsSheetState();
}

class _RideOptionsSheetState extends State<RideOptionsSheet> {
  late List<FareEstimate> _estimates;
  VehicleType _selectedType = VehicleType.economy;
  PaymentMethod _selectedPayment = PaymentMethod.card;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEstimates();
  }

  Future<void> _loadEstimates() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() {
      _estimates = MockData.getFareEstimates(
        pickup: widget.pickup,
        dropoff: widget.dropoff,
      );
      _isLoading = false;
    });
  }

  FareEstimate? get _selectedEstimate {
    if (_isLoading) return null;
    return _estimates.firstWhere(
      (e) => e.vehicleType == _selectedType,
      orElse: () => _estimates.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Route summary
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 30,
                          color: AppColors.border,
                        ),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.pickup.placeName ?? 'Pickup',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.dropoff.placeName ?? 'Dropoff',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Vehicle options
              if (_isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Choose a ride',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ...VehicleTypeConfig.defaultConfigs.map((config) {
                        final estimate = _estimates.firstWhere(
                          (e) => e.vehicleType == config.type,
                        );
                        return _VehicleOption(
                          config: config,
                          estimate: estimate,
                          isSelected: _selectedType == config.type,
                          onTap: () {
                            setState(() {
                              _selectedType = config.type;
                            });
                          },
                        );
                      }),
                      const SizedBox(height: 24),

                      // Payment method
                      Text(
                        'Payment Method',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _PaymentOption(
                        icon: Icons.credit_card,
                        label: 'Card •••• 4242',
                        isSelected: _selectedPayment == PaymentMethod.card,
                        onTap: () {
                          setState(() {
                            _selectedPayment = PaymentMethod.card;
                          });
                        },
                      ),
                      _PaymentOption(
                        icon: Icons.account_balance_wallet,
                        label: 'Wallet Balance',
                        isSelected: _selectedPayment == PaymentMethod.wallet,
                        onTap: () {
                          setState(() {
                            _selectedPayment = PaymentMethod.wallet;
                          });
                        },
                      ),
                      _PaymentOption(
                        icon: Icons.money,
                        label: 'Cash',
                        isSelected: _selectedPayment == PaymentMethod.cash,
                        onTap: () {
                          setState(() {
                            _selectedPayment = PaymentMethod.cash;
                          });
                        },
                      ),
                      const SizedBox(height: 100), // Space for button
                    ],
                  ),
                ),

              // Confirm button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              widget.onConfirm(_selectedType, _selectedPayment);
                              Navigator.of(context).pop();
                            },
                      child: Text(
                        _selectedEstimate != null
                            ? 'Confirm ${_selectedEstimate!.vehicleType.name.toUpperCase()} - \$${_selectedEstimate!.estimatedFare.toStringAsFixed(2)}'
                            : 'Loading...',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VehicleOption extends StatelessWidget {
  final VehicleTypeConfig config;
  final FareEstimate estimate;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleOption({
    required this.config,
    required this.estimate,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getVehicleIcon(config.type),
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        config.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${config.maxCapacity} seats',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    config.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${estimate.duration.inMinutes} min • ${estimate.distanceKm.toStringAsFixed(1)} km',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${estimate.estimatedFare.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
                if (estimate.hasSurge)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${estimate.surgeMultiplier}x',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getVehicleIcon(VehicleType type) {
    switch (type) {
      case VehicleType.economy:
        return Icons.directions_car;
      case VehicleType.comfort:
        return Icons.directions_car;
      case VehicleType.premium:
        return Icons.local_taxi;
      case VehicleType.suv:
        return Icons.directions_car;
      case VehicleType.van:
        return Icons.airport_shuttle;
    }
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
