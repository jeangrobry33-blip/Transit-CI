import '../../gbaka/data/mock_gbaka_repository.dart';
import '../../gbaka/domain/transit_line.dart';
import '../../interurban/data/mock_interurban_repository.dart';
import 'dart:math';
import '../../ride/data/mock_ride_repository.dart';
import '../../ride/domain/ride_models.dart';
import '../../../core/services/traffic_simulator.dart';
import '../domain/trip_models.dart';

/// Points de repère — communes d'Abidjan (trajets urbains) et villes de
/// l'intérieur (trajets interurbains). Les noms de communes correspondent
/// exactement à ceux utilisés par [MockGbakaRepository] pour que les lignes
/// se rattachent directement à un lieu recherché.
class MockTripRepository {
  final _gbakaRepository = MockGbakaRepository();
  final _rideRepository = MockRideRepository();
  final _interurbanRepository = MockInterurbanRepository();

  static const _abidjanCommunes = [
    TripPlace(name: 'Plateau', description: 'Commune d\'Abidjan — centre des affaires', scope: PlaceScope.urbanAbidjan),
    TripPlace(name: 'Cocody', description: 'Commune d\'Abidjan — Riviera, Angré', scope: PlaceScope.urbanAbidjan),
    TripPlace(name: 'Yopougon', description: 'Commune d\'Abidjan — Siporex, Niangon', scope: PlaceScope.urbanAbidjan),
    TripPlace(name: 'Abobo', description: 'Commune d\'Abidjan', scope: PlaceScope.urbanAbidjan),
    TripPlace(name: 'Adjamé', description: 'Commune d\'Abidjan — grand marché, gare routière', scope: PlaceScope.urbanAbidjan),
    TripPlace(name: 'Marcory', description: 'Commune d\'Abidjan — Zone 4', scope: PlaceScope.urbanAbidjan),
    TripPlace(name: 'Treichville', description: 'Commune d\'Abidjan', scope: PlaceScope.urbanAbidjan),
    TripPlace(name: 'Koumassi', description: 'Commune d\'Abidjan — grand marché', scope: PlaceScope.urbanAbidjan),
    TripPlace(name: 'Port-Bouët', description: 'Commune d\'Abidjan — aéroport FHB', scope: PlaceScope.urbanAbidjan),
    TripPlace(name: 'Bingerville', description: 'Commune d\'Abidjan', scope: PlaceScope.urbanAbidjan),
    TripPlace(name: 'Attécoubé', description: 'Commune d\'Abidjan', scope: PlaceScope.urbanAbidjan),
  ];

  static final _interiorCities = MockInterurbanRepository.ivorianCities
      .where((c) => c != 'Abidjan')
      .map((c) => TripPlace(name: c, description: 'Ville de l\'intérieur', scope: PlaceScope.interiorCity))
      .toList();

  List<TripPlace> get allPlaces => [..._abidjanCommunes, ..._interiorCities];

  Future<List<TripPlace>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (query.isEmpty) return allPlaces;
    final q = query.toLowerCase();
    return allPlaces.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  /// Construit les options de trajet adaptées à la distance : moyens urbains
  /// pour une commune d'Abidjan, compagnies interurbaines pour une ville de
  /// l'intérieur (avec un rappel du trajet pour rejoindre la gare routière).
  Future<List<TripOption>> optionsFor(
    TripPlace destination, {
    bool isRaining = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();

    if (destination.scope == PlaceScope.interiorCity) {
      return _interiorOptions(destination, now: now, isRaining: isRaining);
    }
    return _urbanOptions(destination, now: now, isRaining: isRaining);
  }

  Future<List<TripOption>> _urbanOptions(
    TripPlace destination, {
    required DateTime now,
    required bool isRaining,
  }) async {
    final lines = await _gbakaRepository.lines();
    final matching = lines
        .where((l) =>
            l.origin == destination.name ||
            l.destination == destination.name ||
            l.stops.contains(destination.name))
        .toList();

    final options = <TripOption>[];

    for (final line in matching) {
      final waitAdjusted = TrafficSimulator.adjustedMinutes(
        baseMinutes: line.waitMinutes,
        time: now,
        isRaining: isRaining,
      );
      options.add(TripOption(
        kind: switch (line.mode) {
          LineMode.gbaka => TripOptionKind.gbaka,
          LineMode.woroworo => TripOptionKind.woroworo,
          LineMode.busUrbain => TripOptionKind.busUrbain,
        },
        title: line.code,
        subtitle: line.routeLabel,
        priceLow: line.averagePrice,
        priceHigh: line.averagePrice,
        durationMinutes: waitAdjusted,
        referenceId: line.id,
      ));
    }

    // Estimations VTC / taxi compteur / moto-taxi (indicatives uniquement).
    final distanceMeters = _estimateUrbanDistance(destination);
    final baseDuration = TrafficSimulator.adjustedMinutes(
      baseMinutes: (distanceMeters / 300).round().clamp(4, 90),
      time: now,
      isRaining: isRaining,
    );
    for (final type in [VehicleType.vtcStandard, VehicleType.taxiCompteur, VehicleType.motoTaxi]) {
      final (low, high) = _rideRepository.estimateFareRange(type, distanceMeters);
      options.add(TripOption(
        kind: type == VehicleType.motoTaxi ? TripOptionKind.motoTaxi : (type == VehicleType.taxiCompteur ? TripOptionKind.taxiCompteur : TripOptionKind.vtc),
        title: type.label,
        subtitle: 'Estimation — ${type.description}',
        priceLow: low,
        priceHigh: high,
        durationMinutes: baseDuration,
        isEstimateOnly: true,
      ));
    }

    // Trajet combiné illustratif quand aucune ligne directe ne dessert le lieu.
    if (matching.isEmpty && lines.isNotEmpty) {
      final nearest = lines.first;
      options.add(TripOption(
        kind: TripOptionKind.combined,
        title: 'Trajet combiné',
        subtitle: '${nearest.code} puis moto-taxi jusqu\'à ${destination.name}',
        priceLow: nearest.averagePrice + 300,
        priceHigh: nearest.averagePrice + 700,
        durationMinutes: baseDuration + 10,
        legs: [
          TripLeg(kind: TripOptionKind.gbaka, label: nearest.routeLabel, referenceId: nearest.id),
          TripLeg(kind: TripOptionKind.motoTaxi, label: 'Moto-taxi jusqu\'à ${destination.name}'),
        ],
      ));
    }

    return options;
  }

  Future<List<TripOption>> _interiorOptions(
    TripPlace destination, {
    required DateTime now,
    required bool isRaining,
  }) async {
    final trips = await _interurbanRepository.searchTrips(origin: 'Abidjan', destination: destination.name);
    if (trips.isEmpty) return [];

    final cheapest = trips.reduce((a, b) => a.price < b.price ? a : b);
    final fastest = trips.reduce((a, b) => a.durationMinutes < b.durationMinutes ? a : b);

    final gareWaitAdjusted = TrafficSimulator.adjustedMinutes(baseMinutes: 15, time: now, isRaining: isRaining);

    return [
      TripOption(
        kind: TripOptionKind.combined,
        title: 'Rejoindre la gare routière',
        subtitle: 'Gbaka ou wôrô-wôrô jusqu\'à la gare d\'Adjamé, avant le départ du bus',
        priceLow: 300,
        priceHigh: 600,
        durationMinutes: gareWaitAdjusted,
        legs: const [
          TripLeg(kind: TripOptionKind.gbaka, label: 'Gbaka ou wôrô-wôrô vers Adjamé'),
          TripLeg(kind: TripOptionKind.interurbain, label: 'Bus interurbain'),
        ],
      ),
      TripOption(
        kind: TripOptionKind.interurbain,
        title: '${trips.length} trajets disponibles',
        subtitle: 'Moins cher : ${cheapest.company.name} · Plus rapide : ${fastest.company.name}',
        priceLow: cheapest.price,
        priceHigh: trips.map((t) => t.price).reduce(max),
        durationMinutes: fastest.durationMinutes,
      ),
    ];
  }

  double _estimateUrbanDistance(TripPlace destination) {
    // Approximation simplifiée pour le prototype : distance au centre selon
    // la commune, faute de géocodage réel.
    const reference = GeoPoint(5.3599, -4.0083);
    final location = destination.location;
    if (location == null) return 6000;
    final dx = (reference.latitude - location.latitude).abs();
    final dy = (reference.longitude - location.longitude).abs();
    return ((dx + dy) * 111000).clamp(800, 25000);
  }
}
