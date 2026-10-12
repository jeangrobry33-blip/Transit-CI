import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/trip_models.dart';
import '../providers/trip_providers.dart';

/// Recherche unifiée "Où allez-vous ?" — le point d'entrée principal de
/// l'app : l'utilisateur décrit sa destination sans savoir comment s'y
/// rendre, Transit CI détermine ensuite les moyens de transport adaptés
/// selon qu'il s'agit d'un trajet dans Abidjan ou vers l'intérieur du pays.
class TripPlannerSearchScreen extends ConsumerStatefulWidget {
  const TripPlannerSearchScreen({super.key});

  @override
  ConsumerState<TripPlannerSearchScreen> createState() => _TripPlannerSearchScreenState();
}

class _TripPlannerSearchScreenState extends ConsumerState<TripPlannerSearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectPlace(TripPlace place) async {
    final landmark = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _LandmarkSheet(placeName: place.name),
    );
    if (!mounted) return;
    context.push(RoutePaths.tripResults, extra: place.withLandmark(landmark));
  }

  @override
  Widget build(BuildContext context) {
    final placesAsync = ref.watch(tripPlacesSearchProvider(_query));

    return Scaffold(
      appBar: AppBar(title: const Text('Où allez-vous ?')),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.mist),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        onChanged: (v) => setState(() => _query = v),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Un quartier d\'Abidjan ou une ville...',
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: placesAsync.when(
                  data: (places) {
                    final urban = places.where((p) => p.scope == PlaceScope.urbanAbidjan).toList();
                    final interior = places.where((p) => p.scope == PlaceScope.interiorCity).toList();
                    return ListView(
                      children: [
                        if (urban.isNotEmpty) ...[
                          _SectionLabel('Quartiers d\'Abidjan'),
                          ...urban.map((p) => _PlaceTile(place: p, onTap: () => _selectPlace(p))),
                        ],
                        if (interior.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          _SectionLabel('Villes de l\'intérieur'),
                          ...interior.map((p) => _PlaceTile(place: p, onTap: () => _selectPlace(p))),
                        ],
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Erreur : $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.mist)),
    );
  }
}

class _PlaceTile extends StatelessWidget {
  const _PlaceTile({required this.place, required this.onTap});

  final TripPlace place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUrban = place.scope == PlaceScope.urbanAbidjan;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: (isUrban ? AppColors.orange : AppColors.modeInterurbain).withValues(alpha: 0.1),
        child: Icon(
          isUrban ? Icons.place_outlined : Icons.directions_bus_filled_rounded,
          color: isUrban ? AppColors.orange : AppColors.modeInterurbain,
        ),
      ),
      title: Text(place.name),
      subtitle: Text(place.description),
      onTap: onTap,
    );
  }
}

class _LandmarkSheet extends StatefulWidget {
  const _LandmarkSheet({required this.placeName});
  final String placeName;

  @override
  State<_LandmarkSheet> createState() => _LandmarkSheetState();
}

class _LandmarkSheetState extends State<_LandmarkSheet> {
  final _landmarkController = TextEditingController();

  @override
  void dispose() {
    _landmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Précisez un repère (facultatif)', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Décrivez où se trouve exactement le lieu à ${widget.placeName} — utile quand il n\'y a pas d\'adresse précise.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _landmarkController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Ex. : en face de la pharmacie, après le pont...',
              prefixIcon: Icon(Icons.edit_location_alt_rounded, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Continuer',
            onPressed: () => Navigator.of(context).pop(
              _landmarkController.text.trim().isEmpty ? null : _landmarkController.text.trim(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Passer',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
