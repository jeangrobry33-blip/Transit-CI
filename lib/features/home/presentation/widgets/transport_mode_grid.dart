import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_sizes.dart';

class TransportModeItem {
  const TransportModeItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

/// Grille des modes de transport disponibles — point d'entrée central de l'app.
class TransportModeGrid extends StatelessWidget {
  const TransportModeGrid({super.key, required this.items});

  final List<TransportModeItem> items;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, i) {
        final item = items[i];
        final tile = InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const SizedBox(height: 6),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );

        if (reduceMotion) return tile;
        // Entrée échelonnée une seule fois à l'ouverture de l'accueil.
        return tile
            .animate(delay: Duration(milliseconds: 25 * i))
            .fadeIn(duration: 220.ms, curve: Curves.easeOut)
            .slideY(begin: 0.12, end: 0, duration: 220.ms, curve: Curves.easeOut);
      },
    );
  }
}
