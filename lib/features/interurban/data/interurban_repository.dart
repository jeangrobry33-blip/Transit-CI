import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/data/supabase_service.dart';
import '../domain/interurban_models.dart';

/// Compagnies et villes réelles (base Supabase), trajets/sièges simulés —
/// aucune donnée d'horaires/places réelle n'existe publiquement pour
/// l'instant (voir docs/BACKEND_ARCHITECTURE.md §7bis et le rapport de
/// recherche sur le transport ivoirien).
class InterurbanRepository {
  InterurbanRepository(this._supabase);

  final SupabaseService _supabase;

  static const _colorPalette = [
    AppColors.orange,
    AppColors.ivoryGreen,
    AppColors.info,
    AppColors.modeVtc,
    AppColors.modeMoto,
    AppColors.modeWoroworo,
    AppColors.slate,
    AppColors.modeInterurbain,
  ];

  Color _colorFor(String id) => _colorPalette[id.hashCode.abs() % _colorPalette.length];

  BusCompany _parseCompany(Map<String, dynamic> row) {
    final name = row['name'] as String;
    return BusCompany(
      id: row['id'] as String,
      name: name,
      fullName: (row['full_name'] as String?) ?? name,
      color: _colorFor(row['id'] as String),
      citiesServed: List<String>.from(row['cities_served'] as List? ?? const []),
      rating: (row['rating'] as num?)?.toDouble(),
      verificationStatus: (row['verification_status'] as String?) ?? 'unverified',
      sourceUrl: row['source_url'] as String?,
    );
  }

  Future<List<BusCompany>> getCompanies() async {
    final rows = await _supabase.fetchCompanies();
    return rows
        .where((r) => r['type'] != 'informal')
        .map(_parseCompany)
        .toList();
  }

  /// Villes sélectionnables pour la recherche interurbaine : Abidjan (hub
  /// de départ) + toutes les villes de l'intérieur réellement recensées.
  Future<List<String>> interiorCityNames() async {
    final places = await _supabase.fetchTripPlaces();
    final cities = places
        .where((p) => p['scope'] == 'interior_city')
        .map((p) => p['name'] as String)
        .toList()
      ..sort();
    return ['Abidjan', ...cities];
  }

  Future<List<BusTrip>> searchTrips({
    required String origin,
    required String destination,
    DateTime? date,
  }) async {
    final companies = await getCompanies();
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

