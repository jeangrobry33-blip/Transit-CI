import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/status_badge.dart';

/// Modes de transport en commun de type "ligne fixe".
enum LineMode { gbaka, woroworo, busUrbain }

extension LineModeX on LineMode {
  String get label => switch (this) {
        LineMode.gbaka => 'Gbaka',
        LineMode.woroworo => 'Wôrô-wôrô',
        LineMode.busUrbain => 'Bus urbain (SOTRA)',
      };

  Color get color => switch (this) {
        LineMode.gbaka => AppColors.modeGbaka,
        LineMode.woroworo => AppColors.modeWoroworo,
        LineMode.busUrbain => AppColors.modeBusUrbain,
      };

  IconData get icon => switch (this) {
        LineMode.gbaka => Icons.airport_shuttle_rounded,
        LineMode.woroworo => Icons.local_taxi_rounded,
        LineMode.busUrbain => Icons.directions_bus_rounded,
      };
}

class TransitLine {
  const TransitLine({
    required this.id,
    required this.code,
    required this.mode,
    required this.origin,
    required this.destination,
    required this.stops,
    required this.waitMinutes,
    required this.averagePrice,
    required this.affluence,
    this.gpsTracked = true,
  });

  final String id;
  final String code;
  final LineMode mode;
  final String origin;
  final String destination;
  final List<String> stops;
  final int waitMinutes;
  final double averagePrice;
  final AffluenceLevel affluence;
  final bool gpsTracked;

  String get routeLabel => '$origin → $destination';
}
