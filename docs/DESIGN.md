# DESIGN.md — Transit CI

Ce fichier est la source de vérité unique pour l'identité visuelle de
l'application. Tout le code Flutter (thème, widgets, écrans) doit s'y
référer ; si un écran contredit ce document, c'est l'écran qu'on corrige.

Contexte produit (rappel) : Transit CI ne vend rien et ne réserve aucun
chauffeur. C'est un comparateur de moyens de transport à Abidjan et en
Côte d'Ivoire (gbaka, wôrô-wôrô, taxi compteur, VTC, moto-taxi, bus urbain,
compagnies interurbaines) — l'app dit quoi prendre, pour aller où, et ce qui
se passe quand on appuie, jamais un slogan vague.

## 1. Palette

### Palette principale

| Nom | Rôle | Hex | Usage |
|---|---|---|---|
| `night` | Texte principal (clair) / fond (sombre) | `#0B0E14` | Texte sur fond clair, fond en thème sombre |
| `cloud` | Fond (clair) | `#F4F6FA` | Arrière-plan des écrans en thème clair |
| `white` / `surfaceDarkAlt` | Surface ("papier") | `#FFFFFF` / `#1C2330` | Cartes, billets, feuilles de bas d'écran |
| `orange` | Accent primaire | `#FF7A00` | Icônes, grandes surfaces, fond des CTA (jamais en texte sur fond clair, voir §1.2) |
| `ivoryGreenDark` | Accent secondaire | `#0B7A44` | Confirmation, paiement réussi, CTA secondaire |
| `fog` | Bordure (clair) | `#E7EAF0` | Séparateurs, contours de champs en thème clair |

Ces six couleurs restent celles du drapeau ivoirien (orange / blanc / vert),
déjà la base de marque de Transit CI avant cette passe — on ne change pas
l'identité, on la rend juste conforme et distincte dans son usage.

### 1.1 Contrastes vérifiés (WCAG AA, calculés, pas estimés)

J'ai calculé chaque paire réellement utilisée dans l'app (formule de
luminance relative WCAG, script Python exécuté pendant cette passe, pas une
estimation à l'œil) :

| Paire | Ratio | Verdict avant | Correction |
|---|---|---|---|
| Texte blanc sur bouton orange `#FF7A00` | **2.61:1** | ❌ Échec (seuil 4.5:1) | Texte **`night`** sur orange → **7.39:1** ✅ |
| Texte blanc sur bouton vert `#0F9D58` | 3.51:1 | ❌ Échec | Fond **`ivoryGreenDark`** `#0B7A44` + texte blanc → **5.41:1** ✅ |
| Texte `mist` `#8A94A6` sur fond blanc | 3.06:1 | ❌ Échec (texte secondaire) | Nouveau token **`textMuted`** `#4B5362` → **7.74:1** ✅ |
| Texte orange `#FF7A00` sur fond clair (liens, prix) | 2.61:1 | ❌ Échec | Nouveau token **`orangeInk`** `#AD5300` → **5.23:1** ✅ |
| Texte `night` sur fond `cloud` | 17.85:1 | ✅ | — |
| Texte `fog` sur fond `night` (thème sombre) | 16.03:1 | ✅ | — |
| `mist` sur fond `night` (thème sombre) | 6.32:1 | ✅ | `mist` reste utilisé tel quel en thème sombre et pour les icônes/bordures |

**Conséquence concrète** : le bouton principal de l'app passait d'un ratio
d'échec (2.61:1) à 7.39:1 simplement en changeant la couleur du texte, pas
celle du fond — l'orange vif reste intact, c'est juste l'encre qui change.
C'est devenu un trait de signature (§6) plutôt qu'une concession.

### 1.2 Tokens texte additionnels

| Nom | Hex | Rôle |
|---|---|---|
| `orangeInk` | `#AD5300` | Texte accentué sur fond clair (prix, liens, chip sélectionné) — jamais `orange` brut en texte sur fond clair |
| `textMuted` | `#4B5362` | Texte secondaire/légende sur fond clair (remplace `mist` comme couleur de **texte** ; `mist` reste pour icônes/bordures) |

## 2. Typographie

**Fraunces** (titres) + **Archivo** (interface), via `google_fonts` — déjà
une dépendance du projet, aucun asset à ajouter.

- **Pourquoi pas Plus Jakarta Sans** (police actuelle) : c'est devenu le
  nouvel Inter — la police par défaut de tout starter SaaS/fintech généré
  depuis 2023. Rien dans son dessin n'est spécifique à Transit CI.
- **Fraunces** (titres, `display`/`h1`/`h2`/`h3`) : une serif contemporaine
  avec du caractère (empattements marqués, contrastes forts), familière des
  marques éditoriales et pas des dashboards SaaS. Elle donne au nom des
  villes et aux gros prix une présence qu'une grotesque sans-serif n'a pas.
- **Archivo** (`titleMd`, `bodyLg/Md/Sm`, `label`, `button`, `caption`) :
  une grotesque robuste, pensée pour l'interface et les chiffres (largeurs
  de chiffres régulières — important pour comparer des prix en colonne).

| Style | Police | Taille | Graisse | Interligne | Letter-spacing |
|---|---|---|---|---|---|
| `display` | Fraunces | 34 | 600 | 1.1 | -0.4 |
| `h1` | Fraunces | 28 | 600 | 1.15 | -0.3 |
| `h2` | Fraunces | 22 | 600 | 1.2 | -0.2 |
| `h3` | Fraunces | 18 | 600 | 1.25 | 0 |
| `titleMd` | Archivo | 16 | 600 | 1.3 | 0 |
| `bodyLg` | Archivo | 16 | 400 | 1.5 | 0 |
| `bodyMd` | Archivo | 14 | 400 | 1.5 | 0 |
| `bodySm` | Archivo | 12 | 400 | 1.4 | 0.1 |
| `label` | Archivo | 13 | 600 | 1.3 | 0.2 |
| `caption` | Archivo | 11 | 500 | 1.3 | 0.3 |
| `button` | Archivo | 15 | 700 | 1.2 | 0.1 |

Fraunces utilise sa graisse 600 (pas 800/900) : on veut du caractère, pas de
la lourdeur criarde. Letter-spacing négatif seulement sur les titres, pour
qu'ils restent compacts et affirmés plutôt que flottants.

## 3. Espacement

Grille de 4px existante (`AppSpacing` : 4/8/12/16/24/32/48), conservée —
elle est déjà saine et n'avait pas besoin d'être réinventée. Largeur de
contenu : pleine largeur moins 2×16px de marge sur mobile (pas de largeur de
lecture à contraindre, ce n'est pas un article).

## 4. Formes — hiérarchie délibérée, pas un seul rayon partout

| Rayon | Valeur | Usage |
|---|---|---|
| `sm` | 8 | Champs de saisie, puces de tri, petites puces de statut |
| `md` | 14 | Badges d'icône, boutons |
| `lg` | 20 | Cartes de contenu standard (compagnies, historique) |
| `xl` | 28 | Surfaces héros (logo du splash, cadre d'illustration onboarding) |
| `pill` | 999 | **Statuts/étiquettes uniquement** (ex. "Vérifié", "Estimation") — jamais les boutons |

**Forme signature : le billet à encoche.** Un `ShapeBorder` personnalisé
(`TicketShape`, voir `lib/core/widgets/ticket_shape.dart`) qui découpe deux
demi-cercles sur les bords gauche/droit d'une carte, comme un vrai ticket de
bus/car. Utilisé **uniquement** pour ce qui représente un trajet qu'on peut
réellement acheter : les cartes interurbaines dans les résultats de
recherche, le trajet récent sur l'accueil, l'écran de billet QR. **Jamais**
pour les estimations VTC/taxi/moto (qui restent des rectangles arrondis
`lg`) — la forme porte une information réelle (« ceci est un billet » vs
« ceci est une estimation »), elle n'est pas décorative.

Ombres : aucune ombre douce généralisée. Les cartes standard n'ont pas
d'ombre (`elevation: 0`, déjà le cas) ; seule la carte billet porte une
ombre légère et chaude (teinte orange à 8% d'opacité, pas de gris neutre)
pour la détacher du fond — une ombre qui dit "ceci compte", pas un réflexe
Material par défaut.

## 5. Ton éditorial

**Trois adjectifs : direct, débrouillard, ancré.**

"Débrouillard" n'est pas un hasard : c'est le mot qu'un délégué du Haut
Conseil des Transporteurs a employé dans la recherche terrain pour décrire
comment le transport fonctionne réellement en Côte d'Ivoire hors des grands
axes ("la débrouillardise a pris le pas sur l'activité formelle" —
`research_notes/Transport rural Côte Ivoire 2/ouest_sudouest_gaps.md`).
Transit CI reprend ce trait comme une qualité : une app qui aide à se
débrouiller avec ce qui existe vraiment, pas une app qui prétend que tout
est déjà parfaitement organisé.

**Règles d'écriture**
- Phrases courtes, verbe d'action en premier quand possible.
- Les chiffres sont réels ou absents. Jamais de placeholder ("À partir de
  X FCFA" sans X).
- Vocabulaire local assumé et jamais traduit/aseptisé : gbaka, wôrô-wôrô,
  gare routière, FCFA, Orange Money, MTN MoMo, Wave.
- Pas de tiret cadratin (—) ; virgule ou point.
- Pas d'emoji utilisé comme icône — un seul jeu d'icônes (Material Symbols
  Rounded, déjà en place) ou rien.

**Mots interdits** : révolutionnaire, disruptif, boostez, simplifiez votre
vie, propulsé par l'IA, élevez, le meilleur/le plus rapide (sans preuve
chiffrée réelle attachée), toute promotion chiffrée non réellement
disponible (ex. l'ancien bandeau "-20%" sur l'accueil, qui n'existait dans
aucune donnée réelle — supprimé, voir §7).

## 6. Signature — reconnaissable en un coup d'œil

Trois éléments, utilisés ensemble, qu'aucune autre app ne combine ainsi :
1. **Le billet à encoche** pour tout ce qui est un vrai trajet achetable.
2. **Fraunces en titres / Archivo en interface** — une serif de caractère
   au-dessus d'une grotesque utilitaire, jamais l'inverse, jamais une seule
   police pour les deux rôles.
3. **L'encre sombre sur fond orange vif** pour les actions principales,
   au lieu du blanc-sur-couleur par défaut de tout le monde — une
   convention qui vient d'un vrai problème de contraste résolu (§1.1), pas
   d'un choix esthétique arbitraire.

## 7. Ce que ce document corrige explicitement (traçabilité)

- Bandeau promotionnel fabriqué ("-20% sur votre 1er trajet VTC, code
  BIENVENUE20") sur l'accueil : aucune promotion réelle n'existe → supprimé.
- Emoji 👋 utilisé comme icône dans le message d'accueil → supprimé.
- Pattern "grand carré à dégradé + icône géante" répété sur les 4 pages
  d'onboarding → remplacé par un traitement éditorial (Fraunces + motif
  billet), différent par page plutôt qu'un seul gabarit recoloré 4 fois.
- Carte générique (case à icône 44×44 + titre/sous-titre + valeur +
  chevron) recopiée à l'identique pour des contenus différents (compagnie,
  option de trajet, trajet récent) → différenciée par forme selon ce
  qu'elle représente (§4).
