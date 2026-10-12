import '../../trip/data/trip_repository.dart';
import '../../trip/domain/trip_models.dart';
import '../domain/maps_models.dart';

/// Construit un résumé d'itinéraire (direct + combiné) et les points
/// d'intérêt simulés le long du trajet, à partir des options déjà calculées
/// par [TripRepository]. À remplacer par un vrai moteur d'itinéraires
/// (ex. Directions API) et un fournisseur de POI (ex. Places API).
class MockMapsRepository {
  MockMapsRepository(this._tripRepository);

  final TripRepository _tripRepository;

  static const _poiPool = [
    PointOfInterest(name: 'Station Petro Ivoire', category: PoiCategory.fuel, distanceMeters: 450),
    PointOfInterest(name: 'Pharmacie de la Paix', category: PoiCategory.pharmacy, distanceMeters: 800),
    PointOfInterest(name: 'Point Orange Money', category: PoiCategory.mobileMoney, distanceMeters: 150),
    PointOfInterest(name: 'Station Total', category: PoiCategory.fuel, distanceMeters: 1200),
    PointOfInterest(name: 'Pharmacie du Plateau', category: PoiCategory.pharmacy, distanceMeters: 2100),
    PointOfInterest(name: 'Point MTN MoMo', category: PoiCategory.mobileMoney, distanceMeters: 600),
    PointOfInterest(name: 'Point Moov Money', category: PoiCategory.mobileMoney, distanceMeters: 1800),
  ];

  Future<List<TripPlace>> search(String query) => _tripRepository.search(query);

  Future<MapRoute> routeTo(TripPlace destination, {required bool isRaining}) async {
    final options = await _tripRepository.optionsFor(destination, isRaining: isRaining);

    TripOption? direct;
    TripOption? combined;
    for (final o in options) {
      if (o.kind == TripOptionKind.combined) {
        combined ??= o;
      } else {
        if (direct == null || o.durationMinutes < direct.durationMinutes) direct = o;
      }
    }

    // Sélection déterministe (mais variée) de 2 à 3 POI selon le nom du lieu.
    final seed = destination.name.hashCode.abs();
    final count = 2 + (seed % 2);
    final pois = List.generate(count, (i) => _poiPool[(seed + i) % _poiPool.length]);

    return MapRoute(destination: destination, direct: direct, combined: combined, pointsOfInterest: pois);
  }
}
