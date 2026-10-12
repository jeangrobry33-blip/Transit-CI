# QA_AUDIT.md — Transit CI

Audit adapté du brief web (meta tags, sitemap, HTTPS, Lighthouse) à une
app Flutter mobile — ces deux mondes partagent peu de mécanique, cette
colonne "Adaptation" explique le remplacement ou dit "N/A — app mobile".
Chaque ligne a été vérifiée réellement (lecture de code, `grep`, exécution
de `flutter analyze`/`test`/`build`, capture d'écran via navigateur
headless) pendant cette passe, pas devinée. Les limites d'environnement
(pas d'appareil physique, pas d'accès réseau à certains domaines) sont
indiquées explicitement là où elles s'appliquent, pas cachées.

| # | Contrôle | Statut | Preuve |
|---|---|---|---|
| 1 | Politique de confidentialité | **FIX** | `lib/features/legal/presentation/screens/privacy_policy_screen.dart` créé, contenu réel (comptes, position, historique — pas de template générique), lié depuis Paramètres et l'inscription. Bandeau explicite : document produit, pas un avis juridique. |
| 2 | CGU / mentions légales | **FIX** | `terms_screen.dart` créé, même traitement, lié aux mêmes endroits. Mentions légales (raison sociale, siège, RCCM) explicitement marquées à compléter avant mise en production — **ACTION**. |
| 3 | Secrets dans le code/dépôt | **PASS** | `grep -rn -i "api[_-]key\|secret\|token.*="` sur `lib/` : aucun secret trouvé. La clé Supabase dans `supabase_config.dart` est la clé publique "publishable", documentée comme destinée au client dans `docs/BACKEND_ARCHITECTURE.md` §7bis ; RLS bloque toute écriture anonyme côté serveur. |
| 4 | HTTPS forcé | N/A (app mobile) | `supabase_flutter` n'appelle que `https://eangcvlflycbficpdyej.supabase.co`. Pas de redirection http/https à gérer côté app native. |
| 5 | Bannière cookies | N/A (app mobile) | Aucun cookie tiers. Aucun SDK d'analytics tiers n'est présent dans `pubspec.yaml` (ni Firebase Analytics, ni autre) — rien à consentir pour l'instant. |
| 6 | Meta title/description par page | N/A (app mobile) | Équivalent app : `pubspec.yaml` `description` ("Transit CI - La super app du transport en Côte d'Ivoire") — **ACTION** : reformuler pour coller au repositionnement "comparateur, pas dispatch" acté dans ce PR. |
| 7 | Image de partage réseaux sociaux | **ACTION** | Pas d'image Open Graph à fournir pour une app ; équivalent réel = visuel de fiche store (Play Store/App Store), pas encore produit. |
| 8 | Favicon complet + manifest | **PASS (web uniquement)** | `flutter build web` génère `favicon.png`, `manifest.json`, `icons/`. Les icônes Android (`android/app/src/main/res/mipmap-*`) et iOS (`ios/Runner/Assets.xcassets/AppIcon.appiconset/`) existent mais sont les icônes par défaut du template Flutter, pas une icône de marque Transit CI — **ACTION**, besoin d'un asset fourni par l'utilisateur. |
| 9 | sitemap.xml / robots.txt | N/A (app mobile) | Pas de pages indexables côté app. |
| 10 | Texte alternatif sur les images | **PARTIEL / ACTION** | `Image.asset('assets/branding/logo_mark_rounded.png')` (splash) n'a pas de `semanticLabel`. Peu d'images porteuses de sens dans l'app (surtout des icônes vectorielles avec `Semantics` possible) — corrigé pour le bouton notifications (voir #25), reste à auditer plus largement hors du périmètre de cette passe (écrans profil/admin non retouchés). |
| 11 | Images compressées, formats modernes | **PASS** | Un seul asset bitmap réel (`logo_mark_rounded.png`), le reste est vectoriel (icônes Material) ou généré. `flutter build web --release` tree-shake les polices d'icônes (ex. `MaterialIcons-Regular.otf` : 1,6 Mo → 22,6 Ko, -98,6%, log de build). |
| 12 | Vitesse (Lighthouse mobile) | **ACTION — non mesurable ici** | Pas de Lighthouse disponible dans ce bac à sable (pas de Chrome DevTools Protocol complet exposé pour un run Lighthouse). `flutter build web --release` compile sans erreur (92,5s) ; `flutter test` passe. Mesure réelle (LCP/INP/CLS, et leur équivalent natif : temps de démarrage à froid, jank) à faire sur un appareil/émulateur par l'utilisateur. |
| 13 | Contraste AA | **FIX, vérifié par calcul** | Voir `docs/DESIGN.md` §1.1 : ratios calculés (script Python WCAG), pas estimés à l'œil. Corrigés : texte des boutons (2.61→7.39:1), texte secondaire `mist`→`textMuted` (3.06→7.74:1), texte orange `orange`→`orangeInk` (2.61→5.23:1), couleurs d'état en texte (2.35-3.76→4.66-4.75:1), bordures/indicateurs 3:1 (`orangeDark`). **Limite assumée** : `AppColors.mist`/`AppColors.orange` bruts restent utilisés comme texte dans ~30 fichiers non retouchés par cette passe (admin, wallet, paiement, profil, historique, favoris, gbaka, ride) — corrigés uniquement sur les écrans effectivement reconstruits (splash, onboarding, accueil, résultats de trajet) + la couche thème globale (boutons, champs, nav du bas, textes de liens). **ACTION** pour le reste : remplacer au cas par cas, certains sites ne peuvent pas devenir theme-aware sans sortir du contexte `const`. |
| 14 | Responsive (plusieurs largeurs) | **PASS (viewport mobile vérifié)** | Captures d'écran réelles prises à 390×844 (iPhone standard) via Chromium headless + build web local. Zones tactiles : bouton notifications porté de 44 à 48px (seuil Material/WCAG), voir `home_screen.dart`. Largeurs tablette/desktop non testées (app mobile-first assumée, cohérent avec le brief). |
| 15 | Page 404 personnalisée | N/A (app mobile) | Équivalent `go_router` : pas de route `errorBuilder` définie dans `app_router.dart` — **ACTION**, un `errorBuilder` custom éviterait l'écran d'erreur Flutter brut par défaut sur une route inconnue. |
| 16 | Liens cassés | **FIX** | Les deux `ListTile` "Conditions d'utilisation"/"Politique de confidentialité" dans Paramètres avaient `onTap: () {}` (lien mort) — maintenant branchés sur de vrais écrans (voir #1, #2). |
| 17 | Formulaires validés | **PASS (existant, non modifié)** | `AppValidators` déjà en place sur inscription/connexion (non audité en détail dans cette passe, hors périmètre design). |
| 18 | Anti-spam | N/A (app mobile, pas de formulaire public) | — |
| 19 | Analytique respectueuse | **ACTION** | Aucun SDK d'analytics dans `pubspec.yaml` actuellement — rien à auditer pour l'instant, mais aussi rien pour mesurer l'usage réel du CTA principal. |
| 20 | Un seul CTA principal, verbe constant | **PASS** | "Où allez-vous ?" reste l'entrée unique sur l'accueil ; le bouton "Rechercher" est le seul CTA de la recherche interurbaine. Bandeau promotionnel fabriqué supprimé de l'accueil (voir DESIGN.md §7) — il introduisait un second CTA concurrent ("BIENVENUE20") qui n'avait aucune réalité. |
| 21 | `lang`, un seul h1, hiérarchie de titres, repères | **Adapté, ACTION réelle trouvée** | Flutter n'a pas de DOM HTML ; l'équivalent est l'arbre `Semantics`. Tentative réelle d'ajouter `locale: Locale('fr', 'CI')` à `MaterialApp.router` : **a cassé l'app** (`flutter test` échoue, `MaterialLocalizations`/`CupertinoLocalizations` n'ont pas de délégué pour `fr_CI` tant que le package `flutter_localizations` n'est pas ajouté au `pubspec.yaml`) — changement annulé après l'avoir constaté, pas laissé en l'état cassé. **ACTION** réelle pour l'utilisateur : ajouter `flutter_localizations` (SDK Flutter) + les délégués `GlobalMaterialLocalizations`/`GlobalCupertinoLocalizations`/`GlobalWidgetsLocalizations` avant de déclarer une locale explicite. Le formatage des dates fonctionne déjà correctement sans cela via `initializeDateFormatting('fr_FR')` (manuel, `main.dart`), donc ce n'est pas un bloquant actuel. Hiérarchie visuelle respectée par construction (`display`/`h1`/`h2`/`h3` utilisés dans un ordre cohérent, pas de saut arbitraire). |
| 22 | Canonical / 301 www | N/A (app mobile) | — |
| 23 | En-têtes de sécurité (HSTS, CSP...) | N/A (app mobile, pas de serveur HTTP propre) | S'applique à un futur déploiement web/backend, pas à ce dépôt Flutter. |
| 24 | Données structurées JSON-LD | N/A (app mobile) | — |
| 25 | Accessibilité clavier/lecteur d'écran | **FIX partiel** | Bouton notifications (accueil) : ajout de `Semantics(label: 'Notifications', button: true)` + cible portée à 48px. Reste à auditer plus largement (SOS, icônes seules sur écrans non retouchés) — **ACTION**. Testé par lecture de code, pas par un lecteur d'écran réel (aucun appareil disponible ici). |
| 26 | Motion : lisible avec `prefers-reduced-motion`, sans JS, sans CLS | **FIX, voir `docs/motion.md` §5** | `MediaQuery.disableAnimations` vérifié avant chaque animation ajoutée (splash, grille accueil, cartes résultats) ; aucune n'anime `width`/`height`/position de layout (seulement `opacity` et une translation), donc pas de CLS attendu. Non testé sur appareil physique avec l'option réellement activée (limite d'environnement, indiquée dans motion.md). |
| 27 | Polices : auto-hébergées/préchargées, 2 familles max | **PASS, avec réserve** | Exactement 2 familles (Fraunces + Archivo), via `google_fonts` (déjà une dépendance du projet). **Réserve honnête** : `google_fonts` télécharge les polices depuis fonts.gstatic.com au premier lancement (puis les met en cache) plutôt que de les embarquer en asset — fonctionnalité standard du package, mais à vérifier en conditions de connectivité faible (justement le contexte ivoirien documenté dans la recherche transport) ; embarquer les fichiers de police en asset local serait plus robuste — **ACTION** pour une version de production. |
| 28 | Paiement de bout en bout | **N/A pour cette passe** | Le wallet/paiement reste un flux simulé (`Mock*Repository`), non modifié ici — hors périmètre design. |
| 29 | Liens tel:/mailto:/wa.me | **PASS (existant)** | Le bouton SOS (`sos_button.dart`, non modifié) compose déjà les vrais numéros d'urgence ivoiriens (police 111, pompiers 180, SAMU 185) via `url_launcher`, vérifié dans le code et mentionné dans `terms_screen.dart`. |
| 30 | Contenu : pas de lorem ipsum, pas de faux avis/chiffres | **FIX** | Supprimé : bandeau "-20% sur votre 1er trajet VTC / code BIENVENUE20" (promotion fabriquée, aucune réalité), trajet récent fictif "Plateau → Cocody, hier, VTC, 2 200 FCFA" (remplacé par un état honnête "vos trajets récents apparaîtront ici"), emoji 👋 utilisé comme icône. Les textes d'onboarding ont été réécrits pour ne pas surclaimer les données réelles (ex. ne pas prétendre que toutes les compagnies sont "vérifiées" alors que certaines restent `unverified`, voir `docs/BACKEND_ARCHITECTURE.md` §7bis). Espaces insécables ajoutées avant `?`/`:` dans les textes juridiques (` `). |
| 31 | Cadre légal ivoirien (loi 2013-450, ARTCI) | **ACTION — signalé, pas tranché** | L'app collecte des données personnelles (nom, téléphone, e-mail, position GPS) via Supabase. Ceci peut relever d'une obligation de déclaration/autorisation auprès de l'ARTCI au titre de la loi n°2013-450 sur la protection des données à caractère personnel. **Ce n'est pas un avis juridique** : à faire trancher par un juriste ou directement auprès de l'ARTCI avant toute mise en production réelle avec de vrais utilisateurs. |
| 32 | Sauvegarde et reprise | **PASS (partiel)** | Dépôt versionné sous Git (`jeangrobry33-blip/Transit-CI`), base Supabase hébergée (sauvegarde gérée par Supabase). Accès hébergeur/domaine : aucun domaine de production n'existe encore pour cette app (prototype) — rien à documenter pour l'instant. |

## Scores Lighthouse mobile — avant/après

**Non mesurés.** Ce bac à sable n'a pas d'outil Lighthouse fonctionnel
(pas de Chrome DevTools Protocol complet exposé pour un audit automatisé,
seulement un navigateur headless pour des captures d'écran). Je ne vais
pas inventer un chiffre que je n'ai pas obtenu — **ACTION** : à exécuter
par l'utilisateur sur `flutter build web --release` déployé, ou sur un
build Android/iOS réel avec les outils de profilage Flutter DevTools.

## Vérification visuelle réelle effectuée

`flutter build web --release` servi localement (`python3 -m http.server`)
et capturé via Chromium headless (Playwright, déjà installé dans cet
environnement) à 390×844px — pas une description, de vraies captures :
- Onboarding (page 1, forme billet à encoche, Fraunces/Archivo, bouton à
  encre sombre sur orange) — **envoyée à l'utilisateur**.
- Accueil (accès direct via `/#/home`, sans passer par l'authentification
  simulée) — **envoyée à l'utilisateur**.
- Écran de résultats de trajet (cartes billet) : **non vérifiable
  visuellement dans cette session** — le chargement reste bloqué en
  spinner, Supabase n'étant pas joignable depuis le réseau du navigateur
  headless dans ce bac à sable (même restriction que celle qui a limité
  `WebFetch` tout au long de cette conversation). Le composant `
  TicketShapeBorder` est le même que celui déjà vérifié visuellement sur
  l'onboarding, ce qui donne une confiance raisonnable qu'il s'affichera
  correctement, mais ce n'est **pas une vérification directe** — **ACTION**
  pour l'utilisateur : lancer l'app sur un appareil/émulateur avec accès
  réseau réel et confirmer visuellement l'écran de résultats.

## Build/test — résultats réels

- `flutter analyze` → 0 problème (après correction d'une erreur
  `const_with_non_const` introduite puis corrigée pendant cette passe).
- `flutter test` → tous les tests passent (1 test, `widget_test.dart`).
- `flutter build web --release` → succès (92,5s), tree-shaking des polices
  d'icônes actif.

## Verdict final

**Pas encore prêt pour une mise en production avec de vrais utilisateurs**,
mais prêt à continuer d'évoluer sur cette branche. Bloquants réels avant
production : mentions légales à compléter avec de vraies informations
d'entreprise (#2), vérification ARTCI/loi 2013-450 (#31), icônes
d'app de marque (#8), mesure Lighthouse/DevTools réelle sur appareil
(#12, #26), et extension des correctifs de contraste au reste de l'app
(#13 — actuellement limités aux écrans refaits dans cette passe). Rien de
tout cela n'est caché : chaque point est listé ci-dessus comme ACTION,
pas comme PASS.
