import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_badge.dart';

class _HistoryItem {
  const _HistoryItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.price,
    required this.status,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final DateTime date;
  final double price;
  final String status;
}

final _history = [
  _HistoryItem(
    icon: Icons.directions_car_rounded,
    color: AppColors.modeVtc,
    title: 'VTC · Plateau → Cocody',
    subtitle: 'Kouadio Yao · Toyota Corolla',
    date: DateTime.now().subtract(const Duration(days: 1)),
    price: 2200,
    status: 'Terminé',
  ),
  _HistoryItem(
    icon: Icons.directions_bus_filled_rounded,
    color: AppColors.orange,
    title: 'UTB · Abidjan → Bouaké',
    subtitle: '2 sièges · Places 12, 13',
    date: DateTime.now().subtract(const Duration(days: 4)),
    price: 12000,
    status: 'Terminé',
  ),
  _HistoryItem(
    icon: Icons.airport_shuttle_rounded,
    color: AppColors.ivoryGreen,
    title: 'Gbaka 12 · Adjamé → Yopougon',
    subtitle: 'Paiement en espèces',
    date: DateTime.now().subtract(const Duration(days: 6)),
    price: 300,
    status: 'Terminé',
  ),
  _HistoryItem(
    icon: Icons.two_wheeler_rounded,
    color: AppColors.danger,
    title: 'Moto-taxi · Marcory → Zone 4',
    subtitle: 'Ibrahim Traoré',
    date: DateTime.now().subtract(const Duration(days: 9)),
    price: 700,
    status: 'Annulé',
  ),
];

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique des trajets')),
      body: _history.isEmpty
          ? const EmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'Aucun trajet',
              message: 'Vos trajets passés apparaîtront ici.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: _history.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final item = _history[i];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(item.icon, color: item.color),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                            Text(item.subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                StatusBadge(
                                  label: item.status,
                                  color: item.status == 'Annulé' ? AppColors.danger : AppColors.success,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(AppFormatters.date(item.date),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(AppFormatters.currency(item.price), style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
