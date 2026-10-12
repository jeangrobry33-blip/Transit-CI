import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// Politique de confidentialité — contenu réel décrivant ce que l'app
/// collecte effectivement (voir les champs de `auth`/`profile`/`maps`/
/// `sos_button`), pas un texte générique. Rédigée par l'équipe produit,
/// pas par un juriste : à faire relire avant mise en production, en
/// particulier au regard de la loi ivoirienne n°2013-450 et de l'ARTCI
/// (voir docs/QA_AUDIT.md, point 31).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Politique de confidentialité')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          _Notice(),
          SizedBox(height: AppSpacing.lg),
          _Section(
            title: 'Qui sommes-nous ?',
            body:
                'Transit CI est une application de comparaison de moyens de '
                'transport en Côte d\'Ivoire (gbaka, wôrô-wôrô, taxi compteur, '
                'VTC, moto-taxi, bus urbain, compagnies interurbaines). '
                'Transit CI ne réserve aucun chauffeur et n\'organise aucune '
                'course : les options VTC, taxi et moto-taxi affichées '
                'sont des estimations de prix, pas des réservations.',
          ),
          _Section(
            title: 'Quelles données personnelles collectons-nous ?',
            body:
                '• Compte : nom, numéro de téléphone, adresse e-mail et '
                'mot de passe (stocké de façon chiffrée, jamais en clair) '
                'lors de l\'inscription.\n'
                '• Localisation : votre position GPS, uniquement quand '
                'vous l\'autorisez, pour chercher un trajet depuis votre '
                'position ou pour la partager avec vos contacts de confiance '
                'si vous déclenchez le bouton SOS.\n'
                '• Trajets recherchés : ville de départ et d\'arrivée, '
                'pour vous proposer des options et les retrouver dans votre '
                'historique.\n'
                '• Nous ne collectons pas vos données de carte bancaire ou '
                'Mobile Money : les paiements, quand ils existent, sont '
                'traités par l\'opérateur (Orange Money, MTN MoMo, Wave) ou '
                'la compagnie de transport, pas par Transit CI.',
          ),
          _Section(
            title: 'Pourquoi ?',
            body:
                'Ces données servent uniquement à faire fonctionner l\'app : '
                'créer votre compte, afficher des options de trajet '
                'pertinentes, retrouver votre historique, et vous localiser '
                'en cas d\'urgence si vous l\'avez explicitement demandé. '
                'Elles ne sont jamais vendues à un tiers.',
          ),
          _Section(
            title: 'Où sont-elles stockées ?',
            body:
                'Les comptes et préférences sont stockés sur Supabase '
                '(base de données hébergée). Les informations sur les '
                'compagnies de transport, gares et villes desservies sont '
                'des données publiques issues de recherches documentées '
                '(voir le rapport de recherche transport), pas des données '
                'personnelles.',
          ),
          _Section(
            title: 'Combien de temps les conservons-nous ?',
            body:
                'Vos données de compte sont conservées tant que votre compte '
                'existe. Vous pouvez demander leur suppression à tout '
                'moment (voir "Vos droits" ci-dessous) : elles sont alors '
                'effacées sous un délai raisonnable, sauf obligation légale '
                'de conservation contraire.',
          ),
          _Section(
            title: 'Vos droits',
            body:
                'Vous pouvez à tout moment demander à consulter, corriger ou '
                'supprimer vos données, ou retirer votre consentement au '
                'partage de position. Pour cela, contactez-nous à l\'adresse '
                'indiquée ci-dessous.',
          ),
          _Section(
            title: 'Contact',
            body: 'confidentialite@transit-ci.app',
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Document de référence produit, pas un avis juridique. '
              'Dernière mise à jour : octobre 2026.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.info),
            ),
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
