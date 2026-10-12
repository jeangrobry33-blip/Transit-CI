import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../ride/domain/ride_models.dart';

/// Portée d'un lieu recherché — détermine quels moyens de transport
/// s'affichent : déplacement dans Abidjan ou trajet vers l'intérieur du pays.
enum PlaceScope { urbanAbidjan, interiorCity }

/// Lieu unifié (commune d'Abidjan ou ville de l'intérieur) utilisé par la
/// recherche "Où allez-vous ?" pour choisir les moyens de transport adaptés
/// à la distance du trajet.
class TripPlace {
  const TripPlace({
    required this.name,
    required this.description,
    required this.scope,
    this.location,
    this.landmark,
  });

  final String name;
  final String description;
  final PlaceScope scope;
  final GeoPoint? location;
  /// Repère local facultatif ("en face de la pharmacie, après le pont") —
  /// les adresses formelles sont rares en Côte d'Ivoire, Transit CI permet
  /// de décrire un lieu plutôt que de le localiser précisément.
  final String? landmark;

  TripPlace withLandmark(String? value) => TripPlace(
        name: name,
        description: description,
        scope: scope,
        location: location,
        landmark: value,
      );
}

/// Un moyen de transport possible pour rejoindre une destination.
enum TripOptionKind { gbaka, woroworo, busUrbain, taxiCompteur, vtc, motoTaxi, interurbain, combined }

extension TripOptionKindX on TripOptionKind {
  String get label => switch (this) {
        TripOptionKind.gbaka => 'Gbaka',
        TripOptionKind.woroworo => 'Wôrô-wôrô',
        TripOptionKind.busUrbain => 'Bus urbain',
        TripOptionKind.taxiCompteur => 'Taxi compteur',
        TripOptionKind.vtc => 'VTC',
        TripOptionKind.motoTaxi => 'Moto-taxi',
        TripOptionKind.interurbain => 'Bus interurbain',
        TripOptionKind.combined => 'Trajet combiné',
      };

  IconData get icon => switch (this) {
        TripOptionKind.gbaka => Icons.airport_shuttle_rounded,
        TripOptionKind.woroworo => Icons.local_taxi_rounded,
        TripOptionKind.busUrbain => Icons.directions_bus_rounded,
        TripOptionKind.taxiCompteur => Icons.local_taxi_rounded,
        TripOptionKind.vtc => Icons.directions_car_rounded,
        TripOptionKind.motoTaxi => Icons.two_wheeler_rounded,
        TripOptionKind.interurbain => Icons.directions_bus_filled_rounded,
        TripOptionKind.combined => Icons.alt_route_rounded,
      };

  Color get color => switch (this) {
        TripOptionKind.gbaka => AppColors.modeGbaka,
        TripOptionKind.woroworo => AppColors.modeWoroworo,
        TripOptionKind.busUrbain => AppColors.modeBusUrbain,
        TripOptionKind.taxiCompteur => AppColors.modeTaxi,
        TripOptionKind.vtc => AppColors.modeVtc,
        TripOptionKind.motoTaxi => AppColors.modeMoto,
        TripOptionKind.interurbain => AppColors.modeInterurbain,
        TripOptionKind.combined => AppColors.slate,
      };
}

/// Une étape d'un trajet combiné (ex. "Gbaka jusqu'à la gare", puis "Bus UTB").
class TripLeg {
  const TripLeg({required this.kind, required this.label, this.referenceId});

  final TripOptionKind kind;
  final String label;
  /// Identifiant de la ligne/compagnie associée, pour pousser vers son écran.
  final String? referenceId;
}

/// Une option de trajet proposée pour rejoindre une destination, avec prix
/// et durée estimés — éventuellement composée de plusieurs étapes.
class TripOption {
  const TripOption({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.priceLow,
    required this.priceHigh,
    required this.durationMinutes,
    this.legs = const [],
    this.referenceId,
    this.isEstimateOnly = false,
  });

  final TripOptionKind kind;
  final String title;
  final String subtitle;
  final double priceLow;
  final double priceHigh;
  final int durationMinutes;
  final List<TripLeg> legs;
  final String? referenceId;
  /// `true` pour VTC/taxi/moto : prix indicatif, pas de réservation Transit CI.
  final bool isEstimateOnly;
}

enum TripSortMode { economique, rapide }
