import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/utils/formatters.dart';

/// Tableau de bord administrateur — vue d'ensemble de la plateforme Transit CI.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const _weeklyRevenue = [4.2, 5.1, 3.8, 6.4, 7.2, 8.9, 6.1];
  static const _weekLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panneau administrateur')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                icon: Icons.people_alt_rounded,
                label: 'Utilisateurs',
                value: '24 580',
                color: AppColors.modeVtc,
              ),
              _StatCard(
                icon: Icons.badge_rounded,
                label: 'Chauffeurs actifs',
                value: '1 342',
                color: AppColors.ivoryGreen,
              ),
              _StatCard(
                icon: Icons.payments_rounded,
                label: 'Revenus aujourd\'hui',
                value: AppFormatters.currency(1850000),
                color: AppColors.orange,
              ),
              _StatCard(
                icon: Icons.route_rounded,
                label: 'Trajets aujourd\'hui',
                value: '3 927',
                color: AppColors.info,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Revenus de la semaine (millions FCFA)', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 10,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= _weekLabels.length) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(_weekLabels[i], style: Theme.of(context).textTheme.bodySmall),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(_weeklyRevenue.length, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: _weeklyRevenue[i],
                              color: AppColors.orange,
                              width: 18,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Gestion', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          _AdminLink(
            icon: Icons.people_alt_rounded,
            label: 'Utilisateurs',
            onTap: () => context.push(RoutePaths.adminUsers),
          ),
          _AdminLink(
            icon: Icons.badge_rounded,
            label: 'Chauffeurs',
            onTap: () => context.push(RoutePaths.adminDrivers),
          ),
          _AdminLink(
            icon: Icons.apartment_rounded,
            label: 'Compagnies de transport',
            onTap: () => context.push(RoutePaths.adminCompanies),
          ),
          _AdminLink(
            icon: Icons.payments_rounded,
            label: 'Paiements',
            onTap: () => context.push(RoutePaths.adminPayments),
          ),
          _AdminLink(icon: Icons.support_agent_rounded, label: 'Support client', onTap: () {}),
          _AdminLink(icon: Icons.description_rounded, label: 'Documents & vérifications', onTap: () {}),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  final IconData icon;
  final String label;
  final String value;
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
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
        ],
      ),
    );
  }
}

class _AdminLink extends StatelessWidget {
  const _AdminLink({required this.icon, required this.label, required this.onTap});

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
