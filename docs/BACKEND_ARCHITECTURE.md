# Transit CI — Architecture Backend

Ce document décrit le backend à construire pour remplacer les dépôts simulés
(`Mock*Repository`) de l'application Flutter par de vrais services. Il sert
de contrat entre le client mobile et l'API : chaque interface de dépôt Dart
(`lib/features/*/data/*.dart`) correspond à une section ci-dessous.

## 1. Choix technique

Deux options sont compatibles avec l'architecture actuelle (l'app ne connaît
que des interfaces `AuthRepository`, `MockRideRepository`, etc. — l'implémentation
concrète est interchangeable) :

| Option | Quand la choisir |
|---|---|
| **Firebase** (Auth, Firestore, Cloud Functions, FCM, Storage) | Démarrage rapide, scalabilité managée, moins d'ops. Recommandé pour le MVP et la V1 publique. |
| **Node.js** (Express/NestJS + PostgreSQL/PostGIS + Redis) | Contrôle total sur la logique métier (matching chauffeur, tarification dynamique), besoins de requêtes géospatiales complexes, intégrations locales (Orange Money, MTN, Moov) plus simples à orchestrer côté serveur. |

Recommandation : **Firebase pour l'authentification, les notifications push et
le stockage**, combiné à un **service Node.js dédié** pour le matching temps
réel, la tarification et les intégrations de paiement mobile money — les deux
s'intègrent nativement (Cloud Functions peuvent appeler l'API Node.js).

## 2. Authentification (`AuthRepository`)

- **Firebase Auth** : email/mot de passe, téléphone (OTP SMS natif), Google,
  Facebook, Apple Sign-In — tous supportés nativement, ce qui correspond
  exactement aux méthodes exposées par `SocialProvider` côté Flutter.
- Un seul rôle utilisateur (`AppUser`) ; les comptes chauffeurs/compagnies
  sont gérés côté back-office (panneau admin), pas via l'app grand public.
- À la connexion, un **custom claim** `verified: true/false` est ajouté après
  validation OTP pour bloquer l'accès aux réservations tant que le numéro
  n'est pas confirmé.

```
POST /auth/register        { fullName, email, phone, password }
POST /auth/login           { identifier, password }
POST /auth/otp/verify      { phone, code }
POST /auth/social/:provider
POST /auth/password-reset  { identifier }
GET  /auth/me
```

## 3. Modèle de données (Firestore / PostgreSQL)

### `users`
| champ | type | notes |
|---|---|---|
| id | string | uid Firebase Auth |
| fullName, email, phone | string | |
| photoUrl | string? | Cloud Storage |
| walletBalanceCents | int | source de vérité côté serveur, jamais modifiable client |
| rating | float | moyenne calculée par Cloud Function sur les avis |
| emergencyContacts | string[] | pour le bouton SOS |

### `drivers`
id, fullName, phone, vehicleType, vehicleModel, plateNumber, rating,
tripsCount, documents (permis, assurance, carte grise — Cloud Storage),
verificationStatus, currentLocation (GeoPoint, mis à jour via websocket).

### `rides` (VTC / taxi / moto)
id, riderId, driverId, vehicleType, pickup (GeoPoint + adresse), destination,
status (`searching|accepted|arriving|ongoing|completed|cancelled`),
estimatedFare, finalFare, distanceMeters, durationMinutes, createdAt,
route (polyline), rating, tip.

### `transit_lines` (gbaka / wôrô-wôrô / bus urbain)
id, code, mode, origin, destination, stops[], waitMinutesEstimate,
averagePrice, affluenceLevel (recalculé périodiquement via les positions GPS
des véhicules partenaires), gpsTracked, activeVehicles[] (positions live).

### `bus_companies`
id, name, fullName, citiesServed[], rating, logoUrl, contact.

### `bus_trips`
id, companyId, originCity, destinationCity, departureAt, durationMinutes,
price, comfortLevel, hasAc, totalSeats, seatMap ({number: taken}).

### `bookings` (billets interurbains)
id, tripId, userId, passengerName, seatNumbers[], totalPrice, qrPayload,
status, bookedAt.

### `payments`
id, userId, method (`orange_money|mtn_money|moov_money|card|wallet`),
amount, currency=XOF, reference, status, relatedEntity (`ride|booking|topup`),
provider webhook payload brut (audit).

### `notifications`
id, userId, category, title, message, read, createdAt — écrit par les Cloud
Functions/services métier, poussé via FCM.

## 4. Temps réel

- **Position des chauffeurs / véhicules gbaka** : chaque appareil publie sa
  position toutes les 3-5s sur un topic (Firestore avec écriture throttlée,
  ou Redis Geo + WebSocket côté Node.js pour réduire les coûts à grande échelle).
- **Suivi de course côté rider** : écoute en temps réel du document `rides/{id}`
  (Firestore listener, ou WebSocket `/rides/:id/stream`).
- **Estimation de trafic** : intégration d'un fournisseur de données trafic
  (ex. Google Roads/Distance Matrix API) combinée à un modèle interne simple
  (moyenne mobile par tronçon) pour les axes non couverts.

## 5. Paiements (Orange Money / MTN Money / Moov Money / carte / wallet)

Chaque opérateur mobile money expose une API de paiement marchand (push USSD
vers le téléphone du client). Flux standard :

```
1. App -> POST /payments/charge { method, amount, phone, relatedEntity }
2. Backend -> appelle l'API de l'opérateur (Orange Money API, MTN MoMo API,
   Moov Money API) qui déclenche une notification USSD sur le téléphone.
3. L'utilisateur valide sur son téléphone (code secret opérateur).
4. Webhook opérateur -> POST /payments/webhook/:provider (signature vérifiée)
5. Backend met à jour `payments/{id}.status = success` et crédite/débite
   `users/{id}.walletBalanceCents` de façon atomique (transaction).
6. FCM notifie l'app (catégorie "system") + mise à jour temps réel de l'écran.
```

Les cartes bancaires passent par un PSP conforme PCI-DSS opérant en Afrique
de l'Ouest (ex. CinetPay, PayDunya, ou Stripe si disponible) — ne jamais
stocker de PAN côté Transit CI.

## 6. Notifications push

Firebase Cloud Messaging, déclenché par des Cloud Functions sur écriture
Firestore (`onCreate` sur `notifications/{id}`) ou par le service Node.js
pour les événements métier (trafic, promotions ciblées géographiquement).

## 7. Sécurité

- Règles Firestore strictes : un utilisateur ne peut lire/écrire que ses
  propres documents (`request.auth.uid == resource.data.userId`).
- Le solde du portefeuille et les tarifs ne sont **jamais** calculés côté
  client — uniquement lus ; toute mutation passe par une Cloud
  Function/endpoint serveur avec transaction atomique.
- Bouton SOS : endpoint dédié `POST /safety/sos` qui notifie un centre de
  sécurité (équipe support ou intégration avec les services d'urgence
  locaux) + les contacts de confiance, avec position GPS et lien de suivi
  temporaire signé (expire après quelques heures).

## 8. Panneau administrateur

Application web séparée (ou section protégée par rôle `admin` custom claim)
consommant les mêmes collections, avec accès en écriture élargi (validation
des documents chauffeurs, gestion des compagnies, remboursements, support).

## 9. Prochaines étapes suggérées

1. Provisionner un projet Firebase (Auth, Firestore, Storage, FCM, Functions).
2. Générer les modèles serveur à partir des classes Dart de ce dépôt
   (elles font déjà foi pour les champs et types attendus).
3. Remplacer `MockAuthRepository`, `MockRideRepository`,
   `MockGbakaRepository`, `MockInterurbanRepository` par des implémentations
   qui appellent Firebase SDK / l'API Node.js, en conservant les interfaces
   Dart existantes (aucun changement d'UI nécessaire).
4. Ajouter les clés API réelles (Google Maps, opérateurs mobile money) via
   des variables d'environnement / `--dart-define`, jamais en dur dans le code.
