import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_paths.dart';
import '../../../auth/presentation/providers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.orange.withValues(alpha: 0.15),
                child: Text(
                  user?.initials ?? '?',
                  style: const TextStyle(color: AppColors.orange, fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.fullName ?? '', style: Theme.of(context).textTheme.headlineSmall),
                    Text(user?.phone ?? '', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                        Text(' ${user?.rating ?? 5.0}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.push(RoutePaths.editProfile),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _MenuTile(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Portefeuille',
            onTap: () => context.push(RoutePaths.wallet),
          ),
          _MenuTile(
            icon: Icons.credit_card_rounded,
            label: 'Moyens de paiement',
            onTap: () => context.push(RoutePaths.paymentMethods),
          ),
          _MenuTile(
            icon: Icons.history_rounded,
            label: 'Historique des trajets',
            onTap: () => context.push(RoutePaths.history),
          ),
          _MenuTile(
            icon: Icons.star_border_rounded,
            label: 'Mes favoris',
            onTap: () => context.push(RoutePaths.favorites),
          ),
          _MenuTile(
            icon: Icons.notifications_none_rounded,
            label: 'Notifications',
            onTap: () => context.push(RoutePaths.notifications),
          ),
          _MenuTile(
            icon: Icons.settings_outlined,
            label: 'Paramètres',
            onTap: () => context.push(RoutePaths.settings),
          ),
          _MenuTile(
            icon: Icons.support_agent_rounded,
            label: 'Support client',
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go(RoutePaths.login);
            },
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
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
              Icon(icon, color: AppColors.mist),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
              const Icon(Icons.chevron_right_rounded, color: AppColors.mist),
            ],
          ),
        ),
      ),
    );
  }
}
