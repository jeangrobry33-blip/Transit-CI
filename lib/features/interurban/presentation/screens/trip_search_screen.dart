import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../data/mock_interurban_repository.dart';
import '../providers/interurban_controller.dart';
import '../widgets/trip_card.dart';

/// Recherche de trajets interurbains par ville de départ et d'arrivée.
class TripSearchScreen extends ConsumerStatefulWidget {
  const TripSearchScreen({super.key});

  @override
  ConsumerState<TripSearchScreen> createState() => _TripSearchScreenState();
}

class _TripSearchScreenState extends ConsumerState<TripSearchScreen> {
  String _origin = 'Abidjan';
  String _destination = 'Bouaké';
  DateTime _date = DateTime.now();
  bool _searched = false;

  Future<void> _pickCity({required bool isOrigin}) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => _CityPickerSheet(
        cities: MockInterurbanRepository.ivorianCities,
        title: isOrigin ? 'Ville de départ' : 'Ville de destination',
      ),
    );
    if (selected != null) {
      setState(() => isOrigin ? _origin = selected : _destination = selected);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _swap() {
    setState(() {
      final tmp = _origin;
      _origin = _destination;
      _destination = tmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final params = TripSearchParams(origin: _origin, destination: _destination, date: _date);
    final tripsAsync = _searched ? ref.watch(tripSearchProvider(params)) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Voyages interurbains')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _CityField(label: 'Départ', city: _origin, onTap: () => _pickCity(isOrigin: true)),
                      ),
                      IconButton(
                        onPressed: _swap,
                        icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.orange),
                      ),
                      Expanded(
                        child: _CityField(
                          label: 'Destination',
                          city: _destination,
                          onTap: () => _pickCity(isOrigin: false),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.xl),
                  InkWell(
                    onTap: _pickDate,
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.mist),
                        const SizedBox(width: AppSpacing.sm),
                        Text(AppFormatters.date(_date), style: Theme.of(context).textTheme.bodyMedium),
                        const Spacer(),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.mist),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Rechercher',
                    icon: Icons.search_rounded,
                    onPressed: () => setState(() => _searched = true),
                  ),
                ],
              ),
            ),
            Expanded(
              child: !_searched
                  ? const EmptyState(
                      icon: Icons.directions_bus_filled_rounded,
                      title: 'Prêt à voyager ?',
                      message: 'Choisissez vos villes de départ et d\'arrivée pour voir les trajets disponibles.',
                    )
                  : tripsAsync!.when(
                      data: (trips) {
                        if (trips.isEmpty) {
                          return const EmptyState(
                            icon: Icons.event_busy_rounded,
                            title: 'Aucun trajet disponible',
                            message: 'Aucune compagnie ne dessert cet itinéraire pour le moment.',
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          itemCount: trips.length,
                          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, i) {
                            final trip = trips[i];
                            return TripCard(
                              trip: trip,
                              onTap: () {
                                ref.read(interurbanBookingProvider.notifier).selectTrip(trip);
                                context.push(RoutePaths.interurbanSeats);
                              },
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

class _CityField extends StatelessWidget {
  const _CityField({required this.label, required this.city, required this.onTap});

  final String label;
  final String city;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
          const SizedBox(height: 2),
          Text(city, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _CityPickerSheet extends StatelessWidget {
  const _CityPickerSheet({required this.cities, required this.title});

  final List<String> cities;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            ...cities.map((city) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.location_city_rounded, color: AppColors.orange),
                  title: Text(city),
                  onTap: () => Navigator.of(context).pop(city),
                )),
          ],
        ),
      ),
    );
  }
}
