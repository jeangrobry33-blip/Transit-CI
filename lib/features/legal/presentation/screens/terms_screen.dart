import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';

/// Conditions d'utilisation / mentions légales — même logique que
/// [PrivacyPolicyScreen] : contenu réel décrivant ce que l'app fait et ne
/// fait pas, à faire relire par un juriste avant mise en production.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conditions d’utilisation')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          _Section(
            title: 'Ce que Transit CI est',
            body:
                'Une application d\'information et de comparaison de moyens '
                'de transport en Côte d\'Ivoire. Elle affiche des options '
                '(gbaka, wôrô-wôrô, taxi compteur, VTC, moto-taxi, bus '
                'urbain, compagnies interurbaines), leurs prix estimés et '
                'leurs durées estimées.',
          ),
          _Section(
            title: 'Ce que Transit CI n’est pas',
            body:
                'Transit CI n’est pas un service de réservation de '
                'chauffeur : elle ne dispatche aucune course, n’assigne '
                'aucun conducteur et ne garantit aucune disponibilité. Les '
                'prix VTC, taxi compteur et moto-taxi affichés sont des '
                'estimations indicatives, pas des tarifs contractuels. Pour '
                'les trajets interurbains, la réservation de siège et le '
                'paiement se font avec la compagnie de transport '
                'concernée : Transit CI transmet l’information, elle '
                'n’est pas transporteur.',
          ),
          _Section(
            title: 'Fiabilité des données affichées',
            body:
                'Les informations sur les compagnies, gares et villes '
                'desservies proviennent de recherches documentées (presse, '
                'annuaires professionnels, données publiques) et portent '
                'chacune un niveau de confiance indiqué dans l’app '
                '("Vérifié" ou "À vérifier"). Transit CI ne garantit pas '
                'l’exactitude ou l’actualité de ces informations et '
                'vous recommande de confirmer un tarif ou un horaire '
                'directement auprès de la compagnie avant de vous déplacer.',
          ),
          _Section(
            title: 'Compte utilisateur',
            body:
                'Vous êtes responsable de la confidentialité de votre mot de '
                'passe. Vous pouvez supprimer votre compte à tout moment '
                'depuis les paramètres ou en nous contactant.',
          ),
          _Section(
            title: 'Numéros d’urgence',
            body:
                'Le bouton SOS compose les numéros d’urgence réels de '
                'Côte d’Ivoire (police : 111, pompiers : 180, '
                'SAMU : 185). Transit CI n’est pas un service '
                'd’urgence et n’intervient pas lui-même.',
          ),
          _Section(
            title: 'Mentions légales',
            body:
                'Transit CI est un projet en développement. La structure '
                'juridique exploitant le service, son siège social et son '
                'numéro d’immatriculation seront complétés ici avant la '
                'mise en production (voir docs/QA_AUDIT.md).',
          ),
          _Section(
            title: 'Contact',
            body: 'contact@transit-ci.app',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
