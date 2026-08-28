import 'package:mechanical_engineering_toolkit/help/tool_help.dart';

/// French tool explanations.
///
/// Equations, symbol glyphs and units stay untranslated — they are the same
/// notation on a drawing in any language. References stay in English because
/// they are citations: a reader looking the book up needs the title it was
/// published under.
const Map<int, ToolHelp> toolHelpFr = {
  100: ToolHelp(
    summary: 'Contrainte et déformation uniaxiales dans une barre prismatique '
        'sollicitée axialement. La contrainte normale est la charge répartie '
        'sur la section résistante, et la déformation en découle par la loi de '
        'Hooke tant que le matériau reste élastique. C\'est le point de départ '
        'de tout autre calcul de contrainte : tirant, suspente, boulon en '
        'traction pure.',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{P}{A}',
        plain: 'σ = P / A',
        caption: 'Contrainte normale',
      ),
      HelpFormula(
        tex: r'\varepsilon = \frac{\sigma}{E} = \frac{\delta}{L}',
        plain: 'ε = σ / E = δ / L',
        caption: 'Déformation dans le domaine élastique',
      ),
    ],
    symbols: [
      HelpSymbol('σ', 'Contrainte normale', 'MPa'),
      HelpSymbol('P', 'Effort axial, traction positive', 'N'),
      HelpSymbol('A', 'Aire de la section', 'mm²'),
      HelpSymbol('E', 'Module de Young', 'MPa'),
      HelpSymbol('ε', 'Déformation normale'),
    ],
    notes: [
      'Suppose une contrainte uniforme sur la section, ce qui est vrai loin '
          'des points d\'application, des trous et des changements de section '
          '— le principe de Saint-Venant. À proximité, attendez-vous à une '
          'concentration de contrainte que cette formule ne montre pas.',
      'Domaine élastique seulement : dès que σ dépasse la limite de '
          'proportionnalité, ε = σ/E cesse d\'être vrai et la barre garde une '
          'déformation permanente.',
      'Une pièce élancée en compression flambe bien avant d\'atteindre cette '
          'contrainte. Vérifiez-la aussi avec l\'outil de flambement.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 1–3',
      'Gere & Goodno, Mechanics of Materials, ch. 1',
    ],
    diagram: 'images/icon_bar_force.png',
  ),
  101: ToolHelp(
    summary: 'Allongement axial d\'une barre prismatique et la raideur qui va '
        'avec. La barre se comporte comme un ressort linéaire de raideur AE/L, '
        'ce qui fait de cette relation la brique de base des assemblages '
        'boulonnés, des systèmes de tirants et de toute structure résolue en '
        'combinant des raideurs.',
    formulas: [
      HelpFormula(
        tex: r'\delta = \frac{PL}{AE}',
        plain: 'δ = P·L / (A·E)',
        caption: 'Allongement',
      ),
      HelpFormula(
        tex: r'k = \frac{AE}{L}',
        plain: 'k = A·E / L',
        caption: 'Raideur axiale',
      ),
    ],
    symbols: [
      HelpSymbol('δ', 'Allongement, positif en traction', 'mm'),
      HelpSymbol('P', 'Effort axial', 'N'),
      HelpSymbol('L', 'Longueur initiale', 'mm'),
      HelpSymbol('A', 'Aire de la section', 'mm²'),
      HelpSymbol('E', 'Module de Young', 'MPa'),
      HelpSymbol('k', 'Raideur axiale', 'N/mm'),
    ],
    notes: [
      'Valable pour une barre prismatique où P, A et E sont constants sur la '
          'longueur. Pour une barre étagée ou conique, ou qui porte son propre '
          'poids, la découper en tronçons et additionner les allongements.',
      'Théorie linéaire élastique en petites déformations. δ est calculé sur '
          'la longueur initiale, pas sur la longueur déformée.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 4',
      'Gere & Goodno, Mechanics of Materials, ch. 2',
    ],
    diagram: 'images/bar_force_displacement.png',
  ),
  103: ToolHelp(
    summary: 'Contrainte de cisaillement dans un arbre circulaire en torsion '
        'pure. La contrainte croît linéairement de zéro sur l\'axe à son '
        'maximum en surface : un arbre creux transmet donc presque autant de '
        'couple qu\'un arbre plein de même diamètre extérieur, pour un poids '
        'bien moindre.',
    formulas: [
      HelpFormula(
        tex: r'\tau = \frac{T\rho}{J}',
        plain: 'τ = T·ρ / J',
        caption: 'Contrainte de cisaillement au rayon ρ',
      ),
      HelpFormula(
        tex: r'J_{\text{solid}} = \frac{\pi d^4}{32}, \quad '
            r'J_{\text{hollow}} = \frac{\pi (d_o^4 - d_i^4)}{32}',
        plain: 'J = π·d⁴/32 (plein), J = π·(do⁴ − di⁴)/32 (creux)',
        caption: 'Moment quadratique polaire',
      ),
    ],
    symbols: [
      HelpSymbol('τ', 'Contrainte de cisaillement', 'MPa'),
      HelpSymbol('T', 'Couple appliqué', 'N·mm'),
      HelpSymbol('ρ', 'Rayon du point considéré', 'mm'),
      HelpSymbol('J', 'Moment quadratique polaire', 'mm⁴'),
    ],
    notes: [
      'Sections circulaires uniquement. Une section non circulaire se gauchit '
          'hors plan en torsion, et cette formule ne s\'y applique pas du tout '
          '— les barres carrées et rectangulaires ont leurs propres constantes '
          'de torsion.',
      'Élastique linéaire et torsion pure. La flexion combinée à la torsion '
          'passe par l\'outil de sollicitation combinée, puis par un critère '
          'de ruine.',
      'Exprimer T en N·mm lorsque les autres grandeurs sont en mm et MPa.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 5',
      'Gere & Goodno, Mechanics of Materials, ch. 3',
    ],
    diagram: 'images/icon_bar_torsion.png',
  ),
  114: ToolHelp(
    summary: 'De combien une extrémité d\'arbre tourne par rapport à l\'autre '
        'sous couple. L\'angle de torsion décide si une transmission paraît '
        'raide, si une barre de torsion donne la raideur voulue, et comment le '
        'couple se répartit entre chemins parallèles dans un système '
        'hyperstatique.',
    formulas: [
      HelpFormula(
        tex: r'\phi = \frac{TL}{GJ}',
        plain: 'φ = T·L / (G·J)',
        caption: 'Angle de torsion, en radians',
      ),
      HelpFormula(
        tex: r'k_t = \frac{GJ}{L}',
        plain: 'kt = G·J / L',
        caption: 'Raideur en torsion',
      ),
    ],
    symbols: [
      HelpSymbol('φ', 'Angle de torsion', 'rad'),
      HelpSymbol('T', 'Couple appliqué', 'N·mm'),
      HelpSymbol('L', 'Longueur sur laquelle la torsion s\'accumule', 'mm'),
      HelpSymbol('G', 'Module de cisaillement', 'MPa'),
      HelpSymbol('J', 'Moment quadratique polaire', 'mm⁴'),
    ],
    notes: [
      'Arbres circulaires prismatiques à T, G et J constants. Additionner les '
          'angles de chaque tronçon dès que l\'une de ces grandeurs change.',
      'G n\'est pas indépendant de E : pour un matériau isotrope '
          'G = E / [2(1 + ν)], soit environ 0,385·E pour l\'acier.',
      'Le résultat est en radians. Multiplier par 180/π pour des degrés.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 5',
      'Shigley, Mechanical Engineering Design, ch. 3',
    ],
    diagram: 'images/icon_bar_torsion.png',
  ),
  115: ToolHelp(
    summary: 'Le couple transmis par un arbre en rotation pour une puissance '
        'et une vitesse données, ou la puissance délivrée par un couple connu. '
        'Tout dimensionnement d\'arbre commence ici : la plaque du moteur '
        'donne la puissance et la vitesse, et l\'arbre doit être calculé pour '
        'le couple qui en découle.',
    formulas: [
      HelpFormula(
        tex: r'P = T\omega, \quad \omega = \frac{2\pi n}{60}',
        plain: 'P = T·ω, ω = 2π·n / 60',
        caption: 'Puissance à partir du couple et de la vitesse',
      ),
      HelpFormula(
        tex: r'T = \frac{9549\,P_{\text{kW}}}{n}',
        plain: 'T [N·m] = 9549 · P [kW] / n [rpm]',
        caption: 'Forme pratique',
      ),
    ],
    symbols: [
      HelpSymbol('P', 'Puissance transmise', 'W'),
      HelpSymbol('T', 'Couple', 'N·m'),
      HelpSymbol('ω', 'Vitesse angulaire', 'rad/s'),
      HelpSymbol('n', 'Vitesse de rotation', 'rpm'),
    ],
    notes: [
      'C\'est le couple transmis en régime établi. Les couples de démarrage, '
          'de freinage et de blocage peuvent être plusieurs fois supérieurs — '
          'appliquer un facteur de service avant de dimensionner l\'arbre.',
      'Puissance entrante, puissance sortante : les pertes d\'une '
          'transmission se prennent en compte séparément en divisant par son '
          'rendement.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 7',
      'Hibbeler, Mechanics of Materials, ch. 5',
    ],
  ),
  109: ToolHelp(
    summary: 'Contrainte membranaire dans la paroi d\'un réservoir sphérique '
        'mince sous pression. La sphère est la forme la plus efficace pour '
        'contenir une pression : la contrainte est la même dans toutes les '
        'directions et vaut la moitié de la contrainte circonférentielle d\'un '
        'cylindre de même rayon et même épaisseur.',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{pr}{2t}',
        plain: 'σ = p·r / (2·t)',
        caption: 'Contrainte membranaire, identique dans toutes les directions',
      ),
    ],
    symbols: [
      HelpSymbol('σ', 'Contrainte membranaire', 'MPa'),
      HelpSymbol('p', 'Pression intérieure relative', 'MPa'),
      HelpSymbol('r', 'Rayon intérieur', 'mm'),
      HelpSymbol('t', 'Épaisseur de paroi', 'mm'),
    ],
    notes: [
      'Théorie des parois minces, valable tant que r/t dépasse environ 10. '
          'En deçà, la contrainte varie dans l\'épaisseur et il faut une '
          'solution de paroi épaisse (Lamé).',
      'Contraintes membranaires seulement. Les piquages, les supports et le '
          'raccordement à toute autre forme élèvent les contraintes locales '
          'bien au-dessus, et c\'est à cela que les codes d\'appareils à '
          'pression consacrent leurs pages.',
      'Un calcul selon un code tel qu\'ASME VIII ajoute un coefficient de '
          'soudure et une surépaisseur de corrosion ; il n\'y a ici que la '
          'mécanique brute.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 8',
      'ASME BPVC Section VIII, Division 1, UG-27',
    ],
    diagram: 'images/icon_spherical_shell_stress.png',
  ),
  110: ToolHelp(
    summary: 'Contraintes membranaires circonférentielle et longitudinale dans '
        'un cylindre mince sous pression intérieure. La contrainte '
        'circonférentielle vaut le double de la longitudinale, ce qui explique '
        'qu\'un tube sous pression se fende dans sa longueur et non sur sa '
        'circonférence.',
    formulas: [
      HelpFormula(
        tex: r'\sigma_h = \frac{pr}{t}',
        plain: 'σh = p·r / t',
        caption: 'Contrainte circonférentielle',
      ),
      HelpFormula(
        tex: r'\sigma_l = \frac{pr}{2t}',
        plain: 'σl = p·r / (2·t)',
        caption: 'Contrainte longitudinale (axiale)',
      ),
    ],
    symbols: [
      HelpSymbol('σh', 'Contrainte circonférentielle', 'MPa'),
      HelpSymbol('σl', 'Contrainte longitudinale', 'MPa'),
      HelpSymbol('p', 'Pression intérieure relative', 'MPa'),
      HelpSymbol('r', 'Rayon intérieur', 'mm'),
      HelpSymbol('t', 'Épaisseur de paroi', 'mm'),
    ],
    notes: [
      'Théorie des parois minces, valable tant que r/t dépasse environ 10.',
      'Ces deux contraintes sont les contraintes principales dans la paroi, '
          'la troisième étant à peu près nulle. Les passer à l\'outil de '
          'critères de ruine donne une contrainte équivalente.',
      'La contrainte longitudinale n\'existe que si le cylindre est fermé. Un '
          'tube ouvert retenu autrement supporte une autre charge axiale.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 8',
      'ASME BPVC Section VIII, Division 1, UG-27',
    ],
    diagram: 'images/icon_cylindrical_pressure_stress.png',
  ),
  107: ToolHelp(
    summary: 'Fait tourner un état de contrainte plane vers n\'importe quel '
        'autre repère. Le même état physique se lit différemment selon le plan '
        'considéré, et la transformation sert justement à trouver la '
        'contrainte sur une soudure, un joint collé ou une direction de fibres '
        'qui n\'est pas alignée avec la pièce.',
    formulas: [
      HelpFormula(
        tex: r'\sigma_{x\prime} = \frac{\sigma_x+\sigma_y}{2} + '
            r'\frac{\sigma_x-\sigma_y}{2}\cos 2\theta + \tau_{xy}\sin 2\theta',
        plain: 'σx\' = (σx+σy)/2 + (σx−σy)/2·cos2θ + τxy·sin2θ',
      ),
      HelpFormula(
        tex: r'\tau_{x\prime y\prime} = -\frac{\sigma_x-\sigma_y}{2}'
            r'\sin 2\theta + \tau_{xy}\cos 2\theta',
        plain: 'τx\'y\' = −(σx−σy)/2·sin2θ + τxy·cos2θ',
      ),
    ],
    symbols: [
      HelpSymbol('σx, σy', 'Contraintes normales dans le repère initial',
          'MPa'),
      HelpSymbol('τxy', 'Contrainte de cisaillement dans le repère initial',
          'MPa'),
      HelpSymbol('θ', 'Rotation vers le nouveau repère, positive dans le sens '
          'trigonométrique', '°'),
    ],
    notes: [
      'Contrainte plane : la troisième contrainte principale est nulle. Bon '
          'modèle pour une plaque mince chargée dans son plan, mauvais au cœur '
          'd\'un corps épais.',
      'Convention de signes : contrainte normale de traction positive, et '
          'cisaillement positif lorsqu\'il agit sur la face +x dans la '
          'direction +y. Une erreur de signe ici est la cause habituelle d\'un '
          'résultat faux.',
      'Les angles sont doublés dans la transformation, ce que trace justement '
          'le cercle de Mohr — les mêmes relations, vues géométriquement.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 9',
      'Gere & Goodno, Mechanics of Materials, ch. 7',
    ],
    diagram: 'images/icon_stress_element_inclined.png',
  ),
  108: ToolHelp(
    summary: 'Les contraintes normales extrêmes en un point et les plans sur '
        'lesquels elles agissent. La plupart des critères de ruine s\'écrivent '
        'en contraintes principales, si bien que cette étape se situe '
        'généralement entre l\'analyse des contraintes et le coefficient de '
        'sécurité.',
    formulas: [
      HelpFormula(
        tex: r'\sigma_{1,2} = \frac{\sigma_x+\sigma_y}{2} \pm '
            r'\sqrt{\left(\frac{\sigma_x-\sigma_y}{2}\right)^2 + \tau_{xy}^2}',
        plain: 'σ1,2 = (σx+σy)/2 ± √[ ((σx−σy)/2)² + τxy² ]',
        caption: 'Contraintes principales',
      ),
      HelpFormula(
        tex: r'\tan 2\theta_p = \frac{2\tau_{xy}}{\sigma_x-\sigma_y}',
        plain: 'tan2θp = 2·τxy / (σx − σy)',
        caption: 'Orientation des plans principaux',
      ),
      HelpFormula(
        tex: r'\tau_{\max} = \frac{\sigma_1-\sigma_2}{2}',
        plain: 'τmax = (σ1 − σ2) / 2',
        caption: 'Cisaillement maximal dans le plan',
      ),
    ],
    symbols: [
      HelpSymbol('σ1, σ2', 'Contraintes principales, σ1 ≥ σ2', 'MPa'),
      HelpSymbol('θp', 'Angle de x au plan de σ1', '°'),
      HelpSymbol('τmax', 'Cisaillement maximal dans le plan', 'MPa'),
    ],
    notes: [
      'Il n\'y a pas de cisaillement sur un plan principal — c\'est ce qui le '
          'définit.',
      'En contrainte plane, la troisième contrainte principale est nulle, et '
          'elle peut malgré tout être la plus petite des trois. Le vrai '
          'cisaillement maximal vaut (σmax − σmin)/2 sur les trois, et il '
          'dépasse la valeur dans le plan dès que σ1 et σ2 sont de même signe.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 9',
      'Boresi & Schmidt, Advanced Mechanics of Materials, ch. 2',
    ],
    diagram: 'images/icon_stress_element.png',
  ),
  118: ToolHelp(
    summary: 'Le cercle de Mohr est la transformation des contraintes traduite '
        'en géométrie. Chaque plan passant par le point correspond à un point '
        'du cercle, dont le centre est la contrainte normale moyenne et le '
        'rayon le cisaillement maximal dans le plan : contraintes principales '
        'et orientation se lisent d\'un coup d\'œil.',
    formulas: [
      HelpFormula(
        tex: r'C = \frac{\sigma_x+\sigma_y}{2}, \quad '
            r'R = \sqrt{\left(\frac{\sigma_x-\sigma_y}{2}\right)^2+\tau_{xy}^2}',
        plain: 'C = (σx+σy)/2, R = √[ ((σx−σy)/2)² + τxy² ]',
        caption: 'Centre et rayon',
      ),
      HelpFormula(
        tex: r'\sigma_{1,2} = C \pm R, \quad \tau_{\max} = R',
        plain: 'σ1,2 = C ± R, τmax = R',
      ),
    ],
    symbols: [
      HelpSymbol('C', 'Centre du cercle, la contrainte normale moyenne', 'MPa'),
      HelpSymbol('R', 'Rayon du cercle, le cisaillement maximal dans le plan',
          'MPa'),
      HelpSymbol('σx, σy, τxy', 'L\'état de contrainte tracé', 'MPa'),
    ],
    notes: [
      'Un tour complet sur le cercle correspond à une rotation de 180° de '
          'l\'élément physique : les angles sur le cercle valent le double des '
          'angles réels.',
      'Contrainte plane uniquement. Un état tridimensionnel complet se trace '
          'en trois cercles, et c\'est le plus extérieur qui gouverne le '
          'cisaillement maximal.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 9',
      'Gere & Goodno, Mechanics of Materials, ch. 7',
    ],
    diagram: 'images/icon_stress_element_inclined.png',
  ),
  116: ToolHelp(
    summary: 'Ramène un état de contrainte plan à une seule contrainte '
        'équivalente comparable à la limite d\'élasticité. Von Mises (énergie '
        'de distorsion) est le choix courant pour les métaux ductiles ; Tresca '
        '(cisaillement maximal) est un peu plus conservatif et reste utilisé '
        'par plusieurs codes d\'appareils à pression.',
    formulas: [
      HelpFormula(
        tex: r'\sigma_{VM} = \sqrt{\sigma_1^2 - \sigma_1\sigma_2 + \sigma_2^2}',
        plain: 'σVM = √(σ1² − σ1·σ2 + σ2²)',
        caption: 'Von Mises, contrainte plane',
      ),
      HelpFormula(
        tex: r'\sigma_{Tresca} = |\sigma_1 - \sigma_2|',
        plain: 'σTresca = |σ1 − σ2|',
        caption: 'Contrainte équivalente de Tresca',
      ),
      HelpFormula(
        tex: r'n = \frac{S_y}{\sigma_{eq}}',
        plain: 'n = Sy / σeq',
        caption: 'Coefficient de sécurité vis-à-vis de la limite élastique',
      ),
    ],
    symbols: [
      HelpSymbol('σ1, σ2', 'Contraintes principales', 'MPa'),
      HelpSymbol('σVM', 'Contrainte équivalente de von Mises', 'MPa'),
      HelpSymbol('Sy', 'Limite d\'élasticité', 'MPa'),
      HelpSymbol('n', 'Coefficient de sécurité'),
    ],
    notes: [
      'Les deux critères prédisent la plastification des matériaux ductiles. '
          'Les matériaux fragiles rompent plutôt selon la contrainte '
          'principale maximale ou un critère de Mohr–Coulomb, et appliquer von '
          'Mises à la fonte induit en erreur.',
      'Tresca est le plus conservatif des deux, d\'au plus 15% environ : les '
          'deux coïncident en traction simple et s\'écartent le plus en '
          'cisaillement pur.',
      'Plastification statique seulement. Une charge variable demande un '
          'critère de fatigue.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 5',
      'Hibbeler, Mechanics of Materials, ch. 10',
    ],
  ),
  119: ToolHelp(
    summary: 'Coefficient de sécurité d\'une pièce soumise à une contrainte '
        'variable de moyenne non nulle, selon le critère de Goodman modifié. '
        'Une contrainte moyenne de traction aggrave la fatigue plus que '
        'l\'amplitude seule ne le laisse penser, et Goodman est la façon '
        'standard, légèrement conservative, d\'en tenir compte.',
    formulas: [
      HelpFormula(
        tex: r'\frac{\sigma_a}{S_e} + \frac{\sigma_m}{S_{ut}} = \frac{1}{n}',
        plain: 'σa/Se + σm/Sut = 1/n',
        caption: 'Droite de Goodman modifiée',
      ),
      HelpFormula(
        tex: r'\sigma_a = \frac{\sigma_{\max}-\sigma_{\min}}{2}, \quad '
            r'\sigma_m = \frac{\sigma_{\max}+\sigma_{\min}}{2}',
        plain: 'σa = (σmax − σmin)/2, σm = (σmax + σmin)/2',
        caption: 'Composantes alternée et moyenne',
      ),
    ],
    symbols: [
      HelpSymbol('σa', 'Amplitude de contrainte alternée', 'MPa'),
      HelpSymbol('σm', 'Contrainte moyenne', 'MPa'),
      HelpSymbol('Se', 'Limite d\'endurance corrigée', 'MPa'),
      HelpSymbol('Sut', 'Résistance à la traction', 'MPa'),
      HelpSymbol('n', 'Coefficient de sécurité en fatigue'),
    ],
    notes: [
      'Laisser Se vide revient à prendre 0,5·Sut, première estimation '
          'habituelle pour l\'acier. C\'est une valeur non corrigée : un '
          'calcul réel la multiplie par les facteurs de Marin (état de '
          'surface, taille, type de chargement, température, fiabilité), qui '
          'la réduisent typiquement de moitié encore.',
      'Les métaux non ferreux et l\'aluminium n\'ont pas de vraie limite '
          'd\'endurance — ils s\'affaiblissent indéfiniment avec les cycles, '
          'ce qui impose un calcul à durée de vie finie plutôt que celui-ci.',
      'Une contrainte moyenne de compression n\'est pas dommageable de la '
          'même façon. Appliquer Goodman à un σm négatif devient conservatif '
          'au point d\'être faux ; prendre σm = 0 dans ce cas.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 6',
      'Norton, Machine Design, ch. 6',
    ],
  ),
  112: ToolHelp(
    summary: 'Dilatation thermique libre d\'une barre, et contrainte qui '
        'apparaît lorsque cette dilatation est empêchée. Une pièce totalement '
        'bridée développe une contrainte qui ne dépend que du matériau et de '
        'l\'écart de température — ni de sa longueur ni de sa section, ce qui '
        'explique que les longues tuyauteries aient besoin de lyres de '
        'dilatation plutôt que de parois plus épaisses.',
    formulas: [
      HelpFormula(
        tex: r'\delta_T = \alpha \, \Delta T \, L',
        plain: 'δT = α · ΔT · L',
        caption: 'Dilatation libre',
      ),
      HelpFormula(
        tex: r'\sigma_T = -E \alpha \, \Delta T',
        plain: 'σT = −E · α · ΔT',
        caption: 'Contrainte si le bridage est total',
      ),
    ],
    symbols: [
      HelpSymbol('δT', 'Variation libre de longueur', 'mm'),
      HelpSymbol('α', 'Coefficient de dilatation thermique', '1/°C'),
      HelpSymbol('ΔT', 'Variation de température', '°C'),
      HelpSymbol('L', 'Longueur initiale', 'mm'),
      HelpSymbol('σT', 'Contrainte thermique, compression à l\'échauffement',
          'MPa'),
    ],
    notes: [
      'La contrainte de bridage est indépendante de L et de A. Renforcer la '
          'pièce ne la réduit pas — seul le fait de laisser du mouvement, ou '
          'de diminuer ΔT, y parvient.',
      'Le bridage total est le cas le plus défavorable. Un bridage partiel '
          'donne une contrainte comprise entre zéro et cette valeur, '
          'proportionnellement au déplacement empêché.',
      'α varie avec la température ; sur une large plage, utiliser une valeur '
          'moyenne sur l\'intervalle plutôt que la valeur à température '
          'ambiante.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 4',
      'Gere & Goodno, Mechanics of Materials, ch. 2',
    ],
  ),
  111: ToolHelp(
    summary: 'La charge axiale à laquelle une colonne élancée cesse d\'être '
        'stable et se dérobe latéralement. Le flambement est une ruine de '
        'raideur et non de résistance : la charge critique dépend de E et de '
        'I, et à peine de la résistance du matériau. Une longue colonne peut '
        'flamber à une fraction de la charge qui la ferait plastifier.',
    formulas: [
      HelpFormula(
        tex: r'P_{cr} = \frac{\pi^2 EI}{(KL)^2}',
        plain: 'Pcr = π²·E·I / (K·L)²',
        caption: 'Charge critique d\'Euler',
      ),
      HelpFormula(
        tex: r'\sigma_{cr} = \frac{P_{cr}}{A}, \quad '
            r'\lambda = \frac{KL}{r}, \quad r = \sqrt{\frac{I}{A}}',
        plain: 'σcr = Pcr / A, λ = K·L / r, r = √(I/A)',
        caption: 'Contrainte critique et élancement',
      ),
    ],
    symbols: [
      HelpSymbol('Pcr', 'Charge critique de flambement (Euler)', 'N'),
      HelpSymbol('E', 'Module de Young', 'MPa'),
      HelpSymbol('I', 'Plus petit moment quadratique', 'mm⁴'),
      HelpSymbol('K', 'Coefficient de longueur de flambement, fixé par les '
          'liaisons'),
      HelpSymbol('L', 'Longueur non maintenue', 'mm'),
      HelpSymbol('λ', 'Élancement'),
    ],
    notes: [
      'Utiliser le plus petit I de la section : une colonne flambe autour de '
          'son axe le plus faible, quelle que soit la direction attendue.',
      'K théorique vaut 1,0 en rotulé–rotulé, 0,5 en encastré–encastré, 0,7 '
          'en encastré–rotulé et 2,0 en encastré–libre. Les codes recommandent '
          'des valeurs plus grandes, car les liaisons réelles ne sont jamais '
          'parfaitement encastrées.',
      'Euler ne vaut que pour les colonnes élancées. Dès que σcr dépasse '
          'environ la moitié de la limite d\'élasticité, le flambement '
          'inélastique prend le relais et il faut une parabole de Johnson ou '
          'une courbe de flambement de code.',
      'Suppose une colonne parfaitement droite chargée au centre. Le défaut '
          'de rectitude et l\'excentricité réels réduisent la capacité, ce que '
          'couvrent les coefficients de sécurité des codes.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 13',
      'AISC Steel Construction Manual, ch. E',
    ],
    diagram: 'images/buckling/icon_buckling_pinned_pinned.png',
  ),
  120: ToolHelp(
    summary: 'Les trois modes de ruine d\'un assemblage boulonné ou riveté à '
        'recouvrement, dans la tôle et dans la fixation : cisaillement du '
        'boulon, matage de la tôle contre le boulon, et déchirure de la tôle '
        'jusqu\'au bord libre. Les trois sont vérifiés ensemble, car un '
        'assemblage ne vaut que par son mode le plus faible.',
    formulas: [
      HelpFormula(
        tex: r'\tau = \frac{P}{n\,m\,\frac{\pi d^2}{4}}',
        plain: 'τ = P / (n·m·π·d²/4)',
        caption: 'Cisaillement du boulon ; m = 1 simple, 2 double',
      ),
      HelpFormula(
        tex: r'\sigma_b = \frac{P}{n\,d\,t}',
        plain: 'σb = P / (n·d·t)',
        caption: 'Contrainte de matage sur l\'aire projetée',
      ),
      HelpFormula(
        tex: r'\tau_{to} = \frac{P}{2n\left(e-\frac{d}{2}\right)t}',
        plain: 'τto = P / [2·n·(e − d/2)·t]',
        caption: 'Déchirure selon deux plans de cisaillement vers le bord',
      ),
    ],
    symbols: [
      HelpSymbol('P', 'Charge sur l\'assemblage', 'N'),
      HelpSymbol('n', 'Nombre de fixations'),
      HelpSymbol('m', 'Plans de cisaillement par fixation : 1 ou 2'),
      HelpSymbol('d', 'Diamètre de la fixation', 'mm'),
      HelpSymbol('t', 'Tôle assemblée la plus mince', 'mm'),
      HelpSymbol('e', 'Pince, du centre du trou au bord libre', 'mm'),
    ],
    notes: [
      'Assemblage travaillant en pression diamétrale : la charge passe par '
          'les fixations en appui sur les trous, non par frottement. Un '
          'assemblage résistant au glissement se calcule sur la précontrainte '
          'et le frottement, et ces valeurs ne le gouvernent pas.',
      'Suppose une répartition égale de la charge entre fixations. C\'est '
          'raisonnable pour un groupe court et compact, optimiste pour une '
          'longue file de boulons, où les extrémités prennent davantage.',
      'La traction dans la section nette de la tôle est un quatrième mode de '
          'ruine, non vérifié ici — retrancher l\'aire du trou et le contrôler '
          'à part.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 8',
      'AISC Steel Construction Manual, ch. J3',
    ],
  ),
  121: ToolHelp(
    summary: 'Combine effort axial, flexion et torsion agissant au même point '
        'en une contrainte normale et une contrainte de cisaillement. La '
        'superposition est valable tant que tout reste élastique linéaire, et '
        'le couple de valeurs obtenu est exactement ce qu\'attend un critère '
        'de ruine.',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{P}{A} + \frac{Mc}{I}',
        plain: 'σ = P/A + M·c/I',
        caption: 'Contrainte normale : effort axial plus flexion',
      ),
      HelpFormula(
        tex: r'\tau = \frac{Tr}{J}',
        plain: 'τ = T·r / J',
        caption: 'Cisaillement dû à la torsion',
      ),
    ],
    symbols: [
      HelpSymbol('P', 'Effort axial, traction positive', 'N'),
      HelpSymbol('A', 'Aire de la section', 'mm²'),
      HelpSymbol('M', 'Moment de flexion', 'N·mm'),
      HelpSymbol('c', 'Distance de l\'axe neutre au point', 'mm'),
      HelpSymbol('I', 'Moment quadratique autour de l\'axe de flexion', 'mm⁴'),
      HelpSymbol('T', 'Couple', 'N·mm'),
      HelpSymbol('r', 'Rayon jusqu\'au point', 'mm'),
      HelpSymbol('J', 'Moment quadratique polaire', 'mm⁴'),
    ],
    notes: [
      'La superposition suppose l\'élasticité linéaire et de petits '
          'déplacements. Une pièce élancée en compression reçoit en plus un '
          'moment dû à la flèche elle-même (effet P–δ), non pris en compte '
          'ici.',
      'Le cisaillement transversal dû à la flexion est distinct et maximal sur '
          'l\'axe neutre, là où la contrainte de flexion est nulle. Vérifier '
          'les deux points, pas seulement la fibre extrême.',
      'Exprimer les moments en N·mm, en cohérence avec les mm et les MPa.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 8',
      'Shigley, Mechanical Engineering Design, ch. 3',
    ],
  ),

  102: ToolHelp(
    summary: 'Moments quadratiques des sections usuelles, autour des axes '
        'centraux. I est la grandeur géométrique qui fixe la raideur en '
        'flexion d\'une section et le niveau de contrainte sous un moment '
        'donné — c\'est elle qui rend un profilé en I efficace et un plat qui '
        'ne l\'est pas.',
    formulas: [
      HelpFormula(
        tex: r'I_x = \frac{bh^3}{12}, \quad I_y = \frac{hb^3}{12}',
        plain: 'Ix = b·h³/12, Iy = h·b³/12',
        caption: 'Rectangle, autour de son centre de gravité',
      ),
      HelpFormula(
        tex: r'I = \frac{\pi d^4}{64}',
        plain: 'I = π·d⁴/64',
        caption: 'Cercle plein',
      ),
      HelpFormula(
        tex: r'I = I_c + Ad^2',
        plain: 'I = Ic + A·d²',
        caption: 'Théorème de Huygens, pour passer à un autre axe',
      ),
    ],
    symbols: [
      HelpSymbol('I', 'Moment quadratique', 'mm⁴'),
      HelpSymbol('b, h', 'Largeur et hauteur', 'mm'),
      HelpSymbol('A', 'Aire', 'mm²'),
      HelpSymbol('d', 'Distance entre les deux axes parallèles', 'mm'),
    ],
    notes: [
      'La hauteur intervient au cube : elle achète donc de la raideur bien '
          'plus vite que la largeur. Doubler h multiplie Ix par huit, doubler '
          'b seulement par deux.',
      'Le théorème de Huygens ne fait le lien qu\'entre un axe passant par le '
          'centre de gravité et un axe qui lui est parallèle. Pour passer '
          'entre deux axes non centraux, il faut repasser par le centre de '
          'gravité.',
      'Ce sont des moments quadratiques d\'aire, en mm⁴ — et non les moments '
          'd\'inertie de la dynamique, qui sont en kg·m².',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix A',
      'Gere & Goodno, Mechanics of Materials, ch. 12',
    ],
    diagram: 'images/cross_section/icon_cs_rectangle.png',
  ),
  117: ToolHelp(
    summary: 'Centre de gravité, aire, moments quadratiques, ainsi que les '
        'modules de flexion et rayons de giration qui en découlent. Ce sont '
        'les grandeurs dont a besoin tout calcul de poutre et de poteau, et '
        'les obtenir ensemble garantit leur cohérence mutuelle.',
    formulas: [
      HelpFormula(
        tex: r'\bar{y} = \frac{\sum A_i \bar{y}_i}{\sum A_i}',
        plain: 'ȳ = Σ(Ai·ȳi) / Σ Ai',
        caption: 'Centre de gravité d\'une section composée',
      ),
      HelpFormula(
        tex: r'S = \frac{I}{c}, \quad r = \sqrt{\frac{I}{A}}',
        plain: 'S = I / c, r = √(I / A)',
        caption: 'Module de flexion et rayon de giration',
      ),
    ],
    symbols: [
      HelpSymbol('ȳ', 'Position du centre de gravité depuis le bord de '
          'référence', 'mm'),
      HelpSymbol('I', 'Moment quadratique autour de l\'axe central', 'mm⁴'),
      HelpSymbol('S', 'Module de flexion', 'mm³'),
      HelpSymbol('c', 'Distance du centre de gravité à la fibre extrême', 'mm'),
      HelpSymbol('r', 'Rayon de giration', 'mm'),
    ],
    notes: [
      'Le module de flexion sert à dimensionner une poutre en résistance '
          '(σ = M/S) ; le rayon de giration sert à dimensionner un poteau en '
          'stabilité (λ = KL/r).',
      'Pour une section non symétrique par rapport à l\'axe de flexion, c '
          'diffère en haut et en bas : il y a donc deux modules de flexion, et '
          'c\'est le plus petit qui gouverne.',
      'Les propriétés calculées à partir des seules cotes ignorent les congés '
          'de laminage et le métal d\'apport, et restent donc quelques pour '
          'cent en dessous des valeurs publiées d\'un profilé. Pour un profilé '
          'de catalogue, utiliser la bibliothèque de sections normalisées.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix A',
      'AISC Steel Construction Manual, Part 1',
    ],
  ),
  104: ToolHelp(
    summary: 'Contrainte de flexion à n\'importe quelle hauteur d\'une section '
        'de poutre. Elle varie linéairement de zéro sur l\'axe neutre à son '
        'maximum sur la fibre extrême : la matière proche de l\'axe neutre ne '
        'porte presque rien, et les sections efficaces placent leur aire loin '
        'de cet axe.',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{My}{I}',
        plain: 'σ = M·y / I',
        caption: 'Contrainte de flexion à la distance y de l\'axe neutre',
      ),
      HelpFormula(
        tex: r'\sigma_{\max} = \frac{Mc}{I} = \frac{M}{S}',
        plain: 'σmax = M·c / I = M / S',
        caption: 'Sur la fibre extrême',
      ),
    ],
    symbols: [
      HelpSymbol('σ', 'Contrainte de flexion, traction positive', 'MPa'),
      HelpSymbol('M', 'Moment de flexion dans la section', 'N·mm'),
      HelpSymbol('y', 'Distance à l\'axe neutre', 'mm'),
      HelpSymbol('I', 'Moment quadratique autour de l\'axe de flexion', 'mm⁴'),
      HelpSymbol('c', 'Distance à la fibre extrême', 'mm'),
    ],
    notes: [
      'Théorie d\'Euler-Bernoulli : les sections planes restent planes, le '
          'matériau est élastique linéaire, la poutre est droite et '
          'prismatique.',
      'L\'axe neutre ne passe par le centre de gravité que pour la flexion '
          'pure d\'une section homogène. Un effort axial le déplace, et une '
          'section composite demande une analyse en section transformée.',
      'Une flexion autour d\'un axe qui n\'est pas principal est une flexion '
          'déviée, à laquelle cette formule uniaxiale ne s\'applique pas.',
      'Exprimer M en N·mm, en cohérence avec les mm et les MPa.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 6',
      'Gere & Goodno, Mechanics of Materials, ch. 5',
    ],
    diagram: 'images/icon_beam_bending.png',
  ),
  113: ToolHelp(
    summary: 'Contrainte de cisaillement transversal dans une section de '
        'poutre. Elle est maximale sur l\'axe neutre — précisément là où la '
        'contrainte de flexion est nulle — si bien que les deux se vérifient à '
        'des hauteurs différentes. Elle compte surtout pour les poutres '
        'courtes et hautes et pour les âmes minces, où le cisaillement peut '
        'devenir déterminant devant la flexion.',
    formulas: [
      HelpFormula(
        tex: r'\tau = \frac{VQ}{It}',
        plain: 'τ = V·Q / (I·t)',
        caption: 'Cisaillement à la hauteur où Q est pris',
      ),
      HelpFormula(
        tex: r'\tau_{\max} = \frac{3V}{2A} \;\text{(rectangle)}, \quad '
            r'\frac{4V}{3A} \;\text{(circle)}',
        plain: 'τmax = 3V/(2A) rectangle, 4V/(3A) cercle',
        caption: 'Valeurs maximales des sections pleines courantes',
      ),
    ],
    symbols: [
      HelpSymbol('τ', 'Contrainte de cisaillement transversal', 'MPa'),
      HelpSymbol('V', 'Effort tranchant dans la section', 'N'),
      HelpSymbol('Q', 'Moment statique de l\'aire au-delà de la coupure',
          'mm³'),
      HelpSymbol('I', 'Moment quadratique de la section entière', 'mm⁴'),
      HelpSymbol('t', 'Largeur de la section à la coupure', 'mm'),
    ],
    notes: [
      'Q est le moment statique de la seule aire située d\'un côté de la '
          'hauteur vérifiée, pris autour de l\'axe neutre. Il est maximal sur '
          'l\'axe neutre et nul sur les fibres extrêmes.',
      'La formule suppose le cisaillement uniforme sur la largeur t. C\'est '
          'bon pour une âme étroite et mauvais pour une semelle large, où la '
          'distribution réelle varie sur la largeur.',
      'Pour un profilé en I, le raccourci courant — V divisé par l\'aire de '
          'l\'âme — reste à quelques pour cent de la valeur exacte, et c\'est '
          'ce qu\'utilisent les codes.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 7',
      'Gere & Goodno, Mechanics of Materials, ch. 5',
    ],
  ),
  105: ToolHelp(
    summary: 'Flèche et rotation d\'une poutre console pour les cas de charge '
        'usuels, d\'après les solutions analytiques classiques. Pratique pour '
        'un contrôle rapide de raideur, et pour construire des chargements '
        'plus complexes par superposition.',
    formulas: [
      HelpFormula(
        tex: r'\delta_{\max} = \frac{PL^3}{3EI}, \quad '
            r'\theta = \frac{PL^2}{2EI}',
        plain: 'δmax = P·L³/(3·E·I), θ = P·L²/(2·E·I)',
        caption: 'Charge P à l\'extrémité libre',
      ),
      HelpFormula(
        tex: r'\delta_{\max} = \frac{wL^4}{8EI}, \quad '
            r'\theta = \frac{wL^3}{6EI}',
        plain: 'δmax = w·L⁴/(8·E·I), θ = w·L³/(6·E·I)',
        caption: 'Charge répartie w sur toute la longueur',
      ),
    ],
    symbols: [
      HelpSymbol('δ', 'Flèche', 'mm'),
      HelpSymbol('θ', 'Rotation', 'rad'),
      HelpSymbol('P', 'Charge ponctuelle', 'N'),
      HelpSymbol('w', 'Charge répartie', 'N/mm'),
      HelpSymbol('L', 'Portée depuis l\'encastrement', 'mm'),
      HelpSymbol('E·I', 'Rigidité de flexion', 'N·mm²'),
    ],
    notes: [
      'La flèche varie en L³ ou L⁴. Doubler la portée d\'une console chargée '
          'en bout la rend huit fois plus souple — la longueur domine tout le '
          'reste.',
      'Théorie d\'Euler-Bernoulli en petits déplacements, sans déformation de '
          'cisaillement. Ajouter un terme de cisaillement pour une console '
          'trapue, disons L/d inférieur à 10.',
      'Les charges se superposent : pour plusieurs charges simultanées, '
          'additionner les flèches cas par cas.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix C',
      'Roark\'s Formulas for Stress and Strain, Table 8.1',
    ],
    diagram: 'images/cantilever_beam/icon_cantilever_beam.png',
  ),
  106: ToolHelp(
    summary: 'Flèche et rotation d\'une poutre sur deux appuis simples pour '
        'les cas de charge usuels. Les mêmes solutions analytiques que celles '
        'tabulées dans les manuels, pour vérifier rapidement une portée ou '
        'assembler un chargement plus complexe par superposition.',
    formulas: [
      HelpFormula(
        tex: r'\delta_{\max} = \frac{PL^3}{48EI}',
        plain: 'δmax = P·L³/(48·E·I)',
        caption: 'Charge ponctuelle à mi-portée',
      ),
      HelpFormula(
        tex: r'\delta_{\max} = \frac{5wL^4}{384EI}',
        plain: 'δmax = 5·w·L⁴/(384·E·I)',
        caption: 'Charge répartie sur toute la portée',
      ),
    ],
    symbols: [
      HelpSymbol('δ', 'Flèche', 'mm'),
      HelpSymbol('P', 'Charge ponctuelle', 'N'),
      HelpSymbol('w', 'Charge répartie', 'N/mm'),
      HelpSymbol('L', 'Portée entre appuis', 'mm'),
      HelpSymbol('E·I', 'Rigidité de flexion', 'N·mm²'),
    ],
    notes: [
      'Pour une charge ponctuelle excentrée, la flèche maximale ne se trouve '
          'ni sous la charge ni à mi-portée — mais la valeur à mi-portée en '
          'reste à environ 2,5%, ce que les manuels retiennent.',
      'Théorie des petits déplacements, un appui articulé et un appui '
          'glissant, donc sans blocage axial. Une poutre bloquée axialement '
          'aux deux extrémités se raidit en fléchissant, et cette formule '
          'surestime alors le déplacement.',
      'Les limites de service s\'expriment en fraction de la portée — L/360 '
          'sous charge d\'exploitation est courant pour un plancher — plutôt '
          'qu\'en contrainte.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix C',
      'Roark\'s Formulas for Stress and Strain, Table 8.1',
    ],
    diagram: 'images/simple_beam/icon_simple_beam.png',
  ),
  401: ToolHelp(
    summary: 'Réactions d\'appui, effort tranchant et moment de flexion le '
        'long d\'une poutre sur deux appuis simples portant une charge '
        'ponctuelle, une charge répartie, ou les deux. Les diagrammes '
        'indiquent où vérifier la section et avec quel M le faire.',
    formulas: [
      HelpFormula(
        tex: r'\sum F_y = 0, \quad \sum M = 0',
        plain: 'ΣFy = 0, ΣM = 0',
        caption: 'Statique, ce qui fixe les deux réactions',
      ),
      HelpFormula(
        tex: r'V(x) = R_A - \int_0^x w\,dx, \quad M(x) = \int_0^x V\,dx',
        plain: 'V(x) = RA − ∫w dx, M(x) = ∫V dx',
        caption: 'Effort tranchant et moment le long de la portée',
      ),
      HelpFormula(
        tex: r'M_{\max} = \frac{wL^2}{8} \;\text{(UDL)}, \quad '
            r'\frac{PL}{4} \;\text{(central point load)}',
        plain: 'Mmax = w·L²/8 (répartie), P·L/4 (ponctuelle à mi-portée)',
      ),
    ],
    symbols: [
      HelpSymbol('RA, RB', 'Réactions d\'appui', 'N'),
      HelpSymbol('V', 'Effort tranchant', 'N'),
      HelpSymbol('M', 'Moment de flexion', 'N·mm'),
      HelpSymbol('w', 'Charge uniformément répartie', 'N/mm'),
      HelpSymbol('L', 'Portée', 'mm'),
    ],
    notes: [
      'Isostatique uniquement : un appui articulé d\'un côté, glissant de '
          'l\'autre. Une poutre à trois appuis, ou encastrée, est '
          'hyperstatique et demande la compatibilité en plus de l\'équilibre.',
      'Le moment est maximal là où l\'effort tranchant passe par zéro. C\'est '
          'la section à dimensionner, et ce n\'est pas à mi-portée pour une '
          'charge excentrée.',
      'Le poids propre n\'est pas inclus tant qu\'on ne l\'ajoute pas à la '
          'charge répartie.',
    ],
    references: [
      'Hibbeler, Structural Analysis, ch. 4',
      'Gere & Goodno, Mechanics of Materials, ch. 4',
    ],
    diagram: 'images/simple_beam/icon_simple_beam.png',
  ),
  400: ToolHelp(
    summary: 'Additionne des forces concourantes dans un plan en une '
        'résultante unique, avec son module et sa direction. La première étape '
        'de presque tout problème de statique : remplacer un ensemble de '
        'forces par la seule force qui produit le même effet.',
    formulas: [
      HelpFormula(
        tex: r'R_x = \sum F_i\cos\theta_i, \quad R_y = \sum F_i\sin\theta_i',
        plain: 'Rx = Σ Fi·cosθi, Ry = Σ Fi·sinθi',
        caption: 'Composantes',
      ),
      HelpFormula(
        tex: r'R = \sqrt{R_x^2+R_y^2}, \quad '
            r'\theta_R = \operatorname{atan2}(R_y, R_x)',
        plain: 'R = √(Rx² + Ry²), θR = atan2(Ry, Rx)',
        caption: 'Module et direction',
      ),
    ],
    symbols: [
      HelpSymbol('F', 'Module de chaque force', 'N'),
      HelpSymbol('θ', 'Direction de chaque force, depuis l\'axe +x', '°'),
      HelpSymbol('R', 'Module de la résultante', 'N'),
      HelpSymbol('θR', 'Direction de la résultante', '°'),
    ],
    notes: [
      'Forces concourantes seulement — toutes les lignes d\'action se '
          'coupent en un point. Des forces non concourantes produisent aussi '
          'un couple, que l\'on perd en les remplaçant par une force unique '
          'placée au mauvais endroit.',
      'On utilise atan2 plutôt qu\'arctan pour obtenir le bon quadrant : '
          'l\'arctangente seule ne distingue pas 30° de 210°.',
    ],
    references: [
      'Hibbeler, Engineering Mechanics: Statics, ch. 2',
      'Beer & Johnston, Vector Mechanics for Engineers, ch. 2',
    ],
  ),
  402: ToolHelp(
    summary: 'Centre de gravité d\'une aire composée de rectangles, de cercles '
        'et de triangles, trous compris. Le centre de gravité est le point où '
        's\'annule le moment statique de l\'aire, et c\'est l\'axe auquel se '
        'réfère tout calcul de flexion — s\'il est faux, toutes les '
        'contraintes qui suivent le sont aussi.',
    formulas: [
      HelpFormula(
        tex: r'\bar{x} = \frac{\sum A_i \bar{x}_i}{\sum A_i}, \quad '
            r'\bar{y} = \frac{\sum A_i \bar{y}_i}{\sum A_i}',
        plain: 'x̄ = Σ(Ai·x̄i)/ΣAi, ȳ = Σ(Ai·ȳi)/ΣAi',
        caption: 'Moyenne pondérée par les aires',
      ),
    ],
    symbols: [
      HelpSymbol('Ai', 'Aire de chaque partie, négative pour un trou', 'mm²'),
      HelpSymbol('x̄i, ȳi', 'Centre de gravité propre de chaque partie', 'mm'),
      HelpSymbol('x̄, ȳ', 'Centre de gravité de l\'ensemble', 'mm'),
    ],
    notes: [
      'Traiter un trou comme une aire négative avec son propre centre de '
          'gravité. Le calcul s\'en occupe alors sans cas particulier.',
      'Le centre de gravité se trouve sur tout axe de symétrie, ce qui suffit '
          'souvent à écrire une coordonnée sans calcul.',
      'Centre de gravité géométrique et centre de masse ne coïncident que si '
          'la masse volumique est uniforme.',
    ],
    references: [
      'Hibbeler, Engineering Mechanics: Statics, ch. 9',
      'Beer & Johnston, Vector Mechanics for Engineers, ch. 5',
    ],
  ),
  403: ToolHelp(
    summary: 'Résout un treillis plan articulé par la méthode des nœuds : '
        'chaque nœud est un système de forces concourantes en équilibre, si '
        'bien qu\'en avançant de nœud en nœud on obtient tous les efforts dans '
        'les barres. Positif en traction, négatif en compression.',
    formulas: [
      HelpFormula(
        tex: r'\sum F_x = 0, \quad \sum F_y = 0 \;\text{at every joint}',
        plain: 'ΣFx = 0 et ΣFy = 0 à chaque nœud',
        caption: 'Équilibre, deux équations par nœud',
      ),
      HelpFormula(
        tex: r'm + r = 2j',
        plain: 'm + r = 2·j',
        caption: 'Contrôle d\'isostaticité',
      ),
    ],
    symbols: [
      HelpSymbol('m', 'Nombre de barres'),
      HelpSymbol('r', 'Nombre de réactions d\'appui'),
      HelpSymbol('j', 'Nombre de nœuds'),
    ],
    notes: [
      'Suppose des articulations sans frottement et des charges appliquées '
          'uniquement aux nœuds, donc des barres en effort purement axial. '
          'Une charge en travée fléchit aussi la barre, et cette flexion sort '
          'du modèle.',
      'm + r < 2j est un mécanisme et ne tient pas ; m + r > 2j est '
          'hyperstatique et demande les raideurs des barres en plus de '
          'l\'équilibre.',
      'Un treillis isostatique peut malgré tout être instable si la géométrie '
          'est mauvaise — trois réactions concourantes ou parallèles, par '
          'exemple. Le décompte est nécessaire, pas suffisant.',
      'Les barres comprimées doivent aussi être vérifiées au flambement, ce '
          'qui n\'est pas fait ici.',
    ],
    references: [
      'Hibbeler, Structural Analysis, ch. 3',
      'Beer & Johnston, Vector Mechanics for Engineers, ch. 6',
    ],
  ),
  200: ToolHelp(
    summary: 'La loi de Hooke généralisée à trois dimensions pour un matériau '
        'isotrope. Une contrainte dans une direction déforme les deux autres '
        'par le coefficient de Poisson : les six composantes sont donc '
        'couplées et ne peuvent pas être traitées séparément.',
    formulas: [
      HelpFormula(
        tex: r'\varepsilon_x = \frac{1}{E}\left[\sigma_x - '
            r'\nu(\sigma_y+\sigma_z)\right]',
        plain: 'εx = [σx − ν(σy + σz)] / E',
        caption: 'Déformation normale, l\'une des trois',
      ),
      HelpFormula(
        tex: r'\gamma_{xy} = \frac{\tau_{xy}}{G}, \quad '
            r'G = \frac{E}{2(1+\nu)}',
        plain: 'γxy = τxy / G, G = E / [2(1 + ν)]',
        caption: 'Distorsion et relation entre modules',
      ),
    ],
    symbols: [
      HelpSymbol('ε', 'Déformation normale'),
      HelpSymbol('γ', 'Distorsion de l\'ingénieur'),
      HelpSymbol('σ, τ', 'Contraintes normale et de cisaillement', 'MPa'),
      HelpSymbol('E', 'Module de Young', 'MPa'),
      HelpSymbol('ν', 'Coefficient de Poisson'),
      HelpSymbol('G', 'Module de cisaillement', 'MPa'),
    ],
    notes: [
      'Matériau isotrope, homogène, élastique linéaire. Les composites, les '
          'tôles laminées fortement texturées et le bois ne sont rien de tout '
          'cela.',
      'Seuls deux des trois E, G et ν sont indépendants pour un matériau '
          'isotrope, le troisième en découle. Les renseigner tous les trois de '
          'façon incohérente est un bon moyen d\'obtenir un résultat '
          'discrètement faux.',
      'La stabilité thermodynamique impose ν entre −1 et 0,5. Les métaux '
          'réels sont proches de 0,3, et 0,5 signifie incompressible, ce dont '
          'le caoutchouc s\'approche.',
    ],
    references: [
      'Timoshenko & Goodier, Theory of Elasticity, ch. 1',
      'Boresi & Schmidt, Advanced Mechanics of Materials, ch. 3',
    ],
  ),
  201: ToolHelp(
    summary: 'Convertit dans les deux sens entre un état de contrainte '
        'tridimensionnel complet et l\'état de déformation correspondant. La '
        'forme inverse est celle dont a besoin le post-traitement en éléments '
        'finis : le maillage donne des déformations, un critère demande des '
        'contraintes.',
    formulas: [
      HelpFormula(
        tex: r'\sigma_x = \frac{E}{(1+\nu)(1-2\nu)}\left[(1-\nu)'
            r'\varepsilon_x + \nu(\varepsilon_y+\varepsilon_z)\right]',
        plain: 'σx = E/[(1+ν)(1−2ν)] · [(1−ν)εx + ν(εy + εz)]',
        caption: 'Contrainte à partir de la déformation',
      ),
      HelpFormula(
        tex: r'\tau_{xy} = G\gamma_{xy}',
        plain: 'τxy = G · γxy',
        caption: 'Le cisaillement reste découplé',
      ),
    ],
    symbols: [
      HelpSymbol('σ, τ', 'Contraintes normale et de cisaillement', 'MPa'),
      HelpSymbol('ε, γ', 'Déformation normale et distorsion de l\'ingénieur'),
      HelpSymbol('E', 'Module de Young', 'MPa'),
      HelpSymbol('ν', 'Coefficient de Poisson'),
    ],
    notes: [
      'La forme contrainte-à-partir-de-déformation diverge quand ν tend vers '
          '0,5 : le (1 − 2ν) du dénominateur s\'annule, parce qu\'un matériau '
          'incompressible n\'a pas de pression unique pour une déformation '
          'donnée. Les matériaux quasi incompressibles demandent une '
          'formulation mixte.',
      'La distorsion de l\'ingénieur γ vaut le double de la déformation de '
          'cisaillement tensorielle. Mélanger les deux conventions est une '
          'erreur d\'un facteur deux facile à manquer.',
    ],
    references: [
      'Timoshenko & Goodier, Theory of Elasticity, ch. 1',
      'Sadd, Elasticity: Theory, Applications and Numerics, ch. 4',
    ],
  ),
  305: ToolHelp(
    summary: 'Estime la rigidité et la masse volumique d\'un pli '
        'unidirectionnel à partir des propriétés de la fibre et de la matrice. '
        'Dans le sens des fibres, les deux phases se déforment ensemble et la '
        'rigidité se moyenne en volume ; en travers, elles se partagent la '
        'charge et ce sont les souplesses qui se moyennent — d\'où une '
        'rigidité transversale bien plus faible.',
    formulas: [
      HelpFormula(
        tex: r'E_1 = E_f V_f + E_m(1-V_f)',
        plain: 'E1 = Ef·Vf + Em·(1 − Vf)',
        caption: 'Longitudinal — loi des mélanges',
      ),
      HelpFormula(
        tex: r'\frac{1}{E_2} = \frac{V_f}{E_f} + \frac{1-V_f}{E_m}',
        plain: '1/E2 = Vf/Ef + (1 − Vf)/Em',
        caption: 'Transversal — loi des mélanges inverse',
      ),
      HelpFormula(
        tex: r'\nu_{12} = \nu_f V_f + \nu_m(1-V_f)',
        plain: 'ν12 = νf·Vf + νm·(1 − Vf)',
        caption: 'Coefficient de Poisson majeur',
      ),
    ],
    symbols: [
      HelpSymbol('E1', 'Rigidité dans le sens des fibres', 'MPa'),
      HelpSymbol('E2', 'Rigidité en travers des fibres', 'MPa'),
      HelpSymbol('Vf', 'Fraction volumique de fibres'),
      HelpSymbol('Ef, Em', 'Modules de la fibre et de la matrice', 'MPa'),
    ],
    notes: [
      'E1 est fiable ; la loi inverse pour E2 est optimiste et les mesures '
          'réelles tombent généralement en dessous. Halpin–Tsai est '
          'l\'amélioration standard quand la rigidité transversale compte.',
      'Fraction volumique, non massique. Les fournisseurs annoncent souvent '
          'la fraction massique — convertir avec les deux masses volumiques '
          'avant usage.',
      'En pratique, Vf plafonne vers 0,65 pour un stratifié bien consolidé ; '
          'au-delà, il n\'y a plus assez de matrice pour imprégner les fibres.',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 3',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 3',
    ],
    diagram: 'images/lamina.png',
  ),
  301: ToolHelp(
    summary: 'Les quatre constantes de l\'ingénieur indépendantes d\'un pli '
        'orthotrope — deux modules, un module de cisaillement et un '
        'coefficient de Poisson — et la matrice de souplesse qu\'elles '
        'composent. Tout calcul de stratifié part de là.',
    formulas: [
      HelpFormula(
        tex: r'\frac{\nu_{12}}{E_1} = \frac{\nu_{21}}{E_2}',
        plain: 'ν12 / E1 = ν21 / E2',
        caption: 'Réciprocité, qui rend la matrice de souplesse symétrique',
      ),
      HelpFormula(
        tex: r'Q_{11} = \frac{E_1}{1-\nu_{12}\nu_{21}}, \quad '
            r'Q_{22} = \frac{E_2}{1-\nu_{12}\nu_{21}}, \quad Q_{66} = G_{12}',
        plain: 'Q11 = E1/(1 − ν12·ν21), Q22 = E2/(1 − ν12·ν21), Q66 = G12',
        caption: 'Rigidités réduites',
      ),
    ],
    symbols: [
      HelpSymbol('E1, E2', 'Modules longitudinal et transversal', 'MPa'),
      HelpSymbol('G12', 'Module de cisaillement dans le plan', 'MPa'),
      HelpSymbol('ν12', 'Coefficient de Poisson majeur'),
      HelpSymbol('Q', 'Termes de la matrice de rigidité réduite', 'MPa'),
    ],
    notes: [
      'En contrainte plane, seules quatre constantes sont indépendantes ; '
          'ν21 découle de la réciprocité. Saisir un ν21 mesuré séparément et '
          'incohérent rend la matrice non symétrique et non physique.',
      'ν12 est la contraction en 2 provoquée par un chargement selon 1. '
          'L\'ordre des indices est la confusion la plus fréquente en '
          'composites, et certains ouvrages l\'inversent.',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 4',
    ],
    diagram: 'images/lamina.png',
  ),
  300: ToolHelp(
    summary: 'Contrainte et déformation dans un pli isolé, dans les axes du '
        'matériau ou dans un repère tourné. Comme un pli est bien plus rigide '
        'dans le sens des fibres qu\'en travers, une rotation fait plus que '
        'tourner les nombres : un pli désorienté couple contrainte normale et '
        'distorsion.',
    formulas: [
      HelpFormula(
        tex: r'\begin{bmatrix}\sigma_1\\\sigma_2\\\tau_{12}\end{bmatrix} = '
            r'[Q]\begin{bmatrix}\varepsilon_1\\\varepsilon_2\\'
            r'\gamma_{12}\end{bmatrix}',
        plain: '{σ1, σ2, τ12} = [Q] · {ε1, ε2, γ12}',
        caption: 'Dans les axes du matériau',
      ),
      HelpFormula(
        tex: r'[\bar{Q}] = [T]^{-1}[Q][T]^{-T}',
        plain: '[Q̄] = [T]⁻¹ [Q] [T]⁻ᵀ',
        caption: 'Transformée dans les axes du stratifié',
      ),
    ],
    symbols: [
      HelpSymbol('σ1, σ2', 'Contraintes dans le sens et en travers des fibres',
          'MPa'),
      HelpSymbol('τ12', 'Cisaillement dans le plan', 'MPa'),
      HelpSymbol('[Q]', 'Matrice de rigidité réduite', 'MPa'),
      HelpSymbol('θ', 'Angle du pli par rapport à l\'axe x du stratifié', '°'),
    ],
    notes: [
      'Contrainte plane dans le pli : les contraintes hors plan sont '
          'négligées, ce qui convient au cœur d\'un stratifié mince et pas au '
          'bord libre, là où commence le délaminage.',
      'Pour tout θ autre que 0 ou 90°, la matrice transformée présente des '
          'termes Q̄16 et Q̄26 non nuls : c\'est le couplage '
          'cisaillement-extension. Effet bien réel, et non artefact numérique.',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 5',
    ],
    diagram: 'images/lamina.png',
  ),
  302: ToolHelp(
    summary: 'Théorie classique des stratifiés : elle assemble les plis en '
        'matrices A, B et D et relie les efforts et moments dans le plan aux '
        'déformations et courbures du plan moyen. C\'est ce qui transforme un '
        'empilement de plis en matériau de structure au comportement '
        'prévisible.',
    formulas: [
      HelpFormula(
        tex: r'\begin{bmatrix}N\\M\end{bmatrix} = '
            r'\begin{bmatrix}A & B\\B & D\end{bmatrix}'
            r'\begin{bmatrix}\varepsilon^0\\\kappa\end{bmatrix}',
        plain: '{N, M} = [[A, B], [B, D]] · {ε⁰, κ}',
        caption: 'Loi de comportement du stratifié',
      ),
      HelpFormula(
        tex: r'A_{ij}=\sum \bar{Q}_{ij}(z_k-z_{k-1}), \quad '
            r'B_{ij}=\tfrac{1}{2}\sum \bar{Q}_{ij}(z_k^2-z_{k-1}^2), \quad '
            r'D_{ij}=\tfrac{1}{3}\sum \bar{Q}_{ij}(z_k^3-z_{k-1}^3)',
        plain: 'Aij = ΣQ̄ij·(zk − zk−1) ; Bij = ½ΣQ̄ij·(zk² − zk−1²) ; '
            'Dij = ⅓ΣQ̄ij·(zk³ − zk−1³)',
        caption: 'Rigidités de membrane, de couplage et de flexion',
      ),
    ],
    symbols: [
      HelpSymbol('N', 'Effort dans le plan par unité de largeur', 'N/mm'),
      HelpSymbol('M', 'Moment par unité de largeur', 'N·mm/mm'),
      HelpSymbol('ε⁰', 'Déformation du plan moyen'),
      HelpSymbol('κ', 'Courbure', '1/mm'),
      HelpSymbol('z', 'Cote d\'interface de pli depuis le plan moyen', 'mm'),
    ],
    notes: [
      'B est nul si et seulement si l\'empilement est symétrique par rapport '
          'au plan moyen. Un B non nul couple traction et flexion, si bien que '
          'la pièce gauchit en refroidissant après cuisson — d\'où le fait que '
          'presque tout stratifié pratique soit symétrique.',
      'La théorie classique néglige le cisaillement transverse et surestime '
          'donc la rigidité des stratifiés épais et des panneaux sandwich à '
          'âme souple.',
      'Les contraintes thermiques résiduelles de cuisson ne sont pas '
          'incluses et peuvent représenter une bonne part de la charge de '
          'première rupture de pli.',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 4',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 7',
    ],
    diagram: 'images/laminate.png',
  ),
  303: ToolHelp(
    summary: 'Constantes de l\'ingénieur équivalentes dans le plan pour un '
        'stratifié — les modules que l\'on mesurerait en essayant l\'empilement '
        'comme une plaque homogène. Utile pour comparer une séquence à un '
        'métal, et pour introduire un stratifié dans un calcul qui n\'accepte '
        'qu\'un seul matériau.',
    formulas: [
      HelpFormula(
        tex: r'E_x = \frac{1}{h\,a_{11}}, \quad E_y = \frac{1}{h\,a_{22}}, '
            r'\quad G_{xy} = \frac{1}{h\,a_{66}}',
        plain: 'Ex = 1/(h·a11), Ey = 1/(h·a22), Gxy = 1/(h·a66)',
        caption: 'À partir de la rigidité de membrane inversée, [a] = [A]⁻¹',
      ),
      HelpFormula(
        tex: r'\nu_{xy} = -\frac{a_{12}}{a_{11}}',
        plain: 'νxy = −a12 / a11',
      ),
    ],
    symbols: [
      HelpSymbol('Ex, Ey', 'Modules équivalents dans le plan', 'MPa'),
      HelpSymbol('Gxy', 'Module de cisaillement équivalent dans le plan',
          'MPa'),
      HelpSymbol('h', 'Épaisseur totale du stratifié', 'mm'),
      HelpSymbol('[a]', 'Inverse de la matrice A', 'mm/N'),
    ],
    notes: [
      'Ces valeurs ne décrivent que le comportement dans le plan. La rigidité '
          'de flexion vient de D, et pour les mêmes plis dans un ordre '
          'différent elle change alors que A ne change pas — la séquence '
          'd\'empilement compte en flexion, pas en traction.',
      'N\'a de sens que pour un stratifié symétrique. Avec une matrice B non '
          'nulle, l\'empilement ne se comporte pas du tout comme une plaque '
          'homogène.',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 4',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 7',
    ],
    diagram: 'images/laminate.png',
  ),
  304: ToolHelp(
    summary: 'Propriétés équivalentes tridimensionnelles d\'un stratifié, y '
        'compris les termes hors plan que la théorie classique laisse de côté. '
        'Nécessaires lorsque la pièce est épaisse, que des charges hors plan '
        'interviennent, ou pour alimenter un modèle éléments finis volumique.',
    formulas: [
      HelpFormula(
        tex: r'[C] = [S]^{-1}',
        plain: '[C] = [S]⁻¹',
        caption: 'Rigidité comme inverse de la souplesse assemblée',
      ),
    ],
    symbols: [
      HelpSymbol('[C]', 'Matrice de rigidité 6×6', 'MPa'),
      HelpSymbol('[S]', 'Matrice de souplesse 6×6', '1/MPa'),
      HelpSymbol('E3', 'Module dans l\'épaisseur', 'MPa'),
      HelpSymbol('G13, G23', 'Modules de cisaillement transverse', 'MPa'),
    ],
    notes: [
      'Les propriétés dans l\'épaisseur sont pilotées par la matrice et donc '
          'faibles — souvent deux ordres de grandeur sous E1. C\'est pourquoi '
          'les composites délaminent au lieu de plastifier.',
      'Les propriétés 3D équivalentes homogénéisent le stratifié en un solide '
          'anisotrope unique. C\'est bon pour la rigidité globale et inutile '
          'pour les contraintes interlaminaires au bord libre, qui demandent '
          'un modèle pli par pli.',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Herakovich, Mechanics of Fibrous Composites, ch. 3',
    ],
    diagram: 'images/laminate.png',
  ),
  306: ToolHelp(
    summary: 'Critères de première rupture de pli pour un pli unidirectionnel '
        'sous contraintes combinées. Tsai–Hill et Tsai–Wu sont des critères '
        'quadratiques à interaction ; contrainte maximale et déformation '
        'maximale vérifient chaque composante séparément et indiquent le mode '
        'de rupture.',
    formulas: [
      HelpFormula(
        tex: r'\left(\frac{\sigma_1}{X}\right)^2 - '
            r'\frac{\sigma_1\sigma_2}{X^2} + '
            r'\left(\frac{\sigma_2}{Y}\right)^2 + '
            r'\left(\frac{\tau_{12}}{S}\right)^2 = 1',
        plain: '(σ1/X)² − σ1σ2/X² + (σ2/Y)² + (τ12/S)² = 1',
        caption: 'Tsai–Hill',
      ),
      HelpFormula(
        tex: r'F_1\sigma_1 + F_2\sigma_2 + F_{11}\sigma_1^2 + '
            r'F_{22}\sigma_2^2 + F_{66}\tau_{12}^2 + '
            r'2F_{12}\sigma_1\sigma_2 = 1',
        plain: 'F1σ1 + F2σ2 + F11σ1² + F22σ2² + F66τ12² + 2F12σ1σ2 = 1',
        caption: 'Tsai–Wu, qui distingue traction et compression',
      ),
    ],
    symbols: [
      HelpSymbol('X', 'Résistance longitudinale', 'MPa'),
      HelpSymbol('Y', 'Résistance transversale', 'MPa'),
      HelpSymbol('S', 'Résistance au cisaillement dans le plan', 'MPa'),
      HelpSymbol('σ1, σ2, τ12', 'Contraintes du pli dans ses axes matériau',
          'MPa'),
    ],
    notes: [
      'Ces critères prédisent la première rupture de pli, non la ruine du '
          'stratifié. Un stratifié porte généralement bien davantage après la '
          'fissuration du premier pli, et il faut une analyse de rupture '
          'progressive pour connaître la vraie charge ultime.',
      'Utiliser la résistance en traction ou en compression selon le signe de '
          'la contrainte. Tsai–Hill sous sa forme simple ne le fait pas seul.',
      'Tsai–Wu exige le terme d\'interaction F12, difficile à mesurer ; '
          'F12 = −½√(F11·F22) est une valeur par défaut courante et '
          'raisonnable.',
      'Aucun de ces critères ne dit *comment* le pli a rompu. Le critère de '
          'contrainte maximale le dit, ce qui justifie de le calculer en '
          'parallèle.',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Tsai & Wu, "A General Theory of Strength for Anisotropic Materials", '
          'J. Composite Materials, 1971',
    ],
    diagram: 'images/lamina.png',
  ),

  701: ToolHelp(
    summary: 'Ressort hélicoïdal de compression à fil rond : indice du '
        'ressort, facteur correcteur de Wahl qui tient compte de la courbure '
        'et du cisaillement direct, raideur et fréquence de résonance. '
        'L\'indice C est la valeur à surveiller — en dessous de 4 environ le '
        'ressort est difficile à enrouler, au-dessus de 12 il s\'emmêle et '
        'flambe.',
    formulas: [
      HelpFormula(
        tex: r'C = \frac{D}{d}, \quad '
            r'K_W = \frac{4C-1}{4C-4} + \frac{0.615}{C}',
        plain: 'C = D/d, KW = (4C − 1)/(4C − 4) + 0,615/C',
        caption: 'Indice du ressort et facteur de Wahl',
      ),
      HelpFormula(
        tex: r'\tau = K_W \frac{8FD}{\pi d^3}',
        plain: 'τ = KW · 8·F·D / (π·d³)',
        caption: 'Cisaillement corrigé dans le fil',
      ),
      HelpFormula(
        tex: r'k = \frac{Gd^4}{8D^3N_a}',
        plain: 'k = G·d⁴ / (8·D³·Na)',
        caption: 'Raideur du ressort',
      ),
    ],
    symbols: [
      HelpSymbol('d', 'Diamètre du fil', 'mm'),
      HelpSymbol('D', 'Diamètre moyen d\'enroulement', 'mm'),
      HelpSymbol('C', 'Indice du ressort'),
      HelpSymbol('Na', 'Nombre de spires actives'),
      HelpSymbol('G', 'Module de cisaillement du fil', 'MPa'),
      HelpSymbol('k', 'Raideur', 'N/mm'),
    ],
    notes: [
      'D est le diamètre *moyen*, soit le diamètre extérieur moins un '
          'diamètre de fil. Prendre le diamètre extérieur surestime nettement '
          'la raideur.',
      'Les spires actives sont moins nombreuses que les spires totales : des '
          'extrémités rapprochées et meulées en coûtent environ deux, des '
          'extrémités libres presque aucune.',
      'Garder la fréquence de travail loin de la fréquence de résonance — un '
          'facteur 15 à 20 est la règle usuelle pour un ressort de soupape. La '
          'résonance est une onde qui parcourt le ressort, pas un mode de '
          'corps rigide.',
      'La résistance du fil dépend fortement du diamètre : un fil fin est bien '
          'plus résistant qu\'un fil épais du même alliage.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 10',
      'Wahl, Mechanical Springs',
    ],
  ),
  702: ToolHelp(
    summary: 'Géométrie d\'un engrenage droit à développante, denture normale '
        'à 20° — diamètres primitifs, entraxe et rapport — plus une contrainte '
        'de flexion selon Lewis et une estimation simplifiée de la pression de '
        'contact. Un premier dimensionnement, non un calcul de capacité AGMA.',
    formulas: [
      HelpFormula(
        tex: r'd = mN, \quad C = \frac{d_1+d_2}{2}, \quad '
            r'i = \frac{N_2}{N_1}',
        plain: 'd = m·N, C = (d1 + d2)/2, i = N2/N1',
        caption: 'Diamètre primitif, entraxe, rapport',
      ),
      HelpFormula(
        tex: r'\sigma = \frac{W_t}{b\,m\,Y}',
        plain: 'σ = Wt / (b·m·Y)',
        caption: 'Contrainte de flexion en pied de dent selon Lewis',
      ),
    ],
    symbols: [
      HelpSymbol('m', 'Module', 'mm'),
      HelpSymbol('N', 'Nombre de dents'),
      HelpSymbol('d', 'Diamètre primitif', 'mm'),
      HelpSymbol('Wt', 'Effort tangentiel sur la dent', 'N'),
      HelpSymbol('b', 'Largeur de denture', 'mm'),
      HelpSymbol('Y', 'Facteur de forme de Lewis'),
    ],
    notes: [
      'L\'équation de Lewis modélise une dent comme une console chargée '
          'statiquement. Elle ignore la concentration de contrainte au congé '
          'de pied, les effets dynamiques, le partage de charge entre dents et '
          'les défauts d\'alignement — autant de points que l\'AGMA 2001 '
          'traite par des facteurs explicites, et qui comptent pour une vraie '
          'capacité.',
      'Un pignon à denture normale 20° subit une interférence de taillage en '
          'dessous de 17 dents. Moins de dents impose un déport.',
      'La pression de contact (Hertz) gouverne en général la durabilité des '
          'flancs, la flexion la rupture de dent. Les deux sont à vérifier ; '
          'les modes de ruine diffèrent.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 13–14',
      'ANSI/AGMA 2001-D04',
    ],
  ),
  703: ToolHelp(
    summary: 'Diamètre minimal d\'arbre sous flexion alternée et torsion '
        'constante combinées, par le critère de l\'énergie de distorsion '
        'associé à Goodman modifié. C\'est l\'équation standard de '
        'dimensionnement pour le cas courant d\'un arbre tournant : flexion '
        'complètement alternée, couple constant.',
    formulas: [
      HelpFormula(
        tex: r'd = \left(\frac{16n}{\pi}\left\{\frac{1}{S_e}\left[4(K_f '
            r'M_a)^2 + 3(K_{fs}T_a)^2\right]^{1/2} + \frac{1}{S_{ut}}'
            r'\left[4(K_f M_m)^2 + 3(K_{fs}T_m)^2\right]^{1/2}\right\}'
            r'\right)^{1/3}',
        plain: 'd = { (16n/π) · [ (1/Se)·√(4(Kf·Ma)² + 3(Kfs·Ta)²) '
            '+ (1/Sut)·√(4(Kf·Mm)² + 3(Kfs·Tm)²) ] }^(1/3)',
        caption: 'Diamètre d\'arbre DE–Goodman',
      ),
    ],
    symbols: [
      HelpSymbol('Ma, Mm', 'Moments de flexion alterné et moyen', 'N·m'),
      HelpSymbol('Ta, Tm', 'Couples alterné et moyen', 'N·m'),
      HelpSymbol('Se', 'Limite d\'endurance corrigée', 'MPa'),
      HelpSymbol('Sut', 'Résistance à la traction', 'MPa'),
      HelpSymbol('Kf, Kfs', 'Coefficients de concentration en fatigue'),
      HelpSymbol('n', 'Coefficient de dimensionnement'),
    ],
    notes: [
      'Pour un arbre tournant sous charge transversale constante, la flexion '
          'est complètement alternée : Ma vaut le moment entier et Mm est nul. '
          'Le couple d\'un entraînement constant est l\'inverse — seulement '
          'Tm.',
      'Kf et Kfs sont les coefficients de fatigue à la section critique, en '
          'général un congé d\'épaulement, une rainure de clavette ou un '
          'ajustement serré. Les laisser à 1 est optimiste ; un épaulement vif '
          'atteint facilement 2.',
      'Ce calcul ne dimensionne qu\'en fatigue. Vérifier aussi la flèche, la '
          'rotation aux paliers et la vitesse critique — un arbre qui passe ce '
          'contrôle peut rester inutilisable.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 7',
      'ANSI/ASME B106.1M, Design of Transmission Shafting',
    ],
  ),
  704: ToolHelp(
    summary: 'Durée de vie nominale d\'un roulement : le nombre de tours que '
        '90% d\'une population atteint. L\'exposant rend la durée de vie '
        'extrêmement sensible à la charge — diviser la charge par deux '
        'multiplie par huit la vie d\'un roulement à billes.',
    formulas: [
      HelpFormula(
        tex: r'L_{10} = \left(\frac{C}{P}\right)^{p}',
        plain: 'L10 = (C/P)^p, p = 3 billes, 10/3 rouleaux',
        caption: 'Durée de vie nominale, en millions de tours',
      ),
      HelpFormula(
        tex: r'L_{10h} = \frac{10^6 L_{10}}{60n}',
        plain: 'L10h = 10⁶ · L10 / (60·n)',
        caption: 'Convertie en heures',
      ),
    ],
    symbols: [
      HelpSymbol('C', 'Charge dynamique de base, du catalogue', 'N'),
      HelpSymbol('P', 'Charge dynamique équivalente', 'N'),
      HelpSymbol('n', 'Vitesse', 'rpm'),
      HelpSymbol('L10', 'Durée de vie nominale', 'million rev'),
    ],
    notes: [
      'L10 signifie que 10% sont censés avoir défailli à cette échéance, non '
          'que le roulement dure aussi longtemps. La durée de vie médiane vaut '
          'environ cinq fois L10.',
      'P est la charge équivalente P = X·Fr + Y·Fa, qui combine les '
          'composantes radiale et axiale avec les facteurs du catalogue — pas '
          'simplement la charge radiale dès qu\'il y a de la poussée.',
      'La durée de vie de base ignore la lubrification, la pollution et la '
          'température. L\'ISO 281 ajoute pour cela le facteur a-ISO, et un '
          'roulement mal lubrifié peut rester très en deçà de L10.',
      'C doit être la charge *dynamique*. La charge statique C0 gouverne '
          'l\'empreinte d\'un roulement à l\'arrêt et c\'est une autre '
          'grandeur.',
    ],
    references: [
      'ISO 281, Rolling bearings — Dynamic load ratings and rating life',
      'Shigley, Mechanical Engineering Design, ch. 11',
    ],
  ),
  705: ToolHelp(
    summary: 'Géométrie d\'une transmission par courroie ouverte (ou par '
        'chaîne à rouleaux, avec les diamètres primitifs) : rapport de '
        'vitesse, longueur de courroie et angles d\'enroulement sur chaque '
        'poulie. C\'est l\'angle d\'enroulement de la petite poulie qui limite '
        'le couple transmissible avant glissement.',
    formulas: [
      HelpFormula(
        tex: r'i = \frac{D_2}{D_1} = \frac{n_1}{n_2}',
        plain: 'i = D2/D1 = n1/n2',
        caption: 'Rapport de vitesse',
      ),
      HelpFormula(
        tex: r'L = 2C + \frac{\pi}{2}(D_1+D_2) + \frac{(D_2-D_1)^2}{4C}',
        plain: 'L = 2C + (π/2)(D1 + D2) + (D2 − D1)²/(4C)',
        caption: 'Longueur de courroie ouverte',
      ),
      HelpFormula(
        tex: r'\theta_1 = \pi - 2\arcsin\frac{D_2-D_1}{2C}',
        plain: 'θ1 = π − 2·arcsin[(D2 − D1)/(2C)]',
        caption: 'Angle d\'enroulement sur la petite poulie',
      ),
    ],
    symbols: [
      HelpSymbol('D1, D2', 'Diamètres primitifs de la petite et de la grande '
          'poulie', 'mm'),
      HelpSymbol('C', 'Entraxe', 'mm'),
      HelpSymbol('L', 'Longueur de courroie', 'mm'),
      HelpSymbol('θ1', 'Angle d\'enroulement sur la petite poulie', 'rad'),
    ],
    notes: [
      'L\'expression de la longueur est l\'approximation classique, très '
          'précise dès que C dépasse environ (D1 + D2).',
      'Maintenir l\'enroulement sur la petite poulie au-dessus de 120° '
          'environ. En dessous, une courroie plate ou trapézoïdale glisse '
          'avant d\'atteindre sa capacité nominale, et un galet tendeur est le '
          'remède habituel.',
      'Pour une chaîne à rouleaux, utiliser les diamètres primitifs et '
          'arrondir la longueur à un nombre pair de pas — un nombre impair '
          'impose un maillon coudé, plus faible.',
      'Géométrie seulement : la puissance transmissible dépend du profil, de '
          'la vitesse et du facteur de service donnés par le fabricant.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 17',
      'ANSI/ASME B29.1, Precision Power Transmission Roller Chains',
    ],
  ),
  706: ToolHelp(
    summary: 'Le couple de serrage nécessaire pour atteindre une précharge de '
        'boulon visée, par la relation simplifiée couple–tension. Ce qui '
        'maintient réellement un assemblage, c\'est la précharge ; le couple '
        'n\'en est qu\'un indicateur indirect — et imprécis, d\'où la prudence '
        'que mérite ce chiffre.',
    formulas: [
      HelpFormula(
        tex: r'T = K F_i d',
        plain: 'T = K · Fi · d',
        caption: 'Couple pour une précharge visée',
      ),
      HelpFormula(
        tex: r'F_i \approx 0.75 A_t S_p \;\text{(reused)}, \quad '
            r'0.90 A_t S_p \;\text{(permanent)}',
        plain: 'Fi ≈ 0,75·At·Sp réutilisable, 0,90·At·Sp définitif',
        caption: 'Précharges visées usuelles',
      ),
    ],
    symbols: [
      HelpSymbol('T', 'Couple de serrage', 'N·m'),
      HelpSymbol('K', 'Facteur de couple, environ 0,20 pour acier brut'),
      HelpSymbol('Fi', 'Précharge visée', 'N'),
      HelpSymbol('d', 'Diamètre nominal du boulon', 'mm'),
      HelpSymbol('At', 'Section résistante', 'mm²'),
      HelpSymbol('Sp', 'Limite à la charge d\'épreuve', 'MPa'),
    ],
    notes: [
      'K regroupe le frottement dans le filet et sous tête, et c\'est le '
          'point faible de la méthode : il varie avec le revêtement, la '
          'lubrification et la réutilisation, et le seul contrôle au couple '
          'disperse typiquement la précharge de ±25 à 30%.',
      'Environ 90% du couple appliqué part en frottement ; à peine 10% '
          'deviennent de la tension. Une petite variation de frottement est '
          'donc une grande variation de précharge.',
      'Là où la précharge compte vraiment, il faut la mesurer — contrôle à '
          'l\'angle après accostage, mesure de l\'allongement du boulon, ou '
          'rondelle indicatrice — plutôt que de se fier au couple.',
      'Utiliser la section résistante At, non la section du fût. Pour une M10 '
          'à pas gros, cela fait 58 mm² contre 78,5 mm² au diamètre nominal.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 8',
      'Bickford, An Introduction to the Design and Behavior of Bolted Joints',
    ],
  ),
  707: ToolHelp(
    summary: 'Contrainte de cisaillement dans la gorge d\'un cordon d\'angle. '
        'La gorge est la plus petite section du cordon et donc le plan de '
        'rupture, et la pratique de calcul considère tout cordon d\'angle '
        'comme rompant en cisaillement sur cette gorge, quelle que soit la '
        'façon dont l\'assemblage est chargé.',
    formulas: [
      HelpFormula(
        tex: r'a = 0.707\,w, \quad \tau = \frac{F}{a L}',
        plain: 'a = 0,707·w, τ = F / (a·L)',
        caption: 'Épaisseur de gorge et cisaillement associé',
      ),
    ],
    symbols: [
      HelpSymbol('w', 'Côté du cordon d\'angle', 'mm'),
      HelpSymbol('a', 'Gorge utile, 0,707·w pour un cordon à côtés égaux',
          'mm'),
      HelpSymbol('L', 'Longueur utile de cordon', 'mm'),
      HelpSymbol('F', 'Charge sur le groupe de cordons', 'N'),
    ],
    notes: [
      'Considérer tout cordon d\'angle comme rompant en cisaillement sur la '
          'gorge est la simplification standard. Un cordon chargé '
          'transversalement est en réalité environ 50% plus résistant qu\'un '
          'cordon longitudinal ; les codes permettent d\'en tenir compte par '
          'un coefficient directionnel.',
      'Le facteur 0,707 vaut pour un cordon à côtés égaux et à face plate. Un '
          'cordon convexe ou à côtés inégaux a une autre gorge.',
      'Seul le chargement centré est couvert. Une charge excentrée ajoute une '
          'composante de torsion ou de flexion sur le groupe de cordons, à '
          'combiner vectoriellement avec le cisaillement direct.',
      'Le métal d\'apport est normalement de résistance égale ou légèrement '
          'supérieure au métal de base, si bien que le cordon gouverne rarement '
          'à moins d\'être sous-dimensionné.',
    ],
    references: [
      'AWS D1.1, Structural Welding Code — Steel',
      'Shigley, Mechanical Engineering Design, ch. 9',
    ],
  ),
  708: ToolHelp(
    summary: 'Pression de contact, contrainte circonférentielle dans le moyeu '
        'et contrainte dans l\'arbre pour un arbre plein emmanché à force dans '
        'un moyeu du même matériau. L\'ajustement serré est la façon dont sont '
        'réellement fixés la plupart des engrenages et accouplements — sans '
        'rainure de clavette, donc sans concentration de contrainte.',
    formulas: [
      HelpFormula(
        tex: r'p = \frac{E\delta}{2d}\left[\frac{d_o^2-d^2}{d_o^2}\right]',
        plain: 'p = (E·δ / 2d) · (do² − d²)/do²',
        caption: 'Pression de contact, mêmes matériaux',
      ),
      HelpFormula(
        tex: r'\sigma_{h} = p\,\frac{d_o^2+d^2}{d_o^2-d^2}, \quad '
            r'\sigma_{\text{shaft}} = -p',
        plain: 'σh = p·(do² + d²)/(do² − d²), σshaft = −p',
        caption: 'Contrainte circonférentielle à l\'alésage et arbre en '
            'compression uniforme',
      ),
    ],
    symbols: [
      HelpSymbol('δ', 'Serrage diamétral', 'mm'),
      HelpSymbol('d', 'Diamètre nominal de l\'interface', 'mm'),
      HelpSymbol('do', 'Diamètre extérieur du moyeu', 'mm'),
      HelpSymbol('p', 'Pression de contact', 'MPa'),
      HelpSymbol('E', 'Module de Young, saisi en GPa', 'GPa'),
    ],
    notes: [
      'Arbre et moyeu du même matériau : c\'est ce qui permet au coefficient '
          'de Poisson de se simplifier. Des matériaux différents demandent la '
          'forme générale de Lamé, et un arbre acier dans un moyeu aluminium '
          'se desserre en chauffant.',
      'La contrainte circonférentielle à l\'alésage du moyeu est une '
          'traction, et c\'est la plus grande contrainte de l\'assemblage. '
          'C\'est elle qui fissure un moyeu mince, pas la pression.',
      'Déterminer le serrage à partir de l\'*ajustement*, non d\'une valeur '
          'nominale : le serrage réel varie dans l\'intervalle de tolérance, '
          'et les deux extrêmes sont à vérifier — le minimum pour la capacité '
          'de couple, le maximum pour la contrainte du moyeu.',
      'La rugosité est écrasée au montage et réduit le serrage utile ; prévoir '
          'quelques micromètres.',
      'Le couple transmissible vaut μ·p·π·d²·L/2 et n\'est pas calculé ici — '
          'il exigerait un coefficient de frottement et une longueur '
          'd\'emmanchement, que cet outil ne demande pas.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 3 and 7',
      'ISO 286-1, Geometrical product specifications: ISO code system',
    ],
  ),
  709: ToolHelp(
    summary: 'Première vitesse critique en flexion d\'un arbre portant un '
        'rotor, en combinant la pulsation propre du rotor et la masse répartie '
        'de l\'arbre par l\'équation de Dunkerley. À la vitesse critique, un '
        'faible balourd suffit à créer une grande flèche.',
    formulas: [
      HelpFormula(
        tex: r'\omega_r = \sqrt{\frac{k}{m}}, \quad '
            r'\frac{1}{\omega_c^2} = \frac{1}{\omega_r^2} + '
            r'\frac{1}{\omega_s^2}',
        plain: 'ωr = √(k/m), 1/ωc² = 1/ωr² + 1/ωs²',
        caption: 'Rotor et arbre combinés par l\'équation de Dunkerley',
      ),
      HelpFormula(
        tex: r'N_c = \frac{60\,\omega_c}{2\pi}',
        plain: 'Nc = 60·ωc / (2π)',
        caption: 'Vitesse critique en tr/min',
      ),
    ],
    symbols: [
      HelpSymbol('k', 'Raideur latérale au droit du rotor', 'N/mm'),
      HelpSymbol('m', 'Masse du rotor', 'kg'),
      HelpSymbol('ωc', 'Première pulsation critique', 'rad/s'),
      HelpSymbol('Nc', 'Première vitesse critique', 'rpm'),
    ],
    notes: [
      'L\'équation de Dunkerley se trompe toujours par défaut : la vitesse '
          'critique donnée est donc conservative. C\'est le bon sens de '
          'l\'erreur.',
      'Garder la vitesse de service à bonne distance — en dessous d\'environ '
          '75% de la première critique, ou au-dessus d\'environ 140%, est la '
          'règle usuelle. Traverser rapidement une critique au lancement est '
          'acceptable.',
      'Les paliers sont supposés rigides. Des paliers souples ou un carter '
          'flexible abaissent la vitesse critique, parfois beaucoup.',
      'Les effets gyroscopiques, qui scindent la critique en précessions '
          'directe et rétrograde, ne sont pas pris en compte.',
    ],
    references: [
      'Rao, Mechanical Vibrations, ch. 10',
      'Shigley, Mechanical Engineering Design, ch. 7',
    ],
  ),
  710: ToolHelp(
    summary: 'Fréquences propres de flexion d\'une poutre prismatique '
        'uniforme, pour les trois premiers modes et les conditions d\'appui '
        'usuelles. La fréquence propre varie comme la racine du rapport '
        'raideur sur masse, et à l\'inverse du carré de la longueur.',
    formulas: [
      HelpFormula(
        tex: r'f_n = \frac{(\beta_n L)^2}{2\pi L^2}\sqrt{\frac{EI}{\rho A}}',
        plain: 'fn = (βn·L)² / (2π·L²) · √(E·I / (ρ·A))',
        caption: 'Fréquence d\'une poutre d\'Euler-Bernoulli',
      ),
    ],
    symbols: [
      HelpSymbol('fn', 'Fréquence propre du mode n', 'Hz'),
      HelpSymbol('βnL', 'Valeur propre fixée par les conditions d\'appui'),
      HelpSymbol('E·I', 'Rigidité de flexion', 'N·mm²'),
      HelpSymbol('ρ·A', 'Masse par unité de longueur', 'kg/m'),
      HelpSymbol('L', 'Portée', 'mm'),
    ],
    notes: [
      'La théorie d\'Euler-Bernoulli néglige la déformation de cisaillement '
          'et l\'inertie de rotation : les fréquences ressortent trop hautes '
          'pour une poutre trapue — L/d inférieur à 10 environ — et pour les '
          'modes élevés. La théorie de Timoshenko corrige les deux.',
      'La longueur domine : diviser la portée par deux multiplie chaque '
          'fréquence par quatre.',
      'Une masse rapportée qui ne fait pas partie de la poutre — un moteur, '
          'un tube plein d\'eau — abaisse la fréquence et n\'est pas prise en '
          'compte tant qu\'elle n\'est pas intégrée à ρA.',
      'Les conditions d\'appui réelles ne sont jamais parfaitement encastrées '
          'ni parfaitement articulées ; la vraie fréquence se situe entre les '
          'deux idéalisations.',
    ],
    references: [
      'Rao, Mechanical Vibrations, ch. 8',
      'Blevins, Formulas for Natural Frequency and Mode Shape',
    ],
  ),
  711: ToolHelp(
    summary: 'Fréquence propre fondamentale de torsion d\'un arbre circulaire '
        'portant soit un rotor face à un encastrement, soit deux rotors sur un '
        'arbre libre. La résonance de torsion ne se voit pas de l\'extérieur '
        'et cause fréquemment la ruine d\'accouplements et de dentures.',
    formulas: [
      HelpFormula(
        tex: r'k_t = \frac{GJ_p}{L}, \quad '
            r'\omega_n = \sqrt{\frac{k_t}{J_{\text{eff}}}}',
        plain: 'kt = G·Jp / L, ωn = √(kt / Jeff)',
        caption: 'Raideur de torsion et fréquence propre',
      ),
      HelpFormula(
        tex: r'J_{\text{eff}} = \frac{J_1 J_2}{J_1+J_2}',
        plain: 'Jeff = J1·J2 / (J1 + J2)',
        caption: 'Deux rotors sur arbre libre : l\'inertie réduite',
      ),
    ],
    symbols: [
      HelpSymbol('kt', 'Raideur de torsion', 'N·m/rad'),
      HelpSymbol('G', 'Module de cisaillement', 'MPa'),
      HelpSymbol('Jp', 'Moment quadratique polaire de l\'arbre', 'mm⁴'),
      HelpSymbol('J1, J2', 'Moments d\'inertie des rotors', 'kg·m²'),
    ],
    notes: [
      'L\'inertie propre de l\'arbre est négligée. Lorsqu\'elle devient '
          'comparable à celle des rotors, il faut une analyse à plusieurs '
          'masses (Holzer).',
      'Jp est une caractéristique de section en mm⁴ ; J1 et J2 sont des '
          'moments d\'inertie massiques en kg·m². Ce sont des grandeurs '
          'différentes qui partagent une lettre, et les confondre est '
          'l\'erreur habituelle ici.',
      'L\'excitation coïncide rarement avec la vitesse de l\'arbre. Les '
          'ordres d\'allumage d\'un moteur et les fréquences d\'engrènement en '
          'sont des multiples, et ce sont eux qui rencontrent la résonance.',
    ],
    references: [
      'Rao, Mechanical Vibrations, ch. 5 and 6',
      'Nestorides, A Handbook on Torsional Vibration',
    ],
  ),
  800: ToolHelp(
    summary: 'Nombre de Reynolds d\'un écoulement en conduite circulaire et le '
        'régime auquel il correspond. Re est le rapport des forces d\'inertie '
        'aux forces visqueuses, et c\'est le seul nombre qui décide si un '
        'écoulement est ordonné ou chaotique — ce qui fixe ensuite le '
        'coefficient de frottement et le transfert de chaleur.',
    formulas: [
      HelpFormula(
        tex: r'Re = \frac{\rho V D}{\mu} = \frac{VD}{\nu}',
        plain: 'Re = ρ·V·D / μ = V·D / ν',
        caption: 'Nombre de Reynolds',
      ),
      HelpFormula(
        tex: r'V = \frac{Q}{A}, \quad A = \frac{\pi D^2}{4}',
        plain: 'V = Q / A, A = π·D²/4',
        caption: 'Vitesse à partir du débit volumique',
      ),
    ],
    symbols: [
      HelpSymbol('Re', 'Nombre de Reynolds'),
      HelpSymbol('ρ', 'Masse volumique', 'kg/m³'),
      HelpSymbol('V', 'Vitesse moyenne', 'm/s'),
      HelpSymbol('D', 'Diamètre intérieur', 'mm'),
      HelpSymbol('μ', 'Viscosité dynamique', 'Pa·s'),
      HelpSymbol('ν', 'Viscosité cinématique, μ/ρ', 'm²/s'),
    ],
    notes: [
      'En conduite : laminaire en dessous de 2300 environ, turbulent au-delà '
          'de 4000 environ, transitoire entre les deux. La transition n\'est '
          'pas nette et dépend des perturbations d\'entrée et de la rugosité.',
      'D est le diamètre *intérieur* du tube, non la taille nominale. La '
          'table des séries de tuyaux donne la bonne valeur.',
      'Pour une conduite non circulaire, substituer le diamètre hydraulique '
          '4A/P. Cela marche bien en turbulent et mal en laminaire.',
      'V est la vitesse moyenne sur la section. La vitesse sur l\'axe en vaut '
          'le double en laminaire et environ 1,2 fois en turbulent.',
    ],
    references: [
      'White, Fluid Mechanics, ch. 6',
      'Munson, Fundamentals of Fluid Mechanics, ch. 8',
    ],
  ),
  801: ToolHelp(
    summary: 'Perte de charge et chute de pression selon Darcy-Weisbach pour '
        'une conduite en charge, avec le coefficient de frottement issu de '
        'l\'équation de Colebrook et les pertes singulières ajoutées en '
        'hauteurs dynamiques. C\'est la façon standard de dimensionner un '
        'réseau et de choisir la pompe qui l\'alimente.',
    formulas: [
      HelpFormula(
        tex: r'h_f = f\frac{L}{D}\frac{V^2}{2g}',
        plain: 'hf = f · (L/D) · V²/(2g)',
        caption: 'Perte de charge linéaire de Darcy-Weisbach',
      ),
      HelpFormula(
        tex: r'\frac{1}{\sqrt{f}} = -2\log_{10}\left(\frac{\varepsilon/D}'
            r'{3.7} + \frac{2.51}{Re\sqrt{f}}\right)',
        plain: '1/√f = −2·log₁₀[ (ε/D)/3,7 + 2,51/(Re·√f) ]',
        caption: 'Colebrook, résolue par itération',
      ),
      HelpFormula(
        tex: r'h_m = \sum K \frac{V^2}{2g}, \quad \Delta p = \rho g h',
        plain: 'hm = ΣK · V²/(2g), Δp = ρ·g·h',
        caption: 'Pertes singulières et chute de pression',
      ),
    ],
    symbols: [
      HelpSymbol('f', 'Coefficient de frottement de Darcy'),
      HelpSymbol('L', 'Longueur de conduite', 'm'),
      HelpSymbol('D', 'Diamètre intérieur', 'mm'),
      HelpSymbol('ε', 'Rugosité absolue', 'mm'),
      HelpSymbol('ΣK', 'Somme des coefficients de pertes singulières'),
      HelpSymbol('hf', 'Perte de charge', 'm'),
    ],
    notes: [
      'Le coefficient de Darcy vaut quatre fois celui de Fanning. Vérifier '
          'lequel donne un abaque ou une corrélation avant de s\'en servir — '
          'ce facteur quatre est une erreur classique.',
      'Colebrook vaut en régime turbulent. En laminaire, prendre f = 64/Re, '
          'qui ne dépend pas du tout de la rugosité.',
      'Rugosités absolues typiques : 0,045 mm pour l\'acier du commerce, '
          '0,0015 mm pour le tube étiré, 0,26 mm pour la fonte. Un tube '
          'ancien est bien plus rugueux qu\'un neuf, et c\'est là que réside '
          'l\'essentiel de l\'incertitude.',
      'Suppose une conduite pleine de fluide incompressible en régime '
          'permanent. Les écoulements à surface libre et les gaz compressibles '
          'demandent d\'autres traitements.',
    ],
    references: [
      'White, Fluid Mechanics, ch. 6',
      'Crane Technical Paper No. 410, Flow of Fluids Through Valves, '
          'Fittings and Pipe',
    ],
  ),
  802: ToolHelp(
    summary: 'La puissance nécessaire à une pompe ou un ventilateur : le '
        'fluide reçoit l\'élévation de pression multipliée par le débit, et '
        'l\'entraînement doit fournir cela divisé par le rendement. '
        'L\'élévation de pression est aussi donnée en hauteur du fluide '
        'pompé, car c\'est ainsi que sont tracées les courbes de pompe.',
    formulas: [
      HelpFormula(
        tex: r'P_{\text{fluid}} = \Delta p\,Q, \quad '
            r'P_{\text{shaft}} = \frac{\Delta p\,Q}{\eta}',
        plain: 'Pfluid = Δp·Q, Pshaft = Δp·Q / η',
        caption: 'Puissance hydraulique et puissance à l\'arbre',
      ),
      HelpFormula(
        tex: r'H = \frac{\Delta p}{\rho g}',
        plain: 'H = Δp / (ρ·g)',
        caption: 'Élévation de pression exprimée en hauteur',
      ),
    ],
    symbols: [
      HelpSymbol('Δp', 'Élévation de pression dans la machine', 'kPa'),
      HelpSymbol('Q', 'Débit volumique', 'm³/s'),
      HelpSymbol('η', 'Rendement global'),
      HelpSymbol('H', 'Hauteur manométrique', 'm'),
    ],
    notes: [
      'La hauteur est indépendante de la masse volumique, la pression non. '
          'Une pompe développe la même hauteur avec n\'importe quel liquide et '
          'une pression proportionnellement plus faible avec un liquide plus '
          'léger — d\'où des courbes de pompe en mètres.',
      'Le rendement est ici celui de la machine entière. Si le rendement '
          'moteur est séparé, diviser encore par lui pour obtenir la puissance '
          'électrique absorbée.',
      'Vérifier aussi le NPSH disponible face au NPSH requis de la pompe. Une '
          'pompe qui cavite ne délivrera pas utilement cette puissance, quel '
          'que soit le dimensionnement.',
      'Pour un ventilateur, ne traiter le gaz comme incompressible que tant '
          'que l\'élévation de pression reste faible — moins de 3% environ de '
          'la pression absolue.',
    ],
    references: [
      'White, Fluid Mechanics, ch. 11',
      'Hydraulic Institute Standards, ANSI/HI 1.1-1.2',
    ],
  ),
  810: ToolHelp(
    summary: 'Conduction unidimensionnelle en régime permanent à travers une '
        'paroi plane multicouche. Chaque couche est une résistance thermique, '
        'et elles s\'ajoutent en série avec les films de convection sur les '
        'deux faces, ce qui donne le coefficient global, le flux de chaleur et '
        'la température à chaque interface.',
    formulas: [
      HelpFormula(
        tex: r'R_{\text{cond}} = \frac{t}{k}, \quad '
            r'R_{\text{conv}} = \frac{1}{h}',
        plain: 'Rcond = t/k, Rconv = 1/h',
        caption: 'Résistance par unité de surface',
      ),
      HelpFormula(
        tex: r'U = \frac{1}{\sum R}, \quad q = U\,\Delta T',
        plain: 'U = 1 / ΣR, q = U · ΔT',
        caption: 'Coefficient global et densité de flux',
      ),
    ],
    symbols: [
      HelpSymbol('t', 'Épaisseur de couche', 'm'),
      HelpSymbol('k', 'Conductivité thermique', 'W/m·K'),
      HelpSymbol('h', 'Coefficient de convection', 'W/m²·K'),
      HelpSymbol('U', 'Coefficient global de transmission', 'W/m²·K'),
      HelpSymbol('q', 'Densité de flux thermique', 'W/m²'),
    ],
    notes: [
      'Paroi plane uniquement — les résistances s\'ajoutent en t/k. Une '
          'coque cylindrique ou sphérique a une forme logarithmique ou '
          'réciproque, et appliquer la formule plane à un tube de petit '
          'diamètre est nettement faux.',
      'C\'est la plus grande résistance qui gouverne. Ajouter de l\'isolant à '
          'une paroi déjà dominée par un film d\'air immobile rapporte bien '
          'moins que la valeur de k ne le laisse croire.',
      'La résistance de contact entre couches est négligée, et elle peut '
          'compter pour des assemblages métalliques boulonnés ou collés.',
      'Régime permanent seulement : pas d\'inertie thermique, donc rien sur le '
          'temps de réponse de la paroi.',
    ],
    references: [
      'Incropera & DeWitt, Fundamentals of Heat and Mass Transfer, ch. 3',
      'ASHRAE Handbook — Fundamentals, ch. 25',
    ],
  ),
  811: ToolHelp(
    summary: 'Rendement d\'une ailette droite rectangulaire de section '
        'constante, résolue avec une pointe adiabatique et une longueur '
        'corrigée. Le rendement d\'ailette est la fraction du flux idéal '
        'qu\'atteint une ailette réelle, compte tenu de la chute de '
        'température sur sa longueur.',
    formulas: [
      HelpFormula(
        tex: r'm = \sqrt{\frac{2h}{kt}}, \quad L_c = L + \frac{t}{2}',
        plain: 'm = √(2h / (k·t)), Lc = L + t/2',
        caption: 'Paramètre d\'ailette et longueur corrigée',
      ),
      HelpFormula(
        tex: r'\eta_f = \frac{\tanh(mL_c)}{mL_c}',
        plain: 'ηf = tanh(m·Lc) / (m·Lc)',
        caption: 'Rendement d\'ailette',
      ),
    ],
    symbols: [
      HelpSymbol('h', 'Coefficient de convection', 'W/m²·K'),
      HelpSymbol('k', 'Conductivité thermique de l\'ailette', 'W/m·K'),
      HelpSymbol('t', 'Épaisseur de l\'ailette', 'm'),
      HelpSymbol('L', 'Longueur de l\'ailette', 'm'),
      HelpSymbol('ηf', 'Rendement d\'ailette'),
    ],
    notes: [
      'La longueur corrigée est l\'astuce standard pour tenir compte de la '
          'convection en pointe dans une solution à pointe adiabatique. Elle '
          'est précise tant que h·t/k reste faible, ce qui est le cas usuel.',
      'Le rendement chute quand l\'ailette s\'allonge : au-delà d\'un mLc de '
          '2 environ, la longueur supplémentaire n\'apporte que du poids et '
          'presque pas de chaleur. C\'est la limite pratique de hauteur '
          'd\'ailette.',
      'Les ailettes ne servent que si la résistance de surface domine. En '
          'ajouter côté eau d\'un échangeur, où h est déjà élevé, ne change '
          'presque rien.',
      'Conduction unidimensionnelle dans l\'ailette, h uniforme sur la '
          'surface, et pas de rayonnement.',
    ],
    references: [
      'Incropera & DeWitt, Fundamentals of Heat and Mass Transfer, ch. 3',
      'Kraus, Aziz & Welty, Extended Surface Heat Transfer',
    ],
  ),
  812: ToolHelp(
    summary: 'Différence de température moyenne logarithmique à partir des '
        'quatre températures d\'extrémité, et surface nécessaire pour une '
        'puissance donnée. La DTML est la bonne moyenne de l\'écart moteur '
        'd\'un échangeur, parce que l\'écart local varie de façon '
        'exponentielle et non linéaire le long de l\'appareil.',
    formulas: [
      HelpFormula(
        tex: r'\Delta T_{lm} = \frac{\Delta T_1 - \Delta T_2}'
            r'{\ln(\Delta T_1/\Delta T_2)}',
        plain: 'ΔTlm = (ΔT1 − ΔT2) / ln(ΔT1/ΔT2)',
        caption: 'Différence de température moyenne logarithmique',
      ),
      HelpFormula(
        tex: r'A = \frac{Q}{U\,\Delta T_{lm}}',
        plain: 'A = Q / (U · ΔTlm)',
        caption: 'Surface pour une puissance donnée',
      ),
    ],
    symbols: [
      HelpSymbol('ΔT1, ΔT2', 'Écarts de température aux extrémités', 'K'),
      HelpSymbol('U', 'Coefficient global de transmission', 'W/m²·K'),
      HelpSymbol('Q', 'Puissance thermique', 'W'),
      HelpSymbol('A', 'Surface d\'échange', 'm²'),
    ],
    notes: [
      'À contre-courant, chaque entrée s\'apparie avec la sortie opposée ; à '
          'co-courant, les deux entrées vont ensemble. Le contre-courant donne '
          'toujours la plus grande DTML et donc l\'appareil le plus petit, et '
          'c\'est le seul montage qui puisse porter la sortie froide au-dessus '
          'de la sortie chaude.',
      'Pour un faisceau tubulaire ou un courant croisé, multiplier par le '
          'facteur correctif F des abaques usuels. Un F inférieur à 0,8 '
          'environ signale une configuration mal choisie.',
      'Suppose U et chaleurs massiques constants sur l\'appareil, sans '
          'changement de phase. Une condensation ou une ébullition d\'un côté '
          'demande un découpage en zones.',
      'L\'encrassement augmente la résistance avec le temps ; le U de calcul '
          'doit inclure une réserve, sinon l\'échangeur sera sous-dimensionné '
          'en moins d\'un an.',
    ],
    references: [
      'Incropera & DeWitt, Fundamentals of Heat and Mass Transfer, ch. 11',
      'TEMA Standards of the Tubular Exchanger Manufacturers Association',
    ],
  ),
  500: ToolHelp(
    summary: 'Convertit entre unités d\'une même grandeur physique — longueur, '
        'force, pression, couple et les autres. La conversion est exacte '
        'chaque fois que la définition l\'est, ce qui est le cas de la plupart '
        'des unités dérivées du pouce : un pouce vaut exactement 25,4 mm '
        'depuis 1959.',
    formulas: [
      HelpFormula(
        tex: r'v_{\text{target}} = v_{\text{source}} \times '
            r'\frac{f_{\text{source}}}{f_{\text{target}}}',
        plain: 'cible = source × (facteur source / facteur cible)',
        caption: 'Toute conversion passe par une valeur de base SI',
      ),
    ],
    symbols: [
      HelpSymbol('f', 'Facteur ramenant une unité à sa base SI'),
    ],
    notes: [
      'Passer par une base SI unique plutôt que d\'unité à unité signifie un '
          'facteur par unité et non un par paire : une table de n unités ne '
          'peut donc pas se contredire elle-même.',
      'La température fait exception : de °C à °F il y a un décalage en plus '
          'd\'un facteur, si bien qu\'un *écart* de température ne se convertit '
          'pas comme une température.',
      'Livre-force et livre-masse sont deux grandeurs différentes au nom '
          'voisin. Vérifier laquelle est visée avant de convertir.',
    ],
    references: [
      'BIPM, The International System of Units (SI), 9th edition',
      'NIST Special Publication 811, Guide for the Use of the SI',
    ],
  ),
  501: ToolHelp(
    summary: 'Diamètres de perçage avant taraudage et de passage pour les '
        'filetages métriques et en pouces courants. Le perçage laisse assez de '
        'matière pour environ 75% de hauteur de filet — le compromis pratique '
        'entre résistance du filet et couple de taraudage.',
    formulas: [
      HelpFormula(
        tex: r'd_{\text{tap}} \approx D - P',
        plain: 'perçage ≈ D − P (métrique, ≈75% de filet)',
        caption: 'Diamètre extérieur moins un pas — la règle des 75%',
      ),
    ],
    symbols: [
      HelpSymbol('D', 'Diamètre nominal extérieur du filetage', 'mm'),
      HelpSymbol('P', 'Pas', 'mm'),
    ],
    notes: [
      'D − P n\'est pas le diamètre à fond de filet : le diamètre intérieur '
          'de base vaut D − 1,0825·P, et le perçage usuel laisse '
          'délibérément un filet moins profond.',
      'Passer de 75% à 100% de hauteur de filet n\'ajoute qu\'environ 5% de '
          'résistance et double à peu près le couple de taraudage. Cela ne '
          'vaut presque jamais la peine, et cela casse les tarauds.',
      'La résistance d\'un filetage dépend bien plus de la *longueur* '
          'd\'engagement que du pourcentage. Dans un matériau tendre, allonger '
          'le filetage plutôt que l\'approfondir.',
      'Les perçages de passage suivent les classes serrée, moyenne et large. '
          'Moyenne est le choix par défaut, sauf si le montage exige du '
          'rattrapage.',
      'Les tarauds par déformation demandent un trou plus grand que les '
          'tarauds coupants — ils refoulent la matière au lieu de l\'enlever.',
    ],
    references: [
      'ISO 965-1, ISO general purpose metric screw threads — Tolerances',
      'Machinery\'s Handbook, Threads and Threading',
    ],
  ),
  502: ToolHelp(
    summary: 'Écarts et ajustements ISO 286 pour les combinaisons '
        'préférentielles au système de l\'alésage normal. Un ajustement est un '
        'couple d\'intervalles de tolérance : la lettre fixe la position de '
        'l\'intervalle par rapport à la cote nominale et le chiffre sa largeur. '
        'H7/g6 et H7/p6 diffèrent donc par la position, pas par la précision.',
    formulas: [
      HelpFormula(
        tex: r'\text{clearance}_{\max} = \text{hole}_{\max} - '
            r'\text{shaft}_{\min}',
        plain: 'jeu maximal = alésage maxi − arbre mini',
        caption: 'Le jeu minimal vaut alésage mini − arbre maxi',
      ),
    ],
    symbols: [
      HelpSymbol('H', 'Alésage normal : écart inférieur nul'),
      HelpSymbol('IT', 'Degré de tolérance normalisé — la largeur de '
          'l\'intervalle'),
      HelpSymbol('µm', 'Les écarts sont tabulés en micromètres'),
    ],
    notes: [
      'Le système de l\'alésage normal est le choix habituel : les alésages '
          'se font avec des outils de dimension fixe et les arbres sont plus '
          'faciles à retoucher, donc il est moins coûteux de faire varier '
          'l\'arbre.',
      'Un jeu négatif est un serrage. H7/p6 et plus serré sont des '
          'ajustements à la presse, à vérifier avec l\'outil d\'emmanchement '
          'pour la contrainte du moyeu.',
      'À degré IT égal, la largeur croît avec la dimension — un intervalle '
          'IT7 vaut 21 µm à 20 mm et 52 µm à 300 mm.',
      'Les tables ne donnent que des limites de cote. Qu\'un arbre entre '
          'réellement dépend aussi de la forme : les défauts de circularité et '
          'de rectitude mangent le jeu.',
    ],
    references: [
      'ISO 286-1 and ISO 286-2, Geometrical product specifications',
      'Machinery\'s Handbook, Allowances and Tolerances for Fits',
    ],
  ),
  503: ToolHelp(
    summary: 'Dimensions et caractéristiques publiées des profilés laminés — '
        'profilés W de l\'AISC et IPE et HEB européens. Les valeurs publiées '
        'incluent les congés de laminage qu\'un calcul de géométrie brute ne '
        'voit pas, et cela représente quelques pour cent d\'aire et de '
        'rigidité.',
    formulas: [
      HelpFormula(
        tex: r'S = \frac{I}{c}, \quad r = \sqrt{\frac{I}{A}}',
        plain: 'S = I / c, r = √(I / A)',
        caption: 'Module de flexion et rayon de giration, tous deux dérivés ici',
      ),
    ],
    symbols: [
      HelpSymbol('A', 'Aire de la section', 'mm²'),
      HelpSymbol('Ix, Iy', 'Moments quadratiques selon les axes fort et '
          'faible', 'mm⁴'),
      HelpSymbol('S', 'Module de flexion élastique', 'mm³'),
      HelpSymbol('r', 'Rayon de giration', 'mm'),
    ],
    notes: [
      'Seuls l\'aire et les deux moments quadratiques sont stockés ; S et r '
          'en sont calculés, si bien qu\'une erreur de recopie ne peut pas les '
          'rendre incohérents.',
      'Les tables couvrent des profilés en I à double symétrie. Les U et les '
          'cornières ont leur centre de gravité hors mi-hauteur et n\'y '
          'figurent pas.',
      'Ce sont des caractéristiques élastiques. Le calcul plastique utilise '
          'le module plastique Z, plus grand — environ 1,12 fois S pour un '
          'profilé en I courant.',
      'Vérifier une table d\'usine ou de norme à jour avant l\'exécution : '
          'les profilés sont parfois révisés ou supprimés.',
    ],
    references: [
      'AISC Steel Construction Manual, Part 1',
      'EN 10365, Hot rolled steel channels, I and H sections',
    ],
  ),
  504: ToolHelp(
    summary: 'Diamètre extérieur, épaisseur et alésage des tuyaux en acier '
        'ASME B36.10M. Les tuyaux sont fabriqués à diamètre extérieur fixe '
        'pour que les mêmes raccords et filetages conviennent à toutes les '
        'épaisseurs : une série plus lourde rogne donc l\'alésage au lieu '
        'd\'agrandir le tube.',
    formulas: [
      HelpFormula(
        tex: r'ID = OD - 2t, \quad A = \frac{\pi\,ID^2}{4}',
        plain: 'ID = OD − 2·t, A = π·ID²/4',
        caption: 'Alésage et section de passage, tous deux dérivés ici',
      ),
    ],
    symbols: [
      HelpSymbol('NPS', 'Taille nominale — une désignation, pas une cote'),
      HelpSymbol('DN', 'Le diamètre nominal ISO, également une désignation'),
      HelpSymbol('OD', 'Diamètre extérieur', 'mm'),
      HelpSymbol('t', 'Épaisseur de paroi', 'mm'),
    ],
    notes: [
      'NPS n\'est pas une cote. Un tuyau NPS 2 n\'a ni 2 pouces d\'alésage ni '
          '2 pouces de diamètre extérieur ; ce n\'est qu\'à partir de NPS 14 '
          'que le nombre égale le diamètre extérieur en pouces.',
      'Utiliser l\'alésage, non la taille nominale, pour tout calcul '
          'd\'écoulement. À NPS 1 l\'écart atteint environ 5%, et il '
          'intervient à la puissance quatre dans un calcul de perte de charge.',
      'STD et XS ne suivent Sch 40 et Sch 80 que jusqu\'à NPS 10 et NPS 8 '
          'respectivement ; au-delà, les classes de poids cessent de '
          's\'épaissir.',
      'Ce sont des cotes nominales. La tolérance de laminage sur l\'épaisseur '
          'est typiquement de −12,5%, ce qui compte pour un calcul de '
          'pression.',
    ],
    references: [
      'ASME B36.10M, Welded and Seamless Wrought Steel Pipe',
      'ASME B31.3, Process Piping',
    ],
  ),
  505: ToolHelp(
    summary: 'Chaîne de cotes unidimensionnelle sur une suite de cotes '
        'tolérancées, par la méthode au pire des cas et par la méthode '
        'statistique (RSS). Donne le jeu résiduel, s\'il peut devenir négatif, '
        'et quelle cote est responsable de l\'essentiel de la dispersion — '
        'c\'est là que resserrer une tolérance rapporte le plus.',
    formulas: [
      HelpFormula(
        tex: r'g = \sum \pm d_i, \quad '
            r'T_{wc} = \sum t_i',
        plain: 'g = Σ ±di, Twc = Σ ti',
        caption: 'Pire des cas : les tolérances s\'additionnent',
      ),
      HelpFormula(
        tex: r'T_{rss} = \sqrt{\sum t_i^2}',
        plain: 'Trss = √(Σ ti²)',
        caption: 'RSS : elles s\'additionnent quadratiquement',
      ),
    ],
    symbols: [
      HelpSymbol('di', 'Cote nominale de chaque maillon', 'mm'),
      HelpSymbol('ti', 'Demi-tolérance ramenée au symétrique', 'mm'),
      HelpSymbol('g', 'Jeu résiduel', 'mm'),
    ],
    notes: [
      'Le pire des cas est purement arithmétique et incontestable : s\'il '
          'passe, l\'assemblage se fait toujours. Dimensionner dessus.',
      'Le RSS suppose des cotes indépendantes, centrées dans leur intervalle '
          'et à peu près normales. Il ne dit rien d\'un lot de cinq pièces, et '
          'sous-estime la dispersion si le procédé dérive ou si un fournisseur '
          'travaille sur un bord.',
      'Les parts RSS varient comme le carré de chaque tolérance et désignent '
          'donc bien plus nettement la cote la plus large que ne le font les '
          'parts au pire des cas. C\'est celle-là qu\'il faut resserrer.',
      'Une tolérance dissymétrique décale la moyenne statistique : '
          '25 +0,10/−0,00 vaut en réalité 25,05 ±0,05, et l\'additionner comme '
          '25 tire toute la chaîne vers le bas.',
      'Unidimensionnel seulement. Les effets angulaires, les défauts de forme '
          'et les tolérances de position demandent une analyse 3D complète.',
    ],
    references: [
      'ASME Y14.5, Dimensioning and Tolerancing',
      'Fischer, Mechanical Tolerance Stackup and Analysis',
    ],
  ),
};
