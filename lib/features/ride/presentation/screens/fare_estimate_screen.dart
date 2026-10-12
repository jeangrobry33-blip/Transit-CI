import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/providers/weather_provider.dart';
import '../../../../core/services/traffic_simulator.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/ride_models.dart';
import '../providers/ride_controller.dart';

/// Estimation de prix pour VTC / taxi compteur / moto-taxi.
///
/// Transit CI ne réserve pas la course et n'assigne pas de chauffeur — ce
/// n'est pas un service de transport comme Yango. Cet écran aide seulement à
/// comparer le prix et le temps indicatifs de chaque mode avant de réserver
/// via votre application habituelle ou de héler un taxi/moto sur place.
class FareEstimateScreen extends ConsumerWidget {
  const FareEstimateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estimate = ref.watch(rideEstimateProvider);
    final notifier = ref.read(rideEstimateProvider.notifier);
    final isRaining = ref.watch(isRainingProvider);
    final traffic = TrafficSimulator.condition(time: DateTime.now(), isRaining: isRaining);

    if (estimate.pickup == null || estimate.destination == null) {
      return const Scaffold(body: Center(child: Text('Choisissez un trajet')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Estimation de prix')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.my_location_rounded, size: 16, color: AppColors.ivoryGreen),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(estimate.pickup!.name, style: Theme.of(context).textTheme.bodyMedium)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Divider(height: 1),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: AppColors.danger),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(estimate.destination!.name, style: Theme.of(context).textTheme.bodyMedium)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: traffic.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(traffic.icon, size: 16, color: traffic.color),
                  const SizedBox(width: AppSpacing.sm),
                  Text(traffic.label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: traffic.color)),
                  const Spacer(),
                  if (isRaining) const Icon(Icons.water_drop_rounded, size: 14, color: AppColors.info),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.info),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Transit CI ne réserve pas la course : ces prix sont indicatifs pour vous aider à choisir. Réservez ensuite via votre application VTC habituelle ou directement avec le chauffeur.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Comparer les options', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            ...VehicleType.values.map((type) {
              final (low, high) = notifier.fareRange(type);
              final duration = estimate.durationMinutes(isRaining: isRaining);
              final selected = estimate.vehicleType == type;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _FareOptionCard(
                  type: type,
                  low: low,
                  high: high,
                  durationMinutes: duration,
                  selected: selected,
                  onTap: () => notifier.setVehicleType(type),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _FareOptionCard extends StatelessWidget {
  const _FareOptionCard({
    required this.type,
    required this.low,
    required this.high,
    required this.durationMinutes,
    required this.selected,
    required this.onTap,
  });

  final VehicleType type;
  final double low;
  final double high;
  final int durationMinutes;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: selected ? type.color : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: type.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(type.icon, color: type.color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type.label, style: Theme.of(context).textTheme.titleMedium),
                  Text(type.description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${AppFormatters.currency(low)} – ${AppFormatters.currency(high)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.orange),
                  textAlign: TextAlign.end,
                ),
                Text('~$durationMinutes min', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
