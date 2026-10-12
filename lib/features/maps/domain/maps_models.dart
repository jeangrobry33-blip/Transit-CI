import 'package:flutter/material.dart';
import '../../trip/domain/trip_models.dart';

enum PoiCategory { fuel, pharmacy, mobileMoney }

extension PoiCategoryX on PoiCategory {
  String get label => switch (this) {
        PoiCategory.fuel => 'Station-service',
        PoiCategory.pharmacy => 'Pharmacie',
        PoiCategory.mobileMoney => 'Point Mobile Money',
      };

  IconData get icon => switch (this) {
        PoiCategory.fuel => Icons.local_gas_station_rounded,
        PoiCategory.pharmacy => Icons.local_pharmacy_rounded,
        PoiCategory.mobileMoney => Icons.payments_rounded,
      };

  Color get color => switch (this) {
        PoiCategory.fuel => Colors.orange,
        PoiCategory.pharmacy => Colors.redAccent,
        PoiCategory.mobileMoney => Colors.teal,
      };
}

class PointOfInterest {
  const PointOfInterest({required this.name, required this.category, required this.distanceMeters});

  final String name;
  final PoiCategory category;
  final double distanceMeters;
}

/// Résumé d'un itinéraire affiché sur la carte — l'option directe et une
/// alternative combinée (plusieurs moyens de transport), avec les points
/// d'intérêt rencontrés en chemin.
class MapRoute {
  const MapRoute({
    required this.destination,
    required this.direct,
    required this.combined,
    required this.pointsOfInterest,
  });

  final TripPlace destination;
  final TripOption? direct;
  final TripOption? combined;
  final List<PointOfInterest> pointsOfInterest;
}
