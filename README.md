# Transit CI 🇨🇮

Application mobile Flutter qui centralise tous les moyens de transport de
Côte d'Ivoire dans une seule plateforme : gbakas, wôrô-wôrô, taxis compteurs,
bus urbains, VTC, motos-taxis et voyages interurbains (UTB, SBTA, TSR, AVS...).

Ce dépôt contient un **prototype fonctionnel** complet côté client (UI, flux
de réservation, paiement, navigation) construit en Clean Architecture,
prêt à être connecté à un vrai backend (voir
[`docs/BACKEND_ARCHITECTURE.md`](docs/BACKEND_ARCHITECTURE.md)).

## Fonctionnalités du prototype

- **Onboarding & authentification** : inscription, connexion, mot de passe
  oublié, vérification OTP par SMS, connexion Google/Facebook/Apple (UI +
  logique simulée), un seul type de compte utilisateur.
- **Accueil & carte** : géolocalisation, sélection du mode de transport,
  promotions, trajets récents, bouton SOS.
- **VTC / taxi / moto-taxi** : recherche de destination, estimation du prix
  et du temps, sélection du chauffeur, suivi en direct, chat/appel (UI),
  partage de trajet, annulation, notation.
- **Gbaka / wôrô-wôrô / bus urbain** : lignes, itinéraires, points de
  chargement, temps d'attente, prix moyen, niveau d'affluence, suivi GPS.
- **Voyages interurbains** : recherche par ville, comparatif des compagnies
  (UTB, SBTA, TSR, AVS, UTRACO), sélection de sièges, paiement, billet avec
  QR code, historique.
- **Paiements** : Orange Money, MTN Money, Moov Money, carte bancaire,
  portefeuille interne, historique des transactions, coupons, cashback.
- **Notifications, historique, favoris, profil, paramètres** (mode sombre
  inclus), **panneau administrateur** (utilisateurs, chauffeurs, compagnies,
  paiements, statistiques).

## Architecture

```
lib/
  core/                    Design system, thème, routing, widgets partagés, utils
  features/
    auth/                  domain / data / presentation (Clean Architecture)
    onboarding/, splash/
    home/, shell/          tableau de bord + navigation à onglets
    ride/                  VTC, taxi compteur, moto-taxi
    gbaka/                 gbaka, wôrô-wôrô, bus urbain
    interurban/            compagnies, recherche, sièges, billet QR
    payment/, wallet/
    notifications/, history/, favorites/, profile/, settings/
    admin/                 panneau administrateur
```

Chaque feature suit `domain` (entités), `data` (dépôts — actuellement
simulés avec `Mock*Repository`) et `presentation` (Riverpod + écrans/widgets).
Remplacer un dépôt mock par un vrai client API ne nécessite aucun changement
d'interface utilisateur.

**Stack** : Flutter 3.x, Riverpod (state management), go_router (navigation
avec `StatefulShellRoute` pour la barre de navigation), Google Fonts,
Google Maps Flutter, Geolocator, QR Flutter, fl_chart.

## Lancer le projet

```bash
flutter pub get
flutter run            # appareil/émulateur connecté
flutter run -d chrome  # web
```

Un compte de démonstration est créé automatiquement à chaque connexion
(dépôt simulé) — aucune configuration backend n'est requise pour explorer
le prototype.

### Vérifications

```bash
flutter analyze
flutter test
flutter build web --release
```

## Prochaine étape : backend réel

Voir [`docs/BACKEND_ARCHITECTURE.md`](docs/BACKEND_ARCHITECTURE.md) pour le
plan détaillé (Firebase + service Node.js), les modèles de données et les
contrats d'API à implémenter pour remplacer les dépôts simulés.

## Identité visuelle

Palette inspirée du drapeau ivoirien (orange, blanc, vert) avec une base
neutre premium pour un rendu proche des standards Uber/Bolt/Google Maps —
voir `lib/core/constants/app_colors.dart`. Logo et icônes dans
`assets/branding/`.
