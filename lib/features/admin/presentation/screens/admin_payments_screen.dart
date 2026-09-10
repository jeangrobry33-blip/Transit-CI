import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/admin_models.dart';

final _payments = [
  AdminPaymentSummary(reference: 'TRX-88213', method: 'Orange Money', amount: 12000, date: DateTime.now().subtract(const Duration(hours: 2)), status: 'Réussi'),
  AdminPaymentSummary(reference: 'TRX-88214', method: 'MTN Money', amount: 4500, date: DateTime.now().subtract(const Duration(hours: 4)), status: 'Réussi'),
  AdminPaymentSummary(reference: 'TRX-88215', method: 'Carte bancaire', amount: 25000, date: DateTime.now().subtract(const Duration(hours: 6)), status: 'Échoué'),
  AdminPaymentSummary(reference: 'TRX-88216', method: 'Moov Money', amount: 2200, date: DateTime.now().subtract(const Duration(hours: 9)), status: 'En attente'),
];

class AdminPaymentsScreen extends StatelessWidget {
  const AdminPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiements')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _payments.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          final p = _payments[i];
          final color = switch (p.status) {
            'Réussi' => AppColors.success,
            'Échoué' => AppColors.danger,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.reference, style: Theme.of(context).textTheme.titleMedium),
                      Text('${p.method} · ${AppFormatters.dateTime(p.date)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(AppFormatters.currency(p.amount), style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    StatusBadge(label: p.status, color: color),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
