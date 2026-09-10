import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/interurban_models.dart';

class TripCard extends StatelessWidget {
  const TripCard({super.key, required this.trip, this.onTap});

  final BusTrip trip;
  final VoidCallback? onTap;

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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: trip.company.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    trip.company.name,
                    style: TextStyle(color: trip.company.color, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(trip.comfort.label, style: Theme.of(context).textTheme.bodySmall),
                if (trip.hasAc) ...[
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.ac_unit_rounded, size: 14, color: AppColors.info),
                ],
                const Spacer(),
                Text(
                  AppFormatters.currency(trip.price),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.orange),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppFormatters.time(trip.departure), style: Theme.of(context).textTheme.headlineSmall),
                      Text(trip.originCity, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(AppFormatters.duration(Duration(minutes: trip.durationMinutes)),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                      const SizedBox(height: 2),
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Icon(Icons.directions_bus_filled_rounded, size: 16, color: AppColors.mist),
                          Expanded(child: Divider()),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(AppFormatters.time(trip.arrival), style: Theme.of(context).textTheme.headlineSmall),
                      Text(trip.destinationCity, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${trip.availableSeats} places disponibles sur ${trip.totalSeats}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.success),
            ),
          ],
        ),
      ),
    );
  }
}
