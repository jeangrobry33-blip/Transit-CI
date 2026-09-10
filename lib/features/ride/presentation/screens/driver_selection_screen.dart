import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/ride_models.dart';
import '../providers/ride_controller.dart';
import '../widgets/driver_card.dart';

/// Sélection du type de véhicule puis du chauffeur pour la course en cours.
class DriverSelectionScreen extends ConsumerStatefulWidget {
  const DriverSelectionScreen({super.key});

  @override
  ConsumerState<DriverSelectionScreen> createState() => _DriverSelectionScreenState();
}

class _DriverSelectionScreenState extends ConsumerState<DriverSelectionScreen> {
  Driver? _selectedDriver;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(rideBookingProvider.notifier).loadDrivers());
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(rideBookingProvider);
    final notifier = ref.read(rideBookingProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Choisir un véhicule')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              height: 160,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.fog,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.map_rounded, size: 48, color: AppColors.mist),
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: _RouteSummaryChip(booking: booking),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: VehicleType.values.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, i) {
                  final type = VehicleType.values[i];
                  final selected = booking.vehicleType == type;
                  return GestureDetector(
                    onTap: () {
                      notifier.setVehicleType(type);
                      notifier.loadDrivers();
                    },
                    child: Container(
                      width: 96,
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: selected ? type.color.withValues(alpha: 0.12) : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: selected ? type.color : Colors.transparent, width: 1.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(type.icon, color: type.color),
                          const SizedBox(height: 4),
                          Text(
                            type.label,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: booking.loadingDrivers
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      itemCount: booking.drivers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        final driver = booking.drivers[i];
                        return DriverCard(
                          driver: driver,
                          fare: notifier.estimateFare(booking.vehicleType),
                          selected: _selectedDriver?.id == driver.id,
                          onTap: () => setState(() => _selectedDriver = driver),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppButton(
                label: _selectedDriver == null
                    ? 'Sélectionner un chauffeur'
                    : 'Confirmer avec ${_selectedDriver!.name.split(' ').first}',
                onPressed: _selectedDriver == null
                    ? null
                    : () {
                        notifier.confirmDriver(_selectedDriver!);
                        context.push(RoutePaths.rideTracking);
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteSummaryChip extends StatelessWidget {
  const _RouteSummaryChip({required this.booking});

  final RideBookingState booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.route_rounded, size: 16, color: AppColors.orange),
          const SizedBox(width: 6),
          Text(
            '${AppFormatters.distance(booking.distanceMeters)} · ${booking.durationMinutes} min',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
