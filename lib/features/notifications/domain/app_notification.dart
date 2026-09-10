import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum NotificationCategory { departure, arrival, promotion, traffic, system, reminder }

extension NotificationCategoryX on NotificationCategory {
  IconData get icon => switch (this) {
        NotificationCategory.departure => Icons.flight_takeoff_rounded,
        NotificationCategory.arrival => Icons.flight_land_rounded,
        NotificationCategory.promotion => Icons.local_offer_rounded,
        NotificationCategory.traffic => Icons.traffic_rounded,
        NotificationCategory.system => Icons.info_rounded,
        NotificationCategory.reminder => Icons.alarm_rounded,
      };

  Color get color => switch (this) {
        NotificationCategory.departure => AppColors.info,
        NotificationCategory.arrival => AppColors.success,
        NotificationCategory.promotion => AppColors.orange,
        NotificationCategory.traffic => AppColors.warning,
        NotificationCategory.system => AppColors.mist,
        NotificationCategory.reminder => AppColors.modeVtc,
      };
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.category,
    required this.title,
    required this.message,
    required this.date,
    this.read = false,
  });

  final String id;
  final NotificationCategory category;
  final String title;
  final String message;
  final DateTime date;
  final bool read;
}
