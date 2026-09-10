import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/transit_line.dart';
import '../providers/gbaka_providers.dart';

class LineDetailScreen extends ConsumerWidget {
  const LineDetailScreen({super.key, required this.lineId});

  final String lineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineAsync = ref.watch(lineDetailProvider(lineId));

    return Scaffold(
      appBar: AppBar(title: const Text('Détail de la ligne')),
      body: lineAsync.when(
        data: (line) => SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                height: 200,
                margin: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.fog,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Center(
                  child: Icon(Icons.gps_fixed_rounded, size: 48, color: line.mode.color),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  children: [
                    Row(
                      children: [
                        Text(line.code, style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(width: AppSpacing.md),
                        StatusBadge(label: line.mode.label, color: line.mode.color),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(line.routeLabel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mist)),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.schedule_rounded,
                            label: 'Attente estimée',
                            value: '${line.waitMinutes} min',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.payments_rounded,
                            label: 'Prix moyen',
                            value: AppFormatters.currency(line.averagePrice),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _InfoTile(
                      icon: Icons.groups_rounded,
                      label: 'Niveau d\'affluence',
                      value: line.affluence.label,
                      valueColor: line.affluence.color,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Points de chargement', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.md),
                    ...line.stops.asMap().entries.map((entry) {
                      final isLast = entry.key == line.stops.length - 1;
                      return _StopTile(name: entry.value, isLast: isLast, color: line.mode.color);
                    }),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AppButton(
                  label: 'Suivre ce véhicule en direct',
                  icon: Icons.location_on_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Suivi GPS activé pour cette ligne')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur : $e')),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value, this.valueColor});

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.mist),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}

class _StopTile extends StatelessWidget {
  const _StopTile({required this.name, required this.isLast, required this.color});

  final String name;
  final bool isLast;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              if (!isLast) Expanded(child: Container(width: 2, color: color.withValues(alpha: 0.3))),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Text(name, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
