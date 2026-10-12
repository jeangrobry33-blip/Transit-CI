import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/providers/weather_provider.dart';
import '../../../../core/services/traffic_simulator.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/sos_button.dart';
import '../../../trip/domain/trip_models.dart';
import '../../domain/maps_models.dart';
import '../providers/maps_providers.dart';

/// Onglet Carte — navigation interne façon Google Maps : recherche, trafic en
/// temps simulé, mode hors-ligne, points d'intérêt et itinéraire combiné.
class MapsScreen extends ConsumerStatefulWidget {
  const MapsScreen({super.key});

  @override
  ConsumerState<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends ConsumerState<MapsScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';
  TripPlace? _destination;
  bool _showDirect = true;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _selectDestination(TripPlace place) {
    setState(() {
      _destination = place;
      _query = '';
      _searchController.clear();
      _showDirect = true;
    });
    _searchFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isRaining = ref.watch(isRainingProvider);
    final offline = ref.watch(offlineModeProvider);
    final showPois = ref.watch(poiVisibilityProvider);
    final traffic = TrafficSimulator.condition(time: DateTime.now(), isRaining: isRaining);
    final suggestionsAsync = _query.isEmpty ? null : ref.watch(mapsPlacesSearchProvider(_query));

    return Scaffold(
      floatingActionButton: const SosButton(),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _MapCanvasPainter(
                hasDestination: _destination != null,
                destinationSeed: _destination?.name.hashCode ?? 0,
                dim: offline,
              ),
            ),
          ),
          if (offline)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.night.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.cloud_off_rounded, size: 14, color: AppColors.white),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Mode hors-ligne — itinéraires enregistrés localement',
                          style: TextStyle(color: AppColors.white, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (offline) const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: [BoxShadow(color: AppColors.night.withValues(alpha: 0.08), blurRadius: 12)],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: AppColors.mist),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocus,
                            onChanged: (v) => setState(() => _query = v),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              hintText: _destination?.name ?? 'Rechercher un lieu, une adresse...',
                            ),
                          ),
                        ),
                        if (_destination != null)
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () => setState(() => _destination = null),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _ToggleChip(
                          label: traffic.label,
                          icon: traffic.icon,
                          color: traffic.color,
                          selected: true,
                          onTap: () {},
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _ToggleChip(
                          label: 'Pluie',
                          icon: Icons.water_drop_rounded,
                          color: AppColors.info,
                          selected: isRaining,
                          onTap: () => ref.read(isRainingProvider.notifier).toggle(),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _ToggleChip(
                          label: 'Hors-ligne',
                          icon: Icons.cloud_off_rounded,
                          color: AppColors.slate,
                          selected: offline,
                          onTap: () => ref.read(offlineModeProvider.notifier).toggle(),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _ToggleChip(
                          label: 'Points d\'intérêt',
                          icon: Icons.place_rounded,
                          color: AppColors.ivoryGreen,
                          selected: showPois,
                          onTap: () => ref.read(poiVisibilityProvider.notifier).toggle(),
                        ),
                      ],
                    ),
                  ),
                  if (suggestionsAsync != null)
                    Container(
                      margin: const EdgeInsets.only(top: AppSpacing.sm),
                      constraints: const BoxConstraints(maxHeight: 260),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: [BoxShadow(color: AppColors.night.withValues(alpha: 0.1), blurRadius: 16)],
                      ),
                      child: suggestionsAsync.when(
                        data: (places) => ListView.builder(
                          shrinkWrap: true,
                          itemCount: places.length,
                          itemBuilder: (context, i) {
                            final p = places[i];
                            return ListTile(
                              dense: true,
                              leading: Icon(
                                p.scope == PlaceScope.urbanAbidjan ? Icons.place_outlined : Icons.directions_bus_filled_rounded,
                                color: AppColors.orange,
                              ),
                              title: Text(p.name),
                              subtitle: Text(p.description),
                              onTap: () => _selectDestination(p),
                            );
                          },
                        ),
                        loading: () => const Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, st) => Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text('Erreur : $e'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                child: _destination == null
                    ? _EmptyRoutePrompt()
                    : _RoutePanel(
                        destination: _destination!,
                        showDirect: _showDirect,
                        showPois: showPois,
                        onTabChanged: (direct) => setState(() => _showDirect = direct),
                      ),
              ),
            ),
          ),
          Positioned(
            right: AppSpacing.lg,
            bottom: _destination == null ? 110 : 280,
            child: FloatingActionButton.small(
              heroTag: 'recenter',
              backgroundColor: Theme.of(context).cardColor,
              foregroundColor: AppColors.orange,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recentré sur votre position'), duration: Duration(seconds: 1)),
                );
              },
              child: const Icon(Icons.my_location_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRoutePrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [BoxShadow(color: AppColors.night.withValues(alpha: 0.08), blurRadius: 16)],
      ),
      child: Row(
        children: [
          const Icon(Icons.explore_rounded, color: AppColors.orange),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Recherchez une destination pour voir l\'itinéraire, le trafic et les points d\'intérêt.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutePanel extends ConsumerWidget {
  const _RoutePanel({
    required this.destination,
    required this.showDirect,
    required this.showPois,
    required this.onTabChanged,
  });

  final TripPlace destination;
  final bool showDirect;
  final bool showPois;
  final void Function(bool direct) onTabChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRaining = ref.watch(isRainingProvider);
    final routeAsync = ref.watch(mapRouteProvider(destination));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [BoxShadow(color: AppColors.night.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, -4))],
      ),
      child: routeAsync.when(
        data: (route) {
          final hasCombined = route.combined != null;
          final selected = (showDirect || !hasCombined) ? route.direct : route.combined;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(route.destination.name, style: Theme.of(context).textTheme.titleMedium)),
                  if (hasCombined)
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(color: AppColors.cloud, borderRadius: BorderRadius.circular(AppRadius.pill)),
                      child: Row(
                        children: [
                          _RouteTab(label: 'Direct', selected: showDirect, onTap: () => onTabChanged(true)),
                          _RouteTab(label: 'Combiné', selected: !showDirect, onTap: () => onTabChanged(false)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (selected == null)
                Text('Aucun itinéraire disponible pour ce mode.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist))
              else ...[
                Row(
                  children: [
                    Icon(selected.kind.icon, size: 18, color: selected.kind.color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(selected.subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      selected.priceLow == selected.priceHigh
                          ? AppFormatters.currency(selected.priceLow)
                          : '${AppFormatters.currency(selected.priceLow)} – ${AppFormatters.currency(selected.priceHigh)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.orange),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Icon(Icons.schedule_rounded, size: 14, color: AppColors.mist),
                    const SizedBox(width: 4),
                    Text('~${selected.durationMinutes} min',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                  ],
                ),
                if (selected.legs.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: selected.legs
                        .map((leg) => Chip(
                              avatar: Icon(leg.kind.icon, size: 14, color: leg.kind.color),
                              label: Text(leg.label, style: const TextStyle(fontSize: 11)),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ))
                        .toList(),
                  ),
                ],
              ],
              if (showPois && route.pointsOfInterest.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.sm),
                Text('Sur le trajet', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.mist)),
                const SizedBox(height: 6),
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: route.pointsOfInterest.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final poi = route.pointsOfInterest[i];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                        decoration: BoxDecoration(
                          color: poi.category.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(poi.category.icon, size: 13, color: poi.category.color),
                            const SizedBox(width: 4),
                            Text('${poi.name} · ${AppFormatters.distance(poi.distanceMeters)}',
                                style: TextStyle(fontSize: 11, color: poi.category.color)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (isRaining) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.water_drop_rounded, size: 12, color: AppColors.info),
                    const SizedBox(width: 4),
                    Text('Durée ajustée pour la pluie', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.info)),
                  ],
                ),
              ],
            ],
          );
        },
        loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
        error: (e, st) => Text('Erreur : $e'),
      ),
    );
  }
}

class _RouteTab extends StatelessWidget {
  const _RouteTab({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selected ? AppColors.white : AppColors.mist)),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: selected ? color : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: selected ? color : AppColors.mist),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: selected ? color : AppColors.mist, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// Fond de carte stylisé (grille + routes schématiques + repères) tenant
/// lieu de tuiles cartographiques réelles — brancher google_maps_flutter
/// avec une clé API en production pour un rendu live.
class _MapCanvasPainter extends CustomPainter {
  _MapCanvasPainter({required this.hasDestination, required this.destinationSeed, required this.dim});

  final bool hasDestination;
  final int destinationSeed;
  final bool dim;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = dim ? const Color(0xFFE4E7ED) : AppColors.fog;
    canvas.drawRect(Offset.zero & size, bg);

    final gridPaint = Paint()
      ..color = AppColors.mist.withValues(alpha: dim ? 0.12 : 0.18)
      ..strokeWidth = 1;
    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final roadPaint = Paint()
      ..color = AppColors.white.withValues(alpha: dim ? 0.5 : 0.9)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.75), Offset(size.width * 0.9, size.height * 0.3), roadPaint);
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.1), Offset(size.width * 0.3, size.height * 0.9), roadPaint);

    final origin = Offset(size.width * 0.3, size.height * 0.62);
    _drawPin(canvas, origin, AppColors.ivoryGreen, filled: true);

    if (hasDestination) {
      final rand = Random(destinationSeed);
      final dest = Offset(
        size.width * (0.55 + rand.nextDouble() * 0.3),
        size.height * (0.2 + rand.nextDouble() * 0.3),
      );
      final routePaint = Paint()
        ..color = AppColors.orange
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;
      final path = Path()..moveTo(origin.dx, origin.dy);
      _dashedLineTo(path, origin, dest);
      canvas.drawPath(path, routePaint);
      _drawPin(canvas, dest, AppColors.danger, filled: true);
    }
  }

  void _dashedLineTo(Path path, Offset from, Offset to) {
    const dashLength = 10.0;
    final total = (to - from).distance;
    final steps = (total / dashLength).floor();
    for (var i = 0; i < steps; i++) {
      final t1 = i / steps;
      final t2 = (i + 0.5) / steps;
      if (i.isEven) {
        path.moveTo(from.dx + (to.dx - from.dx) * t1, from.dy + (to.dy - from.dy) * t1);
        path.lineTo(from.dx + (to.dx - from.dx) * t2, from.dy + (to.dy - from.dy) * t2);
      }
    }
  }

  void _drawPin(Canvas canvas, Offset center, Color color, {required bool filled}) {
    final paint = Paint()..color = color;
    canvas.drawCircle(center, 9, Paint()..color = AppColors.white);
    canvas.drawCircle(center, 7, paint);
  }

  @override
  bool shouldRepaint(covariant _MapCanvasPainter oldDelegate) =>
      oldDelegate.hasDestination != hasDestination ||
      oldDelegate.destinationSeed != destinationSeed ||
      oldDelegate.dim != dim;
}
