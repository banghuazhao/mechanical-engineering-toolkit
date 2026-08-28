import 'package:mechanical_engineering_toolkit/help/tool_help.dart';

/// German tool explanations.
///
/// Equations, symbol glyphs and units stay untranslated — they are the same
/// notation on a drawing in any language. References stay in English because
/// they are citations: a reader looking the book up needs the title it was
/// published under.
const Map<int, ToolHelp> toolHelpDe = {
  100: ToolHelp(
    summary: 'Einachsige Spannung und Dehnung in einem prismatischen Stab '
        'unter Axiallast. Die Normalspannung ist die Last verteilt auf die '
        'tragende Fläche, und die Dehnung folgt daraus über das Hookesche '
        'Gesetz, solange der Werkstoff elastisch bleibt. Das ist der '
        'Ausgangspunkt jeder weiteren Spannungsberechnung: Zugstange, '
        'Hänger, Schraube unter reinem Zug.',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{P}{A}',
        plain: 'σ = P / A',
        caption: 'Normalspannung',
      ),
      HelpFormula(
        tex: r'\varepsilon = \frac{\sigma}{E} = \frac{\delta}{L}',
        plain: 'ε = σ / E = δ / L',
        caption: 'Dehnung im elastischen Bereich',
      ),
    ],
    symbols: [
      HelpSymbol('σ', 'Normalspannung', 'MPa'),
      HelpSymbol('P', 'Axialkraft, Zug positiv', 'N'),
      HelpSymbol('A', 'Querschnittsfläche', 'mm²'),
      HelpSymbol('E', 'Elastizitätsmodul', 'MPa'),
      HelpSymbol('ε', 'Normaldehnung'),
    ],
    notes: [
      'Setzt eine über den Querschnitt gleichmäßige Spannung voraus. Das gilt '
          'fern von Lasteinleitungen, Bohrungen und Querschnittssprüngen — das '
          'Prinzip von Saint-Venant. In deren Nähe entstehen '
          'Spannungsüberhöhungen, die diese Formel nicht zeigt.',
      'Nur elastisch: Überschreitet σ die Proportionalitätsgrenze, gilt '
          'ε = σ/E nicht mehr, und der Stab bleibt bleibend verformt.',
      'Ein schlanker Stab unter Druck knickt lange bevor er diese Spannung '
          'erreicht. Prüfe ihn zusätzlich mit dem Knickstab-Werkzeug.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 1–3',
      'Gere & Goodno, Mechanics of Materials, ch. 1',
    ],
    diagram: 'images/icon_bar_force.png',
  ),
  101: ToolHelp(
    summary: 'Axiale Verlängerung eines prismatischen Stabes und die '
        'zugehörige Steifigkeit. Der Stab verhält sich wie eine lineare Feder '
        'mit der Rate AE/L. Deshalb ist diese Beziehung der Baustein für '
        'Schraubenverbindungen, Zugstabsysteme und jede Struktur, die man über '
        'Steifigkeiten zusammensetzt.',
    formulas: [
      HelpFormula(
        tex: r'\delta = \frac{PL}{AE}',
        plain: 'δ = P·L / (A·E)',
        caption: 'Verlängerung',
      ),
      HelpFormula(
        tex: r'k = \frac{AE}{L}',
        plain: 'k = A·E / L',
        caption: 'Axialsteifigkeit',
      ),
    ],
    symbols: [
      HelpSymbol('δ', 'Verlängerung, Zug positiv', 'mm'),
      HelpSymbol('P', 'Axialkraft', 'N'),
      HelpSymbol('L', 'Ursprüngliche Länge', 'mm'),
      HelpSymbol('A', 'Querschnittsfläche', 'mm²'),
      HelpSymbol('E', 'Elastizitätsmodul', 'MPa'),
      HelpSymbol('k', 'Axialsteifigkeit', 'N/mm'),
    ],
    notes: [
      'Gilt für einen prismatischen Stab mit über die Länge konstantem P, A '
          'und E. Bei abgesetzten oder konischen Stäben, oder wenn das '
          'Eigengewicht mitwirkt, in Abschnitte teilen und die Verlängerungen '
          'addieren.',
      'Lineare Elastizitätstheorie kleiner Dehnungen. δ bezieht sich auf die '
          'ursprüngliche, nicht auf die verformte Länge.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 4',
      'Gere & Goodno, Mechanics of Materials, ch. 2',
    ],
    diagram: 'images/bar_force_displacement.png',
  ),
  103: ToolHelp(
    summary: 'Schubspannung in einer kreisförmigen Welle unter reiner '
        'Torsion. Die Spannung steigt linear von null in der Achse auf ihren '
        'Höchstwert an der Oberfläche. Deshalb überträgt eine Hohlwelle bei '
        'gleichem Außendurchmesser fast dasselbe Moment wie eine Vollwelle, '
        'wiegt dabei aber deutlich weniger.',
    formulas: [
      HelpFormula(
        tex: r'\tau = \frac{T\rho}{J}',
        plain: 'τ = T·ρ / J',
        caption: 'Schubspannung im Radius ρ',
      ),
      HelpFormula(
        tex: r'J_{\text{solid}} = \frac{\pi d^4}{32}, \quad '
            r'J_{\text{hollow}} = \frac{\pi (d_o^4 - d_i^4)}{32}',
        plain: 'J = π·d⁴/32 (voll), J = π·(do⁴ − di⁴)/32 (hohl)',
        caption: 'Polares Flächenträgheitsmoment',
      ),
    ],
    symbols: [
      HelpSymbol('τ', 'Schubspannung', 'MPa'),
      HelpSymbol('T', 'Torsionsmoment', 'N·mm'),
      HelpSymbol('ρ', 'Radius der betrachteten Stelle', 'mm'),
      HelpSymbol('J', 'Polares Flächenträgheitsmoment', 'mm⁴'),
    ],
    notes: [
      'Nur für Kreisquerschnitte. Ein nicht kreisförmiger Querschnitt '
          'verwölbt sich beim Tordieren aus der Ebene heraus; die Formel gilt '
          'dort überhaupt nicht. Quadrat- und Rechteckstäbe brauchen eigene '
          'Torsionskonstanten.',
      'Linear elastisch und reine Torsion. Für Biegung und Torsion zusammen '
          'zuerst das Werkzeug für kombinierte Belastung, dann ein '
          'Festigkeitskriterium verwenden.',
      'T in N·mm angeben, wenn die übrigen Größen in mm und MPa vorliegen.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 5',
      'Gere & Goodno, Mechanics of Materials, ch. 3',
    ],
    diagram: 'images/icon_bar_torsion.png',
  ),
  114: ToolHelp(
    summary: 'Wie weit sich ein Wellenende unter Moment gegenüber dem anderen '
        'verdreht. Der Verdrehwinkel entscheidet, ob sich eine Antriebswelle '
        'steif anfühlt, ob ein Drehstab die gewünschte Rate erreicht, und wie '
        'sich das Moment in einem statisch unbestimmten System auf parallele '
        'Pfade aufteilt.',
    formulas: [
      HelpFormula(
        tex: r'\phi = \frac{TL}{GJ}',
        plain: 'φ = T·L / (G·J)',
        caption: 'Verdrehwinkel in Radiant',
      ),
      HelpFormula(
        tex: r'k_t = \frac{GJ}{L}',
        plain: 'kt = G·J / L',
        caption: 'Torsionssteifigkeit',
      ),
    ],
    symbols: [
      HelpSymbol('φ', 'Verdrehwinkel', 'rad'),
      HelpSymbol('T', 'Torsionsmoment', 'N·mm'),
      HelpSymbol('L', 'Länge, über die sich die Verdrehung aufbaut', 'mm'),
      HelpSymbol('G', 'Schubmodul', 'MPa'),
      HelpSymbol('J', 'Polares Flächenträgheitsmoment', 'mm⁴'),
    ],
    notes: [
      'Prismatische Kreiswellen mit über die Länge konstantem T, G und J. '
          'Ändert sich eine dieser Größen, die Verdrehwinkel der Abschnitte '
          'addieren.',
      'G ist nicht unabhängig von E: für einen isotropen Werkstoff gilt '
          'G = E / [2(1 + ν)], bei Stahl etwa 0,385·E.',
      'Das Ergebnis steht in Radiant. Für Grad mit 180/π multiplizieren.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 5',
      'Shigley, Mechanical Engineering Design, ch. 3',
    ],
    diagram: 'images/icon_bar_torsion.png',
  ),
  115: ToolHelp(
    summary: 'Das Moment, das eine rotierende Welle bei gegebener Leistung '
        'und Drehzahl überträgt, oder die Leistung zu einem bekannten Moment. '
        'Jede Wellenauslegung beginnt hier: Das Typenschild des Motors nennt '
        'Leistung und Drehzahl, und die Welle muss für das daraus folgende '
        'Moment ausgelegt werden.',
    formulas: [
      HelpFormula(
        tex: r'P = T\omega, \quad \omega = \frac{2\pi n}{60}',
        plain: 'P = T·ω, ω = 2π·n / 60',
        caption: 'Leistung aus Moment und Drehzahl',
      ),
      HelpFormula(
        tex: r'T = \frac{9549\,P_{\text{kW}}}{n}',
        plain: 'T [N·m] = 9549 · P [kW] / n [rpm]',
        caption: 'Praktische Form',
      ),
    ],
    symbols: [
      HelpSymbol('P', 'Übertragene Leistung', 'W'),
      HelpSymbol('T', 'Drehmoment', 'N·m'),
      HelpSymbol('ω', 'Winkelgeschwindigkeit', 'rad/s'),
      HelpSymbol('n', 'Drehzahl', 'rpm'),
    ],
    notes: [
      'Das ist das im stationären Betrieb übertragene Moment. Anfahr-, Brems- '
          'und Blockiermomente können ein Vielfaches betragen — vor der '
          'Wellenauslegung einen Betriebsfaktor ansetzen.',
      'Leistung hinein, Leistung heraus: Verluste im Getriebestrang sind '
          'gesondert durch Division mit dem Wirkungsgrad zu berücksichtigen.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 7',
      'Hibbeler, Mechanics of Materials, ch. 5',
    ],
  ),
  109: ToolHelp(
    summary: 'Membranspannung in der Wand eines dünnwandigen kugelförmigen '
        'Druckbehälters. Die Kugel ist die wirtschaftlichste Form für '
        'Innendruck: Die Spannung ist in jeder Richtung gleich groß und halb '
        'so hoch wie die Umfangsspannung eines Zylinders mit gleichem Radius '
        'und gleicher Wanddicke.',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{pr}{2t}',
        plain: 'σ = p·r / (2·t)',
        caption: 'Membranspannung, in allen Richtungen gleich',
      ),
    ],
    symbols: [
      HelpSymbol('σ', 'Membranspannung', 'MPa'),
      HelpSymbol('p', 'Innerer Überdruck', 'MPa'),
      HelpSymbol('r', 'Innenradius', 'mm'),
      HelpSymbol('t', 'Wanddicke', 'mm'),
    ],
    notes: [
      'Dünnwandtheorie, gültig solange r/t größer als etwa 10 ist. Darunter '
          'ändert sich die Spannung über die Wanddicke, und es ist eine '
          'Dickwandlösung (Lamé) nötig.',
      'Nur Membranspannungen. Stutzen, Auflager und der Anschluss an jede '
          'andere Form heben die örtlichen Spannungen weit darüber hinaus — '
          'genau damit füllen Druckbehälterregelwerke ihre Seiten.',
      'Eine Auslegung nach einem Regelwerk wie ASME VIII ergänzt einen '
          'Nahtfaktor und einen Korrosionszuschlag; hier steht die reine '
          'Mechanik.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 8',
      'ASME BPVC Section VIII, Division 1, UG-27',
    ],
    diagram: 'images/icon_spherical_shell_stress.png',
  ),
  110: ToolHelp(
    summary: 'Umfangs- und Längsmembranspannung in einem dünnwandigen '
        'Zylinder unter Innendruck. Die Umfangsspannung ist doppelt so groß '
        'wie die Längsspannung — deshalb reißt ein unter Druck stehendes Rohr '
        'längs auf und nicht rundum.',
    formulas: [
      HelpFormula(
        tex: r'\sigma_h = \frac{pr}{t}',
        plain: 'σh = p·r / t',
        caption: 'Umfangsspannung',
      ),
      HelpFormula(
        tex: r'\sigma_l = \frac{pr}{2t}',
        plain: 'σl = p·r / (2·t)',
        caption: 'Längsspannung',
      ),
    ],
    symbols: [
      HelpSymbol('σh', 'Umfangsspannung', 'MPa'),
      HelpSymbol('σl', 'Längsspannung', 'MPa'),
      HelpSymbol('p', 'Innerer Überdruck', 'MPa'),
      HelpSymbol('r', 'Innenradius', 'mm'),
      HelpSymbol('t', 'Wanddicke', 'mm'),
    ],
    notes: [
      'Dünnwandtheorie, gültig solange r/t größer als etwa 10 ist.',
      'Die beiden Spannungen sind die Hauptspannungen in der Wand, die dritte '
          'ist näherungsweise null. In das Werkzeug für Festigkeitskriterien '
          'eingegeben ergeben sie eine Vergleichsspannung.',
      'Eine Längsspannung entsteht nur, wenn der Zylinder geschlossen ist. Ein '
          'offenes, anders gehaltenes Rohr trägt eine andere Axiallast.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 8',
      'ASME BPVC Section VIII, Division 1, UG-27',
    ],
    diagram: 'images/icon_cylindrical_pressure_stress.png',
  ),
  107: ToolHelp(
    summary: 'Dreht einen ebenen Spannungszustand in beliebige andere Achsen. '
        'Derselbe physikalische Zustand liest sich je nach betrachteter Ebene '
        'anders, und die Transformation liefert die Spannung in einer Naht, '
        'einer Klebefuge oder einer Faserrichtung, die nicht mit dem Bauteil '
        'ausgerichtet ist.',
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
      HelpSymbol('σx, σy', 'Normalspannungen in den Ausgangsachsen', 'MPa'),
      HelpSymbol('τxy', 'Schubspannung in den Ausgangsachsen', 'MPa'),
      HelpSymbol('θ', 'Drehung zu den neuen Achsen, gegen den Uhrzeigersinn '
          'positiv', '°'),
    ],
    notes: [
      'Ebener Spannungszustand: Die dritte Hauptspannung ist null. Für eine '
          'in ihrer Ebene belastete dünne Scheibe ein gutes Modell, tief im '
          'Inneren eines dicken Körpers ein schlechtes.',
      'Vorzeichen: Zugnormalspannung positiv, Schub positiv, wenn er an der '
          '+x-Fläche in +y-Richtung wirkt. Ein Vorzeichenfehler hier ist die '
          'übliche Ursache für ein falsches Ergebnis.',
      'In der Transformation treten die Winkel doppelt auf — genau das '
          'zeichnet der Mohrsche Spannungskreis: dieselben Beziehungen, nur '
          'geometrisch gesehen.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 9',
      'Gere & Goodno, Mechanics of Materials, ch. 7',
    ],
    diagram: 'images/icon_stress_element_inclined.png',
  ),
  108: ToolHelp(
    summary: 'Die größte und die kleinste Normalspannung in einem Punkt und '
        'die Ebenen, in denen sie wirken. Die meisten Festigkeitskriterien '
        'sind in Hauptspannungen formuliert, deshalb steht dieser Schritt '
        'meist zwischen Spannungsanalyse und Sicherheitsbeiwert.',
    formulas: [
      HelpFormula(
        tex: r'\sigma_{1,2} = \frac{\sigma_x+\sigma_y}{2} \pm '
            r'\sqrt{\left(\frac{\sigma_x-\sigma_y}{2}\right)^2 + \tau_{xy}^2}',
        plain: 'σ1,2 = (σx+σy)/2 ± √[ ((σx−σy)/2)² + τxy² ]',
        caption: 'Hauptspannungen',
      ),
      HelpFormula(
        tex: r'\tan 2\theta_p = \frac{2\tau_{xy}}{\sigma_x-\sigma_y}',
        plain: 'tan2θp = 2·τxy / (σx − σy)',
        caption: 'Lage der Hauptebenen',
      ),
      HelpFormula(
        tex: r'\tau_{\max} = \frac{\sigma_1-\sigma_2}{2}',
        plain: 'τmax = (σ1 − σ2) / 2',
        caption: 'Größte Schubspannung in der Ebene',
      ),
    ],
    symbols: [
      HelpSymbol('σ1, σ2', 'Hauptspannungen, σ1 ≥ σ2', 'MPa'),
      HelpSymbol('θp', 'Winkel von x zur σ1-Ebene', '°'),
      HelpSymbol('τmax', 'Größte Schubspannung in der Ebene', 'MPa'),
    ],
    notes: [
      'In einer Hauptebene wirkt keine Schubspannung — das ist ihre '
          'Definition.',
      'Im ebenen Spannungszustand ist die dritte Hauptspannung null, und sie '
          'kann trotzdem die kleinste der drei sein. Die tatsächlich größte '
          'Schubspannung ist (σmax − σmin)/2 über alle drei und übertrifft den '
          'Wert in der Ebene immer dann, wenn σ1 und σ2 dasselbe Vorzeichen '
          'haben.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 9',
      'Boresi & Schmidt, Advanced Mechanics of Materials, ch. 2',
    ],
    diagram: 'images/icon_stress_element.png',
  ),
  118: ToolHelp(
    summary: 'Der Mohrsche Spannungskreis ist die Spannungstransformation als '
        'Geometrie. Jede Ebene durch den Punkt entspricht einer Stelle auf '
        'einem Kreis, dessen Mittelpunkt die mittlere Normalspannung und '
        'dessen Radius die größte Schubspannung in der Ebene ist. Damit sind '
        'Hauptspannungen und ihre Lage auf einen Blick ablesbar.',
    formulas: [
      HelpFormula(
        tex: r'C = \frac{\sigma_x+\sigma_y}{2}, \quad '
            r'R = \sqrt{\left(\frac{\sigma_x-\sigma_y}{2}\right)^2+\tau_{xy}^2}',
        plain: 'C = (σx+σy)/2, R = √[ ((σx−σy)/2)² + τxy² ]',
        caption: 'Mittelpunkt und Radius',
      ),
      HelpFormula(
        tex: r'\sigma_{1,2} = C \pm R, \quad \tau_{\max} = R',
        plain: 'σ1,2 = C ± R, τmax = R',
      ),
    ],
    symbols: [
      HelpSymbol('C', 'Kreismittelpunkt, die mittlere Normalspannung', 'MPa'),
      HelpSymbol('R', 'Kreisradius, die größte Schubspannung in der Ebene',
          'MPa'),
      HelpSymbol('σx, σy, τxy', 'Der dargestellte Spannungszustand', 'MPa'),
    ],
    notes: [
      'Ein voller Umlauf auf dem Kreis entspricht einer Drehung des '
          'Elements um 180°: Winkel im Kreis sind doppelt so groß wie die '
          'wirklichen.',
      'Nur ebener Spannungszustand. Ein vollständiger räumlicher Zustand '
          'zeichnet sich als drei Kreise, und der äußerste bestimmt die größte '
          'Schubspannung.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 9',
      'Gere & Goodno, Mechanics of Materials, ch. 7',
    ],
    diagram: 'images/icon_stress_element_inclined.png',
  ),
  116: ToolHelp(
    summary: 'Rechnet einen zweiachsigen Spannungszustand in eine einzige '
        'Vergleichsspannung um, die sich mit der Streckgrenze vergleichen '
        'lässt. Von Mises (Gestaltänderungsenergie) ist die übliche Wahl für '
        'zähe Metalle; Tresca (größte Schubspannung) liegt etwas auf der '
        'sicheren Seite und wird von einigen Druckbehälterregelwerken bis '
        'heute verwendet.',
    formulas: [
      HelpFormula(
        tex: r'\sigma_{VM} = \sqrt{\sigma_1^2 - \sigma_1\sigma_2 + \sigma_2^2}',
        plain: 'σVM = √(σ1² − σ1·σ2 + σ2²)',
        caption: 'Von Mises, ebener Spannungszustand',
      ),
      HelpFormula(
        tex: r'\sigma_{Tresca} = |\sigma_1 - \sigma_2|',
        plain: 'σTresca = |σ1 − σ2|',
        caption: 'Vergleichsspannung nach Tresca',
      ),
      HelpFormula(
        tex: r'n = \frac{S_y}{\sigma_{eq}}',
        plain: 'n = Sy / σeq',
        caption: 'Sicherheit gegen Fließen',
      ),
    ],
    symbols: [
      HelpSymbol('σ1, σ2', 'Hauptspannungen', 'MPa'),
      HelpSymbol('σVM', 'Vergleichsspannung nach von Mises', 'MPa'),
      HelpSymbol('Sy', 'Streckgrenze', 'MPa'),
      HelpSymbol('n', 'Sicherheitsbeiwert'),
    ],
    notes: [
      'Beide Kriterien sagen das Fließen zäher Werkstoffe voraus. Spröde '
          'Werkstoffe versagen stattdessen nach der größten Hauptspannung oder '
          'nach Mohr–Coulomb; von Mises auf Gusseisen anzuwenden führt in die '
          'Irre.',
      'Tresca liegt von beiden weiter auf der sicheren Seite, um bis zu etwa '
          '15% — im einachsigen Zug stimmen beide überein, im reinen Schub '
          'weichen sie am stärksten ab.',
      'Nur statisches Fließen. Schwingende Belastung braucht ein '
          'Ermüdungskriterium.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 5',
      'Hibbeler, Mechanics of Materials, ch. 10',
    ],
  ),
  119: ToolHelp(
    summary: 'Sicherheitsbeiwert für ein Bauteil unter schwingender Spannung '
        'mit von null verschiedener Mittelspannung, nach dem modifizierten '
        'Goodman-Kriterium. Eine Zugmittelspannung verschlechtert die '
        'Ermüdungsfestigkeit stärker, als der Ausschlag allein vermuten lässt, '
        'und Goodman ist der übliche, leicht konservative Weg, das zu '
        'berücksichtigen.',
    formulas: [
      HelpFormula(
        tex: r'\frac{\sigma_a}{S_e} + \frac{\sigma_m}{S_{ut}} = \frac{1}{n}',
        plain: 'σa/Se + σm/Sut = 1/n',
        caption: 'Modifizierte Goodman-Gerade',
      ),
      HelpFormula(
        tex: r'\sigma_a = \frac{\sigma_{\max}-\sigma_{\min}}{2}, \quad '
            r'\sigma_m = \frac{\sigma_{\max}+\sigma_{\min}}{2}',
        plain: 'σa = (σmax − σmin)/2, σm = (σmax + σmin)/2',
        caption: 'Ausschlag und Mittelwert',
      ),
    ],
    symbols: [
      HelpSymbol('σa', 'Spannungsamplitude', 'MPa'),
      HelpSymbol('σm', 'Mittelspannung', 'MPa'),
      HelpSymbol('Se', 'Korrigierte Dauerfestigkeit', 'MPa'),
      HelpSymbol('Sut', 'Zugfestigkeit', 'MPa'),
      HelpSymbol('n', 'Sicherheit gegen Ermüdung'),
    ],
    notes: [
      'Bleibt Se leer, wird 0,5·Sut angesetzt, die übliche erste Schätzung für '
          'Stahl. Das ist ein unkorrigierter Wert: In einer realen Auslegung '
          'kommen die Marin-Faktoren für Oberfläche, Größe, Belastungsart, '
          'Temperatur und Zuverlässigkeit hinzu, die ihn typischerweise noch '
          'einmal halbieren.',
      'Nichteisenmetalle und Aluminium haben keine echte Dauerfestigkeit — sie '
          'werden mit zunehmender Lastspielzahl immer schwächer, sodass statt '
          'dieser Rechnung eine Zeitfestigkeitsbetrachtung nötig ist.',
      'Eine Druckmittelspannung schädigt nicht in gleicher Weise. Goodman auf '
          'negatives σm angewendet ist so konservativ, dass es falsch wird; '
          'dort σm = 0 setzen.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 6',
      'Norton, Machine Design, ch. 6',
    ],
  ),
  112: ToolHelp(
    summary: 'Freie Wärmedehnung eines Stabes und die Spannung, die entsteht, '
        'wenn diese Dehnung verhindert wird. Ein vollständig behindertes '
        'Bauteil entwickelt eine Spannung, die nur von Werkstoff und '
        'Temperaturänderung abhängt — nicht von Länge oder Querschnitt. '
        'Deshalb brauchen lange Rohrleitungen Dehnungsbögen und keine '
        'dickeren Wände.',
    formulas: [
      HelpFormula(
        tex: r'\delta_T = \alpha \, \Delta T \, L',
        plain: 'δT = α · ΔT · L',
        caption: 'Freie Dehnung',
      ),
      HelpFormula(
        tex: r'\sigma_T = -E \alpha \, \Delta T',
        plain: 'σT = −E · α · ΔT',
        caption: 'Spannung bei voller Behinderung',
      ),
    ],
    symbols: [
      HelpSymbol('δT', 'Freie Längenänderung', 'mm'),
      HelpSymbol('α', 'Wärmeausdehnungskoeffizient', '1/°C'),
      HelpSymbol('ΔT', 'Temperaturänderung', '°C'),
      HelpSymbol('L', 'Ursprüngliche Länge', 'mm'),
      HelpSymbol('σT', 'Wärmespannung, bei Erwärmung Druck', 'MPa'),
    ],
    notes: [
      'Die Zwängungsspannung hängt nicht von L und A ab. Ein kräftigeres '
          'Bauteil senkt sie nicht — nur Bewegung zulassen oder ΔT verringern.',
      'Volle Behinderung ist der ungünstigste Fall. Teilweise Behinderung '
          'ergibt eine Spannung zwischen null und diesem Wert, im Verhältnis '
          'zur verhinderten Bewegung.',
      'α ändert sich mit der Temperatur; über einen großen Bereich einen '
          'Mittelwert für das Intervall verwenden statt des Werts bei '
          'Raumtemperatur.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 4',
      'Gere & Goodno, Mechanics of Materials, ch. 2',
    ],
  ),
  111: ToolHelp(
    summary: 'Die Axiallast, bei der ein schlanker Stab seine Stabilität '
        'verliert und seitlich ausweicht. Knicken ist ein Versagen der '
        'Steifigkeit, nicht der Festigkeit: Die kritische Last hängt von E und '
        'I ab und kaum davon, wie fest der Werkstoff ist. Ein langer Stab kann '
        'bei einem Bruchteil jener Last knicken, die ihn zum Fließen brächte.',
    formulas: [
      HelpFormula(
        tex: r'P_{cr} = \frac{\pi^2 EI}{(KL)^2}',
        plain: 'Pcr = π²·E·I / (K·L)²',
        caption: 'Kritische Last nach Euler',
      ),
      HelpFormula(
        tex: r'\sigma_{cr} = \frac{P_{cr}}{A}, \quad '
            r'\lambda = \frac{KL}{r}, \quad r = \sqrt{\frac{I}{A}}',
        plain: 'σcr = Pcr / A, λ = K·L / r, r = √(I/A)',
        caption: 'Kritische Spannung und Schlankheitsgrad',
      ),
    ],
    symbols: [
      HelpSymbol('Pcr', 'Kritische Knicklast (Euler)', 'N'),
      HelpSymbol('E', 'Elastizitätsmodul', 'MPa'),
      HelpSymbol('I', 'Kleinstes Flächenträgheitsmoment', 'mm⁴'),
      HelpSymbol('K', 'Knicklängenbeiwert, aus den Lagerungsbedingungen'),
      HelpSymbol('L', 'Ungestützte Länge', 'mm'),
      HelpSymbol('λ', 'Schlankheitsgrad'),
    ],
    notes: [
      'Das kleinste I des Querschnitts verwenden: Ein Stab knickt um seine '
          'schwächste Achse aus, gleich in welche Richtung man ihn erwartet '
          'hätte.',
      'Theoretisch ist K = 1,0 bei beidseitig gelenkiger, 0,5 bei beidseitig '
          'eingespannter, 0,7 bei eingespannt–gelenkiger und 2,0 bei '
          'eingespannt–freier Lagerung. Regelwerke empfehlen größere Werte, '
          'weil reale Lager nie ideal eingespannt sind.',
      'Euler gilt nur für schlanke Stäbe. Übersteigt σcr etwa die halbe '
          'Streckgrenze, übernimmt unelastisches Knicken, und man verwendet '
          'die Johnson-Parabel oder eine Knickspannungslinie aus dem '
          'Regelwerk.',
      'Setzt einen ideal geraden, mittig belasteten Stab voraus. Reale '
          'Vorkrümmung und Lastexzentrizität mindern die Tragfähigkeit — dafür '
          'stehen die Sicherheitsbeiwerte in den Regelwerken.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 13',
      'AISC Steel Construction Manual, ch. E',
    ],
    diagram: 'images/buckling/icon_buckling_pinned_pinned.png',
  ),
  120: ToolHelp(
    summary: 'Die drei Arten, wie eine geschraubte oder genietete '
        'Überlappungsverbindung in Blech und Verbindungsmittel versagt: '
        'Abscheren der Schraube, Lochleibung im Blech und Ausreißen des Blechs '
        'zum freien Rand. Alle drei werden zugleich geprüft, denn eine '
        'Verbindung ist nur so gut wie ihr schwächster Nachweis.',
    formulas: [
      HelpFormula(
        tex: r'\tau = \frac{P}{n\,m\,\frac{\pi d^2}{4}}',
        plain: 'τ = P / (n·m·π·d²/4)',
        caption: 'Abscheren; m = 1 einschnittig, 2 zweischnittig',
      ),
      HelpFormula(
        tex: r'\sigma_b = \frac{P}{n\,d\,t}',
        plain: 'σb = P / (n·d·t)',
        caption: 'Lochleibungsspannung auf der projizierten Fläche',
      ),
      HelpFormula(
        tex: r'\tau_{to} = \frac{P}{2n\left(e-\frac{d}{2}\right)t}',
        plain: 'τto = P / [2·n·(e − d/2)·t]',
        caption: 'Ausreißen entlang zweier Scherflächen zum Rand',
      ),
    ],
    symbols: [
      HelpSymbol('P', 'Last auf der Verbindung', 'N'),
      HelpSymbol('n', 'Anzahl der Verbindungsmittel'),
      HelpSymbol('m', 'Scherflächen je Verbindungsmittel: 1 oder 2'),
      HelpSymbol('d', 'Durchmesser des Verbindungsmittels', 'mm'),
      HelpSymbol('t', 'Dünnstes verbundenes Blech', 'mm'),
      HelpSymbol('e', 'Randabstand, Lochmitte bis freier Rand', 'mm'),
    ],
    notes: [
      'Eine Scher-Lochleibungs-Verbindung: Die Last wird über die Leibung der '
          'Löcher getragen, nicht über Reibung. Eine gleitfeste Verbindung '
          'wird über Vorspannung und Reibung ausgelegt, und diese Werte sind '
          'dort nicht maßgebend.',
      'Setzt voraus, dass sich die Last gleichmäßig auf die Verbindungsmittel '
          'verteilt. Für eine kurze, kompakte Gruppe ist das vertretbar, für '
          'eine lange Reihe optimistisch — dort tragen die äußeren mehr.',
      'Zug im Nettoquerschnitt des Blechs ist eine vierte Versagensart und '
          'wird hier nicht geprüft — Lochfläche abziehen und gesondert '
          'nachweisen.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 8',
      'AISC Steel Construction Manual, ch. J3',
    ],
  ),
  121: ToolHelp(
    summary: 'Fasst Axialkraft, Biegung und Torsion an derselben Stelle zu '
        'einer Normalspannung und einer Schubspannung zusammen. Solange alles '
        'linear elastisch bleibt, gilt die Überlagerung, und das entstehende '
        'Paar ist genau das, was ein Festigkeitskriterium braucht.',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{P}{A} + \frac{Mc}{I}',
        plain: 'σ = P/A + M·c/I',
        caption: 'Normalspannung: Axialkraft und Biegung',
      ),
      HelpFormula(
        tex: r'\tau = \frac{Tr}{J}',
        plain: 'τ = T·r / J',
        caption: 'Schubspannung aus Torsion',
      ),
    ],
    symbols: [
      HelpSymbol('P', 'Axialkraft, Zug positiv', 'N'),
      HelpSymbol('A', 'Querschnittsfläche', 'mm²'),
      HelpSymbol('M', 'Biegemoment', 'N·mm'),
      HelpSymbol('c', 'Abstand der Stelle von der neutralen Faser', 'mm'),
      HelpSymbol('I', 'Flächenträgheitsmoment um die Biegeachse', 'mm⁴'),
      HelpSymbol('T', 'Torsionsmoment', 'N·mm'),
      HelpSymbol('r', 'Radius der betrachteten Stelle', 'mm'),
      HelpSymbol('J', 'Polares Flächenträgheitsmoment', 'mm⁴'),
    ],
    notes: [
      'Überlagerung setzt lineare Elastizität und kleine Verformungen voraus. '
          'Ein schlankes Bauteil unter Druck erhält zusätzlich ein Moment aus '
          'der Verformung selbst (P–δ-Effekt), das hier nicht enthalten ist.',
      'Die Querkraftschubspannung aus der Biegung ist davon getrennt und in '
          'der neutralen Faser am größten, wo die Biegespannung null ist. '
          'Beide Stellen prüfen, nicht nur die Randfaser.',
      'Momente in N·mm angeben, passend zu mm und MPa.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 8',
      'Shigley, Mechanical Engineering Design, ch. 3',
    ],
  ),

  102: ToolHelp(
    summary: 'Flächenträgheitsmomente der Standardquerschnitte um die '
        'Schwerachsen. I ist die geometrische Größe, die über die '
        'Biegesteifigkeit eines Querschnitts und über die Spannung bei '
        'gegebenem Moment entscheidet — sie macht den I-Träger wirtschaftlich '
        'und den Flachstahl nicht.',
    formulas: [
      HelpFormula(
        tex: r'I_x = \frac{bh^3}{12}, \quad I_y = \frac{hb^3}{12}',
        plain: 'Ix = b·h³/12, Iy = h·b³/12',
        caption: 'Rechteck, um den Schwerpunkt',
      ),
      HelpFormula(
        tex: r'I = \frac{\pi d^4}{64}',
        plain: 'I = π·d⁴/64',
        caption: 'Vollkreis',
      ),
      HelpFormula(
        tex: r'I = I_c + Ad^2',
        plain: 'I = Ic + A·d²',
        caption: 'Satz von Steiner, zum Umrechnen auf eine andere Achse',
      ),
    ],
    symbols: [
      HelpSymbol('I', 'Flächenträgheitsmoment', 'mm⁴'),
      HelpSymbol('b, h', 'Breite und Höhe', 'mm'),
      HelpSymbol('A', 'Fläche', 'mm²'),
      HelpSymbol('d', 'Abstand der beiden parallelen Achsen', 'mm'),
    ],
    notes: [
      'Die Höhe geht in der dritten Potenz ein, deshalb bringt Höhe weit mehr '
          'Steifigkeit als Breite: h zu verdoppeln vervielfacht Ix um acht, b '
          'zu verdoppeln nur um zwei.',
      'Der Satz von Steiner rechnet nur zwischen einer Schwerachse und einer '
          'dazu parallelen Achse um. Zwischen zwei Achsen, die beide nicht '
          'durch den Schwerpunkt gehen, muss man den Umweg über den '
          'Schwerpunkt nehmen.',
      'Das sind Flächenmomente in mm⁴ — nicht die Massenträgheitsmomente der '
          'Dynamik, die in kg·m² gemessen werden.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix A',
      'Gere & Goodno, Mechanics of Materials, ch. 12',
    ],
    diagram: 'images/cross_section/icon_cs_rectangle.png',
  ),
  117: ToolHelp(
    summary: 'Schwerpunkt, Fläche, Flächenträgheitsmomente sowie die daraus '
        'abgeleiteten Widerstandsmomente und Trägheitsradien eines '
        'Querschnitts. Diese Größen braucht jede Träger- und Stützenrechnung, '
        'und sie gemeinsam zu bestimmen hält sie untereinander widerspruchsfrei.',
    formulas: [
      HelpFormula(
        tex: r'\bar{y} = \frac{\sum A_i \bar{y}_i}{\sum A_i}',
        plain: 'ȳ = Σ(Ai·ȳi) / Σ Ai',
        caption: 'Schwerpunkt eines zusammengesetzten Querschnitts',
      ),
      HelpFormula(
        tex: r'S = \frac{I}{c}, \quad r = \sqrt{\frac{I}{A}}',
        plain: 'S = I / c, r = √(I / A)',
        caption: 'Widerstandsmoment und Trägheitsradius',
      ),
    ],
    symbols: [
      HelpSymbol('ȳ', 'Schwerpunktlage ab Bezugskante', 'mm'),
      HelpSymbol('I', 'Flächenträgheitsmoment um die Schwerachse', 'mm⁴'),
      HelpSymbol('S', 'Widerstandsmoment', 'mm³'),
      HelpSymbol('c', 'Abstand Schwerpunkt bis Randfaser', 'mm'),
      HelpSymbol('r', 'Trägheitsradius', 'mm'),
    ],
    notes: [
      'Das Widerstandsmoment bemisst einen Träger nach Festigkeit (σ = M/S), '
          'der Trägheitsradius eine Stütze nach Stabilität (λ = KL/r).',
      'Ist ein Querschnitt zur Biegeachse unsymmetrisch, unterscheidet sich c '
          'oben und unten, es gibt also zwei Widerstandsmomente. Das kleinere '
          'ist maßgebend.',
      'Aus reinen Abmessungen berechnete Werte enthalten weder Walzradien noch '
          'Schweißgut und liegen deshalb einige Prozent unter den '
          'veröffentlichten Werten eines Walzprofils. Für Katalogprofile die '
          'Profilbibliothek verwenden.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix A',
      'AISC Steel Construction Manual, Part 1',
    ],
  ),
  104: ToolHelp(
    summary: 'Biegespannung in beliebiger Höhe eines Trägerquerschnitts. Die '
        'Spannung verläuft linear von null in der neutralen Faser bis zum '
        'Höchstwert an der Randfaser. Deshalb trägt Material nahe der '
        'neutralen Faser fast nichts, und wirtschaftliche Querschnitte legen '
        'ihre Fläche weit davon entfernt an.',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{My}{I}',
        plain: 'σ = M·y / I',
        caption: 'Biegespannung im Abstand y von der neutralen Faser',
      ),
      HelpFormula(
        tex: r'\sigma_{\max} = \frac{Mc}{I} = \frac{M}{S}',
        plain: 'σmax = M·c / I = M / S',
        caption: 'An der Randfaser',
      ),
    ],
    symbols: [
      HelpSymbol('σ', 'Biegespannung, Zug positiv', 'MPa'),
      HelpSymbol('M', 'Biegemoment im Schnitt', 'N·mm'),
      HelpSymbol('y', 'Abstand von der neutralen Faser', 'mm'),
      HelpSymbol('I', 'Flächenträgheitsmoment um die Biegeachse', 'mm⁴'),
      HelpSymbol('c', 'Abstand bis zur Randfaser', 'mm'),
    ],
    notes: [
      'Euler-Bernoulli-Theorie: Querschnitte bleiben eben, der Werkstoff ist '
          'linear elastisch, der Träger gerade und prismatisch.',
      'Die neutrale Faser geht nur bei reiner Biegung eines homogenen '
          'Querschnitts durch den Schwerpunkt. Eine Axialkraft verschiebt sie, '
          'und ein Verbundquerschnitt braucht eine Betrachtung mit '
          'ideellem Querschnitt.',
      'Biegung um eine Achse, die keine Hauptachse ist, ist schiefe Biegung; '
          'diese einachsige Formel gilt dafür nicht.',
      'M in N·mm angeben, passend zu mm und MPa.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 6',
      'Gere & Goodno, Mechanics of Materials, ch. 5',
    ],
    diagram: 'images/icon_beam_bending.png',
  ),
  113: ToolHelp(
    summary: 'Querkraftschubspannung über einen Trägerquerschnitt. Sie ist in '
        'der neutralen Faser am größten — genau dort, wo die Biegespannung '
        'null ist — sodass beide in unterschiedlichen Höhen zu prüfen sind. '
        'Am wichtigsten ist sie bei kurzen, hohen Trägern und dünnen Stegen, '
        'wo Schub gegenüber Biegung maßgebend werden kann.',
    formulas: [
      HelpFormula(
        tex: r'\tau = \frac{VQ}{It}',
        plain: 'τ = V·Q / (I·t)',
        caption: 'Schubspannung in der Höhe, für die Q gebildet wird',
      ),
      HelpFormula(
        tex: r'\tau_{\max} = \frac{3V}{2A} \;\text{(rectangle)}, \quad '
            r'\frac{4V}{3A} \;\text{(circle)}',
        plain: 'τmax = 3V/(2A) Rechteck, 4V/(3A) Kreis',
        caption: 'Höchstwerte gängiger Vollquerschnitte',
      ),
    ],
    symbols: [
      HelpSymbol('τ', 'Querkraftschubspannung', 'MPa'),
      HelpSymbol('V', 'Querkraft im Schnitt', 'N'),
      HelpSymbol('Q', 'Statisches Moment der Fläche jenseits des Schnitts',
          'mm³'),
      HelpSymbol('I', 'Flächenträgheitsmoment des Gesamtquerschnitts', 'mm⁴'),
      HelpSymbol('t', 'Querschnittsbreite an der Schnittstelle', 'mm'),
    ],
    notes: [
      'Q ist das statische Moment nur der Fläche auf einer Seite der '
          'betrachteten Höhe, bezogen auf die neutrale Faser. Es ist in der '
          'neutralen Faser am größten und an den Randfasern null.',
      'Die Formel setzt voraus, dass die Schubspannung über die Breite t '
          'gleichmäßig ist. Für einen schmalen Steg trifft das gut zu, für '
          'einen breiten Flansch schlecht, wo die wirkliche Verteilung über '
          'die Breite schwankt.',
      'Beim I-Träger liegt die übliche Näherung V geteilt durch die '
          'Stegfläche nur wenige Prozent neben dem genauen Wert, und '
          'Regelwerke rechnen so.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 7',
      'Gere & Goodno, Mechanics of Materials, ch. 5',
    ],
  ),
  105: ToolHelp(
    summary: 'Durchbiegung und Neigung eines Kragträgers für die üblichen '
        'Lastfälle, aus den klassischen geschlossenen Lösungen. Gut für eine '
        'schnelle Steifigkeitsprüfung und zum Zusammensetzen komplizierterer '
        'Belastungen durch Überlagerung.',
    formulas: [
      HelpFormula(
        tex: r'\delta_{\max} = \frac{PL^3}{3EI}, \quad '
            r'\theta = \frac{PL^2}{2EI}',
        plain: 'δmax = P·L³/(3·E·I), θ = P·L²/(2·E·I)',
        caption: 'Einzellast P am freien Ende',
      ),
      HelpFormula(
        tex: r'\delta_{\max} = \frac{wL^4}{8EI}, \quad '
            r'\theta = \frac{wL^3}{6EI}',
        plain: 'δmax = w·L⁴/(8·E·I), θ = w·L³/(6·E·I)',
        caption: 'Gleichlast w über die volle Länge',
      ),
    ],
    symbols: [
      HelpSymbol('δ', 'Durchbiegung', 'mm'),
      HelpSymbol('θ', 'Neigung', 'rad'),
      HelpSymbol('P', 'Einzellast', 'N'),
      HelpSymbol('w', 'Streckenlast', 'N/mm'),
      HelpSymbol('L', 'Länge ab der Einspannung', 'mm'),
      HelpSymbol('E·I', 'Biegesteifigkeit', 'N·mm²'),
    ],
    notes: [
      'Die Durchbiegung geht mit L³ beziehungsweise L⁴. Verdoppelt man die '
          'Länge eines endbelasteten Kragträgers, wird er achtmal weicher — '
          'die Länge überwiegt alles andere.',
      'Euler-Bernoulli-Theorie kleiner Verformungen ohne Schubverformung. '
          'Für einen gedrungenen Kragträger, etwa L/d unter 10, einen '
          'Schubanteil ergänzen.',
      'Lasten überlagern sich: Bei mehreren Lasten gleichzeitig die '
          'Durchbiegungen der Einzelfälle addieren.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix C',
      'Roark\'s Formulas for Stress and Strain, Table 8.1',
    ],
    diagram: 'images/cantilever_beam/icon_cantilever_beam.png',
  ),
  106: ToolHelp(
    summary: 'Durchbiegung und Neigung eines Einfeldträgers für die üblichen '
        'Lastfälle. Dieselben geschlossenen Lösungen, die ein Handbuch '
        'tabelliert — zum schnellen Prüfen einer Stützweite oder zum '
        'Zusammensetzen komplizierterer Lastfälle durch Überlagerung.',
    formulas: [
      HelpFormula(
        tex: r'\delta_{\max} = \frac{PL^3}{48EI}',
        plain: 'δmax = P·L³/(48·E·I)',
        caption: 'Einzellast in Feldmitte',
      ),
      HelpFormula(
        tex: r'\delta_{\max} = \frac{5wL^4}{384EI}',
        plain: 'δmax = 5·w·L⁴/(384·E·I)',
        caption: 'Gleichlast über die volle Stützweite',
      ),
    ],
    symbols: [
      HelpSymbol('δ', 'Durchbiegung', 'mm'),
      HelpSymbol('P', 'Einzellast', 'N'),
      HelpSymbol('w', 'Streckenlast', 'N/mm'),
      HelpSymbol('L', 'Stützweite', 'mm'),
      HelpSymbol('E·I', 'Biegesteifigkeit', 'N·mm²'),
    ],
    notes: [
      'Bei außermittiger Einzellast liegt die größte Durchbiegung weder unter '
          'der Last noch in Feldmitte — der Wert in Feldmitte liegt aber '
          'innerhalb von etwa 2,5% davon, weshalb Handbücher ihn angeben.',
      'Theorie kleiner Verformungen, ein Auflager gelenkig, das andere '
          'verschieblich, also ohne Längsbehinderung. Ein beidseitig in '
          'Längsrichtung gehaltener Träger versteift sich beim Durchbiegen, '
          'sodass diese Formel die Verformung überschätzt.',
      'Gebrauchstauglichkeitsgrenzen sind meist ein Bruchteil der Stützweite '
          '— L/360 unter Nutzlast ist ein gängiges Kriterium für Decken — und '
          'keine Spannungsgrenze.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix C',
      'Roark\'s Formulas for Stress and Strain, Table 8.1',
    ],
    diagram: 'images/simple_beam/icon_simple_beam.png',
  ),
  401: ToolHelp(
    summary: 'Auflagerkräfte, Querkraft und Biegemoment eines Einfeldträgers '
        'unter Einzellast, Gleichlast oder beidem. Querkraft- und '
        'Momentenverlauf sagen, wo der Querschnitt zu prüfen ist und mit '
        'welchem M das zu geschehen hat.',
    formulas: [
      HelpFormula(
        tex: r'\sum F_y = 0, \quad \sum M = 0',
        plain: 'ΣFy = 0, ΣM = 0',
        caption: 'Gleichgewicht, damit liegen die beiden Auflagerkräfte fest',
      ),
      HelpFormula(
        tex: r'V(x) = R_A - \int_0^x w\,dx, \quad M(x) = \int_0^x V\,dx',
        plain: 'V(x) = RA − ∫w dx, M(x) = ∫V dx',
        caption: 'Querkraft und Moment über die Länge',
      ),
      HelpFormula(
        tex: r'M_{\max} = \frac{wL^2}{8} \;\text{(UDL)}, \quad '
            r'\frac{PL}{4} \;\text{(central point load)}',
        plain: 'Mmax = w·L²/8 (Gleichlast), P·L/4 (Einzellast in Feldmitte)',
      ),
    ],
    symbols: [
      HelpSymbol('RA, RB', 'Auflagerkräfte', 'N'),
      HelpSymbol('V', 'Querkraft', 'N'),
      HelpSymbol('M', 'Biegemoment', 'N·mm'),
      HelpSymbol('w', 'Gleichstreckenlast', 'N/mm'),
      HelpSymbol('L', 'Stützweite', 'mm'),
    ],
    notes: [
      'Nur statisch bestimmt: ein gelenkiges und ein verschiebliches '
          'Auflager. Ein Träger mit drittem Auflager oder eingespannten Enden '
          'ist unbestimmt und braucht neben dem Gleichgewicht auch '
          'Verträglichkeitsbedingungen.',
      'Das Moment ist dort am größten, wo die Querkraft null durchläuft. Das '
          'ist der zu bemessende Schnitt, und bei außermittiger Last liegt er '
          'nicht in Feldmitte.',
      'Das Eigengewicht ist nicht enthalten, solange man es nicht zur '
          'Streckenlast hinzunimmt.',
    ],
    references: [
      'Hibbeler, Structural Analysis, ch. 4',
      'Gere & Goodno, Mechanics of Materials, ch. 4',
    ],
    diagram: 'images/simple_beam/icon_simple_beam.png',
  ),
  400: ToolHelp(
    summary: 'Fasst zentrale Kräfte in einer Ebene zu einer Resultierenden '
        'zusammen, mit Betrag und Richtung. Der erste Schritt fast jeder '
        'Statikaufgabe: mehrere Kräfte durch die eine Kraft ersetzen, die '
        'dasselbe bewirkt.',
    formulas: [
      HelpFormula(
        tex: r'R_x = \sum F_i\cos\theta_i, \quad R_y = \sum F_i\sin\theta_i',
        plain: 'Rx = Σ Fi·cosθi, Ry = Σ Fi·sinθi',
        caption: 'Komponenten',
      ),
      HelpFormula(
        tex: r'R = \sqrt{R_x^2+R_y^2}, \quad '
            r'\theta_R = \operatorname{atan2}(R_y, R_x)',
        plain: 'R = √(Rx² + Ry²), θR = atan2(Ry, Rx)',
        caption: 'Betrag und Richtung',
      ),
    ],
    symbols: [
      HelpSymbol('F', 'Betrag jeder Kraft', 'N'),
      HelpSymbol('θ', 'Richtung jeder Kraft, ab der +x-Achse', '°'),
      HelpSymbol('R', 'Betrag der Resultierenden', 'N'),
      HelpSymbol('θR', 'Richtung der Resultierenden', '°'),
    ],
    notes: [
      'Nur zentrale Kräfte — alle Wirkungslinien schneiden sich in einem '
          'Punkt. Nicht zentrale Kräfte erzeugen zusätzlich ein Kräftepaar, '
          'das verloren geht, wenn man sie durch eine Einzelkraft an der '
          'falschen Stelle ersetzt.',
      'Verwendet wird atan2 statt arctan, damit der Quadrant stimmt; der '
          'reine Arkustangens kann 30° nicht von 210° unterscheiden.',
    ],
    references: [
      'Hibbeler, Engineering Mechanics: Statics, ch. 2',
      'Beer & Johnston, Vector Mechanics for Engineers, ch. 2',
    ],
  ),
  402: ToolHelp(
    summary: 'Schwerpunkt einer Fläche aus Rechtecken, Kreisen und Dreiecken, '
        'auch mit Aussparungen. Der Schwerpunkt ist die Stelle, an der das '
        'statische Moment der Fläche verschwindet, und er ist die Achse, auf '
        'die sich jede Biegerechnung bezieht — liegt er falsch, ist jede '
        'Spannung danach falsch.',
    formulas: [
      HelpFormula(
        tex: r'\bar{x} = \frac{\sum A_i \bar{x}_i}{\sum A_i}, \quad '
            r'\bar{y} = \frac{\sum A_i \bar{y}_i}{\sum A_i}',
        plain: 'x̄ = Σ(Ai·x̄i)/ΣAi, ȳ = Σ(Ai·ȳi)/ΣAi',
        caption: 'Flächengewichteter Mittelwert der Teilflächen',
      ),
    ],
    symbols: [
      HelpSymbol('Ai', 'Fläche jedes Teils, bei einer Aussparung negativ',
          'mm²'),
      HelpSymbol('x̄i, ȳi', 'Eigener Schwerpunkt jedes Teils', 'mm'),
      HelpSymbol('x̄, ȳ', 'Schwerpunkt des Ganzen', 'mm'),
    ],
    notes: [
      'Eine Aussparung als negative Fläche mit eigenem Schwerpunkt behandeln. '
          'Dann erledigt die Rechnung sie ohne Sonderfall.',
      'Der Schwerpunkt liegt auf jeder Symmetrieachse, was oft genügt, um '
          'eine Koordinate ohne Rechnung hinzuschreiben.',
      'Flächenschwerpunkt und Massenschwerpunkt fallen nur bei gleichmäßiger '
          'Dichte zusammen.',
    ],
    references: [
      'Hibbeler, Engineering Mechanics: Statics, ch. 9',
      'Beer & Johnston, Vector Mechanics for Engineers, ch. 5',
    ],
  ),
  403: ToolHelp(
    summary: 'Löst ein ebenes Gelenkfachwerk nach dem Knotenpunktverfahren: '
        'Jeder Knoten ist ein zentrales Kräftesystem im Gleichgewicht, sodass '
        'man Knoten für Knoten alle Stabkräfte erhält. Positiv ist Zug, '
        'negativ Druck.',
    formulas: [
      HelpFormula(
        tex: r'\sum F_x = 0, \quad \sum F_y = 0 \;\text{at every joint}',
        plain: 'ΣFx = 0 und ΣFy = 0 in jedem Knoten',
        caption: 'Gleichgewicht, zwei Gleichungen je Knoten',
      ),
      HelpFormula(
        tex: r'm + r = 2j',
        plain: 'm + r = 2·j',
        caption: 'Nachweis der statischen Bestimmtheit',
      ),
    ],
    symbols: [
      HelpSymbol('m', 'Anzahl der Stäbe'),
      HelpSymbol('r', 'Anzahl der Auflagerreaktionen'),
      HelpSymbol('j', 'Anzahl der Knoten'),
    ],
    notes: [
      'Setzt reibungsfreie Gelenke und Lasten nur in den Knoten voraus, '
          'sodass jeder Stab reine Normalkraft trägt. Eine Last in Stabmitte '
          'biegt ihn zusätzlich, und diese Biegung liegt außerhalb des '
          'Modells.',
      'm + r < 2j ist eine Kinematik und nicht standfest; m + r > 2j ist '
          'unbestimmt und braucht neben dem Gleichgewicht auch '
          'Stabsteifigkeiten.',
      'Ein bestimmtes Fachwerk kann bei ungünstiger Geometrie trotzdem '
          'unstabil sein, etwa bei drei auf einer Geraden liegenden '
          'Auflagerkräften. Die Abzählformel ist notwendig, nicht hinreichend.',
      'Druckstäbe sind zusätzlich auf Knicken zu prüfen, was hier nicht '
          'geschieht.',
    ],
    references: [
      'Hibbeler, Structural Analysis, ch. 3',
      'Beer & Johnston, Vector Mechanics for Engineers, ch. 6',
    ],
  ),
  200: ToolHelp(
    summary: 'Das verallgemeinerte Hookesche Gesetz für einen isotropen '
        'Werkstoff im Raum. Spannung in einer Richtung dehnt über die '
        'Querkontraktionszahl auch die beiden anderen, sodass die sechs '
        'Komponenten gekoppelt sind und nicht einzeln behandelt werden können.',
    formulas: [
      HelpFormula(
        tex: r'\varepsilon_x = \frac{1}{E}\left[\sigma_x - '
            r'\nu(\sigma_y+\sigma_z)\right]',
        plain: 'εx = [σx − ν(σy + σz)] / E',
        caption: 'Normaldehnung, eine von dreien',
      ),
      HelpFormula(
        tex: r'\gamma_{xy} = \frac{\tau_{xy}}{G}, \quad '
            r'G = \frac{E}{2(1+\nu)}',
        plain: 'γxy = τxy / G, G = E / [2(1 + ν)]',
        caption: 'Schubverzerrung und der Zusammenhang der Moduln',
      ),
    ],
    symbols: [
      HelpSymbol('ε', 'Normaldehnung'),
      HelpSymbol('γ', 'Technische Schubverzerrung'),
      HelpSymbol('σ, τ', 'Normal- und Schubspannung', 'MPa'),
      HelpSymbol('E', 'Elastizitätsmodul', 'MPa'),
      HelpSymbol('ν', 'Querkontraktionszahl'),
      HelpSymbol('G', 'Schubmodul', 'MPa'),
    ],
    notes: [
      'Isotroper, homogener, linear elastischer Werkstoff. Faserverbunde, '
          'stark texturiertes Walzblech und Holz sind nichts davon.',
      'Von E, G und ν sind bei einem isotropen Werkstoff nur zwei unabhängig, '
          'das dritte folgt. Alle drei widersprüchlich einzugeben ist ein '
          'beliebter Weg zu einem still falschen Ergebnis.',
      'Aus der thermodynamischen Stabilität folgt ν zwischen −1 und 0,5. '
          'Reale Metalle liegen nahe 0,3, und 0,5 bedeutet inkompressibel, '
          'wie es Gummi näherungsweise ist.',
    ],
    references: [
      'Timoshenko & Goodier, Theory of Elasticity, ch. 1',
      'Boresi & Schmidt, Advanced Mechanics of Materials, ch. 3',
    ],
  ),
  201: ToolHelp(
    summary: 'Rechnet in beide Richtungen zwischen einem vollständigen '
        'räumlichen Spannungszustand und dem zugehörigen Verzerrungszustand '
        'um. Die umgekehrte Form braucht die FE-Auswertung: Verzerrungen '
        'liefert das Netz, Spannungen verlangt das Kriterium.',
    formulas: [
      HelpFormula(
        tex: r'\sigma_x = \frac{E}{(1+\nu)(1-2\nu)}\left[(1-\nu)'
            r'\varepsilon_x + \nu(\varepsilon_y+\varepsilon_z)\right]',
        plain: 'σx = E/[(1+ν)(1−2ν)] · [(1−ν)εx + ν(εy + εz)]',
        caption: 'Spannung aus Verzerrung',
      ),
      HelpFormula(
        tex: r'\tau_{xy} = G\gamma_{xy}',
        plain: 'τxy = G · γxy',
        caption: 'Der Schub bleibt entkoppelt',
      ),
    ],
    symbols: [
      HelpSymbol('σ, τ', 'Normal- und Schubspannung', 'MPa'),
      HelpSymbol('ε, γ', 'Normaldehnung und technische Schubverzerrung'),
      HelpSymbol('E', 'Elastizitätsmodul', 'MPa'),
      HelpSymbol('ν', 'Querkontraktionszahl'),
    ],
    notes: [
      'Die Form Spannung-aus-Verzerrung läuft weg, wenn ν gegen 0,5 geht: Der '
          'Nenner (1 − 2ν) wird null, weil ein inkompressibler Werkstoff zu '
          'einer gegebenen Verzerrung keinen eindeutigen Druck hat. Nahezu '
          'inkompressible Werkstoffe brauchen eine gemischte Formulierung.',
      'Die technische Schubverzerrung γ ist doppelt so groß wie die '
          'Tensorschubverzerrung. Die beiden Konventionen zu vermischen ist '
          'ein leicht zu übersehender Faktor-zwei-Fehler.',
    ],
    references: [
      'Timoshenko & Goodier, Theory of Elasticity, ch. 1',
      'Sadd, Elasticity: Theory, Applications and Numerics, ch. 4',
    ],
  ),
  305: ToolHelp(
    summary: 'Schätzt Steifigkeit und Dichte einer unidirektionalen '
        'Einzelschicht aus den Kennwerten von Faser und Matrix. Längs der '
        'Fasern dehnen sich beide Phasen gleich, und die Steifigkeit mittelt '
        'sich über den Volumenanteil; quer dazu teilen sie sich die Last, und '
        'gemittelt werden die Nachgiebigkeiten — deshalb ist die '
        'Quersteifigkeit so viel geringer.',
    formulas: [
      HelpFormula(
        tex: r'E_1 = E_f V_f + E_m(1-V_f)',
        plain: 'E1 = Ef·Vf + Em·(1 − Vf)',
        caption: 'Längs — die Mischungsregel',
      ),
      HelpFormula(
        tex: r'\frac{1}{E_2} = \frac{V_f}{E_f} + \frac{1-V_f}{E_m}',
        plain: '1/E2 = Vf/Ef + (1 − Vf)/Em',
        caption: 'Quer — die inverse Mischungsregel',
      ),
      HelpFormula(
        tex: r'\nu_{12} = \nu_f V_f + \nu_m(1-V_f)',
        plain: 'ν12 = νf·Vf + νm·(1 − Vf)',
        caption: 'Große Querkontraktionszahl',
      ),
    ],
    symbols: [
      HelpSymbol('E1', 'Steifigkeit längs der Fasern', 'MPa'),
      HelpSymbol('E2', 'Steifigkeit quer zu den Fasern', 'MPa'),
      HelpSymbol('Vf', 'Faservolumengehalt'),
      HelpSymbol('Ef, Em', 'Modul von Faser und Matrix', 'MPa'),
    ],
    notes: [
      'E1 ist zuverlässig; die inverse Regel für E2 ist optimistisch, und '
          'Messwerte liegen meist darunter. Halpin–Tsai ist die übliche '
          'Verbesserung, wenn die Quersteifigkeit zählt.',
      'Volumenanteil, nicht Massenanteil. Lieferanten geben oft Massenanteile '
          'an — vorher mit den beiden Dichten umrechnen.',
      'Praktisch erreichbar ist Vf bis etwa 0,65 bei gut konsolidierten '
          'Laminaten; darüber ist zu wenig Matrix da, um die Fasern zu '
          'benetzen.',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 3',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 3',
    ],
    diagram: 'images/lamina.png',
  ),
  301: ToolHelp(
    summary: 'Die vier unabhängigen technischen Konstanten einer '
        'orthotropen Einzelschicht — zwei Moduln, ein Schubmodul und eine '
        'Querkontraktionszahl — und die Nachgiebigkeitsmatrix, die sich daraus '
        'aufbaut. Jede Laminatrechnung geht davon aus.',
    formulas: [
      HelpFormula(
        tex: r'\frac{\nu_{12}}{E_1} = \frac{\nu_{21}}{E_2}',
        plain: 'ν12 / E1 = ν21 / E2',
        caption: 'Reziprozität, sie macht die Nachgiebigkeitsmatrix symmetrisch',
      ),
      HelpFormula(
        tex: r'Q_{11} = \frac{E_1}{1-\nu_{12}\nu_{21}}, \quad '
            r'Q_{22} = \frac{E_2}{1-\nu_{12}\nu_{21}}, \quad Q_{66} = G_{12}',
        plain: 'Q11 = E1/(1 − ν12·ν21), Q22 = E2/(1 − ν12·ν21), Q66 = G12',
        caption: 'Reduzierte Steifigkeiten',
      ),
    ],
    symbols: [
      HelpSymbol('E1, E2', 'Längs- und Quermodul', 'MPa'),
      HelpSymbol('G12', 'Schubmodul in der Ebene', 'MPa'),
      HelpSymbol('ν12', 'Große Querkontraktionszahl'),
      HelpSymbol('Q', 'Glieder der reduzierten Steifigkeitsmatrix', 'MPa'),
    ],
    notes: [
      'Im ebenen Spannungszustand sind nur vier Konstanten unabhängig; ν21 '
          'folgt aus der Reziprozität. Ein abweichend gemessenes ν21 '
          'einzugeben macht die Matrix unsymmetrisch und unphysikalisch.',
      'ν12 ist die Querkontraktion in Richtung 2 infolge einer Last in '
          'Richtung 1. Die Reihenfolge der Indizes ist die häufigste '
          'Verwechslung in der Faserverbundtechnik, und manche Bücher drehen '
          'sie um.',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 4',
    ],
    diagram: 'images/lamina.png',
  ),
  300: ToolHelp(
    summary: 'Spannung und Verzerrung in einer Einzelschicht, in den '
        'Materialachsen oder in einem gedrehten System. Weil eine Schicht '
        'längs der Fasern weit steifer ist als quer dazu, dreht eine Drehung '
        'mehr als nur die Zahlen: Eine schräg liegende Schicht koppelt '
        'Normalspannung mit Schubverzerrung.',
    formulas: [
      HelpFormula(
        tex: r'\begin{bmatrix}\sigma_1\\\sigma_2\\\tau_{12}\end{bmatrix} = '
            r'[Q]\begin{bmatrix}\varepsilon_1\\\varepsilon_2\\'
            r'\gamma_{12}\end{bmatrix}',
        plain: '{σ1, σ2, τ12} = [Q] · {ε1, ε2, γ12}',
        caption: 'In den Materialachsen',
      ),
      HelpFormula(
        tex: r'[\bar{Q}] = [T]^{-1}[Q][T]^{-T}',
        plain: '[Q̄] = [T]⁻¹ [Q] [T]⁻ᵀ',
        caption: 'Transformiert in die Laminatachsen',
      ),
    ],
    symbols: [
      HelpSymbol('σ1, σ2', 'Spannung längs und quer zu den Fasern', 'MPa'),
      HelpSymbol('τ12', 'Schubspannung in der Ebene', 'MPa'),
      HelpSymbol('[Q]', 'Reduzierte Steifigkeitsmatrix', 'MPa'),
      HelpSymbol('θ', 'Schichtwinkel zur Laminat-x-Achse', '°'),
    ],
    notes: [
      'Ebener Spannungszustand in der Schicht: Spannungen über die Dicke '
          'werden vernachlässigt. Im Inneren eines dünnen Laminats ist das in '
          'Ordnung, am freien Rand nicht — dort beginnt die Delamination.',
      'Für jedes θ außer 0° und 90° hat die transformierte Matrix von null '
          'verschiedene Glieder Q̄16 und Q̄26 — die Kopplung von Schub und '
          'Dehnung. Das ist ein wirklicher Effekt und kein Rechenartefakt.',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 5',
    ],
    diagram: 'images/lamina.png',
  ),
  302: ToolHelp(
    summary: 'Klassische Laminattheorie: Sie setzt die Schichten zu den '
        'Matrizen A, B und D zusammen und verknüpft Schnittkräfte und '
        'Momente mit den Dehnungen und Krümmungen der Mittelebene. Damit wird '
        'aus einem Stapel Schichten ein Werkstoff mit vorhersagbarem Verhalten.',
    formulas: [
      HelpFormula(
        tex: r'\begin{bmatrix}N\\M\end{bmatrix} = '
            r'\begin{bmatrix}A & B\\B & D\end{bmatrix}'
            r'\begin{bmatrix}\varepsilon^0\\\kappa\end{bmatrix}',
        plain: '{N, M} = [[A, B], [B, D]] · {ε⁰, κ}',
        caption: 'Stoffgesetz des Laminats',
      ),
      HelpFormula(
        tex: r'A_{ij}=\sum \bar{Q}_{ij}(z_k-z_{k-1}), \quad '
            r'B_{ij}=\tfrac{1}{2}\sum \bar{Q}_{ij}(z_k^2-z_{k-1}^2), \quad '
            r'D_{ij}=\tfrac{1}{3}\sum \bar{Q}_{ij}(z_k^3-z_{k-1}^3)',
        plain: 'Aij = ΣQ̄ij·(zk − zk−1); Bij = ½ΣQ̄ij·(zk² − zk−1²); '
            'Dij = ⅓ΣQ̄ij·(zk³ − zk−1³)',
        caption: 'Dehn-, Kopplungs- und Biegesteifigkeit',
      ),
    ],
    symbols: [
      HelpSymbol('N', 'Schnittkraft je Breiteneinheit', 'N/mm'),
      HelpSymbol('M', 'Moment je Breiteneinheit', 'N·mm/mm'),
      HelpSymbol('ε⁰', 'Dehnung der Mittelebene'),
      HelpSymbol('κ', 'Krümmung', '1/mm'),
      HelpSymbol('z', 'Schichtgrenze über der Mittelebene', 'mm'),
    ],
    notes: [
      'B ist genau dann null, wenn der Aufbau zur Mittelebene symmetrisch '
          'ist. Ein von null verschiedenes B koppelt Dehnung und Biegung, '
          'sodass sich das Bauteil beim Abkühlen nach dem Aushärten verzieht — '
          'deshalb ist fast jedes praktische Laminat symmetrisch aufgebaut.',
      'Die klassische Laminattheorie vernachlässigt den Querschub und '
          'überschätzt daher die Steifigkeit dicker Laminate und von '
          'Sandwichplatten mit weichem Kern.',
      'Eigenspannungen aus dem Aushärten sind nicht enthalten und können '
          'einen großen Teil der Erstschichtversagenslast ausmachen.',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 4',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 7',
    ],
    diagram: 'images/laminate.png',
  ),
  303: ToolHelp(
    summary: 'Wirksame technische Konstanten eines Laminats in der Ebene — '
        'die Moduln, die man messen würde, wenn man den Aufbau wie eine '
        'homogene Platte prüfte. Nützlich, um einen Lagenaufbau mit Metall zu '
        'vergleichen und um ein Laminat in eine Rechnung einzusetzen, die nur '
        'einen Werkstoff kennt.',
    formulas: [
      HelpFormula(
        tex: r'E_x = \frac{1}{h\,a_{11}}, \quad E_y = \frac{1}{h\,a_{22}}, '
            r'\quad G_{xy} = \frac{1}{h\,a_{66}}',
        plain: 'Ex = 1/(h·a11), Ey = 1/(h·a22), Gxy = 1/(h·a66)',
        caption: 'Aus der invertierten Dehnsteifigkeit, [a] = [A]⁻¹',
      ),
      HelpFormula(
        tex: r'\nu_{xy} = -\frac{a_{12}}{a_{11}}',
        plain: 'νxy = −a12 / a11',
      ),
    ],
    symbols: [
      HelpSymbol('Ex, Ey', 'Wirksame Moduln in der Ebene', 'MPa'),
      HelpSymbol('Gxy', 'Wirksamer Schubmodul in der Ebene', 'MPa'),
      HelpSymbol('h', 'Gesamtdicke des Laminats', 'mm'),
      HelpSymbol('[a]', 'Inverse der A-Matrix', 'mm/N'),
    ],
    notes: [
      'Diese Werte beschreiben nur das Verhalten in der Ebene. Die '
          'Biegesteifigkeit kommt aus D, und für dieselben Schichten in '
          'anderer Reihenfolge fällt sie anders aus, obwohl A gleich bleibt — '
          'die Lagenreihenfolge zählt für Biegung, nicht für Dehnung.',
      'Nur für ein symmetrisches Laminat sinnvoll. Mit einer von null '
          'verschiedenen B-Matrix verhält sich der Aufbau überhaupt nicht wie '
          'eine homogene Platte.',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 4',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 7',
    ],
    diagram: 'images/laminate.png',
  ),
  304: ToolHelp(
    summary: 'Räumliche Ersatzkennwerte eines Laminats, einschließlich der '
        'Glieder über die Dicke, die die klassische Laminattheorie weglässt. '
        'Nötig, wenn ein Bauteil dick ist, wenn Lasten aus der Ebene wirken '
        'oder wenn ein Volumenmodell in der FE-Rechnung gefüttert werden soll.',
    formulas: [
      HelpFormula(
        tex: r'[C] = [S]^{-1}',
        plain: '[C] = [S]⁻¹',
        caption: 'Steifigkeit als Inverse der aufgebauten Nachgiebigkeit',
      ),
    ],
    symbols: [
      HelpSymbol('[C]', '6×6-Steifigkeitsmatrix', 'MPa'),
      HelpSymbol('[S]', '6×6-Nachgiebigkeitsmatrix', '1/MPa'),
      HelpSymbol('E3', 'Modul über die Dicke', 'MPa'),
      HelpSymbol('G13, G23', 'Querschubmoduln', 'MPa'),
    ],
    notes: [
      'Die Kennwerte über die Dicke werden von der Matrix bestimmt und sind '
          'niedrig — oft zwei Größenordnungen unter E1. Deshalb delaminieren '
          'Faserverbunde, statt zu fließen.',
      'Räumliche Ersatzkennwerte verschmieren das Laminat zu einem '
          'homogenen anisotropen Körper. Für die Gesamtsteifigkeit ist das in '
          'Ordnung, für Zwischenfaserspannungen am freien Rand nutzlos — dort '
          'braucht es ein schichtweises Modell.',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Herakovich, Mechanics of Fibrous Composites, ch. 3',
    ],
    diagram: 'images/laminate.png',
  ),
  306: ToolHelp(
    summary: 'Kriterien für das Erstschichtversagen einer unidirektionalen '
        'Schicht unter mehrachsiger Beanspruchung. Tsai–Hill und Tsai–Wu sind '
        'quadratische Kriterien mit Wechselwirkung; Maximalspannung und '
        'Maximaldehnung prüfen jede Komponente einzeln und sagen, welche Art '
        'des Versagens eintritt.',
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
        caption: 'Tsai–Wu, unterscheidet Zug von Druck',
      ),
    ],
    symbols: [
      HelpSymbol('X', 'Längsfestigkeit', 'MPa'),
      HelpSymbol('Y', 'Querfestigkeit', 'MPa'),
      HelpSymbol('S', 'Schubfestigkeit in der Ebene', 'MPa'),
      HelpSymbol('σ1, σ2, τ12', 'Schichtspannungen in den Materialachsen',
          'MPa'),
    ],
    notes: [
      'Diese Kriterien sagen das Erstschichtversagen voraus, nicht das '
          'Versagen des Laminats. Ein Laminat trägt nach dem ersten Riss '
          'meist noch erheblich weiter, und für die wirkliche Bruchlast '
          'braucht es eine fortschreitende Versagensanalyse.',
      'Je nach Vorzeichen der Spannung die Zug- oder die Druckfestigkeit '
          'einsetzen. Tsai–Hill in seiner einfachen Form tut das nicht von '
          'selbst.',
      'Tsai–Wu braucht das Wechselwirkungsglied F12, das schwer zu messen '
          'ist; F12 = −½√(F11·F22) ist ein üblicher und vernünftiger '
          'Standardwert.',
      'Keines dieser Kriterien sagt, *wie* die Schicht versagt hat. Das '
          'Maximalspannungskriterium tut es, weshalb es sich lohnt, es '
          'daneben mitzurechnen.',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Tsai & Wu, "A General Theory of Strength for Anisotropic Materials", '
          'J. Composite Materials, 1971',
    ],
    diagram: 'images/lamina.png',
  ),

  701: ToolHelp(
    summary: 'Zylindrische Schraubendruckfeder aus Runddraht: Wickelverhältnis, '
        'der Wahl-Korrekturfaktor für Krümmung und direkten Schub, die '
        'Federrate und eine geschätzte Eigenfrequenz. Auf das Verhältnis C '
        'kommt es an — unter etwa 4 lässt sich schwer wickeln, über 12 '
        'verhaken sich die Windungen und die Feder knickt aus.',
    formulas: [
      HelpFormula(
        tex: r'C = \frac{D}{d}, \quad '
            r'K_W = \frac{4C-1}{4C-4} + \frac{0.615}{C}',
        plain: 'C = D/d, KW = (4C − 1)/(4C − 4) + 0,615/C',
        caption: 'Wickelverhältnis und Wahl-Faktor',
      ),
      HelpFormula(
        tex: r'\tau = K_W \frac{8FD}{\pi d^3}',
        plain: 'τ = KW · 8·F·D / (π·d³)',
        caption: 'Korrigierte Schubspannung im Draht',
      ),
      HelpFormula(
        tex: r'k = \frac{Gd^4}{8D^3N_a}',
        plain: 'k = G·d⁴ / (8·D³·Na)',
        caption: 'Federrate',
      ),
    ],
    symbols: [
      HelpSymbol('d', 'Drahtdurchmesser', 'mm'),
      HelpSymbol('D', 'Mittlerer Windungsdurchmesser', 'mm'),
      HelpSymbol('C', 'Wickelverhältnis'),
      HelpSymbol('Na', 'Zahl der federnden Windungen'),
      HelpSymbol('G', 'Schubmodul des Drahtes', 'MPa'),
      HelpSymbol('k', 'Federrate', 'N/mm'),
    ],
    notes: [
      'D ist der *mittlere* Windungsdurchmesser, also der Außendurchmesser '
          'abzüglich eines Drahtdurchmessers. Mit dem Außendurchmesser '
          'gerechnet fällt die Rate spürbar zu hoch aus.',
      'Federnde Windungen sind weniger als Gesamtwindungen: angelegte und '
          'geschliffene Enden kosten etwa zwei, offene Enden fast keine.',
      'Die Betriebsfrequenz deutlich unter der Eigenfrequenz halten — bei '
          'Ventilfedern gilt ein Faktor 15 bis 20 als Richtwert. Die '
          'Federresonanz ist eine Welle entlang der Feder, keine '
          'Starrkörperbewegung.',
      'Die Drahtfestigkeit hängt stark vom Durchmesser ab: Dünner Draht ist '
          'bei gleicher Legierung deutlich fester als dicker.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 10',
      'Wahl, Mechanical Springs',
    ],
  ),
  702: ToolHelp(
    summary: 'Geometrie eines Stirnradpaares mit 20°-Evolventenverzahnung in '
        'Normalhöhe — Teilkreisdurchmesser, Achsabstand und Übersetzung — '
        'sowie eine Biegespannung nach Lewis und ein vereinfachter Wert für '
        'die Flankenpressung. Eine erste Auslegung, keine Tragfähigkeitsrechnung '
        'nach AGMA.',
    formulas: [
      HelpFormula(
        tex: r'd = mN, \quad C = \frac{d_1+d_2}{2}, \quad '
            r'i = \frac{N_2}{N_1}',
        plain: 'd = m·N, C = (d1 + d2)/2, i = N2/N1',
        caption: 'Teilkreisdurchmesser, Achsabstand, Übersetzung',
      ),
      HelpFormula(
        tex: r'\sigma = \frac{W_t}{b\,m\,Y}',
        plain: 'σ = Wt / (b·m·Y)',
        caption: 'Biegespannung am Zahnfuß nach Lewis',
      ),
    ],
    symbols: [
      HelpSymbol('m', 'Modul', 'mm'),
      HelpSymbol('N', 'Zähnezahl'),
      HelpSymbol('d', 'Teilkreisdurchmesser', 'mm'),
      HelpSymbol('Wt', 'Umfangskraft am Zahn', 'N'),
      HelpSymbol('b', 'Zahnbreite', 'mm'),
      HelpSymbol('Y', 'Zahnformfaktor nach Lewis'),
    ],
    notes: [
      'Die Lewis-Gleichung behandelt einen Zahn als statisch belasteten '
          'Kragarm. Sie berücksichtigt weder die Kerbwirkung im Fußrundungs- '
          'bereich noch dynamische Zusatzkräfte, Lastaufteilung auf mehrere '
          'Zähne oder Fluchtungsfehler — alles Punkte, die AGMA 2001 mit '
          'eigenen Faktoren erfasst und die für eine echte Tragfähigkeit '
          'zählen.',
      'Ein Ritzel mit 20°-Normalverzahnung wird unter 17 Zähnen '
          'unterschnitten. Weniger Zähne brauchen eine Profilverschiebung.',
      'Die Flankenpressung (Hertzsche Pressung) bestimmt meist die '
          'Grübchentragfähigkeit, die Biegung den Zahnbruch. Beides ist zu '
          'prüfen; die Versagensarten sind verschieden.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 13–14',
      'ANSI/AGMA 2001-D04',
    ],
  ),
  703: ToolHelp(
    summary: 'Mindestdurchmesser einer Welle bei schwingender Biegung und '
        'ruhender Torsion, nach der Gestaltänderungsenergiehypothese in '
        'Verbindung mit dem modifizierten Goodman-Kriterium. Das ist die '
        'übliche Auslegungsgleichung für den Normalfall einer rotierenden '
        'Welle: Biegung wechselnd, Moment ruhend.',
    formulas: [
      HelpFormula(
        tex: r'd = \left(\frac{16n}{\pi}\left\{\frac{1}{S_e}\left[4(K_f '
            r'M_a)^2 + 3(K_{fs}T_a)^2\right]^{1/2} + \frac{1}{S_{ut}}'
            r'\left[4(K_f M_m)^2 + 3(K_{fs}T_m)^2\right]^{1/2}\right\}'
            r'\right)^{1/3}',
        plain: 'd = { (16n/π) · [ (1/Se)·√(4(Kf·Ma)² + 3(Kfs·Ta)²) '
            '+ (1/Sut)·√(4(Kf·Mm)² + 3(Kfs·Tm)²) ] }^(1/3)',
        caption: 'Wellendurchmesser nach DE–Goodman',
      ),
    ],
    symbols: [
      HelpSymbol('Ma, Mm', 'Wechselndes und mittleres Biegemoment', 'N·m'),
      HelpSymbol('Ta, Tm', 'Wechselndes und mittleres Torsionsmoment', 'N·m'),
      HelpSymbol('Se', 'Korrigierte Dauerfestigkeit', 'MPa'),
      HelpSymbol('Sut', 'Zugfestigkeit', 'MPa'),
      HelpSymbol('Kf, Kfs', 'Kerbwirkungszahlen für Ermüdung'),
      HelpSymbol('n', 'Auslegungsfaktor'),
    ],
    notes: [
      'Bei einer rotierenden Welle unter ruhender Querlast ist die Biegung '
          'reine Wechselbiegung: Ma ist das volle Moment und Mm ist null. Beim '
          'Moment aus einem gleichmäßigen Antrieb ist es umgekehrt — nur Tm.',
      'Kf und Kfs sind die Kerbwirkungszahlen an der maßgebenden Stelle, meist '
          'ein Absatzradius, eine Passfedernut oder ein Pressverband. Sie auf 1 '
          'zu lassen ist optimistisch; ein scharfer Absatz liegt leicht bei 2.',
      'Bemessen wird hier allein nach Ermüdungsfestigkeit. Außerdem sind '
          'Durchbiegung, Neigung an den Lagerstellen und kritische Drehzahl zu '
          'prüfen — eine Welle, die diesen Nachweis besteht, kann trotzdem '
          'unbrauchbar sein.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 7',
      'ANSI/ASME B106.1M, Design of Transmission Shafting',
    ],
  ),
  704: ToolHelp(
    summary: 'Nominelle Lebensdauer eines Wälzlagers: die Zahl der '
        'Umdrehungen, die 90% einer Serie überstehen. Der Exponent macht die '
        'Lebensdauer außerordentlich lastempfindlich — halbe Last bedeutet '
        'achtfache Lebensdauer bei einem Kugellager.',
    formulas: [
      HelpFormula(
        tex: r'L_{10} = \left(\frac{C}{P}\right)^{p}',
        plain: 'L10 = (C/P)^p, p = 3 Kugel, 10/3 Rolle',
        caption: 'Nominelle Lebensdauer in Millionen Umdrehungen',
      ),
      HelpFormula(
        tex: r'L_{10h} = \frac{10^6 L_{10}}{60n}',
        plain: 'L10h = 10⁶ · L10 / (60·n)',
        caption: 'Umgerechnet in Stunden',
      ),
    ],
    symbols: [
      HelpSymbol('C', 'Dynamische Tragzahl aus dem Katalog', 'N'),
      HelpSymbol('P', 'Äquivalente dynamische Lagerbelastung', 'N'),
      HelpSymbol('n', 'Drehzahl', 'rpm'),
      HelpSymbol('L10', 'Nominelle Lebensdauer', 'million rev'),
    ],
    notes: [
      'L10 bedeutet, dass bis dahin 10% ausgefallen sein dürften — nicht, '
          'dass das Lager so lange hält. Die mittlere Lebensdauer liegt etwa '
          'beim Fünffachen von L10.',
      'P ist die äquivalente Belastung P = X·Fr + Y·Fa, die Radial- und '
          'Axialanteil mit Katalogfaktoren zusammenfasst — bei vorhandener '
          'Axialkraft also nicht einfach die Radiallast.',
      'Die nominelle Lebensdauer berücksichtigt weder Schmierung noch '
          'Verschmutzung oder Temperatur. ISO 281 ergänzt dafür den '
          'Lebensdauerbeiwert a-ISO, und ein schlecht geschmiertes Lager kann '
          'weit hinter L10 zurückbleiben.',
      'C muss die *dynamische* Tragzahl sein. Die statische Tragzahl C0 '
          'bestimmt die bleibende Eindrückung im stehenden Lager und ist eine '
          'andere Größe.',
    ],
    references: [
      'ISO 281, Rolling bearings — Dynamic load ratings and rating life',
      'Shigley, Mechanical Engineering Design, ch. 11',
    ],
  ),
  705: ToolHelp(
    summary: 'Geometrie eines offenen Riementriebs oder einer Rollenkette '
        '(mit Teilkreisdurchmessern): Übersetzung, Riemenlänge und '
        'Umschlingungswinkel an beiden Scheiben. Der Umschlingungswinkel an '
        'der kleinen Scheibe begrenzt das Moment, das ein Reibriemen '
        'übertragen kann, bevor er rutscht.',
    formulas: [
      HelpFormula(
        tex: r'i = \frac{D_2}{D_1} = \frac{n_1}{n_2}',
        plain: 'i = D2/D1 = n1/n2',
        caption: 'Übersetzung',
      ),
      HelpFormula(
        tex: r'L = 2C + \frac{\pi}{2}(D_1+D_2) + \frac{(D_2-D_1)^2}{4C}',
        plain: 'L = 2C + (π/2)(D1 + D2) + (D2 − D1)²/(4C)',
        caption: 'Länge des offenen Riemens',
      ),
      HelpFormula(
        tex: r'\theta_1 = \pi - 2\arcsin\frac{D_2-D_1}{2C}',
        plain: 'θ1 = π − 2·arcsin[(D2 − D1)/(2C)]',
        caption: 'Umschlingungswinkel an der kleinen Scheibe',
      ),
    ],
    symbols: [
      HelpSymbol('D1, D2', 'Teilkreisdurchmesser der kleinen und der großen '
          'Scheibe', 'mm'),
      HelpSymbol('C', 'Achsabstand', 'mm'),
      HelpSymbol('L', 'Riemenlänge', 'mm'),
      HelpSymbol('θ1', 'Umschlingungswinkel an der kleinen Scheibe', 'rad'),
    ],
    notes: [
      'Der Ausdruck für die Riemenlänge ist die übliche Näherung und für C '
          'größer als etwa (D1 + D2) sehr genau.',
      'Den Umschlingungswinkel an der kleinen Scheibe über etwa 120° halten. '
          'Darunter rutscht ein Flach- oder Keilriemen, bevor er seine '
          'Nennleistung erreicht; üblicherweise hilft eine Spannrolle.',
      'Bei Rollenketten mit Teilkreisdurchmessern rechnen und die Länge auf '
          'eine gerade Gliederzahl runden — eine ungerade braucht ein '
          'gekröpftes Glied, das schwächer ist.',
      'Nur Geometrie: Die übertragbare Leistung eines Riemens hängt von '
          'Profil, Geschwindigkeit und Betriebsfaktor aus den Herstellertabellen '
          'ab.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 17',
      'ANSI/ASME B29.1, Precision Power Transmission Roller Chains',
    ],
  ),
  706: ToolHelp(
    summary: 'Das Anziehmoment für eine angestrebte Schraubenvorspannkraft, '
        'nach der vereinfachten Beziehung zwischen Moment und Vorspannkraft. '
        'Zusammengehalten wird eine Verbindung durch die Vorspannkraft; das '
        'Moment ist dafür nur ein Ersatzmaß — und ein ungenaues, weshalb '
        'dieser Wert mit Vorsicht zu behandeln ist.',
    formulas: [
      HelpFormula(
        tex: r'T = K F_i d',
        plain: 'T = K · Fi · d',
        caption: 'Moment für eine angestrebte Vorspannkraft',
      ),
      HelpFormula(
        tex: r'F_i \approx 0.75 A_t S_p \;\text{(reused)}, \quad '
            r'0.90 A_t S_p \;\text{(permanent)}',
        plain: 'Fi ≈ 0,75·At·Sp wiederverwendbar, 0,90·At·Sp dauerhaft',
        caption: 'Übliche Zielwerte der Vorspannkraft',
      ),
    ],
    symbols: [
      HelpSymbol('T', 'Anziehmoment', 'N·m'),
      HelpSymbol('K', 'Anziehfaktor, etwa 0,20 für blanken Stahl'),
      HelpSymbol('Fi', 'Angestrebte Vorspannkraft', 'N'),
      HelpSymbol('d', 'Nenndurchmesser der Schraube', 'mm'),
      HelpSymbol('At', 'Spannungsquerschnitt', 'mm²'),
      HelpSymbol('Sp', 'Streckgrenzenspannung (proof strength)', 'MPa'),
    ],
    notes: [
      'K fasst Gewinde- und Kopfreibung zusammen und ist die Schwachstelle '
          'des Verfahrens: Er ändert sich mit Beschichtung, Schmierung und '
          'Wiederverwendung, und reine Momentensteuerung streut die '
          'Vorspannkraft typisch um ±25–30%.',
      'Rund 90% des eingeleiteten Moments gehen in Reibung, nur etwa 10% '
          'werden zu Zugkraft. Eine kleine Änderung der Reibung ist deshalb '
          'eine große Änderung der Vorspannkraft.',
      'Wo die Vorspannkraft wirklich zählt, sollte man sie messen — '
          'Drehwinkelsteuerung nach dem Fügepunkt, Längenmessung der Schraube '
          'oder eine Kraftanzeigescheibe — statt sich auf das Moment zu '
          'verlassen.',
      'Den Spannungsquerschnitt At verwenden, nicht den Schaftquerschnitt. '
          'Bei einer M10 mit Regelgewinde sind das 58 mm² gegenüber 78,5 mm² '
          'für den Nenndurchmesser.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 8',
      'Bickford, An Introduction to the Design and Behavior of Bolted Joints',
    ],
  ),
  707: ToolHelp(
    summary: 'Schubspannung im Nahtquerschnitt einer Kehlnaht. Der '
        'Nahtquerschnitt (die Kehlnahtdicke) ist der kleinste Schnitt durch '
        'die Naht und damit die Bruchfläche, und die Auslegungspraxis '
        'behandelt jede Kehlnaht als dort auf Schub versagend, gleich wie die '
        'Verbindung belastet wird.',
    formulas: [
      HelpFormula(
        tex: r'a = 0.707\,w, \quad \tau = \frac{F}{a L}',
        plain: 'a = 0,707·w, τ = F / (a·L)',
        caption: 'Nahtdicke und Schubspannung darin',
      ),
    ],
    symbols: [
      HelpSymbol('w', 'Schenkellänge der Kehlnaht', 'mm'),
      HelpSymbol('a', 'Rechnerische Nahtdicke, 0,707·w bei gleichen Schenkeln',
          'mm'),
      HelpSymbol('L', 'Rechnerische Nahtlänge', 'mm'),
      HelpSymbol('F', 'Last auf der Nahtgruppe', 'N'),
    ],
    notes: [
      'Jede Kehlnaht als im Nahtquerschnitt auf Schub versagend zu behandeln '
          'ist die übliche Vereinfachung. Eine quer belastete Kehlnaht ist '
          'tatsächlich etwa 50% tragfähiger als eine längs belastete; '
          'Regelwerke lassen dafür einen Richtungsbeiwert zu.',
      'Der Faktor 0,707 gilt für eine Naht mit gleichen Schenkeln und flacher '
          'Oberfläche. Eine überwölbte oder ungleichschenklige Naht hat eine '
          'andere Nahtdicke.',
      'Erfasst ist nur mittige Belastung. Eine ausmittige Last erzeugt in der '
          'Nahtgruppe zusätzlich Torsion oder Biegung, die mit dem direkten '
          'Schub vektoriell zu überlagern ist.',
      'Schweißgut ist üblicherweise gleich fest oder etwas fester als der '
          'Grundwerkstoff, sodass die Naht selten maßgebend wird, sofern sie '
          'nicht unterdimensioniert ist.',
    ],
    references: [
      'AWS D1.1, Structural Welding Code — Steel',
      'Shigley, Mechanical Engineering Design, ch. 9',
    ],
  ),
  708: ToolHelp(
    summary: 'Fugendruck, Umfangsspannung in der Nabe und Spannung in der '
        'Welle für eine Vollwelle, die in eine Nabe aus demselben Werkstoff '
        'eingepresst ist. Pressverbände sind der übliche Weg, Zahnräder und '
        'Kupplungen zu befestigen — ohne Passfedernut und damit ohne Kerbe.',
    formulas: [
      HelpFormula(
        tex: r'p = \frac{E\delta}{2d}\left[\frac{d_o^2-d^2}{d_o^2}\right]',
        plain: 'p = (E·δ / 2d) · (do² − d²)/do²',
        caption: 'Fugendruck, beide Teile aus demselben Werkstoff',
      ),
      HelpFormula(
        tex: r'\sigma_{h} = p\,\frac{d_o^2+d^2}{d_o^2-d^2}, \quad '
            r'\sigma_{\text{shaft}} = -p',
        plain: 'σh = p·(do² + d²)/(do² − d²), σshaft = −p',
        caption: 'Umfangsspannung an der Nabenbohrung und Welle unter '
            'allseitigem Druck',
      ),
    ],
    symbols: [
      HelpSymbol('δ', 'Übermaß am Durchmesser', 'mm'),
      HelpSymbol('d', 'Nenndurchmesser der Fuge', 'mm'),
      HelpSymbol('do', 'Außendurchmesser der Nabe', 'mm'),
      HelpSymbol('p', 'Fugendruck', 'MPa'),
      HelpSymbol('E', 'Elastizitätsmodul, Eingabe in GPa', 'GPa'),
    ],
    notes: [
      'Welle und Nabe aus demselben Werkstoff — nur dann kürzt sich die '
          'Querkontraktionszahl heraus. Unterschiedliche Werkstoffe brauchen '
          'die allgemeine Lamé-Form, und eine Stahlwelle in einer '
          'Aluminiumnabe löst sich bei Erwärmung.',
      'Die Umfangsspannung an der Nabenbohrung ist eine Zugspannung und die '
          'größte Spannung im Verband. Sie lässt eine dünne Nabe reißen, nicht '
          'der Druck.',
      'Das Übermaß aus der *Passung* ableiten, nicht aus einem Nennwert: Das '
          'tatsächliche Übermaß schwankt über das Toleranzfeld, und beide '
          'Extreme sind zu prüfen — das kleinste für die Momentenübertragung, '
          'das größte für die Nabenspannung.',
      'Die Rauheit wird beim Fügen eingeebnet und verringert das wirksame '
          'Übermaß; einige Mikrometer dafür vorsehen.',
      'Das übertragbare Moment beträgt μ·p·π·d²·L/2 und wird hier nicht '
          'berechnet — dafür bräuchte es einen Reibwert und eine Fügelänge, '
          'und beide fragt dieses Werkzeug nicht ab.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 3 and 7',
      'ISO 286-1, Geometrical product specifications: ISO code system',
    ],
  ),
  709: ToolHelp(
    summary: 'Erste biegekritische Drehzahl einer Welle mit einem Läufer, '
        'wobei die Eigenfrequenz des Läufers und die verteilte Masse der Welle '
        'selbst über die Gleichung von Dunkerley zusammengefasst werden. Läuft '
        'die Welle in der kritischen Drehzahl, baut eine kleine Unwucht eine '
        'große Auslenkung auf.',
    formulas: [
      HelpFormula(
        tex: r'\omega_r = \sqrt{\frac{k}{m}}, \quad '
            r'\frac{1}{\omega_c^2} = \frac{1}{\omega_r^2} + '
            r'\frac{1}{\omega_s^2}',
        plain: 'ωr = √(k/m), 1/ωc² = 1/ωr² + 1/ωs²',
        caption: 'Läufer und Welle nach Dunkerley zusammengefasst',
      ),
      HelpFormula(
        tex: r'N_c = \frac{60\,\omega_c}{2\pi}',
        plain: 'Nc = 60·ωc / (2π)',
        caption: 'Kritische Drehzahl in min⁻¹',
      ),
    ],
    symbols: [
      HelpSymbol('k', 'Quersteifigkeit am Läufer', 'N/mm'),
      HelpSymbol('m', 'Läufermasse', 'kg'),
      HelpSymbol('ωc', 'Erste kritische Kreisfrequenz', 'rad/s'),
      HelpSymbol('Nc', 'Erste kritische Drehzahl', 'rpm'),
    ],
    notes: [
      'Die Gleichung von Dunkerley liegt immer zu niedrig, die ausgegebene '
          'kritische Drehzahl ist also konservativ. Das ist die nützliche '
          'Richtung, in der man daneben liegen kann.',
      'Die Betriebsdrehzahl mit deutlichem Abstand wählen — unter etwa 75% '
          'oder über etwa 140% der ersten kritischen Drehzahl ist die übliche '
          'Regel. Zügiges Durchfahren beim Hochlauf ist unbedenklich.',
      'Die Lager werden als starr angenommen. Weiche Lager oder ein '
          'nachgiebiges Gehäuse senken die kritische Drehzahl, mitunter '
          'erheblich.',
      'Kreiseleffekte, die die kritische Drehzahl in Gleich- und Gegenlauf '
          'aufspalten, sind nicht enthalten.',
    ],
    references: [
      'Rao, Mechanical Vibrations, ch. 10',
      'Shigley, Mechanical Engineering Design, ch. 7',
    ],
  ),
  710: ToolHelp(
    summary: 'Biegeeigenfrequenzen eines prismatischen Trägers für die ersten '
        'drei Moden und die üblichen Lagerungsbedingungen. Die Eigenfrequenz '
        'wächst mit der Wurzel aus Steifigkeit durch Masse und fällt mit dem '
        'Quadrat der Länge.',
    formulas: [
      HelpFormula(
        tex: r'f_n = \frac{(\beta_n L)^2}{2\pi L^2}\sqrt{\frac{EI}{\rho A}}',
        plain: 'fn = (βn·L)² / (2π·L²) · √(E·I / (ρ·A))',
        caption: 'Eigenfrequenz nach Euler-Bernoulli',
      ),
    ],
    symbols: [
      HelpSymbol('fn', 'Eigenfrequenz der Mode n', 'Hz'),
      HelpSymbol('βnL', 'Eigenwert aus den Lagerungsbedingungen'),
      HelpSymbol('E·I', 'Biegesteifigkeit', 'N·mm²'),
      HelpSymbol('ρ·A', 'Masse je Längeneinheit', 'kg/m'),
      HelpSymbol('L', 'Stützweite', 'mm'),
    ],
    notes: [
      'Die Euler-Bernoulli-Theorie vernachlässigt Schubverformung und '
          'Drehträgheit, sodass die Frequenzen für einen gedrungenen Träger — '
          'L/d unter etwa 10 — und für höhere Moden zu hoch ausfallen. Die '
          'Timoshenko-Theorie korrigiert beides.',
      'Die Länge überwiegt: Halbiert man die Stützweite, vervierfacht sich '
          'jede Frequenz.',
      'Zusatzmassen, die nicht zum Träger gehören — ein Motor, ein mit Wasser '
          'gefülltes Rohr — senken die Frequenz und sind nicht enthalten, '
          'solange sie nicht in ρA eingerechnet werden.',
      'Reale Lagerungen sind nie ideal eingespannt oder ideal gelenkig; die '
          'wirkliche Frequenz liegt zwischen den beiden Idealisierungen.',
    ],
    references: [
      'Rao, Mechanical Vibrations, ch. 8',
      'Blevins, Formulas for Natural Frequency and Mode Shape',
    ],
  ),
  711: ToolHelp(
    summary: 'Grundtorsionseigenfrequenz einer runden Welle, entweder mit '
        'einem Läufer gegen ein festes Ende oder mit zwei Läufern auf einer '
        'freien Welle. Torsionsresonanz ist von außen nicht zu sehen und eine '
        'häufige Ursache für Schäden an Kupplungen und Zahnflanken.',
    formulas: [
      HelpFormula(
        tex: r'k_t = \frac{GJ_p}{L}, \quad '
            r'\omega_n = \sqrt{\frac{k_t}{J_{\text{eff}}}}',
        plain: 'kt = G·Jp / L, ωn = √(kt / Jeff)',
        caption: 'Torsionssteifigkeit und Eigenfrequenz',
      ),
      HelpFormula(
        tex: r'J_{\text{eff}} = \frac{J_1 J_2}{J_1+J_2}',
        plain: 'Jeff = J1·J2 / (J1 + J2)',
        caption: 'Zwei Läufer auf freier Welle: die reduzierte Trägheit',
      ),
    ],
    symbols: [
      HelpSymbol('kt', 'Torsionssteifigkeit', 'N·m/rad'),
      HelpSymbol('G', 'Schubmodul', 'MPa'),
      HelpSymbol('Jp', 'Polares Flächenträgheitsmoment der Welle', 'mm⁴'),
      HelpSymbol('J1, J2', 'Massenträgheitsmomente der Läufer', 'kg·m²'),
    ],
    notes: [
      'Die Trägheit der Welle selbst wird vernachlässigt. Ist sie mit der der '
          'Läufer vergleichbar, braucht es stattdessen eine Mehrmassenrechnung '
          '(Holzer).',
      'Jp ist eine Querschnittsgröße in mm⁴; J1 und J2 sind '
          'Massenträgheitsmomente in kg·m². Es sind verschiedene Größen mit '
          'demselben Buchstaben, und sie zu verwechseln ist hier der übliche '
          'Fehler.',
      'Die Anregung liegt selten bei der Wellendrehzahl. Zündordnungen von '
          'Motoren und Zahneingriffsfrequenzen sind Vielfache davon, und meist '
          'treffen diese die Resonanz.',
    ],
    references: [
      'Rao, Mechanical Vibrations, ch. 5 and 6',
      'Nestorides, A Handbook on Torsional Vibration',
    ],
  ),
  800: ToolHelp(
    summary: 'Reynolds-Zahl für die Strömung in einem runden Rohr und das '
        'Strömungsregime, in das sie fällt. Re ist das Verhältnis von '
        'Trägheits- zu Zähigkeitskräften und die eine Zahl, die entscheidet, '
        'ob eine Strömung geordnet oder wirr ist — und das bestimmt wiederum '
        'Rohrreibungszahl und Wärmeübergang.',
    formulas: [
      HelpFormula(
        tex: r'Re = \frac{\rho V D}{\mu} = \frac{VD}{\nu}',
        plain: 'Re = ρ·V·D / μ = V·D / ν',
        caption: 'Reynolds-Zahl',
      ),
      HelpFormula(
        tex: r'V = \frac{Q}{A}, \quad A = \frac{\pi D^2}{4}',
        plain: 'V = Q / A, A = π·D²/4',
        caption: 'Geschwindigkeit aus dem Volumenstrom',
      ),
    ],
    symbols: [
      HelpSymbol('Re', 'Reynolds-Zahl'),
      HelpSymbol('ρ', 'Dichte', 'kg/m³'),
      HelpSymbol('V', 'Mittlere Geschwindigkeit', 'm/s'),
      HelpSymbol('D', 'Innendurchmesser', 'mm'),
      HelpSymbol('μ', 'Dynamische Viskosität', 'Pa·s'),
      HelpSymbol('ν', 'Kinematische Viskosität, μ/ρ', 'm²/s'),
    ],
    notes: [
      'Für Rohrströmung: laminar unter etwa 2300, turbulent über etwa 4000, '
          'dazwischen der Übergangsbereich. Der Übergang ist nicht scharf und '
          'hängt von Zulaufstörungen und Rauheit ab.',
      'D ist der *Innen*durchmesser des Rohres, nicht die Nennweite. Den '
          'richtigen Wert liefert die Rohrmaßtabelle.',
      'Bei nicht kreisförmigem Querschnitt den hydraulischen Durchmesser 4A/P '
          'einsetzen. Für turbulente Strömung passt das gut, für laminare '
          'schlecht.',
      'V ist die über den Querschnitt gemittelte Geschwindigkeit. In der '
          'Rohrachse ist sie laminar doppelt so groß und turbulent etwa das '
          '1,2-Fache.',
    ],
    references: [
      'White, Fluid Mechanics, ch. 6',
      'Munson, Fundamentals of Fluid Mechanics, ch. 8',
    ],
  ),
  801: ToolHelp(
    summary: 'Druckverlusthöhe und Druckverlust nach Darcy-Weisbach für ein '
        'voll durchströmtes Rohr, mit der Rohrreibungszahl aus der '
        'Colebrook-Gleichung und Einzelverlusten als Geschwindigkeitshöhen. '
        'Das ist der übliche Weg, eine Rohrleitung zu bemessen und die Pumpe '
        'dazu auszuwählen.',
    formulas: [
      HelpFormula(
        tex: r'h_f = f\frac{L}{D}\frac{V^2}{2g}',
        plain: 'hf = f · (L/D) · V²/(2g)',
        caption: 'Reibungshöhe nach Darcy-Weisbach',
      ),
      HelpFormula(
        tex: r'\frac{1}{\sqrt{f}} = -2\log_{10}\left(\frac{\varepsilon/D}'
            r'{3.7} + \frac{2.51}{Re\sqrt{f}}\right)',
        plain: '1/√f = −2·log₁₀[ (ε/D)/3,7 + 2,51/(Re·√f) ]',
        caption: 'Colebrook, iterativ gelöst',
      ),
      HelpFormula(
        tex: r'h_m = \sum K \frac{V^2}{2g}, \quad \Delta p = \rho g h',
        plain: 'hm = ΣK · V²/(2g), Δp = ρ·g·h',
        caption: 'Einzelverluste und Druckverlust',
      ),
    ],
    symbols: [
      HelpSymbol('f', 'Rohrreibungszahl nach Darcy'),
      HelpSymbol('L', 'Rohrlänge', 'm'),
      HelpSymbol('D', 'Innendurchmesser', 'mm'),
      HelpSymbol('ε', 'Absolute Wandrauheit', 'mm'),
      HelpSymbol('ΣK', 'Summe der Einzelverlustbeiwerte'),
      HelpSymbol('hf', 'Verlusthöhe', 'm'),
    ],
    notes: [
      'Die Darcy-Rohrreibungszahl ist viermal so groß wie die von Fanning. '
          'Vor der Verwendung eines Diagramms oder einer Korrelation prüfen, '
          'welche gemeint ist — der Faktor vier ist ein klassischer Fehler.',
      'Colebrook gilt für turbulente Strömung. Laminar ist f = 64/Re und '
          'hängt überhaupt nicht von der Rauheit ab.',
      'Übliche absolute Rauheiten: 0,045 mm für Handelsstahlrohr, 0,0015 mm '
          'für gezogenes Rohr, 0,26 mm für Gusseisen. Altes Rohr ist weit '
          'rauer als neues, und dort steckt die meiste Unsicherheit.',
      'Setzt ein volles Rohr mit inkompressiblem Fluid bei stationärer '
          'Strömung voraus. Teilgefüllte Freispiegelleitungen und '
          'kompressible Gasströmung brauchen andere Ansätze.',
    ],
    references: [
      'White, Fluid Mechanics, ch. 6',
      'Crane Technical Paper No. 410, Flow of Fluids Through Valves, '
          'Fittings and Pipe',
    ],
  ),
  802: ToolHelp(
    summary: 'Die Leistung, die eine Pumpe oder ein Ventilator braucht: Das '
        'Fluid erhält Druckdifferenz mal Volumenstrom, und der Antrieb muss '
        'das geteilt durch den Wirkungsgrad aufbringen. Die Druckerhöhung wird '
        'außerdem als Förderhöhe des geförderten Fluids ausgegeben, denn so '
        'werden Pumpenkennlinien gezeichnet.',
    formulas: [
      HelpFormula(
        tex: r'P_{\text{fluid}} = \Delta p\,Q, \quad '
            r'P_{\text{shaft}} = \frac{\Delta p\,Q}{\eta}',
        plain: 'Pfluid = Δp·Q, Pshaft = Δp·Q / η',
        caption: 'Hydraulische Leistung und Wellenleistung',
      ),
      HelpFormula(
        tex: r'H = \frac{\Delta p}{\rho g}',
        plain: 'H = Δp / (ρ·g)',
        caption: 'Druckerhöhung als Förderhöhe',
      ),
    ],
    symbols: [
      HelpSymbol('Δp', 'Druckerhöhung über die Maschine', 'kPa'),
      HelpSymbol('Q', 'Volumenstrom', 'm³/s'),
      HelpSymbol('η', 'Gesamtwirkungsgrad'),
      HelpSymbol('H', 'Förderhöhe', 'm'),
    ],
    notes: [
      'Die Förderhöhe ist von der Dichte unabhängig, der Druck nicht. Eine '
          'Pumpe erzeugt bei jeder Flüssigkeit dieselbe Förderhöhe und bei '
          'einer leichteren einen entsprechend geringeren Druck — deshalb sind '
          'Pumpenkennlinien in Metern angegeben.',
      'Der Wirkungsgrad ist hier der der ganzen Maschine. Ist der '
          'Motorwirkungsgrad getrennt anzusetzen, noch einmal durch ihn teilen, '
          'um die elektrische Aufnahmeleistung zu erhalten.',
      'Auch den vorhandenen NPSH-Wert gegen den erforderlichen der Pumpe '
          'prüfen. Eine kavitierende Pumpe liefert diese Leistung nicht '
          'sinnvoll ab, wie immer man sie auslegt.',
      'Bei einem Ventilator das Gas nur solange als inkompressibel behandeln, '
          'wie die Druckerhöhung klein bleibt — unter etwa 3% des absoluten '
          'Drucks.',
    ],
    references: [
      'White, Fluid Mechanics, ch. 11',
      'Hydraulic Institute Standards, ANSI/HI 1.1-1.2',
    ],
  ),
  810: ToolHelp(
    summary: 'Stationäre eindimensionale Wärmeleitung durch eine geschichtete '
        'ebene Wand. Jede Schicht ist ein Wärmewiderstand, und sie addieren '
        'sich in Reihe mit den Wärmeübergängen an beiden Oberflächen. Daraus '
        'folgen der Wärmedurchgangskoeffizient, der Wärmestrom und die '
        'Temperatur an jeder Schichtgrenze.',
    formulas: [
      HelpFormula(
        tex: r'R_{\text{cond}} = \frac{t}{k}, \quad '
            r'R_{\text{conv}} = \frac{1}{h}',
        plain: 'Rcond = t/k, Rconv = 1/h',
        caption: 'Widerstand je Flächeneinheit',
      ),
      HelpFormula(
        tex: r'U = \frac{1}{\sum R}, \quad q = U\,\Delta T',
        plain: 'U = 1 / ΣR, q = U · ΔT',
        caption: 'Wärmedurchgangskoeffizient und Wärmestromdichte',
      ),
    ],
    symbols: [
      HelpSymbol('t', 'Schichtdicke', 'm'),
      HelpSymbol('k', 'Wärmeleitfähigkeit', 'W/m·K'),
      HelpSymbol('h', 'Wärmeübergangskoeffizient', 'W/m²·K'),
      HelpSymbol('U', 'Wärmedurchgangskoeffizient', 'W/m²·K'),
      HelpSymbol('q', 'Wärmestromdichte', 'W/m²'),
    ],
    notes: [
      'Nur ebene Wand — die Widerstände addieren sich als t/k. Eine '
          'zylindrische oder kugelförmige Schale hat stattdessen eine '
          'logarithmische beziehungsweise reziproke Form, und die ebene Formel '
          'auf ein Rohr kleinen Durchmessers angewandt liegt spürbar daneben.',
      'Der größte Widerstand bestimmt das Ergebnis. Dämmung an einer Wand zu '
          'ergänzen, deren Widerstand ohnehin von einer ruhenden Luftschicht '
          'bestimmt wird, bringt weit weniger, als der k-Wert vermuten lässt.',
      'Der Kontaktwiderstand zwischen den Schichten ist vernachlässigt und '
          'kann bei geschraubten oder geklebten Metallverbindungen eine Rolle '
          'spielen.',
      'Nur stationär: keine Wärmekapazität, also keine Aussage darüber, wie '
          'lange eine Wand zum Einschwingen braucht.',
    ],
    references: [
      'Incropera & DeWitt, Fundamentals of Heat and Mass Transfer, ch. 3',
      'ASHRAE Handbook — Fundamentals, ch. 25',
    ],
  ),
  811: ToolHelp(
    summary: 'Wirkungsgrad einer geraden Rechteckrippe konstanten Querschnitts, '
        'gelöst mit adiabater Spitze und korrigierter Länge. Der '
        'Rippenwirkungsgrad ist der Anteil des idealen Wärmestroms, den eine '
        'wirkliche Rippe erreicht, weil ihre Temperatur über die Länge abfällt.',
    formulas: [
      HelpFormula(
        tex: r'm = \sqrt{\frac{2h}{kt}}, \quad L_c = L + \frac{t}{2}',
        plain: 'm = √(2h / (k·t)), Lc = L + t/2',
        caption: 'Rippenparameter und korrigierte Länge',
      ),
      HelpFormula(
        tex: r'\eta_f = \frac{\tanh(mL_c)}{mL_c}',
        plain: 'ηf = tanh(m·Lc) / (m·Lc)',
        caption: 'Rippenwirkungsgrad',
      ),
    ],
    symbols: [
      HelpSymbol('h', 'Wärmeübergangskoeffizient', 'W/m²·K'),
      HelpSymbol('k', 'Wärmeleitfähigkeit der Rippe', 'W/m·K'),
      HelpSymbol('t', 'Rippendicke', 'm'),
      HelpSymbol('L', 'Rippenlänge', 'm'),
      HelpSymbol('ηf', 'Rippenwirkungsgrad'),
    ],
    notes: [
      'Die korrigierte Länge ist der übliche Kunstgriff, um in einer Lösung '
          'mit adiabater Spitze den Wärmeübergang an der Spitze zu erfassen. '
          'Sie ist genau, solange h·t/k klein bleibt, was meist der Fall ist.',
      'Der Wirkungsgrad fällt mit zunehmender Länge: Jenseits eines mLc von '
          'etwa 2 bringt zusätzliche Länge Gewicht und fast keine Wärme mehr. '
          'Das ist die praktische Grenze der Rippenhöhe.',
      'Rippen helfen nur, wenn der Widerstand an der Oberfläche überwiegt. '
          'Sie auf der Wasserseite eines Wärmeübertragers anzubringen, wo h '
          'ohnehin groß ist, bringt sehr wenig.',
      'Eindimensionale Wärmeleitung in der Rippe, gleichmäßiges h über die '
          'Oberfläche und keine Strahlung.',
    ],
    references: [
      'Incropera & DeWitt, Fundamentals of Heat and Mass Transfer, ch. 3',
      'Kraus, Aziz & Welty, Extended Surface Heat Transfer',
    ],
  ),
  812: ToolHelp(
    summary: 'Die logarithmische mittlere Temperaturdifferenz aus den vier '
        'Endtemperaturen und die Fläche, die eine gegebene Leistung braucht. '
        'Die LMTD ist die richtige mittlere treibende Temperaturdifferenz '
        'eines Wärmeübertragers, weil die örtliche Differenz über seine Länge '
        'exponentiell und nicht linear verläuft.',
    formulas: [
      HelpFormula(
        tex: r'\Delta T_{lm} = \frac{\Delta T_1 - \Delta T_2}'
            r'{\ln(\Delta T_1/\Delta T_2)}',
        plain: 'ΔTlm = (ΔT1 − ΔT2) / ln(ΔT1/ΔT2)',
        caption: 'Logarithmische mittlere Temperaturdifferenz',
      ),
      HelpFormula(
        tex: r'A = \frac{Q}{U\,\Delta T_{lm}}',
        plain: 'A = Q / (U · ΔTlm)',
        caption: 'Fläche für eine gegebene Leistung',
      ),
    ],
    symbols: [
      HelpSymbol('ΔT1, ΔT2', 'Temperaturdifferenzen an den Enden', 'K'),
      HelpSymbol('U', 'Wärmedurchgangskoeffizient', 'W/m²·K'),
      HelpSymbol('Q', 'Wärmeleistung', 'W'),
      HelpSymbol('A', 'Wärmeübertragungsfläche', 'm²'),
    ],
    notes: [
      'Im Gegenstrom gehört jeder Eintritt zum gegenüberliegenden Austritt, '
          'im Gleichstrom die beiden Eintritte zusammen. Der Gegenstrom liefert '
          'stets die größere LMTD und damit den kleineren Apparat, und nur er '
          'kann den kalten Austritt über den warmen Austritt heben.',
      'Für Rohrbündel- oder Kreuzstromanordnungen mit dem Korrekturfaktor F '
          'aus den üblichen Diagrammen multiplizieren. Ein F unter etwa 0,8 '
          'deutet auf eine schlecht gewählte Schaltung hin.',
      'Setzt ein über den Apparat konstantes U und konstante spezifische '
          'Wärmekapazitäten voraus, ohne Phasenwechsel. Kondensation oder '
          'Verdampfung auf einer Seite verlangt eine zonenweise Betrachtung.',
      'Verschmutzung erhöht den Widerstand mit der Zeit; das Auslegungs-U '
          'sollte einen Verschmutzungszuschlag enthalten, sonst ist der '
          'Apparat binnen eines Jahres zu klein.',
    ],
    references: [
      'Incropera & DeWitt, Fundamentals of Heat and Mass Transfer, ch. 11',
      'TEMA Standards of the Tubular Exchanger Manufacturers Association',
    ],
  ),
  500: ToolHelp(
    summary: 'Rechnet zwischen Einheiten derselben physikalischen Größe um — '
        'Länge, Kraft, Druck, Moment und weitere. Wo die Definition exakt ist, '
        'ist auch die Umrechnung exakt, und für die zollbasierten Einheiten '
        'trifft das meistens zu: Ein Zoll ist seit 1959 genau 25,4 mm.',
    formulas: [
      HelpFormula(
        tex: r'v_{\text{target}} = v_{\text{source}} \times '
            r'\frac{f_{\text{source}}}{f_{\text{target}}}',
        plain: 'Ziel = Quelle × (Faktor Quelle / Faktor Ziel)',
        caption: 'Jede Umrechnung läuft über einen SI-Basiswert',
      ),
    ],
    symbols: [
      HelpSymbol('f', 'Faktor, der eine Einheit auf ihre SI-Basis bringt'),
    ],
    notes: [
      'Über einen einzigen SI-Basiswert statt von Einheit zu Einheit '
          'umzurechnen bedeutet einen Faktor je Einheit statt einen je Paar. '
          'So kann sich eine Tabelle mit n Einheiten nicht selbst widersprechen.',
      'Die Temperatur ist die Ausnahme: Von °C nach °F gibt es neben dem '
          'Faktor auch einen Versatz, sodass sich eine Temperatur*differenz* '
          'anders umrechnet als eine Temperatur.',
      'Pound-force und pound-mass sind verschiedene Größen mit ähnlichem '
          'Namen. Vor dem Umrechnen prüfen, welche gemeint ist.',
    ],
    references: [
      'BIPM, The International System of Units (SI), 9th edition',
      'NIST Special Publication 811, Guide for the Use of the SI',
    ],
  ),
  501: ToolHelp(
    summary: 'Kernloch- und Durchgangsbohrungen für gängige metrische und '
        'Zollgewinde. Das Kernloch lässt so viel Material stehen, dass sich '
        'etwa 75% Tragtiefe ergeben — der praktische Kompromiss zwischen '
        'Gewindefestigkeit und dem Moment, das zum Schneiden nötig ist.',
    formulas: [
      HelpFormula(
        tex: r'd_{\text{tap}} \approx D - P',
        plain: 'Kernloch ≈ D − P (metrisch, ≈75% Tragtiefe)',
        caption: 'Außendurchmesser abzüglich einer Steigung — die 75%-Regel',
      ),
    ],
    symbols: [
      HelpSymbol('D', 'Nennaußendurchmesser des Gewindes', 'mm'),
      HelpSymbol('P', 'Steigung', 'mm'),
    ],
    notes: [
      'D − P ist nicht der Kerndurchmesser: Der Nennkerndurchmesser ist '
          'D − 1,0825·P, und das übliche Kernloch lässt bewusst ein flacheres '
          'Gewinde stehen.',
      'Von 75% auf 100% Tragtiefe zu gehen bringt nur etwa 5% mehr '
          'Festigkeit, verdoppelt aber ungefähr das Schneidmoment. Das lohnt '
          'sich fast nie und bricht Gewindebohrer.',
      'Die Gewindefestigkeit hängt weit stärker von der Einschraub*länge* ab '
          'als vom Prozentwert. In weichem Werkstoff lieber länger als tiefer '
          'einschrauben.',
      'Durchgangsbohrungen richten sich nach den Passungsreihen fein, mittel '
          'und grob. Mittel ist der Regelfall, sofern die Montage keinen '
          'Ausgleich braucht.',
      'Furchende Gewindebohrer brauchen ein größeres Loch als schneidende — '
          'sie verdrängen Werkstoff, statt ihn abzutragen.',
    ],
    references: [
      'ISO 965-1, ISO general purpose metric screw threads — Tolerances',
      'Machinery\'s Handbook, Threads and Threading',
    ],
  ),
  502: ToolHelp(
    summary: 'Grenzmaße und Passungen nach ISO 286 für die bevorzugten '
        'Einheitsbohrungs-Kombinationen. Eine Passung ist ein Paar von '
        'Toleranzfeldern: Der Buchstabe legt die Lage des Feldes zum Nennmaß '
        'fest, die Zahl seine Breite. H7/g6 und H7/p6 unterscheiden sich also '
        'in der Lage, nicht in der Genauigkeit.',
    formulas: [
      HelpFormula(
        tex: r'\text{clearance}_{\max} = \text{hole}_{\max} - '
            r'\text{shaft}_{\min}',
        plain: 'Höchstspiel = Höchstmaß Bohrung − Mindestmaß Welle',
        caption: 'Mindestspiel ist Mindestmaß Bohrung − Höchstmaß Welle',
      ),
    ],
    symbols: [
      HelpSymbol('H', 'Einheitsbohrung: unteres Abmaß gleich null'),
      HelpSymbol('IT', 'Grundtoleranzgrad — die Breite des Feldes'),
      HelpSymbol('µm', 'Abmaße sind in Mikrometern tabelliert'),
    ],
    notes: [
      'Die Einheitsbohrung ist die übliche Wahl: Bohrungen entstehen mit '
          'Werkzeugen fester Größe, Wellen lassen sich leichter anpassen, '
          'also ist es billiger, die Welle zu variieren.',
      'Ein negatives Spiel ist ein Übermaß. H7/p6 und enger sind '
          'Pressverbände und brauchen das Pressverband-Werkzeug zur Prüfung '
          'der Nabenspannung.',
      'Die Feldbreite wächst bei gleichem IT-Grad mit der Größe — ein '
          'IT7-Feld misst 21 µm bei 20 mm und 52 µm bei 300 mm.',
      'Die Tabellen enthalten nur Grenzmaße. Ob eine Welle tatsächlich passt, '
          'hängt auch von der Form ab: Rundheits- und Geradheitsabweichungen '
          'zehren am Spiel.',
    ],
    references: [
      'ISO 286-1 and ISO 286-2, Geometrical product specifications',
      'Machinery\'s Handbook, Allowances and Tolerances for Fits',
    ],
  ),
  503: ToolHelp(
    summary: 'Veröffentlichte Abmessungen und Querschnittswerte gewalzter '
        'Profile — AISC-W-Profile sowie europäische IPE und HEB. Die '
        'veröffentlichten Werte enthalten die Walzradien, die eine reine '
        'Geometrierechnung nicht sieht, und das macht einige Prozent an Fläche '
        'und Steifigkeit aus.',
    formulas: [
      HelpFormula(
        tex: r'S = \frac{I}{c}, \quad r = \sqrt{\frac{I}{A}}',
        plain: 'S = I / c, r = √(I / A)',
        caption: 'Widerstandsmoment und Trägheitsradius, beide hier abgeleitet',
      ),
    ],
    symbols: [
      HelpSymbol('A', 'Querschnittsfläche', 'mm²'),
      HelpSymbol('Ix, Iy', 'Flächenträgheitsmomente um starke und schwache '
          'Achse', 'mm⁴'),
      HelpSymbol('S', 'Elastisches Widerstandsmoment', 'mm³'),
      HelpSymbol('r', 'Trägheitsradius', 'mm'),
    ],
    notes: [
      'Gespeichert sind nur Fläche und die beiden Flächenträgheitsmomente; S '
          'und r werden daraus berechnet, sodass ein Übertragungsfehler sie '
          'nicht widersprüchlich machen kann.',
      'Die Tabellen umfassen doppeltsymmetrische I-Profile. U-Profile und '
          'Winkel haben ihren Schwerpunkt nicht auf halber Höhe und sind nicht '
          'enthalten.',
      'Das sind elastische Werte. Die plastische Bemessung verwendet das '
          'plastische Widerstandsmoment Z, das größer ist — etwa das '
          '1,12-Fache von S bei einem typischen I-Profil.',
      'Vor der Ausführungsplanung eine aktuelle Werks- oder Normtabelle '
          'prüfen: Profile werden gelegentlich geändert oder zurückgezogen.',
    ],
    references: [
      'AISC Steel Construction Manual, Part 1',
      'EN 10365, Hot rolled steel channels, I and H sections',
    ],
  ),
  504: ToolHelp(
    summary: 'Außendurchmesser, Wanddicke und lichte Weite für Stahlrohre nach '
        'ASME B36.10M. Rohre werden auf einen festen Außendurchmesser '
        'gefertigt, damit dieselben Fittings und Gewinde zu jeder Wanddicke '
        'passen. Eine schwerere Schedule frisst deshalb in die lichte Weite '
        'hinein, statt das Rohr größer zu machen.',
    formulas: [
      HelpFormula(
        tex: r'ID = OD - 2t, \quad A = \frac{\pi\,ID^2}{4}',
        plain: 'ID = OD − 2·t, A = π·ID²/4',
        caption: 'Lichte Weite und Strömungsquerschnitt, beide hier abgeleitet',
      ),
    ],
    symbols: [
      HelpSymbol('NPS', 'Nennrohrgröße — eine Bezeichnung, kein Maß'),
      HelpSymbol('DN', 'Die ISO-Nennweite, ebenfalls eine Bezeichnung'),
      HelpSymbol('OD', 'Außendurchmesser', 'mm'),
      HelpSymbol('t', 'Wanddicke', 'mm'),
    ],
    notes: [
      'NPS ist kein Maß. Ein Rohr NPS 2 hat weder 2 Zoll lichte Weite noch 2 '
          'Zoll Außendurchmesser; erst ab NPS 14 entspricht die Zahl dem '
          'Außendurchmesser in Zoll.',
      'Für jede Strömungsrechnung die lichte Weite verwenden, nicht die '
          'Nennweite. Bei NPS 1 beträgt der Unterschied etwa 5%, und in eine '
          'Druckverlustrechnung geht er in der vierten Potenz ein.',
      'STD und XS folgen Sch 40 und Sch 80 nur bis NPS 10 beziehungsweise '
          'NPS 8; darüber nehmen die Gewichtsklassen nicht weiter zu.',
      'Das sind Nennmaße. Die Walztoleranz auf die Wanddicke beträgt '
          'typischerweise −12,5%, was für eine Druckberechnung zählt.',
    ],
    references: [
      'ASME B36.10M, Welded and Seamless Wrought Steel Pipe',
      'ASME B31.3, Process Piping',
    ],
  ),
  505: ToolHelp(
    summary: 'Eindimensionale Toleranzkette über eine Folge von Maßen, sowohl '
        'nach der Worst-Case- als auch nach der statistischen (RSS-)Methode. '
        'Ausgegeben werden das Schließmaß, ob es negativ werden kann, und '
        'welches Maß den größten Teil der Streuung verursacht — dort bringt '
        'eine engere Toleranz am meisten.',
    formulas: [
      HelpFormula(
        tex: r'g = \sum \pm d_i, \quad '
            r'T_{wc} = \sum t_i',
        plain: 'g = Σ ±di, Twc = Σ ti',
        caption: 'Worst Case: Toleranzen addieren sich arithmetisch',
      ),
      HelpFormula(
        tex: r'T_{rss} = \sqrt{\sum t_i^2}',
        plain: 'Trss = √(Σ ti²)',
        caption: 'RSS: sie addieren sich quadratisch',
      ),
    ],
    symbols: [
      HelpSymbol('di', 'Nennmaß jedes Gliedes der Kette', 'mm'),
      HelpSymbol('ti', 'Symmetrisch gerechnete Halbtoleranz je Maß', 'mm'),
      HelpSymbol('g', 'Schließmaß', 'mm'),
    ],
    notes: [
      'Der Worst Case ist reine Arithmetik und unstrittig: Geht er auf, passt '
          'die Baugruppe immer. Danach bemessen.',
      'RSS setzt voraus, dass die Maße unabhängig streuen, mittig im '
          'Toleranzfeld liegen und annähernd normalverteilt sind. Über eine '
          'Losgröße von fünf sagt es nichts aus, und bei driftendem Prozess '
          'oder einem Lieferanten am Feldrand unterschätzt es die Streuung.',
      'Die RSS-Anteile gehen mit dem Quadrat jeder Toleranz und zeigen daher '
          'weit deutlicher auf das lockerste Maß als die Worst-Case-Anteile. '
          'Genau dieses ist zu verengen.',
      'Eine unsymmetrische Toleranz verschiebt den statistischen Mittelwert: '
          '25 +0,10/−0,00 ist in Wirklichkeit 25,05 ±0,05, und als 25 '
          'aufsummiert zieht es die ganze Kette nach unten.',
      'Nur eindimensional. Winkeleinflüsse, Formabweichungen und '
          'Positionstoleranzen brauchen eine vollständige 3D-Toleranzanalyse.',
    ],
    references: [
      'ASME Y14.5, Dimensioning and Tolerancing',
      'Fischer, Mechanical Tolerance Stackup and Analysis',
    ],
  ),
};
