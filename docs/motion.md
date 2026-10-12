# motion.md — Transit CI

Adaptation du brief motion (pensé pour GSAP/Lenis/Motion.dev, un site web)
à une application Flutter native. GSAP, ScrollTrigger, Lenis et la View
Transitions API n'existent pas dans ce contexte : ce document les remplace
par les primitives d'animation réelles de Flutter et par `flutter_animate`
(ajouté à `pubspec.yaml`), seule nouvelle dépendance introduite pour cette
passe.

Ton du mouvement : **direct, débrouillard, ancré** (les trois adjectifs de
`docs/DESIGN.md` §5 — le mouvement ne doit pas se mettre en scène plus que
l'app elle-même). Appareil cible principal : mobile milieu de gamme Android
(le plus répandu dans le parc ivoirien d'après les constats de la recherche
transport — connectivité et matériel variables).

## 1. Le moment signature

**Les billets arrivent comme distribués.** Sur l'écran de résultats de
recherche (`trip_results_screen.dart`), quand les options de trajet se
chargent, chaque carte apparaît avec un léger décalage dans le temps
(cascade de 45ms), montant légèrement et s'estompant vers son opacité
finale. Ce n'est pas une animation de scroll ni un effet plaqué sur
n'importe quel écran : c'est la réponse visuelle au moment exact où l'app
remplit sa promesse ("voici vos options"), et elle réutilise la forme
billet définie dans DESIGN.md plutôt que d'ajouter un effet indépendant.
Tout le reste de l'app est délibérément plus discret (voir §4).

Un second traitement, plus mineur, suit le même principe sur l'accueil
(la grille des modes de transport apparaît en cascade à l'ouverture) — la
même mécanique, pour que l'app ait une seule "signature de mouvement"
reconnaissable, pas deux effets différents qui se concurrencent.

## 2. Tableau par élément animé

| Élément | Déclencheur | Propriétés | Durée | Easing | Délai | Mobile | `disableAnimations` |
|---|---|---|---|---|---|---|---|
| Cartes de résultats de trajet | Chargement des résultats (une fois) | opacity, translationY (8%→0) | 260ms | `Curves.easeOut` | 45ms × index | Identique (déjà léger) | Rendu immédiat, sans animation |
| Grille des modes de transport (accueil) | Premier affichage de l'écran | opacity, translationY (12%→0) | 220ms | `Curves.easeOut` | 25ms × index | Identique | Rendu immédiat |
| Logo + titre du splash | Démarrage de l'app | scale (0.8→1) | 900ms | `Curves.easeOutBack` | 0 | Identique | `AlwaysStoppedAnimation(1)` — pas de scale |
| Ligne tracée sous le titre (splash) | Démarrage de l'app, lié au même contrôleur | largeur (0→100%) | lié à l'anim. du splash | `Curves.easeOut` | 0 | Identique | Tracée à 100% immédiatement |
| Points de pagination (onboarding) | Changement de page | largeur (8px↔24px) | 250ms | implicite (`AnimatedContainer`) | 0 | Identique | Flutter respecte déjà `disableAnimations` nativement ici |
| Boutons (`AppButton`) | Appui | opacity (désactivé) | — | — | — | — | Pas concerné (état, pas mouvement) |

Aucune animation ne dépasse 900ms (le splash, borné dans le temps par la
logique de démarrage existante) ; toutes les autres restent sous 300ms,
cohérent avec "révélations : 0,75 à 1,1s" du brief original ramené à
l'échelle d'une app mobile où l'attente doit rester courte.

## 3. Tokens de mouvement

Pas de fichier `motion.config` séparé : en Flutter, les constantes
d'easing/durée vivent soit comme `Curves.*` (fournies par le SDK, pas besoin
de les redéfinir), soit en ligne dans chaque `.animate()` — un fichier de
tokens séparé serait une indirection inutile pour le volume d'animations
réellement présent dans l'app (moins de dix). Les valeurs de référence :

- **Easing d'entrée** : `Curves.easeOut` (déplacements/fondus), `Curves.
  easeOutBack` (le seul "rebond", réservé au logo du splash — un retour
  comme un ticket qu'on sort du composteur, pas un rebond ludique gratuit).
- **Durées** : 220 à 260ms pour les révélations de listes/grilles, jusqu'à
  900ms pour le seul moment de démarrage (splash).
- **Stagger** : 25 à 45ms par élément — volontairement plus serré que les
  60 à 140ms suggérés pour un site web, parce que sur mobile une cascade
  trop lente sur une liste de 6 à 10 options de trajet retarderait la
  lecture de l'information la plus importante de l'app.

## 4. Ce qui n'a volontairement PAS été animé

| Écran/élément | Pourquoi |
|---|---|
| Écrans admin, wallet, paiement, profil, historique, favoris | Écrans utilitaires à faible fréquence de visite ; une signature de mouvement y ajouterait de la décoration sans servir la lecture. Cohérent avec "le mouvement ne décore jamais". |
| Transitions de navigation entre écrans (push/pop) | Les transitions par défaut de `go_router`/Material (slide standard de la plateforme) sont déjà familières à l'utilisateur ivoirien habitué à Android ; les réinventer n'apporterait rien et risquerait de ralentir la navigation perçue. |
| Carte (`maps_screen.dart`) | Contient déjà une couche "trafic/pluie simulée" dynamique (`TrafficSimulator`) ; ajouter des animations d'entrée par-dessus une carte interactive créerait une concurrence visuelle, pas de la clarté. |
| Curseur personnalisé, traînée de souris | N'existe pas sur mobile tactile — explicitement hors sujet, contrairement à un site web. |
| Scroll-jacking / sections pinnées | Flutter n'a pas d'équivalent direct à `ScrollTrigger` pin + scrub, et l'app n'a aucune page de storytelling au scroll (ce n'est pas un site vitrine) : non pertinent pour ce produit. |

## 5. Contrôle final

- **`prefers-reduced-motion` (équivalent Flutter : `MediaQuery.
  disableAnimations`)** : vérifié dans le code pour les trois endroits
  animés (splash, grille de l'accueil, cartes de résultats) — chacun a une
  branche explicite qui rend le contenu final immédiatement, sans
  attendre une animation. Testé en lisant le code (`reduceMotion` est
  vérifié avant `.animate()` à chaque site), pas sur un appareil physique
  réel : **aucun appareil/émulateur n'est disponible dans ce bac à
  sable pour un test visuel en direct** — à vérifier par l'utilisateur sur
  un vrai téléphone avant mise en production (voir `docs/QA_AUDIT.md`).
- **Sans JavaScript** : non applicable, Flutter compile en code natif/Dart,
  il n'y a pas de dégradation "JS désactivé" possible pour une app mobile ;
  seul le build web (`flutter build web`) pourrait avoir un équivalent, et
  il a été vérifié avec succès (`flutter build web --release`, voir
  `docs/QA_AUDIT.md`).
- **Mobile** : mêmes durées qu'ailleurs (déjà pensées courtes dès le
  départ, voir §2) — pas de réduction supplémentaire nécessaire comme le
  préconise le brief original pour un site, car il n'y a ici ni pin ni
  galerie horizontale lourde à alléger.
- **Mesure de performance** : non mesurée sur device réel (même
  contrainte d'environnement). Les animations ajoutées n'animent que
  `opacity` et une translation (`slideY`), jamais `width`/`height`/
  position de mise en page — donc pas de recalcul de layout attendu, mais
  cette prédiction reste à confirmer avec Flutter DevTools sur un appareil
  physique avant mise en production.
