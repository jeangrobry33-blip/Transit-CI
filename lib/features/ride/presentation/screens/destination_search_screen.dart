import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_paths.dart';
import '../../domain/ride_models.dart';
import '../providers/ride_controller.dart';

/// Recherche du point de départ et de la destination avant réservation VTC/taxi.
class DestinationSearchScreen extends ConsumerStatefulWidget {
  const DestinationSearchScreen({super.key});

  @override
  ConsumerState<DestinationSearchScreen> createState() => _DestinationSearchScreenState();
}

class _DestinationSearchScreenState extends ConsumerState<DestinationSearchScreen> {
  final _destinationController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(rideBookingProvider);
    final placesAsync = ref.watch(placesSearchProvider(_query));

    return Scaffold(
      appBar: AppBar(title: const Text('Choisir votre trajet')),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  children: [
                    _LocationRow(
                      icon: Icons.my_location_rounded,
                      iconColor: AppColors.ivoryGreen,
                      label: booking.pickup?.name ?? 'Ma position actuelle',
                      sub: booking.pickup?.address ?? 'Détection GPS automatique',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Divider(height: 1),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.danger, size: 20),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: TextField(
                            controller: _destinationController,
                            onChanged: (v) => setState(() => _query = v),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Où allez-vous ?',
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Suggestions', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: placesAsync.when(
                  data: (places) => ListView.separated(
                    itemCount: places.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final place = places[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.orange.withValues(alpha: 0.1),
                          child: Icon(
                            place.isFavorite ? Icons.star_rounded : Icons.place_outlined,
                            color: AppColors.orange,
                          ),
                        ),
                        title: Text(place.name),
                        subtitle: Text(place.address),
                        onTap: () {
                          ref.read(rideBookingProvider.notifier).setDestination(place);
                          if (booking.pickup == null) {
                            ref.read(rideBookingProvider.notifier).setPickup(
                                  const PlaceSuggestion(
                                    name: 'Ma position actuelle',
                                    address: 'Localisation GPS',
                                    location: MockGeoDefaults.abidjan,
                                  ),
                                );
                          }
                          context.push(RoutePaths.rideDrivers);
                        },
                      );
                    },
                  ),
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

class MockGeoDefaults {
  static const abidjan = GeoPoint(5.3599, -4.0083);
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sub,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              Text(sub, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
            ],
          ),
        ),
      ],
    );
  }
}
