import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../domain/ride_models.dart';

class DriverCard extends StatelessWidget {
  const DriverCard({
    super.key,
    required this.driver,
    required this.fare,
    this.onTap,
    this.selected = false,
  });

  final Driver driver;
  final double fare;
  final VoidCallback? onTap;
  final bool selected;

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
          border: Border.all(
            color: selected ? AppColors.orange : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: driver.vehicleType.color.withValues(alpha: 0.15),
              child: Text(
                driver.photoInitials,
                style: TextStyle(color: driver.vehicleType.color, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(driver.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    driver.vehicleModel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                      const SizedBox(width: 2),
                      Text('${driver.rating}', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(width: AppSpacing.sm),
                      Text('· ${driver.tripsCount} courses',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${driver.etaMinutes} min', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  '${fare.round()} FCFA',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
