import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/weather_provider.dart';
import '../../data/mock_maps_repository.dart';
import '../../domain/maps_models.dart';
import '../../../trip/domain/trip_models.dart';

final mapsRepositoryProvider = Provider((ref) => MockMapsRepository());

final mapsPlacesSearchProvider = FutureProvider.family<List<TripPlace>, String>((ref, query) {
  return ref.read(mapsRepositoryProvider).search(query);
});

final mapRouteProvider = FutureProvider.family<MapRoute, TripPlace>((ref, destination) {
  final isRaining = ref.watch(isRainingProvider);
  return ref.read(mapsRepositoryProvider).routeTo(destination, isRaining: isRaining);
});

/// Simule une zone de faible connexion — bascule l'affichage de la carte en
/// mode hors-ligne (itinéraires mis en cache, pas de trafic en direct).
class OfflineModeController extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final offlineModeProvider = NotifierProvider<OfflineModeController, bool>(OfflineModeController.new);

/// Affichage des points d'intérêt sur la carte (station-service, pharmacie...).
class PoiVisibilityController extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

final poiVisibilityProvider = NotifierProvider<PoiVisibilityController, bool>(PoiVisibilityController.new);
