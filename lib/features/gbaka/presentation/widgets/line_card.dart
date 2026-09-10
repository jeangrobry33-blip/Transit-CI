import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/transit_line.dart';

class LineCard extends StatelessWidget {
  const LineCard({super.key, required this.line, this.onTap});

  final TransitLine line;
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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: line.mode.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(line.mode.icon, color: line.mode.color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(line.code, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(width: AppSpacing.sm),
                      if (line.gpsTracked)
                        const Icon(Icons.gps_fixed_rounded, size: 14, color: AppColors.info),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    line.routeLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      StatusBadge(label: line.affluence.label, color: line.affluence.color),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(Icons.schedule_rounded, size: 12, color: AppColors.mist),
                      const SizedBox(width: 2),
                      Text('~${line.waitMinutes} min',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              AppFormatters.currency(line.averagePrice),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
