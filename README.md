# Transit CI 🇨🇮

Application mobile Flutter qui centralise tous les moyens de transport de
Côte d'Ivoire dans une seule plateforme : gbakas, wôrô-wôrô, taxis compteurs,
bus urbains, VTC, motos-taxis et voyages interurbains (UTB, SBTA, TSR, AVS...).

**Transit CI n'est pas un service de transport comme Yango** : l'app
n'organise pas de course et n'assigne pas de chauffeur. Son rôle est
d'aider un utilisateur qui ne connaît pas un lieu à voir, pour sa
destination, tous les moyens de s'y rendre avec leur prix — adaptés à la
distance (un trajet dans Abidjan n'affiche pas les mêmes options qu'un
trajet vers une ville de l'intérieur) — avec un GPS interne complet et les
moyens de paiement pour ce que l'app réserve réellement (billets
interurbains, portefeuille).

Ce dépôt contient un **prototype fonctionnel** complet côté client (UI,
planification de trajet, paiement, navigation) construit en Clean
Architecture, prêt à être connecté à un vrai backend (voir
[`docs/BACKEND_ARCHITECTURE.md`](docs/BACKEND_ARCHITECTURE.md)).

## Fonctionnalités du prototype

- **Onboarding & authentification** : inscription, connexion, mot de passe
  oublié, vérification OTP par SMS, connexion Google/Facebook/Apple (UI +
  logique simulée), un seul type de compte utilisateur.
- **Planification de trajet ("Où allez-vous ?")** : recherche unifiée d'un
  quartier d'Abidjan ou d'une ville de l'intérieur, avec repère local
  facultatif (adresses informelles) ; affiche automatiquement les moyens de
  transport adaptés à la distance — lignes gbaka/wôrô-wôrô/bus urbain et
  estimations VTC/taxi/moto pour un trajet dans Abidjan, compagnies
  interurbaines (+ trajet pour rejoindre la gare) pour une ville de
  l'intérieur — triables par prix ou par rapidité.
- **Carte / GPS interne** (onglet dédié) : recherche de lieu, trafic simulé
  selon l'heure et la météo (heures de pointe, pluie), mode hors-ligne,
  points d'intérêt le long du trajet (stations-service, pharmacies, points
  Mobile Money), itinéraire combiné multimodal, bouton SOS avec numéros
  d'urgence ivoiriens (police 111, pompiers 180, SAMU 185).
- **VTC / taxi compteur / moto-taxi** : estimation de prix et de temps
  uniquement — Transit CI ne réserve pas la course, c'est un comparateur
  avant de réserver ailleurs ou de héler un véhicule sur place.
- **Gbaka / wôrô-wôrô / bus urbain** : lignes, itinéraires, points de
  chargement, temps d'attente, prix moyen, niveau d'affluence (ajusté selon
  le trafic et la météo), suivi GPS.
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
  core/                    Design system, thème, routing, widgets partagés, utils,
                           simulateur de trafic/météo
  features/
    auth/                  domain / data / presentation (Clean Architecture)
    onboarding/, splash/
    home/, shell/          tableau de bord + navigation à onglets (5 onglets)
    trip/                  planification "Où allez-vous ?" (lieux unifiés,
                           options de trajet adaptées à la distance)
    maps/                  onglet Carte/GPS : trafic, hors-ligne, POI, combiné
    ride/                  VTC, taxi compteur, moto-taxi — estimation uniquement
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
