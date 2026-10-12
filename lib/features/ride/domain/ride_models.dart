import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Types de véhicules à la demande proposés par Transit CI.
enum VehicleType { vtcStandard, vtcConfort, taxiCompteur, motoTaxi }

extension VehicleTypeX on VehicleType {
  String get label => switch (this) {
        VehicleType.vtcStandard => 'VTC Standard',
        VehicleType.vtcConfort => 'VTC Confort',
        VehicleType.taxiCompteur => 'Taxi compteur',
        VehicleType.motoTaxi => 'Moto-taxi',
      };

  String get description => switch (this) {
        VehicleType.vtcStandard => 'Rapide et économique',
        VehicleType.vtcConfort => 'Véhicules récents et climatisés',
        VehicleType.taxiCompteur => 'Taxi officiel au compteur',
        VehicleType.motoTaxi => 'Idéal pour les embouteillages',
      };

  IconData get icon => switch (this) {
        VehicleType.vtcStandard => Icons.directions_car_rounded,
        VehicleType.vtcConfort => Icons.airline_seat_recline_extra_rounded,
        VehicleType.taxiCompteur => Icons.local_taxi_rounded,
        VehicleType.motoTaxi => Icons.two_wheeler_rounded,
      };

  Color get color => switch (this) {
        VehicleType.vtcStandard => AppColors.modeVtc,
        VehicleType.vtcConfort => AppColors.modeVtc,
        VehicleType.taxiCompteur => AppColors.modeTaxi,
        VehicleType.motoTaxi => AppColors.modeMoto,
      };

  double get baseFare => switch (this) {
        VehicleType.vtcStandard => 1000,
        VehicleType.vtcConfort => 1800,
        VehicleType.taxiCompteur => 800,
        VehicleType.motoTaxi => 500,
      };

  double get perKm => switch (this) {
        VehicleType.vtcStandard => 350,
        VehicleType.vtcConfort => 500,
        VehicleType.taxiCompteur => 300,
        VehicleType.motoTaxi => 200,
      };
}

class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

class PlaceSuggestion {
  const PlaceSuggestion({
    required this.name,
    required this.address,
    required this.location,
    this.isFavorite = false,
  });

  final String name;
  final String address;
  final GeoPoint location;
  final bool isFavorite;
}

/// Estimation de prix pour un mode de transport à la demande — Transit CI
/// n'organise pas la course elle-même (ce n'est pas un service de VTC comme
/// Yango), elle aide seulement à comparer les options avant de réserver
/// ailleurs ou de héler un taxi/moto sur place.
class FareEstimate {
  const FareEstimate({
    required this.vehicleType,
    required this.pickup,
    required this.destination,
    required this.lowFare,
    required this.highFare,
    required this.distanceMeters,
    required this.durationMinutes,
  });

  final VehicleType vehicleType;
  final PlaceSuggestion pickup;
  final PlaceSuggestion destination;
  final double lowFare;
  final double highFare;
  final double distanceMeters;
  final int durationMinutes;
}
