import '../domain/ride_models.dart';

/// Dépôt simulé pour la recherche de lieux et de chauffeurs à proximité.
/// À remplacer par des appels à l'API Transit CI (géocodage + matching temps réel).
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

  Future<List<Driver>> nearbyDrivers(VehicleType type) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      Driver(
        id: 'drv_1',
        name: 'Kouadio Yao',
        vehicleType: type,
        vehicleModel: 'Toyota Corolla · Gris',
        plateNumber: 'CI 4521 AB',
        rating: 4.9,
        tripsCount: 1204,
        etaMinutes: 3,
        photoInitials: 'KY',
      ),
      Driver(
        id: 'drv_2',
        name: 'Fatou Diabaté',
        vehicleType: type,
        vehicleModel: 'Hyundai Accent · Blanche',
        plateNumber: 'CI 7788 CD',
        rating: 4.7,
        tripsCount: 856,
        etaMinutes: 5,
        photoInitials: 'FD',
      ),
      Driver(
        id: 'drv_3',
        name: 'Ibrahim Traoré',
        vehicleType: type,
        vehicleModel: 'Suzuki Swift · Rouge',
        plateNumber: 'CI 1092 EF',
        rating: 4.8,
        tripsCount: 632,
        etaMinutes: 7,
        photoInitials: 'IT',
      ),
    ];
  }

  double estimateFare(VehicleType type, double distanceMeters) {
    final km = distanceMeters / 1000;
    return type.baseFare + (type.perKm * km);
  }
}
