import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/providers/weather_provider.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/services/traffic_simulator.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/trip_models.dart';
import '../providers/trip_providers.dart';

/// Résultats de la recherche "Où allez-vous ?" — tous les moyens de
/// transport adaptés à la distance du trajet, triables par prix ou rapidité.
class TripPlannerResultsScreen extends ConsumerWidget {
  const TripPlannerResultsScreen({super.key, required this.destination});

  final TripPlace destination;

  void _openLeg(BuildContext context, List<TripLeg> legs) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Étapes du trajet', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.lg),
            ...legs.asMap().entries.map((entry) {
              final leg = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: leg.kind.color.withValues(alpha: 0.15),
                      child: Text('${entry.key + 1}', style: TextStyle(color: leg.kind.color, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(leg.label, style: Theme.of(context).textTheme.bodyMedium)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsAsync = ref.watch(tripOptionsProvider(destination));
    final sortMode = ref.watch(tripSortProvider);
    final isRaining = ref.watch(isRainingProvider);
    final traffic = TrafficSimulator.condition(time: DateTime.now(), isRaining: isRaining);

    return Scaffold(
      appBar: AppBar(title: Text(destination.name)),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (destination.landmark != null && destination.landmark!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Row(
                        children: [
                          const Icon(Icons.edit_location_alt_rounded, size: 14, color: AppColors.mist),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(destination.landmark!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => ref.read(isRainingProvider.notifier).toggle(),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: traffic.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(traffic.icon, size: 14, color: traffic.color),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(traffic.label,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: traffic.color),
                                      overflow: TextOverflow.ellipsis),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  isRaining ? Icons.water_drop_rounded : Icons.water_drop_outlined,
                                  size: 14,
                                  color: isRaining ? AppColors.info : AppColors.mist,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _SortToggle(mode: sortMode, onChanged: (m) => ref.read(tripSortProvider.notifier).setMode(m)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: optionsAsync.when(
                data: (options) {
                  if (options.isEmpty) {
                    return const EmptyState(
                      icon: Icons.sentiment_dissatisfied_rounded,
                      title: 'Aucune option trouvée',
                      message: 'Aucun moyen de transport n\'a été trouvé pour cette destination pour le moment.',
                    );
                  }
                  final sorted = sortTripOptions(options, sortMode);
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: sorted.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) => _TripOptionCard(
                      option: sorted[i],
                      onTap: () {
                        final option = sorted[i];
                        if (option.kind == TripOptionKind.combined) {
                          _openLeg(context, option.legs);
                        } else if (option.referenceId != null) {
                          context.push('${RoutePaths.gbakaLineDetail}/${option.referenceId}');
                        } else if (option.kind == TripOptionKind.interurbain) {
                          context.push(RoutePaths.interurbanSearch, extra: destination.name);
                        }
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Erreur : $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortToggle extends StatelessWidget {
  const _SortToggle({required this.mode, required this.onChanged});

  final TripSortMode mode;
  final void Function(TripSortMode) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SortChip(
            label: 'Économique',
            icon: Icons.payments_rounded,
            selected: mode == TripSortMode.economique,
            onTap: () => onChanged(TripSortMode.economique),
          ),
          _SortChip(
            label: 'Rapide',
            icon: Icons.bolt_rounded,
            selected: mode == TripSortMode.rapide,
            onTap: () => onChanged(TripSortMode.rapide),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({required this.label, required this.icon, required this.selected, required this.onTap});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? AppColors.white : AppColors.mist),
            const SizedBox(width: 4),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: selected ? AppColors.white : AppColors.mist, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _TripOptionCard extends StatelessWidget {
  const _TripOptionCard({required this.option, required this.onTap});

  final TripOption option;
  final VoidCallback onTap;

  bool get _isActionable =>
      option.kind == TripOptionKind.combined ||
      option.referenceId != null ||
      option.kind == TripOptionKind.interurbain;

  @override
  Widget build(BuildContext context) {
    final card = Container(
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
              color: option.kind.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(option.kind.icon, color: option.kind.color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(option.title, style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis)),
                    if (option.isEstimateOnly) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.mist.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: const Text('Estimation', style: TextStyle(fontSize: 10, color: AppColors.mist)),
                      ),
                    ],
                  ],
                ),
                Text(
                  option.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                option.priceLow == option.priceHigh
                    ? AppFormatters.currency(option.priceLow)
                    : '${AppFormatters.currency(option.priceLow)} – ${AppFormatters.currency(option.priceHigh)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.orange),
                textAlign: TextAlign.end,
              ),
              Text('~${option.durationMinutes} min', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
            ],
          ),
          if (_isActionable) ...[
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: AppColors.mist),
          ],
        ],
      ),
    );

    if (!_isActionable) return card;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(AppRadius.lg), child: card);
  }
}
