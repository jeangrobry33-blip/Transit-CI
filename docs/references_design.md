# Références de direction artistique — Transit CI

## Limite technique à connaître avant de lire ce document

Cette session tourne dans un bac à sable dont l'accès réseau sortant vers les
domaines habituels de veille design (dribbble.com, behance.net, mobbin.com,
awwwards.com, siteinspire.com, land-book.com, lapa.ninja, onepagelove.com,
refero.design) est bloqué — la même restriction DNS/proxy qui a empêché les
agents de recherche transport (voir `research_notes/`) de lire directement
les pages koaci.com ou fratmat.info. Je ne peux donc pas « parcourir ces
galeries » au sens littéral (ouvrir une page, regarder les pixels, capturer
une direction artistique précise).

Ce qui suit s'appuie à la place sur ma connaissance générale, vérifiable et
publique d'applications de mobilité largement documentées et utilisées
(Citymapper, Moovit, Google Maps, Bolt) — des faits de design que je peux
affirmer sans avoir besoin de les revoir en direct, plutôt que sur une
inspection fraîche de shots Dribbble que je n'ai pas pu charger. Si tu as des
captures d'écran précises d'apps que tu aimes, montre-les-moi : je peux les
lire directement (outil Read) même sans accès réseau.

## 5 références retenues

### 1. Citymapper (iOS/Android) — hiérarchie de l'information, pas le style
**Ce que je retiens** : Citymapper résout le même problème que Transit CI
(comparer plusieurs moyens de transport pour un même trajet) en affichant les
options sous forme de bandeaux horizontaux empilés, chacun avec une couleur de
mode distincte, un temps et un prix en gros, et un détail d'étapes réduit à
des pictogrammes alignés sur une ligne de temps. La hiérarchie typographique
est brutale : le chiffre (temps, prix) domine toujours le libellé.
**Ce que je refuse de copier** : sa palette très saturée multi-couleurs
(une couleur par ligne de métro londonien) n'a aucun sens pour nous — nos
« lignes » n'ont pas d'identité officielle à respecter. Je retiens le
principe (le chiffre domine, une couleur = un mode), pas la palette.

### 2. Moovit — codification par mode de transport informel
**Ce que je retiens** : Moovit s'adapte à des pays où les transports en commun
ne sont pas un réseau unique opéré par une autorité (comme nos gbaka et
wôrô-wôrô) en traitant chaque ligne comme une entité nommée par son numéro et
son itinéraire plutôt que par un logo de compagnie. C'est exactement notre cas
pour les lignes gbaka : pas de branding officiel, juste un trajet reconnu par
l'usage.
**Ce que je refuse de copier** : son UI très dense, orientée temps réel GPS
précis (position du bus en direct) — nous n'avons pas cette donnée (confirmé
dans `docs/BACKEND_ARCHITECTURE.md` : `transit_lines` est vide, aucune donnée
de ligne réelle structurée n'a été trouvée). Afficher une fausse précision
temps réel serait mentir à l'utilisateur.

### 3. Google Maps — le motif du itinéraire comme ligne dessinée
**Ce que je retiens** : le principe du trajet représenté comme une ligne
continue qui se dessine (plutôt qu'une simple liste), et l'usage de formes
de « pastille » asymétriques (goutte inversée) pour marquer un point sur un
itinéraire plutôt qu'un cercle neutre — un signifiant fort et unique à la
catégorie « lieu sur une carte ».
**Ce que je refuse de copier** : son identité visuelle washée/neutre à
dessein (Google Maps doit être invisible derrière les apps qui l'intègrent).
Transit CI n'a pas cette contrainte : on peut se permettre une personnalité
beaucoup plus marquée.

### 4. Bolt (application grand public en Afrique de l'Ouest, dont Abidjan) —
ton éditorial direct, prix en avant
**Ce que je retiens** : Bolt affiche le prix exact avant toute confirmation,
en gros caractères, jamais en sous-texte — cohérent avec notre contrainte
« tout chiffre affiché doit être réel ». Le CTA est toujours un verbe d'action
concret (« Commander », jamais « Découvrir » ou « En savoir plus »).
**Ce que je refuse de copier** : Bolt est un service de dispatch (on réserve
un chauffeur) — toute sa grammaire d'interface (suivi live du chauffeur, chat,
notation) répond à un besoin que Transit CI n'a pas et ne doit pas simuler
(rappel du brief produit : VTC/taxi/moto restent des estimations de prix, pas
une réservation).

### 5. Signalétique physique des gares routières ivoiriennes (Adjamé,
Anonkoua-Kouté) — référence hors-écran, mais réelle
**Ce que je retiens** : ce n'est pas une référence numérique mais c'est la
plus pertinente culturellement. Les gares routières ivoiriennes utilisent des
panneaux peints à la main, des numéros de quai, et le ticket papier physique
perforé/découpé comme objet de confiance (preuve d'achat, numéro de place).
C'est la source du motif signature retenu dans `DESIGN.md` (la forme
« billet à encoche »), documentée dans nos propres notes de recherche
(`research_notes/Transport rural Côte Ivoire*/`).
**Ce que je refuse de copier** : l'aspect visuel désordonné/dégradé de
certaines gares (manque d'infrastructure, documenté dans la recherche
round 2) — on garde le principe du ticket, pas le niveau de finition
physique réel.

## Principe de méthode

Pour chaque référence : j'extrais un *principe d'interaction ou de
hiérarchie*, jamais une palette, une police ou une mise en page complète.
Rien dans Transit CI ne doit être la copie reconnaissable d'une de ces
applications.
