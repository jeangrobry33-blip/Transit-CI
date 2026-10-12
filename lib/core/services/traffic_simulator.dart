import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Niveau de trafic routier simulé (dépend de l'heure et de la météo).
enum TrafficCondition { fluid, moderate, dense }

extension TrafficConditionX on TrafficCondition {
  String get label => switch (this) {
        TrafficCondition.fluid => 'Trafic fluide',
        TrafficCondition.moderate => 'Trafic modéré',
        TrafficCondition.dense => 'Trafic dense',
      };

  Color get color => switch (this) {
        TrafficCondition.fluid => AppColors.success,
        TrafficCondition.moderate => AppColors.warning,
        TrafficCondition.dense => AppColors.danger,
      };

  IconData get icon => switch (this) {
        TrafficCondition.fluid => Icons.trending_flat_rounded,
        TrafficCondition.moderate => Icons.traffic_rounded,
        TrafficCondition.dense => Icons.warning_amber_rounded,
      };

  /// Multiplicateur appliqué aux durées de trajet estimées.
  double get durationMultiplier => switch (this) {
        TrafficCondition.fluid => 1.0,
        TrafficCondition.moderate => 1.25,
        TrafficCondition.dense => 1.6,
      };
}

/// Simule les conditions de circulation à Abidjan selon l'heure (heures de
/// pointe 7h-9h et 17h-19h) et la météo (pluie = routes plus difficiles).
/// À remplacer par un vrai fournisseur de données trafic (ex. Google Roads API).
class TrafficSimulator {
  TrafficSimulator._();

  static bool isRushHour(DateTime time) {
    final hour = time.hour;
    return (hour >= 7 && hour < 9) || (hour >= 17 && hour < 19);
  }

  static TrafficCondition condition({required DateTime time, bool isRaining = false}) {
    final rushHour = isRushHour(time);
    if (rushHour && isRaining) return TrafficCondition.dense;
    if (rushHour) return TrafficCondition.dense;
    if (isRaining) return TrafficCondition.moderate;
    return TrafficCondition.fluid;
  }

  static int adjustedMinutes({
    required int baseMinutes,
    required DateTime time,
    bool isRaining = false,
  }) {
    final c = condition(time: time, isRaining: isRaining);
    return (baseMinutes * c.durationMultiplier).round();
  }
}
