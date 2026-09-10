import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../payment/domain/payment_method.dart';

/// Portefeuille interne Transit CI — solde, recharge, historique, cashback.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  static final _transactions = [
    WalletTransaction(
      id: 'tx1',
      title: 'Recharge Orange Money',
      amount: 10000,
      date: DateTime.now().subtract(const Duration(days: 1)),
      isCredit: true,
    ),
    WalletTransaction(
      id: 'tx2',
      title: 'Course VTC · Plateau → Cocody',
      amount: 2200,
      date: DateTime.now().subtract(const Duration(days: 2)),
      isCredit: false,
    ),
    WalletTransaction(
      id: 'tx3',
      title: 'Cashback fidélité',
      amount: 350,
      date: DateTime.now().subtract(const Duration(days: 3)),
      isCredit: true,
    ),
    WalletTransaction(
      id: 'tx4',
      title: 'Billet UTB · Abidjan → Bouaké',
      amount: 6000,
      date: DateTime.now().subtract(const Duration(days: 5)),
      isCredit: false,
    ),
  ];

  Future<void> _topUp(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => _TopUpSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Portefeuille')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Solde disponible', style: TextStyle(color: AppColors.white, fontSize: 13)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  AppFormatters.currency(user?.walletBalance ?? 0),
                  style: const TextStyle(color: AppColors.white, fontSize: 32, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: 160,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.white, foregroundColor: AppColors.orange),
                    onPressed: () => _topUp(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Recharger'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _PromoTile(
                  icon: Icons.local_offer_rounded,
                  title: 'Coupons',
                  subtitle: '2 promotions actives',
                  color: AppColors.ivoryGreen,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _PromoTile(
                  icon: Icons.savings_rounded,
                  title: 'Cashback',
                  subtitle: '350 FCFA ce mois-ci',
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Historique des transactions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          ..._transactions.map((tx) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (tx.isCredit ? AppColors.success : AppColors.danger).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          tx.isCredit ? Icons.south_west_rounded : Icons.north_east_rounded,
                          color: tx.isCredit ? AppColors.success : AppColors.danger,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx.title, style: Theme.of(context).textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(AppFormatters.dateTime(tx.date),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                          ],
                        ),
                      ),
                      Text(
                        '${tx.isCredit ? '+' : '-'}${AppFormatters.currency(tx.amount)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: tx.isCredit ? AppColors.success : AppColors.danger,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _PromoTile extends StatelessWidget {
  const _PromoTile({required this.icon, required this.title, required this.subtitle, required this.color});

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
        ],
      ),
    );
  }
}

class _TopUpSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recharger mon portefeuille', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.lg),
            ...[PaymentMethodType.orangeMoney, PaymentMethodType.mtnMoney, PaymentMethodType.moovMoney, PaymentMethodType.card]
                .map((type) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(type.icon, color: type.color),
                      title: Text(type.label),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).pop(),
                    )),
          ],
        ),
      ),
    );
  }
}
