import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/weather_provider.dart';
import '../../data/mock_trip_repository.dart';
import '../../domain/trip_models.dart';

final tripRepositoryProvider = Provider((ref) => MockTripRepository());

final tripPlacesSearchProvider = FutureProvider.family<List<TripPlace>, String>((ref, query) {
  return ref.read(tripRepositoryProvider).search(query);
});

final tripOptionsProvider = FutureProvider.family<List<TripOption>, TripPlace>((ref, destination) {
  final isRaining = ref.watch(isRainingProvider);
  return ref.read(tripRepositoryProvider).optionsFor(destination, isRaining: isRaining);
});

class TripSortController extends Notifier<TripSortMode> {
  @override
  TripSortMode build() => TripSortMode.economique;

  void setMode(TripSortMode mode) => state = mode;
}

final tripSortProvider = NotifierProvider<TripSortController, TripSortMode>(TripSortController.new);

List<TripOption> sortTripOptions(List<TripOption> options, TripSortMode mode) {
  final sorted = [...options];
  sorted.sort((a, b) => switch (mode) {
        TripSortMode.economique => a.priceLow.compareTo(b.priceLow),
        TripSortMode.rapide => a.durationMinutes.compareTo(b.durationMinutes),
      });
  return sorted;
}
