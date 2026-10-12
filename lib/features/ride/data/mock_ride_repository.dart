import '../domain/ride_models.dart';

/// Dépôt simulé pour la recherche de lieux et l'estimation de tarifs.
/// À remplacer par des appels à l'API Transit CI (géocodage + barèmes réels).
class MockRideRepository {
  static const abidjanCenter = GeoPoint(5.3599, -4.0083);

  final List<PlaceSuggestion> _places = const [
    PlaceSuggestion(
      name: 'Plateau',
      address: 'Le Plateau, Abidjan',
      location: GeoPoint(5.3247, -4.0225),
      isFavorite: true,
    ),
    PlaceSuggestion(
      name: 'Cocody Riviera',
      address: 'Cocody, Abidjan',
      location: GeoPoint(5.3639, -3.9862),
    ),
    PlaceSuggestion(
      name: 'Aéroport FHB',
      address: 'Port-Bouët, Abidjan',
      location: GeoPoint(5.2610, -3.9263),
    ),
    PlaceSuggestion(
      name: 'Marché de Adjamé',
      address: 'Adjamé, Abidjan',
      location: GeoPoint(5.3667, -4.0247),
    ),
    PlaceSuggestion(
      name: 'Yopougon Siporex',
      address: 'Yopougon, Abidjan',
      location: GeoPoint(5.3458, -4.0742),
    ),
    PlaceSuggestion(
      name: 'Zone 4',
      address: 'Marcory, Abidjan',
      location: GeoPoint(5.2926, -3.9944),
      isFavorite: true,
    ),
  ];

  Future<List<PlaceSuggestion>> searchPlaces(String query) async {
    await Future.delayed(const Duration(milliseconds: 350));
    if (query.isEmpty) return _places;
    return _places
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<List<PlaceSuggestion>> favorites() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _places.where((p) => p.isFavorite).toList();
  }

  /// Fourchette de prix indicative — un vrai barème dépendrait de l'opérateur
  /// VTC/taxi choisi par l'utilisateur ; Transit CI ne fixe pas le prix final.
  (double low, double high) estimateFareRange(VehicleType type, double distanceMeters) {
    final km = distanceMeters / 1000;
    final mid = type.baseFare + (type.perKm * km);
    return (mid * 0.9, mid * 1.15);
  }
}
