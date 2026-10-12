import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/traffic_simulator.dart';
import '../../data/mock_ride_repository.dart';
import '../../domain/ride_models.dart';

final rideRepositoryProvider = Provider((ref) => MockRideRepository());

class RideEstimateState {
  const RideEstimateState({
    this.pickup,
    this.destination,
    this.vehicleType = VehicleType.vtcStandard,
  });

  final PlaceSuggestion? pickup;
  final PlaceSuggestion? destination;
  final VehicleType vehicleType;

  double get distanceMeters {
    if (pickup == null || destination == null) return 0;
    final dx = (pickup!.location.latitude - destination!.location.latitude).abs();
    final dy = (pickup!.location.longitude - destination!.location.longitude).abs();
    // Approximation simplifiée pour le prototype (1 degré ~ 111km).
    return ((dx + dy) * 111000).clamp(800, 45000);
  }

  int baseDurationMinutes() => (distanceMeters / 300).round().clamp(4, 90);

  /// Durée ajustée selon l'heure actuelle et la météo simulée (pluie).
  int durationMinutes({required bool isRaining}) => TrafficSimulator.adjustedMinutes(
        baseMinutes: baseDurationMinutes(),
        time: DateTime.now(),
        isRaining: isRaining,
      );

  RideEstimateState copyWith({
    PlaceSuggestion? pickup,
    PlaceSuggestion? destination,
    VehicleType? vehicleType,
  }) {
    return RideEstimateState(
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
      vehicleType: vehicleType ?? this.vehicleType,
    );
  }
}

class RideEstimateController extends Notifier<RideEstimateState> {
  @override
  RideEstimateState build() => const RideEstimateState();

  MockRideRepository get _repository => ref.read(rideRepositoryProvider);

  void setPickup(PlaceSuggestion place) => state = state.copyWith(pickup: place);

  void setDestination(PlaceSuggestion place) => state = state.copyWith(destination: place);

  void setVehicleType(VehicleType type) => state = state.copyWith(vehicleType: type);

  (double low, double high) fareRange(VehicleType type) =>
      _repository.estimateFareRange(type, state.distanceMeters);

  void reset() => state = const RideEstimateState();
}

final rideEstimateProvider = NotifierProvider<RideEstimateController, RideEstimateState>(
  RideEstimateController.new,
);

final placesSearchProvider = FutureProvider.family<List<PlaceSuggestion>, String>((ref, query) {
  return ref.read(rideRepositoryProvider).searchPlaces(query);
});

final favoritePlacesProvider = FutureProvider<List<PlaceSuggestion>>((ref) {
  return ref.read(rideRepositoryProvider).favorites();
});
