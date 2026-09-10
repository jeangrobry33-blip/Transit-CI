import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/admin_models.dart';

final _users = [
  AdminUserSummary(name: 'Aya Kouassi', phone: '+225 07 01 02 03 04', tripsCount: 128, joinedAt: DateTime(2024, 3, 12), status: 'Actif'),
  AdminUserSummary(name: 'Mamadou Coulibaly', phone: '+225 05 11 22 33 44', tripsCount: 64, joinedAt: DateTime(2024, 6, 2), status: 'Actif'),
  AdminUserSummary(name: 'Josiane N\'Guessan', phone: '+225 01 55 66 77 88', tripsCount: 12, joinedAt: DateTime(2025, 1, 20), status: 'Suspendu'),
  AdminUserSummary(name: 'Yves Bamba', phone: '+225 07 44 55 66 77', tripsCount: 302, joinedAt: DateTime(2023, 11, 9), status: 'Actif'),
];

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Utilisateurs')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _users.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          final user = _users[i];
          return Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.orange.withValues(alpha: 0.12),
                  child: Text(user.name.substring(0, 1), style: const TextStyle(color: AppColors.orange)),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: Theme.of(context).textTheme.titleMedium),
                      Text(user.phone, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                      Text('${user.tripsCount} trajets · Inscrit le ${AppFormatters.date(user.joinedAt)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                    ],
                  ),
                ),
                StatusBadge(
                  label: user.status,
                  color: user.status == 'Actif' ? AppColors.success : AppColors.danger,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
