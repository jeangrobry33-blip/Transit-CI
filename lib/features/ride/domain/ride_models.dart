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

class Driver {
  const Driver({
    required this.id,
    required this.name,
    required this.vehicleType,
    required this.vehicleModel,
    required this.plateNumber,
    required this.rating,
    required this.tripsCount,
    required this.etaMinutes,
    required this.photoInitials,
  });

  final String id;
  final String name;
  final VehicleType vehicleType;
  final String vehicleModel;
  final String plateNumber;
  final double rating;
  final int tripsCount;
  final int etaMinutes;
  final String photoInitials;
}

enum RideStatus { searching, accepted, arriving, ongoing, completed, cancelled }

class RideTrip {
  const RideTrip({
    required this.id,
    required this.pickup,
    required this.destination,
    required this.vehicleType,
    required this.driver,
    required this.estimatedFare,
    required this.distanceMeters,
    required this.durationMinutes,
    this.status = RideStatus.searching,
  });

  final String id;
  final PlaceSuggestion pickup;
  final PlaceSuggestion destination;
  final VehicleType vehicleType;
  final Driver driver;
  final double estimatedFare;
  final double distanceMeters;
  final int durationMinutes;
  final RideStatus status;

  RideTrip copyWith({RideStatus? status}) {
    return RideTrip(
      id: id,
      pickup: pickup,
      destination: destination,
      vehicleType: vehicleType,
      driver: driver,
      estimatedFare: estimatedFare,
      distanceMeters: distanceMeters,
      durationMinutes: durationMinutes,
      status: status ?? this.status,
    );
  }
}
