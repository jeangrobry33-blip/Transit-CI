import 'dart:math';
import '../../gbaka/data/mock_gbaka_repository.dart';
import '../../gbaka/domain/transit_line.dart';
import '../../interurban/data/interurban_repository.dart';
import '../../ride/data/mock_ride_repository.dart';
import '../../ride/domain/ride_models.dart';
import '../../../core/data/supabase_service.dart';
import '../../../core/services/traffic_simulator.dart';
import '../domain/trip_models.dart';

/// Lieux réels (communes d'Abidjan + villes de l'intérieur, base Supabase)
/// combinés aux options de trajet par mode. Les noms de communes
/// correspondent à ceux utilisés par [MockGbakaRepository] pour que les
/// lignes se rattachent directement à un lieu recherché.
class TripRepository {
  TripRepository(this._supabase, this._interurbanRepository);

  final SupabaseService _supabase;
  final InterurbanRepository _interurbanRepository;
  final _gbakaRepository = MockGbakaRepository();
  final _rideRepository = MockRideRepository();

  TripPlace _parsePlace(Map<String, dynamic> row) {
    final lat = row['latitude'] as num?;
    final lng = row['longitude'] as num?;
    return TripPlace(
      name: row['name'] as String,
      description: (row['description'] as String?) ?? '',
      scope: row['scope'] == 'urban_abidjan' ? PlaceScope.urbanAbidjan : PlaceScope.interiorCity,
      location: lat != null && lng != null ? GeoPoint(lat.toDouble(), lng.toDouble()) : null,
    );
  }

  Future<List<TripPlace>> search(String query) async {
    final rows = await _supabase.fetchTripPlaces();
    final places = rows.map(_parsePlace).toList();
    if (query.isEmpty) return places;
    final q = query.toLowerCase();
    return places.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  /// Construit les options de trajet adaptées à la distance : moyens urbains
  /// pour une commune d'Abidjan, compagnies interurbaines pour une ville de
  /// l'intérieur (avec un rappel du trajet pour rejoindre la gare routière).
  Future<List<TripOption>> optionsFor(
    TripPlace destination, {
    bool isRaining = false,
  }) async {
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
