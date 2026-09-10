import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_interurban_repository.dart';
import '../../domain/interurban_models.dart';

final interurbanRepositoryProvider = Provider((ref) => MockInterurbanRepository());

final companiesProvider = FutureProvider((ref) => ref.read(interurbanRepositoryProvider).getCompanies());

class TripSearchParams {
  const TripSearchParams({required this.origin, required this.destination, this.date});
  final String origin;
  final String destination;
  final DateTime? date;
}

final tripSearchProvider = FutureProvider.family<List<BusTrip>, TripSearchParams>((ref, params) {
  return ref.read(interurbanRepositoryProvider).searchTrips(
        origin: params.origin,
        destination: params.destination,
        date: params.date,
      );
});

final seatMapProvider = FutureProvider.family<List<BusSeat>, BusTrip>((ref, trip) {
  return ref.read(interurbanRepositoryProvider).seatMap(trip);
});

class InterurbanBookingState {
  const InterurbanBookingState({
    this.selectedTrip,
    this.selectedSeats = const {},
    this.booking,
  });

  final BusTrip? selectedTrip;
  final Set<int> selectedSeats;
  final TripBooking? booking;

  double get totalPrice => (selectedTrip?.price ?? 0) * selectedSeats.length;

  InterurbanBookingState copyWith({
    BusTrip? selectedTrip,
    Set<int>? selectedSeats,
    TripBooking? booking,
  }) {
    return InterurbanBookingState(
      selectedTrip: selectedTrip ?? this.selectedTrip,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      booking: booking ?? this.booking,
    );
  }
}

class InterurbanBookingController extends Notifier<InterurbanBookingState> {
  @override
  InterurbanBookingState build() => const InterurbanBookingState();

  void selectTrip(BusTrip trip) {
    state = InterurbanBookingState(selectedTrip: trip);
  }

  void toggleSeat(int number) {
    final seats = Set<int>.from(state.selectedSeats);
    if (seats.contains(number)) {
      seats.remove(number);
    } else if (seats.length < 6) {
      seats.add(number);
    }
    state = state.copyWith(selectedSeats: seats);
  }

  void confirmBooking(String passengerName) {
    if (state.selectedTrip == null || state.selectedSeats.isEmpty) return;
    final booking = TripBooking(
      id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
      trip: state.selectedTrip!,
      passengerName: passengerName,
      seatNumbers: state.selectedSeats.toList()..sort(),
      totalPrice: state.totalPrice,
      bookedAt: DateTime.now(),
    );
    state = state.copyWith(booking: booking);
  }

  void reset() {
    state = const InterurbanBookingState();
  }
}

final interurbanBookingProvider =
    NotifierProvider<InterurbanBookingController, InterurbanBookingState>(
  InterurbanBookingController.new,
);
