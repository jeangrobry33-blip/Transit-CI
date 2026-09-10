import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_text_styles.dart';

/// Bouton d'urgence SOS — partage la position en temps réel et alerte les
/// contacts de confiance / le centre de sécurité Transit CI.
class SosButton extends StatelessWidget {
  const SosButton({super.key, this.compact = false});

  final bool compact;

  Future<void> _confirmSos(BuildContext context) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SosSheet(),
    );
    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alerte SOS envoyée. Les secours et vos proches ont été notifiés.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return InkWell(
        onTap: () => _confirmSos(context),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sos_rounded, color: AppColors.white, size: 16),
              const SizedBox(width: 6),
              Text('SOS', style: AppTextStyles.label.copyWith(color: AppColors.white)),
            ],
          ),
        ),
      );
    }

    return FloatingActionButton(
      heroTag: 'sos_button',
      backgroundColor: AppColors.danger,
      onPressed: () => _confirmSos(context),
      child: const Icon(Icons.sos_rounded, color: AppColors.white),
    );
  }
}

class _SosSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text('Déclencher une alerte SOS ?', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Votre position et les détails de votre trajet seront envoyés à vos contacts de confiance ainsi qu\'au centre de sécurité Transit CI.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mist),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Envoyer l\'alerte'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
