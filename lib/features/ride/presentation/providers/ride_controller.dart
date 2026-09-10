import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_ride_repository.dart';
import '../../domain/ride_models.dart';

final rideRepositoryProvider = Provider((ref) => MockRideRepository());

class RideBookingState {
  const RideBookingState({
    this.pickup,
    this.destination,
    this.vehicleType = VehicleType.vtcStandard,
    this.drivers = const [],
    this.loadingDrivers = false,
    this.trip,
  });

  final PlaceSuggestion? pickup;
  final PlaceSuggestion? destination;
  final VehicleType vehicleType;
  final List<Driver> drivers;
  final bool loadingDrivers;
  final RideTrip? trip;

  double get distanceMeters {
    if (pickup == null || destination == null) return 0;
    final dx = (pickup!.location.latitude - destination!.location.latitude).abs();
    final dy = (pickup!.location.longitude - destination!.location.longitude).abs();
    // Approximation simplifiée pour le prototype (1 degré ~ 111km).
    return ((dx + dy) * 111000).clamp(800, 45000);
  }

  int get durationMinutes => (distanceMeters / 300).round().clamp(4, 90);

  RideBookingState copyWith({
    PlaceSuggestion? pickup,
    PlaceSuggestion? destination,
    VehicleType? vehicleType,
    List<Driver>? drivers,
    bool? loadingDrivers,
    RideTrip? trip,
  }) {
    return RideBookingState(
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
      vehicleType: vehicleType ?? this.vehicleType,
      drivers: drivers ?? this.drivers,
      loadingDrivers: loadingDrivers ?? this.loadingDrivers,
      trip: trip ?? this.trip,
    );
  }
}

class RideBookingController extends Notifier<RideBookingState> {
  @override
  RideBookingState build() => const RideBookingState();

  MockRideRepository get _repository => ref.read(rideRepositoryProvider);

  void setPickup(PlaceSuggestion place) => state = state.copyWith(pickup: place);

  void setDestination(PlaceSuggestion place) => state = state.copyWith(destination: place);

  void setVehicleType(VehicleType type) => state = state.copyWith(vehicleType: type);

  double estimateFare(VehicleType type) => _repository.estimateFare(type, state.distanceMeters);

  Future<void> loadDrivers() async {
    state = state.copyWith(loadingDrivers: true);
    final drivers = await _repository.nearbyDrivers(state.vehicleType);
    state = state.copyWith(drivers: drivers, loadingDrivers: false);
  }

  void confirmDriver(Driver driver) {
    if (state.pickup == null || state.destination == null) return;
    final trip = RideTrip(
      id: 'ride_${DateTime.now().millisecondsSinceEpoch}',
      pickup: state.pickup!,
      destination: state.destination!,
      vehicleType: state.vehicleType,
      driver: driver,
      estimatedFare: estimateFare(state.vehicleType),
      distanceMeters: state.distanceMeters,
      durationMinutes: state.durationMinutes,
      status: RideStatus.accepted,
    );
    state = state.copyWith(trip: trip);
  }

  void updateTripStatus(RideStatus status) {
    if (state.trip == null) return;
    state = state.copyWith(trip: state.trip!.copyWith(status: status));
  }

  void cancelTrip() {
    state = const RideBookingState();
  }

  void reset() {
    state = const RideBookingState();
  }
}

final rideBookingProvider = NotifierProvider<RideBookingController, RideBookingState>(
  RideBookingController.new,
);

final placesSearchProvider = FutureProvider.family<List<PlaceSuggestion>, String>((ref, query) {
  return ref.read(rideRepositoryProvider).searchPlaces(query);
});

final favoritePlacesProvider = FutureProvider<List<PlaceSuggestion>>((ref) {
  return ref.read(rideRepositoryProvider).favorites();
});
