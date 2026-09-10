import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Petite étiquette colorée pour indiquer un statut (affluence, disponibilité...).
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Indicateur de niveau d'affluence pour les gbakas / wôrô-wôrô.
enum AffluenceLevel { low, medium, high }

extension AffluenceLevelX on AffluenceLevel {
  Color get color => switch (this) {
        AffluenceLevel.low => AppColors.affluenceLow,
        AffluenceLevel.medium => AppColors.affluenceMedium,
        AffluenceLevel.high => AppColors.affluenceHigh,
      };

  String get label => switch (this) {
        AffluenceLevel.low => 'Fluide',
        AffluenceLevel.medium => 'Modérée',
        AffluenceLevel.high => 'Forte affluence',
      };
}
