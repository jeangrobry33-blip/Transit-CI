import '../../../core/constants/app_colors.dart';
import '../domain/interurban_models.dart';

/// Données simulées des compagnies et trajets interurbains ivoiriens.
/// À remplacer par une intégration API par compagnie (UTB, SBTA, TSR, AVS...).
class MockInterurbanRepository {
  static const ivorianCities = [
    'Abidjan',
    'Bouaké',
    'Yamoussoukro',
    'San-Pédro',
    'Korhogo',
    'Man',
    'Daloa',
    'Gagnoa',
    'Abengourou',
    'Divo',
  ];

  static final companies = [
    BusCompany(
      id: 'utb',
      name: 'UTB',
      fullName: 'Union des Transports de Bouaké',
      color: AppColors.orange,
      rating: 4.5,
      citiesServed: ['Abidjan', 'Bouaké', 'Korhogo', 'Man'],
    ),
    BusCompany(
      id: 'sbta',
      name: 'SBTA',
      fullName: 'Société de Bus Transport Abidjan',
      color: AppColors.ivoryGreen,
      rating: 4.3,
      citiesServed: ['Abidjan', 'Yamoussoukro', 'Daloa', 'Gagnoa'],
    ),
    BusCompany(
      id: 'tsr',
      name: 'TSR',
      fullName: 'Transport Sonon Rapide',
      color: AppColors.info,
      rating: 4.1,
      citiesServed: ['Abidjan', 'San-Pédro', 'Divo'],
    ),
    BusCompany(
      id: 'avs',
      name: 'AVS',
      fullName: 'Alliance Voyage Sécurisé',
      color: AppColors.modeVtc,
      rating: 4.6,
      citiesServed: ['Abidjan', 'Abengourou', 'Bouaké'],
    ),
    BusCompany(
      id: 'utraco',
      name: 'UTRACO',
      fullName: 'Union des Transporteurs de Côte d\'Ivoire',
      color: AppColors.modeMoto,
      rating: 4.0,
      citiesServed: ['Abidjan', 'Man', 'Daloa'],
    ),
  ];

  Future<List<BusCompany>> getCompanies() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return companies;
  }

  Future<List<BusTrip>> searchTrips({
    required String origin,
    required String destination,
    DateTime? date,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final day = date ?? DateTime.now();
    final eligible = companies
        .where((c) => c.citiesServed.contains(origin) && c.citiesServed.contains(destination))
        .toList();
    if (eligible.isEmpty) return [];

    final hours = [6, 8, 10, 13, 15, 18, 21];
    return List.generate(eligible.length * 2, (i) {
      final company = eligible[i % eligible.length];
      final hour = hours[i % hours.length];
      return BusTrip(
        id: 'trip_${company.id}_$i',
        company: company,
        originCity: origin,
        destinationCity: destination,
        departure: DateTime(day.year, day.month, day.day, hour, i.isEven ? 0 : 30),
        durationMinutes: 210 + (i % 3) * 30,
        price: [4500, 6000, 7500, 9000][i % 4].toDouble(),
        comfort: ComfortLevel.values[i % ComfortLevel.values.length],
        hasAc: i.isEven,
        totalSeats: 42,
        availableSeats: 42 - (i * 5 % 30),
      );
    });
  }

  Future<List<BusSeat>> seatMap(BusTrip trip) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final takenCount = trip.totalSeats - trip.availableSeats;
    return List.generate(trip.totalSeats, (i) {
      final number = i + 1;
      return BusSeat(number: number, taken: number <= takenCount);
    });
  }
}
