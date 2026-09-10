import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/transit_line.dart';
import '../providers/gbaka_providers.dart';
import '../widgets/line_card.dart';

/// Recherche intelligente et liste des lignes de gbaka / wôrô-wôrô / bus urbains.
class GbakaLinesScreen extends ConsumerStatefulWidget {
  const GbakaLinesScreen({super.key});

  @override
  ConsumerState<GbakaLinesScreen> createState() => _GbakaLinesScreenState();
}

class _GbakaLinesScreenState extends ConsumerState<GbakaLinesScreen> {
  LineMode? _selectedMode;

  @override
  Widget build(BuildContext context) {
    final linesAsync = ref.watch(linesProvider(_selectedMode));

    return Scaffold(
      appBar: AppBar(title: const Text('Transport en commun')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: [
                  _ModeChip(
                    label: 'Toutes les lignes',
                    selected: _selectedMode == null,
                    onTap: () => setState(() => _selectedMode = null),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ...LineMode.values.map((mode) => Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: _ModeChip(
                          label: mode.label,
                          selected: _selectedMode == mode,
                          onTap: () => setState(() => _selectedMode = mode),
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: linesAsync.when(
                data: (lines) {
                  if (lines.isEmpty) {
                    return const EmptyState(
                      icon: Icons.route_rounded,
                      title: 'Aucune ligne trouvée',
                      message: 'Essayez un autre mode de transport ou revenez plus tard.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: lines.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final line = lines[i];
                      return LineCard(
                        line: line,
                        onTap: () => context.push('${RoutePaths.gbakaLineDetail}/${line.id}'),
                      );
                    },
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

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
