import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/admin_models.dart';

final _drivers = [
  AdminDriverSummary(name: 'Kouadio Yao', vehicle: 'Toyota Corolla · CI 4521 AB', rating: 4.9, tripsCount: 1204, status: 'En ligne'),
  AdminDriverSummary(name: 'Fatou Diabaté', vehicle: 'Hyundai Accent · CI 7788 CD', rating: 4.7, tripsCount: 856, status: 'En ligne'),
  AdminDriverSummary(name: 'Ibrahim Traoré', vehicle: 'Suzuki Swift · CI 1092 EF', rating: 4.8, tripsCount: 632, status: 'Hors ligne'),
  AdminDriverSummary(name: 'Adama Ouattara', vehicle: 'Moto Honda · CI M-4471', rating: 4.6, tripsCount: 2011, status: 'Vérification requise'),
];

class AdminDriversScreen extends StatelessWidget {
  const AdminDriversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chauffeurs')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _drivers.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          final driver = _drivers[i];
          final color = switch (driver.status) {
            'En ligne' => AppColors.success,
            'Hors ligne' => AppColors.mist,
            _ => AppColors.warning,
          };
          return Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.modeVtc.withValues(alpha: 0.12),
                  child: Text(driver.name.substring(0, 1), style: const TextStyle(color: AppColors.modeVtc)),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(driver.name, style: Theme.of(context).textTheme.titleMedium),
                      Text(driver.vehicle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 12, color: AppColors.warning),
                          Text(' ${driver.rating} · ${driver.tripsCount} courses',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                        ],
                      ),
                    ],
                  ),
                ),
                StatusBadge(label: driver.status, color: color),
              ],
            ),
          );
        },
      ),
    );
  }
}
