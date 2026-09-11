// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'de';

  static String m0(name) => "Zu „${name}“ hinzugefügt";

  static String m1(n) => "Last ${n}";

  static String m2(label) => "${label} kopiert";

  static String m3(label) =>
      "Entlang der Linie ziehen, um andere Werte von ${label} zu erkunden.";

  static String m4(x) => "Einspannmoment bei x = ${x}";

  static String m5(index) => "Schicht ${index}";

  static String m6(index) => "Eigenform ${index}";

  static String m7(total) =>
      "Alle ${total} Werkzeuge — Maschinenbau, Verbundwerkstoffe, Strömung und Wärme, Schwingungen und mehr";

  static String m8(count, total) =>
      "${count} von ${total} Werkzeugen sind kostenlos. Premium schaltet die übrigen frei.";

  static String m9(count) =>
      "Die ${count} neuesten werden angezeigt. Premium zeigt alle.";

  static String m10(tool) => "${tool} ist ein Premium-Werkzeug";

  static String m11(value) => "Vorschau: ${value}";

  static String m12(count) => "${count} Berechnungen";

  static String m13(name) => "„${name}“ gespeichert";

  static String m14(name) => "In „${name}“ umbenannt";

  static String m15(x) => "Auflagerkraft bei x = ${x}";

  static String m16(tool) => "${tool} aus Favoriten entfernen";

  static String m17(n) => "Maß ${n}";

  static String m18(label) => "Was wäre wenn: ${label}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "A_From_A": MessageLookupByLibrary.simpleMessage("a (ab A)"),
    "About_This_Tool": MessageLookupByLibrary.simpleMessage(
      "Über dieses Werkzeug",
    ),
    "Active_Coils_Na": MessageLookupByLibrary.simpleMessage(
      "Wirksame Windungen, Na",
    ),
    "Add_Custom_Material": MessageLookupByLibrary.simpleMessage(
      "Eigenes Material hinzufügen",
    ),
    "Add_Dimension": MessageLookupByLibrary.simpleMessage("Maß hinzufügen"),
    "Add_Force": MessageLookupByLibrary.simpleMessage("Kraft hinzufügen"),
    "Add_Joint": MessageLookupByLibrary.simpleMessage("Knoten hinzufügen"),
    "Add_Layer": MessageLookupByLibrary.simpleMessage("Schicht hinzufügen"),
    "Add_Load": MessageLookupByLibrary.simpleMessage("Last hinzufügen"),
    "Add_Member": MessageLookupByLibrary.simpleMessage("Stab hinzufügen"),
    "Add_Shape": MessageLookupByLibrary.simpleMessage("Form hinzufügen"),
    "Add_to_Favorites": MessageLookupByLibrary.simpleMessage(
      "Zu Favoriten hinzufügen",
    ),
    "Added_To_Project": m0,
    "Added_to_Favorites": MessageLookupByLibrary.simpleMessage(
      "Zu Favoriten hinzugefügt",
    ),
    "Ads_Removed": MessageLookupByLibrary.simpleMessage("Werbung entfernt"),
    "Ads_Removed_Description": MessageLookupByLibrary.simpleMessage(
      "Danke, dass du ME Toolkit unterstützt.",
    ),
    "Aerospace_Engineering": MessageLookupByLibrary.simpleMessage(
      "Luft- und Raumfahrttechnik",
    ),
    "All": MessageLookupByLibrary.simpleMessage("Alle"),
    "Allowable_Shear_Stress_Optional": MessageLookupByLibrary.simpleMessage(
      "Zulässige Schubspannung (optional)",
    ),
    "Alternating_Moment_Ma": MessageLookupByLibrary.simpleMessage(
      "Wechselmoment, Ma",
    ),
    "Alternating_Torque_Ta": MessageLookupByLibrary.simpleMessage(
      "Wechseldrehmoment, Ta",
    ),
    "Ambient_Temperature": MessageLookupByLibrary.simpleMessage(
      "Umgebungstemperatur",
    ),
    "Analysis_Type": MessageLookupByLibrary.simpleMessage("Analyseart"),
    "Angle_of_Rotation": MessageLookupByLibrary.simpleMessage("Drehwinkel"),
    "Angle_of_twist": MessageLookupByLibrary.simpleMessage("Verdrehwinkel"),
    "Anisotropic_material": MessageLookupByLibrary.simpleMessage(
      "Anisotropes Material",
    ),
    "Answer_No": MessageLookupByLibrary.simpleMessage("Nein"),
    "Answer_Yes": MessageLookupByLibrary.simpleMessage("Ja"),
    "Appearance": MessageLookupByLibrary.simpleMessage("DARSTELLUNG"),
    "Applied_Force_F": MessageLookupByLibrary.simpleMessage(
      "Angreifende Kraft, F",
    ),
    "Area": MessageLookupByLibrary.simpleMessage("Fläche"),
    "Area_A": MessageLookupByLibrary.simpleMessage("Fläche, A"),
    "Axial_Load_F": MessageLookupByLibrary.simpleMessage("Axialkraft, F"),
    "Ball_Bearing": MessageLookupByLibrary.simpleMessage("Kugellager (p = 3)"),
    "Base_Temperature": MessageLookupByLibrary.simpleMessage("Fußtemperatur"),
    "Beam_And_Supports": MessageLookupByLibrary.simpleMessage(
      "Träger & Lagerung",
    ),
    "Beam_Cantilever": MessageLookupByLibrary.simpleMessage("Kragbalken"),
    "Beam_Configuration": MessageLookupByLibrary.simpleMessage(
      "Balkenkonfiguration",
    ),
    "Beam_Determinate_Note": MessageLookupByLibrary.simpleMessage(
      "Statisch bestimmt: Die Auflagerreaktionen folgen allein aus dem Gleichgewicht.",
    ),
    "Beam_Engineering": MessageLookupByLibrary.simpleMessage(
      "Balkenberechnung",
    ),
    "Beam_Fixed_Fixed": MessageLookupByLibrary.simpleMessage(
      "Beidseitig eingespannt",
    ),
    "Beam_Fixed_Pinned": MessageLookupByLibrary.simpleMessage(
      "Eingespannt–gelenkig",
    ),
    "Beam_Free_Free": MessageLookupByLibrary.simpleMessage("Frei–frei"),
    "Beam_Frequency_Footnote": MessageLookupByLibrary.simpleMessage(
      "Euler-Bernoulli-Theorie: Schubverformung und Drehträgheit bleiben unberücksichtigt, daher fallen die Frequenzen bei gedrungenen Balken (L/d unter etwa 10) und bei höheren Eigenformen zu hoch aus.",
    ),
    "Beam_Indeterminate_Note": MessageLookupByLibrary.simpleMessage(
      "Statisch unbestimmt: Die Auflagerreaktionen hängen von EI ab, Querschnitt und Werkstoff verändern also nicht nur die Durchbiegung, sondern auch sie.",
    ),
    "Beam_Length_L": MessageLookupByLibrary.simpleMessage("Balkenlänge, L"),
    "Beam_Load_Analysis": MessageLookupByLibrary.simpleMessage(
      "Balken-Lastanalyse",
    ),
    "Beam_Load_N": m1,
    "Beam_Loads": MessageLookupByLibrary.simpleMessage("Lasten"),
    "Beam_Mode_Constant": MessageLookupByLibrary.simpleMessage(
      "Modenkonstante, βL",
    ),
    "Beam_Model_Note": MessageLookupByLibrary.simpleMessage(
      "Linear-elastische Euler-Bernoulli-Berechnung auf einem Netz aus 120 Elementen. Das Eigengewicht ist nicht enthalten, sofern es nicht als Streckenlast eingegeben wird, und die Schubverformung wird vernachlässigt — bei einem Träger, der kürzer als etwa das Zehnfache seiner Höhe ist, fällt die Durchbiegung damit zu klein aus.",
    ),
    "Beam_Natural_Frequency": MessageLookupByLibrary.simpleMessage(
      "Eigenfrequenz eines Balkens",
    ),
    "Beam_Properties": MessageLookupByLibrary.simpleMessage("Balkenkennwerte"),
    "Beam_Section_Properties": MessageLookupByLibrary.simpleMessage(
      "Querschnittswerte des Balkens",
    ),
    "Beam_Simply_Supported": MessageLookupByLibrary.simpleMessage(
      "Gelenkig gelagert",
    ),
    "Bearing_L10_Life": MessageLookupByLibrary.simpleMessage(
      "Lagerlebensdauer L10",
    ),
    "Belt_Chain_Drive": MessageLookupByLibrary.simpleMessage(
      "Riemen-/Kettenantrieb",
    ),
    "Belt_Length_L": MessageLookupByLibrary.simpleMessage("Riemenlänge, L"),
    "Belt_Pull_Ft": MessageLookupByLibrary.simpleMessage("Riemenzugkraft, Ft"),
    "Bending_Moment_Diagram": MessageLookupByLibrary.simpleMessage(
      "Biegemomentenverlauf",
    ),
    "Bending_Stress_At_Mmax": MessageLookupByLibrary.simpleMessage(
      "Biegespannung bei Mmax",
    ),
    "Bending_Stress_Pinion": MessageLookupByLibrary.simpleMessage(
      "Biegespannung, σ (Ritzel)",
    ),
    "Bolt_Grades_Footnote": MessageLookupByLibrary.simpleMessage(
      "Die Klemmkraft beträgt 75 % der Prüfspannung im Spannungsquerschnitt; das Drehmoment folgt aus T = K·F·d mit K = 0,2 für ein blankes, ungeschmiertes Gewinde. K fasst die gesamte Reibung in einer Zahl zusammen — Beschichtung, Wachs oder Montagepaste verschieben sie zwischen etwa 0,10 und 0,25, und das Drehmoment mit ihr. Wo die Vorspannung zählt, sollte sie gemessen statt über den Drehmomentschlüssel geschätzt werden. Zum Kopieren auf eine Zeile tippen.",
    ),
    "Bolt_Grades_Torque": MessageLookupByLibrary.simpleMessage(
      "Schraubenklassen & Drehmoment",
    ),
    "Bolt_Preload_Torque_Tension": MessageLookupByLibrary.simpleMessage(
      "Schraubenvorspannung / Anzugsmoment",
    ),
    "Bolt_Size": MessageLookupByLibrary.simpleMessage("Größe"),
    "Bolted_Riveted_Joint": MessageLookupByLibrary.simpleMessage(
      "Schraub-/Nietverbindung",
    ),
    "Both": MessageLookupByLibrary.simpleMessage("Beide"),
    "Buckling_Load": MessageLookupByLibrary.simpleMessage("Knicklast"),
    "Buckling_load_of_column": MessageLookupByLibrary.simpleMessage(
      "Knicklast einer Stütze",
    ),
    "Calculate": MessageLookupByLibrary.simpleMessage("Berechnen"),
    "Calculation": MessageLookupByLibrary.simpleMessage("Berechnung"),
    "Calculation_Copied": MessageLookupByLibrary.simpleMessage(
      "Berechnung kopiert",
    ),
    "Cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "Center_Distance": MessageLookupByLibrary.simpleMessage("Achsabstand"),
    "Center_Distance_C": MessageLookupByLibrary.simpleMessage("Achsabstand, C"),
    "Centroid_of_Composite_Area": MessageLookupByLibrary.simpleMessage(
      "Schwerpunkt einer zusammengesetzten Fläche",
    ),
    "Choose_Project": MessageLookupByLibrary.simpleMessage("Projekt wählen"),
    "Circular_Frequency_Omega": MessageLookupByLibrary.simpleMessage(
      "Kreisfrequenz, ω",
    ),
    "Civil_Structural_Engineering": MessageLookupByLibrary.simpleMessage(
      "Bauwesen / Tragwerksplanung",
    ),
    "Clamp_Load_Fi": MessageLookupByLibrary.simpleMessage("Klemmkraft Fi"),
    "Clear": MessageLookupByLibrary.simpleMessage("Löschen"),
    "Clear_History": MessageLookupByLibrary.simpleMessage("Verlauf löschen"),
    "Clear_History_Description": MessageLookupByLibrary.simpleMessage(
      "Dadurch werden alle gespeicherten Berechnungen von diesem Gerät entfernt.",
    ),
    "Clear_History_Question": MessageLookupByLibrary.simpleMessage(
      "Verlauf löschen?",
    ),
    "Clear_Search": MessageLookupByLibrary.simpleMessage("Suche löschen"),
    "Clearance_Close": MessageLookupByLibrary.simpleMessage(
      "Durchgangsloch eng",
    ),
    "Clearance_Free": MessageLookupByLibrary.simpleMessage(
      "Durchgangsloch weit",
    ),
    "Clearance_um": MessageLookupByLibrary.simpleMessage("Spiel (µm)"),
    "Closing_Gap": MessageLookupByLibrary.simpleMessage("Schließmaß"),
    "Cold_Inlet": MessageLookupByLibrary.simpleMessage("Kalteintritt"),
    "Cold_Outlet": MessageLookupByLibrary.simpleMessage("Kaltaustritt"),
    "Cold_Stream_Range": MessageLookupByLibrary.simpleMessage(
      "Temperaturspanne kalt",
    ),
    "Collar_Diameter_Dc": MessageLookupByLibrary.simpleMessage(
      "Mittlerer Bunddurchmesser, dc",
    ),
    "Collar_Friction_Muc": MessageLookupByLibrary.simpleMessage(
      "Bundreibung, μc",
    ),
    "Collar_Hint": MessageLookupByLibrary.simpleMessage(
      "Bunddurchmesser auf null lassen, wenn die Schraube gegen ein Axiallager läuft — dessen Reibung ist gegenüber einem Gleitbund vernachlässigbar.",
    ),
    "Collar_Torque": MessageLookupByLibrary.simpleMessage("Bundmoment"),
    "Combined_Loading_at_a_Point": MessageLookupByLibrary.simpleMessage(
      "Kombinierte Belastung an einem Punkt",
    ),
    "Compliance_Matrix_S": MessageLookupByLibrary.simpleMessage(
      "Nachgiebigkeitsmatrix S",
    ),
    "Composite_Failure_Criteria": MessageLookupByLibrary.simpleMessage(
      "Versagenskriterien für Verbundwerkstoffe (Tsai-Hill / Tsai-Wu)",
    ),
    "Composite_Material": MessageLookupByLibrary.simpleMessage(
      "Verbundwerkstoff",
    ),
    "Composite_Wall_Conduction": MessageLookupByLibrary.simpleMessage(
      "Wärmeleitung durch Schichtwand",
    ),
    "Conductivity_k": MessageLookupByLibrary.simpleMessage(
      "Wärmeleitfähigkeit, k",
    ),
    "Constitutive_relation_of_linear_elastic_material":
        MessageLookupByLibrary.simpleMessage(
          "Stoffgesetz eines linear-elastischen Materials",
        ),
    "Contact_Pressure_P": MessageLookupByLibrary.simpleMessage(
      "Kontaktdruck, p",
    ),
    "Contact_Stress_Est": MessageLookupByLibrary.simpleMessage(
      "Flankenpressung, σc (geschätzt)",
    ),
    "Contributing_Frequencies": MessageLookupByLibrary.simpleMessage(
      "Beitragende Frequenzen",
    ),
    "Copied": MessageLookupByLibrary.simpleMessage("Kopiert"),
    "Copied_Value": m2,
    "Copy": MessageLookupByLibrary.simpleMessage("Kopieren"),
    "Copy_Result": MessageLookupByLibrary.simpleMessage("Ergebnis kopieren"),
    "Corrected_Length_Lc": MessageLookupByLibrary.simpleMessage(
      "Korrigierte Länge, Lc",
    ),
    "CountdownDays": MessageLookupByLibrary.simpleMessage("Countdown Days"),
    "Counter_Flow": MessageLookupByLibrary.simpleMessage("Gegenstrom"),
    "Critical_Speed_Footnote": MessageLookupByLibrary.simpleMessage(
      "Die Gleichung nach Dunkerley liegt stets auf der sicheren Seite, die angegebene kritische Drehzahl ist also konservativ. Halten Sie zur Betriebsdrehzahl einen ausreichenden Abstand.",
    ),
    "Critical_Speed_Nc": MessageLookupByLibrary.simpleMessage(
      "Kritische Drehzahl, Nc",
    ),
    "Cross_Section": MessageLookupByLibrary.simpleMessage("Querschnitt"),
    "Deflection": MessageLookupByLibrary.simpleMessage("Durchbiegung"),
    "Deflection_Delta": MessageLookupByLibrary.simpleMessage("Durchbiegung, δ"),
    "Deflections_and_slopes_of_cantilever_beams":
        MessageLookupByLibrary.simpleMessage(
          "Durchbiegungen und Neigungen von Kragträgern",
        ),
    "Deflections_and_slopes_of_simple_beams":
        MessageLookupByLibrary.simpleMessage(
          "Durchbiegungen und Neigungen einfacher Balken",
        ),
    "Delete": MessageLookupByLibrary.simpleMessage("Löschen"),
    "Delete_Project_Description": MessageLookupByLibrary.simpleMessage(
      "Damit werden das Projekt und seine gespeicherten Eingaben von diesem Gerät entfernt.",
    ),
    "Delete_Project_Question": MessageLookupByLibrary.simpleMessage(
      "Dieses Projekt löschen?",
    ),
    "Density": MessageLookupByLibrary.simpleMessage("Dichte"),
    "Desc_Beam_Analysis": MessageLookupByLibrary.simpleMessage(
      "Gelöst mit dem Weggrößenverfahren und Euler-Bernoulli-Elementen. Damit sind neben den statisch bestimmten Fällen auch der gestützte Kragträger, der beidseitig eingespannte Träger und der Träger mit eingerückten Lagern erfasst — Fälle, die das Gleichgewicht allein nicht löst.",
    ),
    "Desc_Beam_Natural_Frequency": MessageLookupByLibrary.simpleMessage(
      "Biegeeigenfrequenzen eines prismatischen Balkens aus Querschnitt, Länge und Werkstoff. Die ersten drei Biegeeigenformen für fünf Randbedingungen.",
    ),
    "Desc_Beam_Supports": MessageLookupByLibrary.simpleMessage(
      "Zuerst die Lagerung wählen, dann die Lasten eintragen. Einzellasten, gleichmäßige, dreieckige oder trapezförmige Streckenlasten und eingeprägte Momente lassen sich beliebig kombinieren.",
    ),
    "Desc_Bearing_Life": MessageLookupByLibrary.simpleMessage(
      "Nominelle Lebensdauer aus der katalogisierten dynamischen Tragzahl C, der äquivalenten Belastung P und der Drehzahl n: L10 = (C/P)^p.",
    ),
    "Desc_Belt_Drive": MessageLookupByLibrary.simpleMessage(
      "Geometrie eines offenen Riementriebs (oder Kettentriebs mit Teilkreisdurchmessern): Übersetzungsverhältnis, ungefähre Riemenlänge und Umschlingungswinkel der Scheiben.",
    ),
    "Desc_Bolt_Grades": MessageLookupByLibrary.simpleMessage(
      "Prüfspannung, Streckgrenze und Zugfestigkeit für metrische Festigkeitsklassen nach ISO 898-1 und Zollklassen nach SAE J429, mit der Klemmkraft und dem Anziehdrehmoment, die sich für jede Größe und Klasse ergeben. Klemmkraft und Drehmoment werden aus den tabellierten Festigkeiten berechnet und können ihnen daher nicht widersprechen.",
    ),
    "Desc_Bolt_Preload": MessageLookupByLibrary.simpleMessage(
      "Schätzt das erforderliche Anzugsmoment für eine geforderte Schraubenvorspannung anhand der vereinfachten Kurzform der Anzugsmomenten-Gleichung.",
    ),
    "Desc_Composite_Wall": MessageLookupByLibrary.simpleMessage(
      "Stationäre eindimensionale Wärmeleitung durch eine geschichtete ebene Wand. Die Schichtwiderstände t/k liegen in Reihe mit den optionalen Wärmeübergangswiderständen 1/h an beiden Oberflächen und ergeben U, den Wärmestrom und die Temperatur an jeder Schichtgrenze.",
    ),
    "Desc_Fillet_Weld": MessageLookupByLibrary.simpleMessage(
      "Schubspannung in der Nahtwurzel einer Kehlnaht mit Nahtdicke w und wirksamer Länge L, wobei die Wurzel als Versagensebene angenommen wird (übliches vereinfachtes Verfahren).",
    ),
    "Desc_Fin_Efficiency": MessageLookupByLibrary.simpleMessage(
      "Gerade Rechteckrippe mit konstantem Querschnitt, gelöst mit adiabater Spitze und der korrigierten Länge Lc = L + t/2: m = √(2h/kt) und η = tanh(mLc)/(mLc).",
    ),
    "Desc_Lmtd": MessageLookupByLibrary.simpleMessage(
      "Mittlere logarithmische Temperaturdifferenz aus den vier Ein- und Austrittstemperaturen sowie die Fläche, die eine gegebene Leistung benötigt: A = Q/(U·ΔT_lm). Im Gegenstrom gehört zu jedem Eintritt der gegenüberliegende Austritt, im Gleichstrom stehen die beiden Eintritte zusammen.",
    ),
    "Desc_Pipe_Pressure_Drop": MessageLookupByLibrary.simpleMessage(
      "Druckverlust und Verlusthöhe nach Darcy–Weisbach für ein vollgefülltes Rohr: h = f·(L/D)·V²/2g. Die Rohrreibungszahl folgt aus der Colebrook-Gleichung, Einbautenverluste kommen als ΣK Geschwindigkeitshöhen hinzu.",
    ),
    "Desc_Pipe_Schedules": MessageLookupByLibrary.simpleMessage(
      "Außendurchmesser, Wanddicke und lichte Weite für Stahlrohre nach ASME B36.10M, NPS 1/8 bis 24, in den Schedules 10, 40, 80 und 160. Innendurchmesser und Strömungsquerschnitt werden aus dem angegebenen Außendurchmesser und der Wanddicke berechnet.",
    ),
    "Desc_Power_Screw": MessageLookupByLibrary.simpleMessage(
      "Anzugs- und Absenkmoment einer Bewegungsschraube unter Last, ihr Wirkungsgrad und ob sie die Last ohne Bremse hält. Gilt für Wagenheber, Schraubstock, Spanner oder die Leitspindel eines Maschinenschlittens.",
    ),
    "Desc_Press_Fit": MessageLookupByLibrary.simpleMessage(
      "Kontaktdruck und Tangentialspannung für eine massive Welle, die in eine Nabe gepresst wird, wobei für beide Teile dasselbe Material angenommen wird (übliche Vereinfachung — die Poissonzahl hebt sich weg).",
    ),
    "Desc_Pump_Fan_Power": MessageLookupByLibrary.simpleMessage(
      "Leistungsbedarf einer Pumpe oder eines Ventilators: dem Fluid wird P = Δp·Q zugeführt, der Antrieb muss diesen Wert geteilt durch den Wirkungsgrad aufbringen. Die Druckerhöhung wird zusätzlich als Förderhöhe des Fluids angegeben.",
    ),
    "Desc_Reynolds_Number": MessageLookupByLibrary.simpleMessage(
      "Reynolds-Zahl Re = ρVD/μ für die Strömung im Kreisrohr, mit der zugehörigen laminaren, transitionalen oder turbulenten Strömungsform. Geben Sie entweder eine Geschwindigkeit oder einen Volumenstrom ein; der jeweils andere Wert wird mit ausgegeben.",
    ),
    "Desc_Section_Properties": MessageLookupByLibrary.simpleMessage(
      "Berechnet die auf den Schwerpunkt bezogenen geometrischen Kennwerte für Biege- und Spannungsberechnungen am Balken. Die x-Achse verläuft horizontal, die y-Achse vertikal durch den Schwerpunkt.",
    ),
    "Desc_Shaft_Critical_Speed": MessageLookupByLibrary.simpleMessage(
      "Erste biegekritische Drehzahl einer Welle mit einem Läufer an beliebiger Stelle der Stützweite. Läuferwirbel und Eigenmasse der Welle werden nach Dunkerley überlagert.",
    ),
    "Desc_Shaft_Fatigue": MessageLookupByLibrary.simpleMessage(
      "Mindestwellendurchmesser bei kombinierter wechselnder Biegung und Torsion nach dem Gestaltänderungsenergie-/modifizierten Goodman-Kriterium (Shigley). Belassen Sie mittleres Moment/Drehmoment bei 0 für eine Welle mit rein wechselnder Biegung und konstantem Drehmoment — der übliche Fall.",
    ),
    "Desc_Spring_Design": MessageLookupByLibrary.simpleMessage(
      "Federindex, Wahl-Spannungskorrekturfaktor, Federrate und geschätzte Grundeigenfrequenz (beide Enden fest eingespannt) für eine zylindrische Schraubendruckfeder aus Runddraht.",
    ),
    "Desc_Spur_Gear": MessageLookupByLibrary.simpleMessage(
      "Stirnradpaar mit 20°-Vollflankenevolvente: Teilkreisdurchmesser, Achsabstand und einfache Biegespannung nach Lewis mit vereinfachter Schätzung der Flankenpressung. Keine vollständige AGMA-Auslegung.",
    ),
    "Desc_Standard_Sections": MessageLookupByLibrary.simpleMessage(
      "Veröffentlichte Abmessungen und Querschnittswerte gebräuchlicher Normprofile. Widerstandsmoment und Trägheitsradius werden aus der angegebenen Fläche und dem Flächenträgheitsmoment abgeleitet und bleiben dadurch mit diesen konsistent.",
    ),
    "Desc_Tolerance_Stackup": MessageLookupByLibrary.simpleMessage(
      "Eindimensionale Toleranzkette aus mehreren tolerierten Maßen, sowohl nach dem Worst-Case- als auch nach dem statistischen (RSS-)Verfahren. Ausgegeben werden die Grenzen des Schließmaßes, ob es negativ werden kann, und welches Maß den größten Teil der Streuung verursacht.",
    ),
    "Desc_Torsional_Natural_Frequency": MessageLookupByLibrary.simpleMessage(
      "Torsionsgrundfrequenz einer runden Welle, mit einem Läufer gegen ein eingespanntes Ende oder mit zwei Läufern auf freier Welle.",
    ),
    "Desc_Truss_Determinacy": MessageLookupByLibrary.simpleMessage(
      "Ein statisch bestimmtes ebenes Fachwerk erfordert Stäbe + Reaktionen = 2 × Knoten. Geben Sie mindestens ein Fest- und ein Loslager an.",
    ),
    "Description": MessageLookupByLibrary.simpleMessage("Beschreibung"),
    "Description_and_Formulas": MessageLookupByLibrary.simpleMessage(
      "Beschreibung und Formeln",
    ),
    "Diameter_D": MessageLookupByLibrary.simpleMessage("Durchmesser, d"),
    "Diametral_Interference": MessageLookupByLibrary.simpleMessage(
      "Durchmesserübermaß, δ",
    ),
    "Displacement": MessageLookupByLibrary.simpleMessage("Verschiebung"),
    "Display_Format": MessageLookupByLibrary.simpleMessage("ANZEIGEFORMAT"),
    "Double_Shear": MessageLookupByLibrary.simpleMessage("Zweischnittig"),
    "Drag_Along_Line": m3,
    "Drill_Tap_Chart": MessageLookupByLibrary.simpleMessage(
      "Bohrer- & Gewindetabelle",
    ),
    "Drill_Tap_Footnote": MessageLookupByLibrary.simpleMessage(
      "Durchmesser sind in mm; Zollbohrer zeigen die Bezeichnung mit dem mm-Äquivalent darunter. Kernlochbohrer ergeben etwa 75 % Gewindeeingriff in Stahl, metrische Durchgangslöcher folgen ISO 273 (enge und weite Reihe). Zeile antippen, um sie zu kopieren.",
    ),
    "Driving_Torque_T1": MessageLookupByLibrary.simpleMessage(
      "Antriebsmoment, T1",
    ),
    "Dynamic_Load_Rating_C": MessageLookupByLibrary.simpleMessage(
      "Dynamische Tragzahl, C",
    ),
    "Dynamic_Viscosity": MessageLookupByLibrary.simpleMessage(
      "Dynamische Viskosität, μ",
    ),
    "E_Modulus": MessageLookupByLibrary.simpleMessage("E (Elastizitätsmodul)"),
    "Effective_Inertia_J": MessageLookupByLibrary.simpleMessage(
      "Effektives Trägheitsmoment, Jeff",
    ),
    "Effective_Length_L": MessageLookupByLibrary.simpleMessage(
      "Wirksame Länge, L",
    ),
    "Efficiency_Eta": MessageLookupByLibrary.simpleMessage(
      "Wirkungsgrad, η (%)",
    ),
    "Elastic": MessageLookupByLibrary.simpleMessage("Elastisch"),
    "Elastic_Coefficient_Cp": MessageLookupByLibrary.simpleMessage(
      "Elastizitätskoeffizient, Cp (√MPa)",
    ),
    "Elastic_Deflection": MessageLookupByLibrary.simpleMessage(
      "Elastische Durchbiegung",
    ),
    "Elastic_Modulus_E": MessageLookupByLibrary.simpleMessage(
      "Elastizitätsmodul, E",
    ),
    "End_Approach_1": MessageLookupByLibrary.simpleMessage(
      "Temperaturdifferenz Ende 1, ΔT1",
    ),
    "End_Approach_2": MessageLookupByLibrary.simpleMessage(
      "Temperaturdifferenz Ende 2, ΔT2",
    ),
    "End_Condition": MessageLookupByLibrary.simpleMessage("Randbedingung"),
    "Endurance_Limit_Se": MessageLookupByLibrary.simpleMessage(
      "Dauerfestigkeit, Se",
    ),
    "Engineering_Constants": MessageLookupByLibrary.simpleMessage(
      "Technische Konstanten",
    ),
    "Enter_Fx_Fy_Components": MessageLookupByLibrary.simpleMessage(
      "Geben Sie die Fx- und Fy-Komponenten für jede Kraft ein (N)",
    ),
    "Equivalent_Load_P": MessageLookupByLibrary.simpleMessage(
      "Äquivalente Belastung, P",
    ),
    "Equivalent_Shaft_Speed": MessageLookupByLibrary.simpleMessage(
      "Entsprechende Drehzahl",
    ),
    "Err_Active_Coils_Positive": MessageLookupByLibrary.simpleMessage(
      "Die Anzahl der wirksamen Windungen muss positiv sein.",
    ),
    "Err_Add_One_Member": MessageLookupByLibrary.simpleMessage(
      "Fügen Sie mindestens einen Stab hinzu.",
    ),
    "Err_Beam_Load_Incomplete": MessageLookupByLibrary.simpleMessage(
      "Jede Last vollständig ausfüllen oder entfernen.",
    ),
    "Err_C_Positive": MessageLookupByLibrary.simpleMessage(
      "Die dynamische Tragzahl C muss positiv sein.",
    ),
    "Err_Center_Distance_Positive": MessageLookupByLibrary.simpleMessage(
      "Der Achsabstand muss positiv sein.",
    ),
    "Err_Dimensions_Positive": MessageLookupByLibrary.simpleMessage(
      "Die Abmessungen müssen größer als null sein.",
    ),
    "Err_Enter_Beam_Frequency_Inputs": MessageLookupByLibrary.simpleMessage(
      "Geben Sie E, I, A, die Länge und die Dichte ein.",
    ),
    "Err_Enter_C_P_N": MessageLookupByLibrary.simpleMessage(
      "Geben Sie C, P und n ein.",
    ),
    "Err_Enter_Critical_Speed_Inputs": MessageLookupByLibrary.simpleMessage(
      "Geben Sie E, Wellendurchmesser, Stützweite, Läufermasse und Läuferposition ein.",
    ),
    "Err_Enter_D1_D2_C_N1": MessageLookupByLibrary.simpleMessage(
      "Geben Sie d1, d2, C und n1 ein.",
    ),
    "Err_Enter_D_BigD_Na_G": MessageLookupByLibrary.simpleMessage(
      "Geben Sie d, D, Na und G ein.",
    ),
    "Err_Enter_F_D": MessageLookupByLibrary.simpleMessage(
      "Geben Sie F und d ein.",
    ),
    "Err_Enter_Fin_Inputs": MessageLookupByLibrary.simpleMessage(
      "Geben Sie Rippengeometrie, Wärmeleitfähigkeit, Wärmeübergangskoeffizient und Temperaturen ein.",
    ),
    "Err_Enter_Layer_Values": MessageLookupByLibrary.simpleMessage(
      "Jede Schicht braucht eine Dicke und eine Wärmeleitfähigkeit.",
    ),
    "Err_Enter_Lmtd_Inputs": MessageLookupByLibrary.simpleMessage(
      "Geben Sie alle vier Temperaturen, U und die Wärmeleistung ein.",
    ),
    "Err_Enter_Module_N1_N2_Face": MessageLookupByLibrary.simpleMessage(
      "Geben Sie Modul, N1, N2 und Zahnbreite ein.",
    ),
    "Err_Enter_Moment_Or_Torque": MessageLookupByLibrary.simpleMessage(
      "Geben Sie mindestens ein Biegemoment oder Drehmoment ein.",
    ),
    "Err_Enter_One_Load": MessageLookupByLibrary.simpleMessage(
      "Geben Sie mindestens eine Last ein.",
    ),
    "Err_Enter_Pipe_Inputs": MessageLookupByLibrary.simpleMessage(
      "Geben Sie Durchmesser, Länge, Volumenstrom und Fluideigenschaften ein.",
    ),
    "Err_Enter_Pump_Inputs": MessageLookupByLibrary.simpleMessage(
      "Geben Sie Volumenstrom, Druckerhöhung, Dichte und Wirkungsgrad ein.",
    ),
    "Err_Enter_R_Ro_Delta_E": MessageLookupByLibrary.simpleMessage(
      "Geben Sie r, ro, δ und E ein.",
    ),
    "Err_Enter_Reynolds_Inputs": MessageLookupByLibrary.simpleMessage(
      "Geben Sie Durchmesser, Fluideigenschaften und entweder eine Geschwindigkeit oder einen Volumenstrom ein.",
    ),
    "Err_Enter_Se_Sut": MessageLookupByLibrary.simpleMessage(
      "Geben Sie Se und Sut ein.",
    ),
    "Err_Enter_Torsional_Inputs": MessageLookupByLibrary.simpleMessage(
      "Geben Sie G, Wellendurchmesser, Länge und Läuferträgheitsmoment ein.",
    ),
    "Err_Enter_W_L_F": MessageLookupByLibrary.simpleMessage(
      "Geben Sie w, L und F ein.",
    ),
    "Err_Enter_Wall_Inputs": MessageLookupByLibrary.simpleMessage(
      "Geben Sie die Wandfläche und beide Temperaturen ein.",
    ),
    "Err_F_D_Positive": MessageLookupByLibrary.simpleMessage(
      "F und d müssen positiv sein.",
    ),
    "Err_Face_Width_Positive": MessageLookupByLibrary.simpleMessage(
      "Die Zahnbreite muss positiv sein.",
    ),
    "Err_Input_Speed_Positive": MessageLookupByLibrary.simpleMessage(
      "Die Antriebsdrehzahl muss positiv sein.",
    ),
    "Err_Interface_Radius_Positive": MessageLookupByLibrary.simpleMessage(
      "Der Kontaktradius muss positiv sein.",
    ),
    "Err_Interference_Positive": MessageLookupByLibrary.simpleMessage(
      "Das Übermaß muss positiv sein.",
    ),
    "Err_Loads_Non_Negative": MessageLookupByLibrary.simpleMessage(
      "Lasten dürfen nicht negativ sein.",
    ),
    "Err_Member_Unknown_Joint": MessageLookupByLibrary.simpleMessage(
      "Ein Stab verweist auf einen unbekannten Knoten.",
    ),
    "Err_Module_Positive": MessageLookupByLibrary.simpleMessage(
      "Der Modul muss positiv sein.",
    ),
    "Err_Modulus_Positive": MessageLookupByLibrary.simpleMessage(
      "Der Elastizitätsmodul muss positiv sein.",
    ),
    "Err_Nut_Factor_Positive": MessageLookupByLibrary.simpleMessage(
      "Der Nutfaktor K muss positiv sein.",
    ),
    "Err_P_Positive": MessageLookupByLibrary.simpleMessage(
      "Die äquivalente Belastung P muss positiv sein.",
    ),
    "Err_Power_Screw_Inputs": MessageLookupByLibrary.simpleMessage(
      "Außendurchmesser, Steigung und Axialkraft eingeben.",
    ),
    "Err_Pulley_Positive": MessageLookupByLibrary.simpleMessage(
      "Die Riemenscheibendurchmesser müssen positiv sein.",
    ),
    "Err_Result_Not_Savable": MessageLookupByLibrary.simpleMessage(
      "Dieses Ergebnis lässt sich keinem Werkzeug zuordnen und kann daher nicht gespeichert werden.",
    ),
    "Err_Rotor_Position_Range": MessageLookupByLibrary.simpleMessage(
      "Der Läufer muss auf der Welle liegen, abseits der Lager.",
    ),
    "Err_Se_Sut_Positive": MessageLookupByLibrary.simpleMessage(
      "Se und Sut müssen positiv sein.",
    ),
    "Err_Second_Rotor_Inertia": MessageLookupByLibrary.simpleMessage(
      "Geben Sie das Trägheitsmoment des zweiten Läufers ein.",
    ),
    "Err_Shear_Modulus_Positive": MessageLookupByLibrary.simpleMessage(
      "Der Schubmodul muss positiv sein.",
    ),
    "Err_Span_Positive": MessageLookupByLibrary.simpleMessage(
      "Die Spannweite muss größer als null sein.",
    ),
    "Err_Speed_Positive": MessageLookupByLibrary.simpleMessage(
      "Die Drehzahl muss positiv sein.",
    ),
    "Err_Stackup_Dimension": MessageLookupByLibrary.simpleMessage(
      "Für jedes Maß Nennmaß und beide Abmaße eingeben.",
    ),
    "Err_Stackup_Two_Rows": MessageLookupByLibrary.simpleMessage(
      "Eine Toleranzkette braucht mindestens zwei Maße.",
    ),
    "Err_Target_FoS_Positive": MessageLookupByLibrary.simpleMessage(
      "Der geforderte Sicherheitsfaktor muss positiv sein.",
    ),
    "Err_Truss_Two_Joints": MessageLookupByLibrary.simpleMessage(
      "Ein Fachwerk benötigt mindestens 2 Knoten.",
    ),
    "Err_Values_Positive": MessageLookupByLibrary.simpleMessage(
      "Alle Werte müssen größer als null sein.",
    ),
    "Err_W_L_F_Positive": MessageLookupByLibrary.simpleMessage(
      "w, L und F müssen positiv sein.",
    ),
    "Err_Wire_Coil_Positive": MessageLookupByLibrary.simpleMessage(
      "Draht- und Wicklungsdurchmesser müssen positiv sein.",
    ),
    "Export_Report": MessageLookupByLibrary.simpleMessage(
      "Bericht exportieren",
    ),
    "Express_Scan": MessageLookupByLibrary.simpleMessage("Express Scan"),
    "Extreme_Fibre_C": MessageLookupByLibrary.simpleMessage(
      "Randfaserabstand, c",
    ),
    "Extreme_Fibre_Hint": MessageLookupByLibrary.simpleMessage(
      "Optional — mit c wird zusätzlich die Biegespannung ausgegeben.",
    ),
    "Face_Width_F": MessageLookupByLibrary.simpleMessage("Zahnbreite, F"),
    "Factor_of_Safety": MessageLookupByLibrary.simpleMessage(
      "Sicherheitsfaktor",
    ),
    "Failure_criteria_von_Mises_Tresca": MessageLookupByLibrary.simpleMessage(
      "Versagenskriterien (Von Mises & Tresca)",
    ),
    "Family_Angle": MessageLookupByLibrary.simpleMessage("Winkelprofile"),
    "Family_Channel": MessageLookupByLibrary.simpleMessage("U-Profile"),
    "Family_HEB": MessageLookupByLibrary.simpleMessage("HEB-Profile"),
    "Family_HSS": MessageLookupByLibrary.simpleMessage("Hohlprofile"),
    "Family_IPE": MessageLookupByLibrary.simpleMessage("IPE-Profile"),
    "Family_Pipe": MessageLookupByLibrary.simpleMessage("Rohre"),
    "Family_W": MessageLookupByLibrary.simpleMessage("W-Profile"),
    "Fatigue_Safety_Factor": MessageLookupByLibrary.simpleMessage(
      "Dauerfestigkeits-Sicherheitsfaktor (modifiziertes Goodman-Kriterium)",
    ),
    "Favorites": MessageLookupByLibrary.simpleMessage("Favoriten"),
    "Feedback": MessageLookupByLibrary.simpleMessage("Feedback"),
    "Fillet_Weld_Strength": MessageLookupByLibrary.simpleMessage(
      "Festigkeit einer Kehlnaht",
    ),
    "Film_Coefficient_h": MessageLookupByLibrary.simpleMessage(
      "Wärmeübergangskoeffizient, h",
    ),
    "Film_Optional_Note": MessageLookupByLibrary.simpleMessage(
      "Bleibt ein Wärmeübergangskoeffizient leer, gilt die zugehörige Temperatur als Oberflächentemperatur.",
    ),
    "Fin_Effectiveness": MessageLookupByLibrary.simpleMessage(
      "Rippenwirksamkeit, εf",
    ),
    "Fin_Efficiency": MessageLookupByLibrary.simpleMessage(
      "Rippenwirkungsgrad",
    ),
    "Fin_Efficiency_Eta": MessageLookupByLibrary.simpleMessage(
      "Rippenwirkungsgrad, ηf",
    ),
    "Fin_Heat_Flow": MessageLookupByLibrary.simpleMessage("Rippenwärmestrom"),
    "Fin_Length_L": MessageLookupByLibrary.simpleMessage("Rippenlänge, L"),
    "Fin_Parameter_m": MessageLookupByLibrary.simpleMessage(
      "Rippenparameter, m",
    ),
    "Fin_Surface_Area": MessageLookupByLibrary.simpleMessage(
      "Rippenoberfläche",
    ),
    "Fin_Thickness_t": MessageLookupByLibrary.simpleMessage("Rippendicke, t"),
    "Fin_Width_w": MessageLookupByLibrary.simpleMessage("Rippenbreite, w"),
    "FinanceGo": MessageLookupByLibrary.simpleMessage("Finance Go"),
    "Find_Power": MessageLookupByLibrary.simpleMessage("Leistung berechnen"),
    "Find_Torque": MessageLookupByLibrary.simpleMessage("Drehmoment berechnen"),
    "Fit": MessageLookupByLibrary.simpleMessage("Passung"),
    "Fits_Footnote": MessageLookupByLibrary.simpleMessage(
      "Einheitsbohrung-Passungen für 1–500 mm. Jede Zelle zeigt das obere über dem unteren Grenzmaß, in µm ab dem Nennmaß; ein negatives Spiel ist eine Überdeckung. Bänder verlaufen vom unteren bis zum oberen Grenzwert. Die Wellenpassungen c, s und u sind nicht aufgeführt, da ihre Abmaße sich in feinere Größenbänder aufteilen.",
    ),
    "Fits_Tolerances": MessageLookupByLibrary.simpleMessage(
      "Passungen & Toleranzen (ISO 286)",
    ),
    "Fixing_Moment_At_X": m4,
    "Flange_Thickness": MessageLookupByLibrary.simpleMessage("Flanschdicke"),
    "Flexural_Rigidity_EI": MessageLookupByLibrary.simpleMessage(
      "Biegesteifigkeit, EI",
    ),
    "Flexure_formula_of_beam": MessageLookupByLibrary.simpleMessage(
      "Biegeformel eines Balkens",
    ),
    "Flow_Area": MessageLookupByLibrary.simpleMessage("Strömungsquerschnitt"),
    "Flow_Arrangement": MessageLookupByLibrary.simpleMessage("Stromführung"),
    "Flow_Laminar": MessageLookupByLibrary.simpleMessage("Laminar"),
    "Flow_Rate_Q": MessageLookupByLibrary.simpleMessage("Volumenstrom, Q"),
    "Flow_Regime": MessageLookupByLibrary.simpleMessage("Strömungsform"),
    "Flow_Transitional": MessageLookupByLibrary.simpleMessage(
      "Übergangsbereich",
    ),
    "Flow_Turbulent": MessageLookupByLibrary.simpleMessage("Turbulent"),
    "Flow_Velocity_V": MessageLookupByLibrary.simpleMessage(
      "Strömungsgeschwindigkeit, V",
    ),
    "Fluid_Presets": MessageLookupByLibrary.simpleMessage("Fluid-Vorlagen"),
    "Fluids_and_Thermal": MessageLookupByLibrary.simpleMessage(
      "Strömung & Wärme",
    ),
    "Force": MessageLookupByLibrary.simpleMessage("Kraft"),
    "Force_displacement_relation_of_bar": MessageLookupByLibrary.simpleMessage(
      "Kraft-Verschiebungs-Beziehung eines Stabs",
    ),
    "Forces": MessageLookupByLibrary.simpleMessage("Kräfte"),
    "Format_Auto": MessageLookupByLibrary.simpleMessage("Automatisch"),
    "Format_Decimal": MessageLookupByLibrary.simpleMessage("Dezimal"),
    "Format_Engineering": MessageLookupByLibrary.simpleMessage("Technisch"),
    "Format_Scientific": MessageLookupByLibrary.simpleMessage(
      "Wissenschaftlich",
    ),
    "Formula": MessageLookupByLibrary.simpleMessage("Formel"),
    "Formulas": MessageLookupByLibrary.simpleMessage("Formeln"),
    "Friction_Factor_f": MessageLookupByLibrary.simpleMessage(
      "Rohrreibungszahl, f",
    ),
    "Friction_Head_Loss": MessageLookupByLibrary.simpleMessage(
      "Reibungsverlusthöhe",
    ),
    "From": MessageLookupByLibrary.simpleMessage("Von"),
    "Full_Span_UDL_W": MessageLookupByLibrary.simpleMessage(
      "Gleichmäßige Streckenlast über die volle Spannweite, w",
    ),
    "G_Shear_Modulus": MessageLookupByLibrary.simpleMessage("G (Schubmodul)"),
    "Gear_Pitch_Diameter_D2": MessageLookupByLibrary.simpleMessage(
      "Teilkreisdurchmesser Rad, d2",
    ),
    "Gear_Ratio": MessageLookupByLibrary.simpleMessage(
      "Übersetzungsverhältnis",
    ),
    "Gear_Teeth_N2": MessageLookupByLibrary.simpleMessage("Radzähne, N2"),
    "General_stress_calculation": MessageLookupByLibrary.simpleMessage(
      "Allgemeine Spannungsberechnung",
    ),
    "Grade_Class": MessageLookupByLibrary.simpleMessage("Klasse"),
    "Grid_View": MessageLookupByLibrary.simpleMessage("Rasteransicht"),
    "Group_Building": MessageLookupByLibrary.simpleMessage("Baustoffe"),
    "Group_Insulation": MessageLookupByLibrary.simpleMessage("Dämmstoffe"),
    "Group_Metal": MessageLookupByLibrary.simpleMessage("Metalle"),
    "Heat_Duty_Q": MessageLookupByLibrary.simpleMessage("Wärmeleistung, Q"),
    "Heat_Exchanger_LMTD": MessageLookupByLibrary.simpleMessage(
      "Wärmeübertrager (LMTD)",
    ),
    "Heat_Flow_Q": MessageLookupByLibrary.simpleMessage("Wärmestrom, Q"),
    "Heat_Flux": MessageLookupByLibrary.simpleMessage("Wärmestromdichte, q\""),
    "Height_H": MessageLookupByLibrary.simpleMessage("Höhe h"),
    "Helical_Compression_Spring": MessageLookupByLibrary.simpleMessage(
      "Schraubendruckfeder",
    ),
    "Help_Assumptions": MessageLookupByLibrary.simpleMessage(
      "Annahmen & Grenzen",
    ),
    "Help_References": MessageLookupByLibrary.simpleMessage("Quellen"),
    "Help_Symbols": MessageLookupByLibrary.simpleMessage("Formelzeichen"),
    "Help_Unavailable": MessageLookupByLibrary.simpleMessage(
      "Für dieses Werkzeug gibt es noch keine ausführlichen Hinweise.",
    ),
    "History": MessageLookupByLibrary.simpleMessage("Verlauf"),
    "Holds_With_Collar": MessageLookupByLibrary.simpleMessage(
      "Hält mit Bundreibung",
    ),
    "Hole_um": MessageLookupByLibrary.simpleMessage("Bohrung (µm)"),
    "Hot_Inlet": MessageLookupByLibrary.simpleMessage("Heißeintritt"),
    "Hot_Outlet": MessageLookupByLibrary.simpleMessage("Heißaustritt"),
    "Hot_Stream_Range": MessageLookupByLibrary.simpleMessage(
      "Temperaturspanne heiß",
    ),
    "Hub_Hoop_Stress": MessageLookupByLibrary.simpleMessage(
      "Tangentialspannung der Nabenbohrung, σt",
    ),
    "Hub_Outer_Radius_Ro": MessageLookupByLibrary.simpleMessage(
      "Außenradius der Nabe, ro",
    ),
    "Hydraulic_Power": MessageLookupByLibrary.simpleMessage(
      "Hydraulische Leistung",
    ),
    "Image_Guru": MessageLookupByLibrary.simpleMessage("Image Guru"),
    "Imperial_US": MessageLookupByLibrary.simpleMessage(
      "Angloamerikanisch (US)",
    ),
    "Include_Shaft_Mass": MessageLookupByLibrary.simpleMessage(
      "Eigenmasse der Welle berücksichtigen",
    ),
    "Input_Speed_N1": MessageLookupByLibrary.simpleMessage(
      "Antriebsdrehzahl, n1",
    ),
    "Inputs": MessageLookupByLibrary.simpleMessage("Eingaben"),
    "Inside_Air": MessageLookupByLibrary.simpleMessage("Innenluft"),
    "Inside_Diameter_D": MessageLookupByLibrary.simpleMessage(
      "Innendurchmesser, D",
    ),
    "Inside_Film_Coefficient": MessageLookupByLibrary.simpleMessage(
      "Innerer Wärmeübergangskoeffizient, hi",
    ),
    "Inside_Temperature": MessageLookupByLibrary.simpleMessage(
      "Innentemperatur",
    ),
    "Instant_Face": MessageLookupByLibrary.simpleMessage("Instant Face"),
    "Interface_Radius_R": MessageLookupByLibrary.simpleMessage(
      "Kontaktradius, r",
    ),
    "Isothermal_Max_Heat_Flow": MessageLookupByLibrary.simpleMessage(
      "Maximum bei isothermer Rippe",
    ),
    "Isotropic_material": MessageLookupByLibrary.simpleMessage(
      "Isotropes Material",
    ),
    "Joints": MessageLookupByLibrary.simpleMessage("Knoten"),
    "Kf_Bending": MessageLookupByLibrary.simpleMessage("Kf (Biegung)"),
    "Kfs_Torsion": MessageLookupByLibrary.simpleMessage("Kfs (Torsion)"),
    "Kinematic_Viscosity": MessageLookupByLibrary.simpleMessage(
      "Kinematische Viskosität, ν",
    ),
    "L10_Hours": MessageLookupByLibrary.simpleMessage("L10 (Stunden)"),
    "L10_Million_Revolutions": MessageLookupByLibrary.simpleMessage(
      "L10 (Millionen Umdrehungen)",
    ),
    "Lamina_Constants": MessageLookupByLibrary.simpleMessage(
      "Lamina-Konstanten",
    ),
    "Lamina_engineering_constants": MessageLookupByLibrary.simpleMessage(
      "Technische Konstanten einer Lamina",
    ),
    "Lamina_stressstrain": MessageLookupByLibrary.simpleMessage(
      "Spannung/Dehnung einer Lamina",
    ),
    "Laminate_3D_properties": MessageLookupByLibrary.simpleMessage(
      "3D-Eigenschaften eines Laminats",
    ),
    "Laminate_plane_properties": MessageLookupByLibrary.simpleMessage(
      "Ebene Eigenschaften eines Laminats",
    ),
    "Laminate_stressstrain": MessageLookupByLibrary.simpleMessage(
      "Spannung/Dehnung eines Laminats",
    ),
    "Language": MessageLookupByLibrary.simpleMessage("Sprache"),
    "Large_Pulley_Diameter_D2": MessageLookupByLibrary.simpleMessage(
      "Großer Riemenscheibendurchmesser, d2",
    ),
    "Layer_Number": m5,
    "Layer_Resistances": MessageLookupByLibrary.simpleMessage(
      "Schichtwiderstände",
    ),
    "Layer_Thickness": MessageLookupByLibrary.simpleMessage("Schichtdicke"),
    "Layup_Angle": MessageLookupByLibrary.simpleMessage("Faserwinkel"),
    "Layup_Sequence": MessageLookupByLibrary.simpleMessage("Schichtaufbau"),
    "Lead_Angle_Lambda": MessageLookupByLibrary.simpleMessage(
      "Steigungswinkel, λ",
    ),
    "Lead_L": MessageLookupByLibrary.simpleMessage("Steigungshöhe"),
    "Left_Reaction_RA": MessageLookupByLibrary.simpleMessage(
      "Linke Auflagerreaktion, RA",
    ),
    "Left_Support_Position": MessageLookupByLibrary.simpleMessage(
      "Linkes Lager bei",
    ),
    "Leg_Size_W": MessageLookupByLibrary.simpleMessage("Nahtdicke, w"),
    "Lewis_Form_Factor_Y": MessageLookupByLibrary.simpleMessage(
      "Lewis-Formfaktor, Y (Ritzel)",
    ),
    "List_View": MessageLookupByLibrary.simpleMessage("Listenansicht"),
    "Load_Case": MessageLookupByLibrary.simpleMessage("Lastfall"),
    "Load_Couple_M": MessageLookupByLibrary.simpleMessage(
      "Moment, M (linksdrehend +)",
    ),
    "Load_Ends_At": MessageLookupByLibrary.simpleMessage("Endet bei"),
    "Load_Fx": MessageLookupByLibrary.simpleMessage("Last Fx"),
    "Load_Fy": MessageLookupByLibrary.simpleMessage("Last Fy"),
    "Load_Intensity_End": MessageLookupByLibrary.simpleMessage(
      "Intensität am Ende",
    ),
    "Load_Intensity_Start": MessageLookupByLibrary.simpleMessage(
      "Intensität am Anfang",
    ),
    "Load_Magnitude_P": MessageLookupByLibrary.simpleMessage(
      "Betrag, P (nach unten +)",
    ),
    "Load_Position_X": MessageLookupByLibrary.simpleMessage("Position, x"),
    "Load_Starts_At": MessageLookupByLibrary.simpleMessage("Beginnt bei"),
    "Load_Type": MessageLookupByLibrary.simpleMessage("Lasttyp"),
    "Load_Type_Couple": MessageLookupByLibrary.simpleMessage("Moment"),
    "Load_Type_Distributed": MessageLookupByLibrary.simpleMessage(
      "Streckenlast",
    ),
    "Load_Type_Point": MessageLookupByLibrary.simpleMessage("Einzellast"),
    "Log_Mean_Delta_T": MessageLookupByLibrary.simpleMessage(
      "Mittlere log. Temperaturdifferenz",
    ),
    "ME_Toolkit": MessageLookupByLibrary.simpleMessage("ME Toolkit"),
    "Machine_Design": MessageLookupByLibrary.simpleMessage(
      "Maschinenkonstruktion",
    ),
    "Major_Diameter_D": MessageLookupByLibrary.simpleMessage(
      "Außendurchmesser, d",
    ),
    "Mass_Per_Length": MessageLookupByLibrary.simpleMessage(
      "Masse pro Länge, ρA",
    ),
    "Material_Density_Default_Steel": MessageLookupByLibrary.simpleMessage(
      "Materialdichte (Standard Stahl)",
    ),
    "Material_Presets": MessageLookupByLibrary.simpleMessage(
      "Materialvorlagen",
    ),
    "Materials_Science_Engineering": MessageLookupByLibrary.simpleMessage(
      "Werkstoffwissenschaft und -technik",
    ),
    "Maximum_Bending_Moment": MessageLookupByLibrary.simpleMessage(
      "Maximales Biegemoment",
    ),
    "Maximum_Downward_Deflection": MessageLookupByLibrary.simpleMessage(
      "Maximale Durchbiegung nach unten",
    ),
    "Maximum_Hogging_Moment": MessageLookupByLibrary.simpleMessage(
      "Größtes Stützmoment",
    ),
    "Maximum_Sagging_Moment": MessageLookupByLibrary.simpleMessage(
      "Größtes Feldmoment",
    ),
    "Maximum_Shear": MessageLookupByLibrary.simpleMessage("Größte Querkraft"),
    "Maybe_Later": MessageLookupByLibrary.simpleMessage("Vielleicht später"),
    "Mean_Coil_Diameter_D": MessageLookupByLibrary.simpleMessage(
      "Mittlerer Wicklungsdurchmesser, D",
    ),
    "Mean_Diameter_Dm": MessageLookupByLibrary.simpleMessage(
      "Flankendurchmesser, dm",
    ),
    "Mean_Moment_Mm": MessageLookupByLibrary.simpleMessage(
      "Mittleres Moment, Mm",
    ),
    "Mean_Torque_Tm": MessageLookupByLibrary.simpleMessage(
      "Mittleres Drehmoment, Tm",
    ),
    "Mechanical_Engineering": MessageLookupByLibrary.simpleMessage(
      "Maschinenbau",
    ),
    "Mechanics_of_Material": MessageLookupByLibrary.simpleMessage(
      "Festigkeitslehre",
    ),
    "Member_Forces": MessageLookupByLibrary.simpleMessage(
      "Stabkräfte (+ Zug, \\u2212 Druck)",
    ),
    "Members": MessageLookupByLibrary.simpleMessage("Stäbe"),
    "Metric_Coarse": MessageLookupByLibrary.simpleMessage("Metrisch grob"),
    "Metric_Fine": MessageLookupByLibrary.simpleMessage("Metrisch fein"),
    "Metric_SI": MessageLookupByLibrary.simpleMessage("Metrisch (SI)"),
    "Metronome_Go": MessageLookupByLibrary.simpleMessage("Metronome Go"),
    "Minor_Head_Loss": MessageLookupByLibrary.simpleMessage(
      "Einzelverlusthöhe",
    ),
    "Minor_Loss_K": MessageLookupByLibrary.simpleMessage("Einzelverluste, ΣK"),
    "Mint_Translate": MessageLookupByLibrary.simpleMessage("Mint Translate"),
    "Minus_Tolerance": MessageLookupByLibrary.simpleMessage("Unteres Abmaß, −"),
    "Mode_Number": m6,
    "Module_M": MessageLookupByLibrary.simpleMessage("Modul, m"),
    "Modulus_E": MessageLookupByLibrary.simpleMessage("Elastizitätsmodul, E"),
    "Mohrs_Circle_for_Plane_Stress": MessageLookupByLibrary.simpleMessage(
      "Mohrscher Spannungskreis für ebene Spannungszustände",
    ),
    "Moments_of_Inertia": MessageLookupByLibrary.simpleMessage(
      "Flächenträgheitsmomente",
    ),
    "Moments_of_inertia_of_plane_areas": MessageLookupByLibrary.simpleMessage(
      "Flächenträgheitsmomente ebener Flächen",
    ),
    "MoneyTracker": MessageLookupByLibrary.simpleMessage("Money Tracker"),
    "Money_Tracker": MessageLookupByLibrary.simpleMessage("Money Tracker"),
    "Monoclinic_material": MessageLookupByLibrary.simpleMessage(
      "Monoklines Material",
    ),
    "More": MessageLookupByLibrary.simpleMessage("Mehr"),
    "MoreApps": MessageLookupByLibrary.simpleMessage("Weitere Apps"),
    "MyFavourite": MessageLookupByLibrary.simpleMessage("Meine Favoriten"),
    "NASALover": MessageLookupByLibrary.simpleMessage("NASA Lover"),
    "Name": MessageLookupByLibrary.simpleMessage("Name"),
    "Natural_Frequency_Estimate": MessageLookupByLibrary.simpleMessage(
      "Eigenfrequenz (Schätzung)",
    ),
    "Natural_Frequency_F": MessageLookupByLibrary.simpleMessage(
      "Eigenfrequenz, f",
    ),
    "New_Project": MessageLookupByLibrary.simpleMessage("Neues Projekt"),
    "No_Favorites_Yet": MessageLookupByLibrary.simpleMessage(
      "Noch keine Favoriten",
    ),
    "No_Fluids_Found": MessageLookupByLibrary.simpleMessage(
      "Keine Fluide gefunden",
    ),
    "No_History_Yet": MessageLookupByLibrary.simpleMessage("Noch kein Verlauf"),
    "No_Matches": MessageLookupByLibrary.simpleMessage("Keine Treffer"),
    "No_Matches_Description": MessageLookupByLibrary.simpleMessage(
      "Versuchen Sie eine andere Größe oder setzen Sie die Filter zurück.",
    ),
    "No_Materials_Found": MessageLookupByLibrary.simpleMessage(
      "Keine Materialien gefunden",
    ),
    "No_Pipes_Found": MessageLookupByLibrary.simpleMessage(
      "Keine Rohrgrößen gefunden",
    ),
    "No_Saved_Projects_Message": MessageLookupByLibrary.simpleMessage(
      "Speichern Sie eine Berechnung aus dem Verlauf, um ihre Eingaben hier aufzubewahren.",
    ),
    "No_Saved_Projects_Yet": MessageLookupByLibrary.simpleMessage(
      "Noch keine gespeicherten Projekte",
    ),
    "No_Sections_Found": MessageLookupByLibrary.simpleMessage(
      "Keine Profile gefunden",
    ),
    "No_Tools_Found": MessageLookupByLibrary.simpleMessage(
      "Keine Werkzeuge gefunden",
    ),
    "Node_Position": MessageLookupByLibrary.simpleMessage(
      "Knoten, ab Läufer 1",
    ),
    "Nominal_Diameter_D": MessageLookupByLibrary.simpleMessage(
      "Nenndurchmesser, d",
    ),
    "Nominal_Gap": MessageLookupByLibrary.simpleMessage("Nennschließmaß"),
    "Nominal_Size": MessageLookupByLibrary.simpleMessage("Nennmaß"),
    "Nominal_Size_mm": MessageLookupByLibrary.simpleMessage("Größe (mm)"),
    "None": MessageLookupByLibrary.simpleMessage("Keine"),
    "Not_a_number": MessageLookupByLibrary.simpleMessage("Keine Zahl"),
    "Note_Polar_Moment": MessageLookupByLibrary.simpleMessage(
      "J = Ix + Iy ist das polare Flächenträgheitsmoment. Es entspricht nicht der Saint-Venant-Torsionskonstante für nicht-kreisförmige Querschnitte.",
    ),
    "NovelsHub": MessageLookupByLibrary.simpleMessage("Novels Hub"),
    "Novels_Hub": MessageLookupByLibrary.simpleMessage("Novels Hub"),
    "Nut_Factor_K": MessageLookupByLibrary.simpleMessage(
      "Nutfaktor, K (Standard 0,2 — typisch für unbehandelten Stahl; ca. 0,15 geschmiert/beschichtet, ca. 0,2–0,3 trocken)",
    ),
    "Onlynote": MessageLookupByLibrary.simpleMessage("Onlynote"),
    "Operating_Force_F": MessageLookupByLibrary.simpleMessage(
      "Betriebskraft, F",
    ),
    "Optional_For_Bending_Contact": MessageLookupByLibrary.simpleMessage(
      "Optional — für Biege-/Flankenpressung",
    ),
    "Optional_For_Deflection_Frequency": MessageLookupByLibrary.simpleMessage(
      "Optional — für Betriebsdurchbiegung/-spannung und Eigenfrequenz",
    ),
    "Orthotropic_material": MessageLookupByLibrary.simpleMessage(
      "Orthotropes Material",
    ),
    "Output_Speed_N2": MessageLookupByLibrary.simpleMessage(
      "Abtriebsdrehzahl, n2",
    ),
    "Outside_Air": MessageLookupByLibrary.simpleMessage("Außenluft"),
    "Outside_Diameter_OD": MessageLookupByLibrary.simpleMessage(
      "Außendurchmesser, OD",
    ),
    "Outside_Film_Coefficient": MessageLookupByLibrary.simpleMessage(
      "Äußerer Wärmeübergangskoeffizient, ho",
    ),
    "Outside_Temperature": MessageLookupByLibrary.simpleMessage(
      "Außentemperatur",
    ),
    "Overall_Coefficient_U": MessageLookupByLibrary.simpleMessage(
      "Wärmedurchgangskoeffizient, U",
    ),
    "Overall_Height": MessageLookupByLibrary.simpleMessage("Gesamthöhe"),
    "PDF_Missing_Characters": MessageLookupByLibrary.simpleMessage(
      "Im PDF fehlen möglicherweise einige Zeichen",
    ),
    "P_Load": MessageLookupByLibrary.simpleMessage("P (Last)"),
    "Parallel_Flow": MessageLookupByLibrary.simpleMessage("Gleichstrom"),
    "Pick_Fluid": MessageLookupByLibrary.simpleMessage("Fluid wählen"),
    "Pick_Material": MessageLookupByLibrary.simpleMessage("Material auswählen"),
    "Pick_Pipe_Size": MessageLookupByLibrary.simpleMessage("Rohrgröße wählen"),
    "Pick_Standard_Section": MessageLookupByLibrary.simpleMessage(
      "Normprofil wählen",
    ),
    "Pick_Thermal_Material": MessageLookupByLibrary.simpleMessage(
      "Material wählen",
    ),
    "Pin": MessageLookupByLibrary.simpleMessage("Festlager"),
    "Pinion_Pitch_Diameter_D1": MessageLookupByLibrary.simpleMessage(
      "Teilkreisdurchmesser Ritzel, d1",
    ),
    "Pinion_Teeth_N1": MessageLookupByLibrary.simpleMessage("Ritzelzähne, N1"),
    "Pipe_Fill_Note": MessageLookupByLibrary.simpleMessage(
      "Die Auswahl einer Größe füllt den Innendurchmesser unten aus.",
    ),
    "Pipe_Length_L": MessageLookupByLibrary.simpleMessage("Rohrlänge, L"),
    "Pipe_Pressure_Drop": MessageLookupByLibrary.simpleMessage(
      "Rohrdruckverlust",
    ),
    "Pipe_Schedule": MessageLookupByLibrary.simpleMessage("Schedule"),
    "Pipe_Schedules": MessageLookupByLibrary.simpleMessage(
      "Rohrmaße & Schedule",
    ),
    "Pipe_Size_NPS": MessageLookupByLibrary.simpleMessage("NPS"),
    "Pipes_Footnote": MessageLookupByLibrary.simpleMessage(
      "Geschweißte und nahtlose Stahlrohre nach ASME B36.10M. NPS und DN sind Bezeichnungen, keine Maße: erst ab NPS 14 entspricht die Zahl dem Außendurchmesser in Zoll. STD und XS sind nur dort vermerkt, wo sie mit Sch 40 und Sch 80 übereinstimmen.",
    ),
    "Pitch_TPI": MessageLookupByLibrary.simpleMessage("Steigung / TPI"),
    "Plane_Stresses": MessageLookupByLibrary.simpleMessage("Ebene Spannungen"),
    "Plane_stresses_transformation": MessageLookupByLibrary.simpleMessage(
      "Transformation ebener Spannungen",
    ),
    "Plus_Tolerance": MessageLookupByLibrary.simpleMessage("Oberes Abmaß, +"),
    "Point_Load": MessageLookupByLibrary.simpleMessage("Einzellast"),
    "Point_Load_P": MessageLookupByLibrary.simpleMessage("Einzellast, P"),
    "Point_Position_A": MessageLookupByLibrary.simpleMessage(
      "Position der Einzellast, a",
    ),
    "Polar_Area_Moment_J": MessageLookupByLibrary.simpleMessage(
      "Polares Flächenträgheitsmoment, J",
    ),
    "Polar_Moment_Jp": MessageLookupByLibrary.simpleMessage(
      "Polares Flächenmoment, Jp",
    ),
    "Power_Lost": MessageLookupByLibrary.simpleMessage("Verlustleistung"),
    "Power_Optional": MessageLookupByLibrary.simpleMessage(
      "Leistung (optional)",
    ),
    "Power_Screw": MessageLookupByLibrary.simpleMessage("Bewegungsschraube"),
    "Power_Screw_Note": MessageLookupByLibrary.simpleMessage(
      "Coulombsche Reibung an einem einzigen mittleren Radius, wie es die Herleitung nach Shigley voraussetzt. Der wirkliche Reibwert hängt von der Werkstoffpaarung, dem Schmierstoff und dem Verschleiß des Gewindes ab; 0,10 bis 0,20 deckt die meisten Stahl-Bronze-Paarungen ab — eine größere Bandbreite als die meisten Zahlen oben.",
    ),
    "Precision": MessageLookupByLibrary.simpleMessage("GENAUIGKEIT"),
    "Premium": MessageLookupByLibrary.simpleMessage("Premium"),
    "Premium_Badge": MessageLookupByLibrary.simpleMessage("Premium"),
    "Premium_Benefit_Export": MessageLookupByLibrary.simpleMessage(
      "PDF-Berichte, CSV-Export und Ergebnisbilder",
    ),
    "Premium_Benefit_History": MessageLookupByLibrary.simpleMessage(
      "Ihr vollständiger Berechnungsverlauf",
    ),
    "Premium_Benefit_Projects": MessageLookupByLibrary.simpleMessage(
      "Gespeicherte Projekte und zusammengefasste Projektberichte",
    ),
    "Premium_Benefit_Sweep": MessageLookupByLibrary.simpleMessage(
      "Was-wäre-wenn-Parameterdiagramme",
    ),
    "Premium_Benefit_Tools": m7,
    "Premium_Benefit_Universal": MessageLookupByLibrary.simpleMessage(
      "Ohne Aufpreis auch auf iPhone und iPad enthalten",
    ),
    "Premium_Description": MessageLookupByLibrary.simpleMessage(
      "Einmal kaufen, dauerhaft freigeschaltet — auf diesem Mac und auf Ihrem iPhone und iPad.",
    ),
    "Premium_Free_Tools_Note": m8,
    "Premium_History_Limited": m9,
    "Premium_Locked_Export": MessageLookupByLibrary.simpleMessage(
      "PDF-, CSV- und Bildexport gehören zu Premium.",
    ),
    "Premium_Locked_History": MessageLookupByLibrary.simpleMessage(
      "Premium zeigt Ihren vollständigen Berechnungsverlauf.",
    ),
    "Premium_Locked_Projects": MessageLookupByLibrary.simpleMessage(
      "Gespeicherte Projekte gehören zu Premium.",
    ),
    "Premium_Locked_Sweep": MessageLookupByLibrary.simpleMessage(
      "Was-wäre-wenn-Diagramme gehören zu Premium.",
    ),
    "Premium_Locked_Tool": m10,
    "Premium_Not_Found": MessageLookupByLibrary.simpleMessage(
      "Premium ist im App Store noch nicht verfügbar.",
    ),
    "Premium_Purchase_Success": MessageLookupByLibrary.simpleMessage(
      "Premium freigeschaltet. Alle Werkzeuge und Exporte sind jetzt verfügbar.",
    ),
    "Premium_Restore_Not_Found": MessageLookupByLibrary.simpleMessage(
      "Es wurde kein früherer Kauf gefunden.",
    ),
    "Premium_Restore_Success": MessageLookupByLibrary.simpleMessage(
      "Ihr Premium-Kauf wurde wiederhergestellt.",
    ),
    "Premium_Unlocked": MessageLookupByLibrary.simpleMessage(
      "Premium freigeschaltet",
    ),
    "Premium_Unlocked_Description": MessageLookupByLibrary.simpleMessage(
      "Danke, dass Sie ME Toolkit unterstützen. Alle Werkzeuge und Exporte stehen Ihnen zur Verfügung.",
    ),
    "Press_Shrink_Fit_Interference": MessageLookupByLibrary.simpleMessage(
      "Übermaß bei Press-/Schrumpfsitz",
    ),
    "Pressure_Drop": MessageLookupByLibrary.simpleMessage("Druckverlust, Δp"),
    "Pressure_Rise": MessageLookupByLibrary.simpleMessage("Druckerhöhung, Δp"),
    "Preview_Value": m11,
    "Principal_stresses_and_plane": MessageLookupByLibrary.simpleMessage(
      "Hauptspannungen und Hauptebene",
    ),
    "Privacy": MessageLookupByLibrary.simpleMessage("Datenschutz"),
    "Privacy_Choices": MessageLookupByLibrary.simpleMessage(
      "Datenschutzeinstellungen",
    ),
    "Privacy_Choices_Description": MessageLookupByLibrary.simpleMessage(
      "Überprüfen oder ändern Sie Ihre Einwilligung zu personalisierter Werbung.",
    ),
    "Privacy_Choices_Unavailable": MessageLookupByLibrary.simpleMessage(
      "Datenschutzeinstellungen sind derzeit nicht verfügbar. Bitte später erneut versuchen.",
    ),
    "Privacy_Policy": MessageLookupByLibrary.simpleMessage(
      "Datenschutzerklärung",
    ),
    "Product_Not_Found": MessageLookupByLibrary.simpleMessage(
      "„Werbung entfernen“ ist im App Store noch nicht verfügbar.",
    ),
    "Project_Calculations": m12,
    "Project_Entry_No_Result": MessageLookupByLibrary.simpleMessage(
      "Nur Eingaben",
    ),
    "Project_Name": MessageLookupByLibrary.simpleMessage("Projektname"),
    "Project_Name_Hint": MessageLookupByLibrary.simpleMessage(
      "z. B. Ventilfeder — Rev. C",
    ),
    "Project_Name_Required": MessageLookupByLibrary.simpleMessage(
      "Bitte einen Namen eingeben",
    ),
    "Project_Report_Empty": MessageLookupByLibrary.simpleMessage(
      "Dieses Projekt enthält noch keine gespeicherten Ergebnisse. Öffne eine Berechnung und speichere sie im Projekt.",
    ),
    "Project_Saved": m13,
    "Project_Updated": m14,
    "Proof_Strength_Sp": MessageLookupByLibrary.simpleMessage(
      "Prüfspannung Sp",
    ),
    "Pump_Fan_Power": MessageLookupByLibrary.simpleMessage(
      "Pumpen- & Ventilatorleistung",
    ),
    "Pump_Head": MessageLookupByLibrary.simpleMessage("Förderhöhe, H"),
    "Purchase_Cancelled": MessageLookupByLibrary.simpleMessage(
      "Kauf abgebrochen. Es wurden keine Änderungen vorgenommen.",
    ),
    "Purchase_Failed": MessageLookupByLibrary.simpleMessage(
      "Der Kauf konnte nicht abgeschlossen werden. Bitte versuche es erneut.",
    ),
    "Purchase_Pending": MessageLookupByLibrary.simpleMessage(
      "Kauf wartet auf Bestätigung.",
    ),
    "Purchase_Success": MessageLookupByLibrary.simpleMessage(
      "Die Werbung wurde dauerhaft entfernt.",
    ),
    "Purchase_Unavailable": MessageLookupByLibrary.simpleMessage(
      "Käufe sind derzeit nicht verfügbar.",
    ),
    "Purchasing": MessageLookupByLibrary.simpleMessage("Kauf läuft…"),
    "Radius_Gyration_rx": MessageLookupByLibrary.simpleMessage(
      "Trägheitsradius, rx",
    ),
    "Radius_Gyration_ry": MessageLookupByLibrary.simpleMessage(
      "Trägheitsradius, ry",
    ),
    "RatethisApp": MessageLookupByLibrary.simpleMessage("App bewerten"),
    "Reaction_At_X": m15,
    "Recommended_by_Major": MessageLookupByLibrary.simpleMessage(
      "Nach Fachrichtung empfohlen",
    ),
    "Relative_Roughness": MessageLookupByLibrary.simpleMessage(
      "Relative Rauheit, ε/D",
    ),
    "Relaxing_Up": MessageLookupByLibrary.simpleMessage("Relaxing Up"),
    "Remove_Ads": MessageLookupByLibrary.simpleMessage("Werbung entfernen"),
    "Remove_Ads_Description": MessageLookupByLibrary.simpleMessage(
      "Entfernt dauerhaft alle Werbung aus dieser App.",
    ),
    "Remove_Dimension": MessageLookupByLibrary.simpleMessage("Entfernen"),
    "Remove_From_Project": MessageLookupByLibrary.simpleMessage(
      "Aus Projekt entfernen",
    ),
    "Remove_Layer": MessageLookupByLibrary.simpleMessage("Schicht entfernen"),
    "Remove_Load": MessageLookupByLibrary.simpleMessage("Last entfernen"),
    "Remove_Tool_from_Favorites": m16,
    "Remove_from_Favorites": MessageLookupByLibrary.simpleMessage(
      "Aus Favoriten entfernen",
    ),
    "Removed_from_Favorites": MessageLookupByLibrary.simpleMessage(
      "Aus Favoriten entfernt",
    ),
    "Rename_Project": MessageLookupByLibrary.simpleMessage(
      "Projekt umbenennen",
    ),
    "Required_Area_A": MessageLookupByLibrary.simpleMessage(
      "Erforderliche Fläche, A",
    ),
    "Required_Diameter_D": MessageLookupByLibrary.simpleMessage(
      "Erforderlicher Durchmesser, d",
    ),
    "Restore_Not_Found": MessageLookupByLibrary.simpleMessage(
      "Es wurde kein vorheriger Kauf von „Werbung entfernen“ gefunden.",
    ),
    "Restore_Purchases": MessageLookupByLibrary.simpleMessage(
      "Käufe wiederherstellen",
    ),
    "Restore_Success": MessageLookupByLibrary.simpleMessage(
      "Dein Kauf „Werbung entfernen“ wurde wiederhergestellt.",
    ),
    "Restoring": MessageLookupByLibrary.simpleMessage(
      "Wird wiederhergestellt…",
    ),
    "Result": MessageLookupByLibrary.simpleMessage("Ergebnis"),
    "Result_Copied": MessageLookupByLibrary.simpleMessage("Ergebnis kopiert"),
    "Result_Precision": MessageLookupByLibrary.simpleMessage(
      "Ergebnisgenauigkeit",
    ),
    "Result_Strain": MessageLookupByLibrary.simpleMessage("Ergebnisdehnung"),
    "Result_Stress": MessageLookupByLibrary.simpleMessage("Ergebnisspannung"),
    "Resultant_of_Forces_2D": MessageLookupByLibrary.simpleMessage(
      "Kräfteresultierende (2D)",
    ),
    "Reynolds_Number": MessageLookupByLibrary.simpleMessage(
      "Reynolds-Zahl & Strömungsform",
    ),
    "Reynolds_Number_Re": MessageLookupByLibrary.simpleMessage(
      "Reynolds-Zahl, Re",
    ),
    "Right_Reaction_RB": MessageLookupByLibrary.simpleMessage(
      "Rechte Auflagerreaktion, RB",
    ),
    "Right_Support_Position": MessageLookupByLibrary.simpleMessage(
      "Rechtes Lager bei",
    ),
    "Roller_Bearing": MessageLookupByLibrary.simpleMessage(
      "Rollenlager (p = 10/3)",
    ),
    "Roller_Horizontal": MessageLookupByLibrary.simpleMessage(
      "Loslager (horizontale Reaktion)",
    ),
    "Roller_Vertical": MessageLookupByLibrary.simpleMessage(
      "Loslager (vertikale Reaktion)",
    ),
    "Rotor_Alone_Frequency": MessageLookupByLibrary.simpleMessage(
      "Nur Läufer, masselose Welle",
    ),
    "Rotor_Inertia_J1": MessageLookupByLibrary.simpleMessage(
      "Läuferträgheitsmoment, J1",
    ),
    "Rotor_Inertia_J2": MessageLookupByLibrary.simpleMessage(
      "Trägheitsmoment des zweiten Läufers, J2",
    ),
    "Rotor_Mass_M": MessageLookupByLibrary.simpleMessage("Läufermasse, m"),
    "Rotor_Position_A": MessageLookupByLibrary.simpleMessage(
      "Läuferposition von links, a",
    ),
    "Rule_of_mixtures": MessageLookupByLibrary.simpleMessage("Mischungsregel"),
    "Save": MessageLookupByLibrary.simpleMessage("Speichern"),
    "Save_To_Project": MessageLookupByLibrary.simpleMessage(
      "Im Projekt speichern",
    ),
    "Save_as_Project": MessageLookupByLibrary.simpleMessage(
      "Als Projekt speichern",
    ),
    "Saved_Projects": MessageLookupByLibrary.simpleMessage(
      "Gespeicherte Projekte",
    ),
    "Screw_Efficiency": MessageLookupByLibrary.simpleMessage("Wirkungsgrad"),
    "Screw_Pitch_P": MessageLookupByLibrary.simpleMessage("Steigung, p"),
    "Search": MessageLookupByLibrary.simpleMessage("Suche"),
    "Search_Bolt_Size_Grade": MessageLookupByLibrary.simpleMessage(
      "Größe oder Klasse suchen",
    ),
    "Search_Fluids": MessageLookupByLibrary.simpleMessage("Fluide suchen"),
    "Search_Materials": MessageLookupByLibrary.simpleMessage(
      "Materialien durchsuchen",
    ),
    "Search_Pipe_Size": MessageLookupByLibrary.simpleMessage(
      "NPS, DN oder Schedule suchen",
    ),
    "Search_Section": MessageLookupByLibrary.simpleMessage(
      "Bezeichnung suchen, z. B. W12X40",
    ),
    "Search_Size_Or_Fit": MessageLookupByLibrary.simpleMessage(
      "Durchmesser oder Passung suchen",
    ),
    "Search_Thread_Size": MessageLookupByLibrary.simpleMessage(
      "Gewindegröße suchen",
    ),
    "Search_Tools": MessageLookupByLibrary.simpleMessage(
      "Werkzeuge durchsuchen",
    ),
    "Second_Moment_I": MessageLookupByLibrary.simpleMessage(
      "Flächenträgheitsmoment, I",
    ),
    "Second_Moment_Ix": MessageLookupByLibrary.simpleMessage(
      "Flächenträgheitsmoment, Ix",
    ),
    "Second_Moment_Iy": MessageLookupByLibrary.simpleMessage(
      "Flächenträgheitsmoment, Iy",
    ),
    "Section_Depth_d": MessageLookupByLibrary.simpleMessage("Höhe, d"),
    "Section_Designation": MessageLookupByLibrary.simpleMessage("Bezeichnung"),
    "Section_Dimensions": MessageLookupByLibrary.simpleMessage("Abmessungen"),
    "Section_Fill_Note": MessageLookupByLibrary.simpleMessage(
      "Die Auswahl eines Profils füllt die Abmessungen unten aus. Daraus berechnete Querschnittswerte lassen die Ausrundungen außer Acht und liegen daher einige Prozent unter den Tabellenwerten.",
    ),
    "Section_Flange_tf": MessageLookupByLibrary.simpleMessage("Flansch, tf"),
    "Section_Modulus_Zx": MessageLookupByLibrary.simpleMessage(
      "Widerstandsmoment, Zx",
    ),
    "Section_Modulus_Zy": MessageLookupByLibrary.simpleMessage(
      "Widerstandsmoment, Zy",
    ),
    "Section_Web_tw": MessageLookupByLibrary.simpleMessage("Steg, tw"),
    "Section_Width_b": MessageLookupByLibrary.simpleMessage("Breite, b"),
    "Sections_Footnote": MessageLookupByLibrary.simpleMessage(
      "Nennwerte der aufgeführten Profile. Widerstandsmoment und Trägheitsradius werden aus den angegebenen A und I berechnet. Prüfen Sie vor der Ausführungsplanung eine aktuelle Werks- oder Normtabelle.",
    ),
    "See_Premium": MessageLookupByLibrary.simpleMessage("Premium ansehen"),
    "Self_Locking_Thread": MessageLookupByLibrary.simpleMessage(
      "Selbsthemmend im Gewinde",
    ),
    "Settings": MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "Shaft_Alone_Frequency": MessageLookupByLibrary.simpleMessage(
      "Nur Wellenmasse",
    ),
    "Shaft_And_Rotor": MessageLookupByLibrary.simpleMessage("Welle und Läufer"),
    "Shaft_Between_Bearings": MessageLookupByLibrary.simpleMessage(
      "Zwischen Lagern",
    ),
    "Shaft_Both_Ends_Fixed": MessageLookupByLibrary.simpleMessage(
      "Beide Enden eingespannt",
    ),
    "Shaft_Critical_Speed": MessageLookupByLibrary.simpleMessage(
      "Kritische Drehzahl der Welle",
    ),
    "Shaft_Diameter_D": MessageLookupByLibrary.simpleMessage(
      "Wellendurchmesser, d",
    ),
    "Shaft_Fatigue_Design": MessageLookupByLibrary.simpleMessage(
      "Wellenauslegung auf Dauerfestigkeit (DE-Goodman)",
    ),
    "Shaft_Length_L": MessageLookupByLibrary.simpleMessage("Wellenlänge, L"),
    "Shaft_Mass": MessageLookupByLibrary.simpleMessage("Wellenmasse"),
    "Shaft_Overhung": MessageLookupByLibrary.simpleMessage("Fliegend gelagert"),
    "Shaft_Power": MessageLookupByLibrary.simpleMessage("Wellenleistung"),
    "Shaft_Stiffness_K": MessageLookupByLibrary.simpleMessage(
      "Wellensteifigkeit am Läufer, k",
    ),
    "Shaft_Surface_Stress": MessageLookupByLibrary.simpleMessage(
      "Oberflächenspannung der Welle, σs",
    ),
    "Shaft_power_and_torque": MessageLookupByLibrary.simpleMessage(
      "Wellenleistung und Drehmoment",
    ),
    "Shaft_um": MessageLookupByLibrary.simpleMessage("Welle (µm)"),
    "Shape": MessageLookupByLibrary.simpleMessage("Form"),
    "Shape_Type": MessageLookupByLibrary.simpleMessage("Formtyp"),
    "Share_Format_CSV": MessageLookupByLibrary.simpleMessage("CSV"),
    "Share_Format_CSV_Description": MessageLookupByLibrary.simpleMessage(
      "Eine Tabelle der Werte und Einheiten",
    ),
    "Share_Format_Image": MessageLookupByLibrary.simpleMessage("Bild"),
    "Share_Format_Image_Description": MessageLookupByLibrary.simpleMessage(
      "Ein Bild dieser Ergebnisseite",
    ),
    "Share_Format_PDF": MessageLookupByLibrary.simpleMessage("PDF"),
    "Share_Format_PDF_Description": MessageLookupByLibrary.simpleMessage(
      "Ein Bericht mit Tabellen und Formel",
    ),
    "Share_Format_Text": MessageLookupByLibrary.simpleMessage("Text"),
    "Share_Format_Text_Description": MessageLookupByLibrary.simpleMessage(
      "Reiner Text zum Einfügen an beliebiger Stelle",
    ),
    "Share_Results": MessageLookupByLibrary.simpleMessage("Ergebnisse teilen"),
    "SharethisApp": MessageLookupByLibrary.simpleMessage("App teilen"),
    "Shear_Force_Diagram": MessageLookupByLibrary.simpleMessage(
      "Querkraftverlauf",
    ),
    "Shear_Modulus_G": MessageLookupByLibrary.simpleMessage("Schubmodul, G"),
    "Shear_Stress_Tau": MessageLookupByLibrary.simpleMessage(
      "Schubspannung, τ",
    ),
    "Shows": MessageLookupByLibrary.simpleMessage("Shows"),
    "Simple_Calculator": MessageLookupByLibrary.simpleMessage(
      "Simple Calculator",
    ),
    "Simple_English_Dictionary": MessageLookupByLibrary.simpleMessage(
      "Simple English Dictionary",
    ),
    "Simply_Supported_Beam": MessageLookupByLibrary.simpleMessage(
      "Einfach gelagerter Balken",
    ),
    "Simply_Supported_Beam_Note": MessageLookupByLibrary.simpleMessage(
      "Einfach gelagerter Balken — Festlager bei A (links), Loslager bei B (rechts)",
    ),
    "Single_Shear": MessageLookupByLibrary.simpleMessage("Einschnittig"),
    "Slope": MessageLookupByLibrary.simpleMessage("Neigung"),
    "Small_Pulley_Diameter_D1": MessageLookupByLibrary.simpleMessage(
      "Kleiner Riemenscheibendurchmesser, d1",
    ),
    "Solid_Height": MessageLookupByLibrary.simpleMessage("Blocklänge"),
    "Span_L": MessageLookupByLibrary.simpleMessage("Spannweite, L"),
    "Span_L_Short": MessageLookupByLibrary.simpleMessage("Spannweite L"),
    "Speed_N": MessageLookupByLibrary.simpleMessage("Drehzahl, n"),
    "Speed_Ratio": MessageLookupByLibrary.simpleMessage(
      "Übersetzungsverhältnis",
    ),
    "Spring_Index_C": MessageLookupByLibrary.simpleMessage("Federindex, C"),
    "Spring_Rate_K": MessageLookupByLibrary.simpleMessage("Federrate, k"),
    "Spur_Gear_Geometry": MessageLookupByLibrary.simpleMessage(
      "Stirnradgeometrie",
    ),
    "Stackup_Adds": MessageLookupByLibrary.simpleMessage("Addiert"),
    "Stackup_Clearance": MessageLookupByLibrary.simpleMessage("Immer Spiel"),
    "Stackup_Contributions": MessageLookupByLibrary.simpleMessage(
      "Anteil an der Streuung",
    ),
    "Stackup_Dimension_N": m17,
    "Stackup_Dimensions": MessageLookupByLibrary.simpleMessage("Maßkette"),
    "Stackup_Dominant": MessageLookupByLibrary.simpleMessage("Größter Anteil"),
    "Stackup_Footnote": MessageLookupByLibrary.simpleMessage(
      "Der Worst Case ist reine Arithmetik: geht er auf, passt die Baugruppe immer. RSS setzt voraus, dass die Maße unabhängig streuen, mittig im Toleranzfeld liegen und annähernd normalverteilt sind — für eine Losgröße von fünf sagt es nichts aus, und bei driftendem Prozess oder einem Lieferanten am Feldrand unterschätzt es die Streuung. Auslegen nach Worst Case; Toleranz dort vergeben, wohin RSS zeigt.",
    ),
    "Stackup_Interference": MessageLookupByLibrary.simpleMessage(
      "Übermaß möglich",
    ),
    "Stackup_Line_To_Line": MessageLookupByLibrary.simpleMessage("Spielfrei"),
    "Stackup_Maximum": MessageLookupByLibrary.simpleMessage("Maximum"),
    "Stackup_Mean": MessageLookupByLibrary.simpleMessage("Mittelwert"),
    "Stackup_Minimum": MessageLookupByLibrary.simpleMessage("Minimum"),
    "Stackup_Outcome": MessageLookupByLibrary.simpleMessage(
      "Worst-Case-Ergebnis",
    ),
    "Stackup_RSS": MessageLookupByLibrary.simpleMessage("Statistisch (RSS)"),
    "Stackup_RSS_Saving": MessageLookupByLibrary.simpleMessage(
      "RSS verringert das Band um",
    ),
    "Stackup_Spread": MessageLookupByLibrary.simpleMessage("Gesamtstreuung"),
    "Stackup_Subtracts": MessageLookupByLibrary.simpleMessage("Subtrahiert"),
    "Stackup_Worst_Case": MessageLookupByLibrary.simpleMessage("Worst Case"),
    "Standard_Sections": MessageLookupByLibrary.simpleMessage("Normprofile"),
    "Static_Deflection_Delta": MessageLookupByLibrary.simpleMessage(
      "Statische Durchbiegung, δst",
    ),
    "Stiffness_Matrix_C": MessageLookupByLibrary.simpleMessage(
      "Steifigkeitsmatrix C",
    ),
    "Stiffness_Matrix_Q": MessageLookupByLibrary.simpleMessage(
      "Steifigkeitsmatrix Q",
    ),
    "Strain": MessageLookupByLibrary.simpleMessage("Dehnung"),
    "Stress": MessageLookupByLibrary.simpleMessage("Spannung"),
    "Stress_Area_As": MessageLookupByLibrary.simpleMessage(
      "Spannungsquerschnitt",
    ),
    "Stress_Concentration_Defaults": MessageLookupByLibrary.simpleMessage(
      "Kerbwirkungszahlen (Standard: profilierte Passfedernut) und geforderter Sicherheitsfaktor",
    ),
    "Stress_Results": MessageLookupByLibrary.simpleMessage(
      "Spannungsergebnisse",
    ),
    "Stresses_in_a_thin_walled_cylindrical_pressure_vessel":
        MessageLookupByLibrary.simpleMessage(
          "Spannungen in einem dünnwandigen zylindrischen Druckbehälter",
        ),
    "Stresses_in_the_wall_of_a_spherical_shell":
        MessageLookupByLibrary.simpleMessage(
          "Spannungen in der Wand einer Kugelschale",
        ),
    "Stressstrain_of_linear_elastic_material":
        MessageLookupByLibrary.simpleMessage(
          "Spannung/Dehnung eines linear-elastischen Materials",
        ),
    "Strong_Axis": MessageLookupByLibrary.simpleMessage("Starke Achse (x-x)"),
    "Subtract": MessageLookupByLibrary.simpleMessage("Subtrahieren"),
    "Sudoku_Lover": MessageLookupByLibrary.simpleMessage("Sudoku Lover"),
    "Support": MessageLookupByLibrary.simpleMessage("Lager"),
    "Support_Arrangement": MessageLookupByLibrary.simpleMessage("Lagerungsart"),
    "Support_Cantilever_Left": MessageLookupByLibrary.simpleMessage(
      "Kragträger, links eingespannt",
    ),
    "Support_Cantilever_Right": MessageLookupByLibrary.simpleMessage(
      "Kragträger, rechts eingespannt",
    ),
    "Support_Fixed_Fixed": MessageLookupByLibrary.simpleMessage(
      "Beidseitig eingespannt",
    ),
    "Support_Overhang": MessageLookupByLibrary.simpleMessage(
      "Kragarme beidseitig",
    ),
    "Support_Propped_Cantilever": MessageLookupByLibrary.simpleMessage(
      "Eingespannt und gestützt",
    ),
    "Support_Reactions": MessageLookupByLibrary.simpleMessage(
      "Auflagerreaktionen",
    ),
    "Support_Simply_Supported": MessageLookupByLibrary.simpleMessage(
      "Gelenkig gelagert",
    ),
    "Swap": MessageLookupByLibrary.simpleMessage("Tauschen"),
    "SwiftComp": MessageLookupByLibrary.simpleMessage(
      "SwiftComp:Composites Material",
    ),
    "System_Default": MessageLookupByLibrary.simpleMessage("Systemstandard"),
    "Tangential_Load_Wt": MessageLookupByLibrary.simpleMessage(
      "Tangentialkraft, Wt",
    ),
    "Tap_Drill": MessageLookupByLibrary.simpleMessage("Kernlochbohrer"),
    "Target_Factor_of_Safety_N": MessageLookupByLibrary.simpleMessage(
      "Geforderter Sicherheitsfaktor, n",
    ),
    "Target_Preload_F": MessageLookupByLibrary.simpleMessage(
      "Geforderte Vorspannkraft, F",
    ),
    "Target_Safety_Factor_N": MessageLookupByLibrary.simpleMessage(
      "Geforderter Sicherheitsfaktor, n",
    ),
    "The_Maximum_Shear_Stress": MessageLookupByLibrary.simpleMessage(
      "Maximale Schubspannung",
    ),
    "Theme_Dark": MessageLookupByLibrary.simpleMessage("Dunkel"),
    "Theme_Dark_Description": MessageLookupByLibrary.simpleMessage(
      "Immer das dunkle Design verwenden",
    ),
    "Theme_Light": MessageLookupByLibrary.simpleMessage("Hell"),
    "Theme_Light_Description": MessageLookupByLibrary.simpleMessage(
      "Immer das helle Design verwenden",
    ),
    "Theme_System": MessageLookupByLibrary.simpleMessage("Systemstandard"),
    "Theme_System_Description": MessageLookupByLibrary.simpleMessage(
      "Folgt der Darstellungseinstellung des Geräts",
    ),
    "Theory_of_Elasticity": MessageLookupByLibrary.simpleMessage(
      "Elastizitätstheorie",
    ),
    "Thermal": MessageLookupByLibrary.simpleMessage("Thermisch"),
    "Thermal_Material_Presets": MessageLookupByLibrary.simpleMessage(
      "Wärmetechnische Materialien",
    ),
    "Thermal_Results": MessageLookupByLibrary.simpleMessage(
      "Thermische Ergebnisse",
    ),
    "Thermal_deformation_and_stress": MessageLookupByLibrary.simpleMessage(
      "Thermische Verformung und Spannung",
    ),
    "Thickness_t": MessageLookupByLibrary.simpleMessage("Dicke, t"),
    "Thread": MessageLookupByLibrary.simpleMessage("Gewinde"),
    "Thread_Form": MessageLookupByLibrary.simpleMessage("Gewindeform"),
    "Thread_Form_ACME": MessageLookupByLibrary.simpleMessage("ACME 29°"),
    "Thread_Form_Square": MessageLookupByLibrary.simpleMessage("Flach"),
    "Thread_Form_Trapezoidal": MessageLookupByLibrary.simpleMessage(
      "Trapez 30°",
    ),
    "Thread_Friction_Mu": MessageLookupByLibrary.simpleMessage(
      "Gewindereibung, μ",
    ),
    "Thread_Starts": MessageLookupByLibrary.simpleMessage("Gangzahl"),
    "Thread_Torque_Lower": MessageLookupByLibrary.simpleMessage(
      "Gewindemoment, Senken",
    ),
    "Thread_Torque_Raise": MessageLookupByLibrary.simpleMessage(
      "Gewindemoment, Heben",
    ),
    "Tightening_Torque_T": MessageLookupByLibrary.simpleMessage(
      "Anzugsmoment, T",
    ),
    "Tip_Temperature": MessageLookupByLibrary.simpleMessage(
      "Spitzentemperatur",
    ),
    "Tolerance_Stackup": MessageLookupByLibrary.simpleMessage("Toleranzkette"),
    "Torque_T": MessageLookupByLibrary.simpleMessage("Drehmoment T"),
    "Torque_To_Lower": MessageLookupByLibrary.simpleMessage(
      "Moment zum Senken",
    ),
    "Torque_To_Raise": MessageLookupByLibrary.simpleMessage("Moment zum Heben"),
    "Torsion_formula_of_bar": MessageLookupByLibrary.simpleMessage(
      "Torsionsformel eines Stabs",
    ),
    "Torsional_Footnote": MessageLookupByLibrary.simpleMessage(
      "Die Eigenträgheit der Welle bleibt unberücksichtigt. Ist sie mit der der Läufer vergleichbar, verwenden Sie stattdessen eine vollständige Mehrmassenrechnung (Holzer).",
    ),
    "Torsional_Natural_Frequency": MessageLookupByLibrary.simpleMessage(
      "Torsionseigenfrequenz",
    ),
    "Torsional_Single_Rotor": MessageLookupByLibrary.simpleMessage(
      "Ein Läufer, fernes Ende eingespannt",
    ),
    "Torsional_Stiffness_Kt": MessageLookupByLibrary.simpleMessage(
      "Torsionssteifigkeit, kt",
    ),
    "Torsional_Two_Rotor": MessageLookupByLibrary.simpleMessage(
      "Zwei Läufer, freie Welle",
    ),
    "Total_Head_Loss": MessageLookupByLibrary.simpleMessage(
      "Gesamtverlusthöhe",
    ),
    "Total_Resistance_R": MessageLookupByLibrary.simpleMessage(
      "Gesamtwiderstand, R",
    ),
    "Transverse_shear_stress_in_beam": MessageLookupByLibrary.simpleMessage(
      "Querschubspannung im Balken",
    ),
    "Transversely_isotropic_material": MessageLookupByLibrary.simpleMessage(
      "Transversal-isotropes Material",
    ),
    "Truss_Analysis_Method_of_Joints": MessageLookupByLibrary.simpleMessage(
      "Fachwerkanalyse (Knotenpunktverfahren)",
    ),
    "Truss_Geometry": MessageLookupByLibrary.simpleMessage("Fachwerkgeometrie"),
    "Truss_Statics": MessageLookupByLibrary.simpleMessage("Fachwerk / Statik"),
    "UDL": MessageLookupByLibrary.simpleMessage("Streckenlast"),
    "Ultimate_Strength": MessageLookupByLibrary.simpleMessage("Zugfestigkeit"),
    "Ultimate_Strength_Sut": MessageLookupByLibrary.simpleMessage(
      "Zugfestigkeit, Sut",
    ),
    "Unified_Coarse": MessageLookupByLibrary.simpleMessage(
      "Unified grob (UNC)",
    ),
    "Unified_Fine": MessageLookupByLibrary.simpleMessage("Unified fein (UNF)"),
    "Uniform_Distributed_Load_Full_Span": MessageLookupByLibrary.simpleMessage(
      "Gleichmäßige Streckenlast (volle Spannweite)",
    ),
    "Unit_Converter": MessageLookupByLibrary.simpleMessage(
      "Einheitenumrechner",
    ),
    "Unit_System": MessageLookupByLibrary.simpleMessage("EINHEITENSYSTEM"),
    "Unlock_Premium": MessageLookupByLibrary.simpleMessage(
      "Premium freischalten",
    ),
    "Utilities": MessageLookupByLibrary.simpleMessage("Werkzeuge"),
    "Velocity_Head": MessageLookupByLibrary.simpleMessage(
      "Geschwindigkeitshöhe, V²/2g",
    ),
    "Vibration_Modes": MessageLookupByLibrary.simpleMessage("Eigenfrequenzen"),
    "W_Intensity": MessageLookupByLibrary.simpleMessage("w (Streckenlast)"),
    "Wahl_Factor_Kw": MessageLookupByLibrary.simpleMessage("Wahl-Faktor, Kw"),
    "Wall_Area_A": MessageLookupByLibrary.simpleMessage("Wandfläche, A"),
    "Wall_Interface": MessageLookupByLibrary.simpleMessage("Schichtgrenze"),
    "Wall_Layers": MessageLookupByLibrary.simpleMessage("Wandschichten"),
    "Wall_Roughness": MessageLookupByLibrary.simpleMessage("Wandrauheit, ε"),
    "Wall_Surface": MessageLookupByLibrary.simpleMessage("Oberfläche"),
    "Wall_Temperatures": MessageLookupByLibrary.simpleMessage(
      "Temperaturen durch die Wand",
    ),
    "Wall_Thickness": MessageLookupByLibrary.simpleMessage("Wandstärke"),
    "Water_Tracker": MessageLookupByLibrary.simpleMessage("Water Tracker"),
    "Weak_Axis": MessageLookupByLibrary.simpleMessage("Schwache Achse (y-y)"),
    "Web_Thickness": MessageLookupByLibrary.simpleMessage("Stegdicke"),
    "What_If": m18,
    "Wire_Diameter_D": MessageLookupByLibrary.simpleMessage(
      "Drahtdurchmesser, d",
    ),
    "World_Weather_Live": MessageLookupByLibrary.simpleMessage(
      "World Weather Live",
    ),
    "Wrap_Angle_Large_Pulley": MessageLookupByLibrary.simpleMessage(
      "Umschlingungswinkel, große Scheibe",
    ),
    "Wrap_Angle_Small_Pulley": MessageLookupByLibrary.simpleMessage(
      "Umschlingungswinkel, kleine Scheibe",
    ),
    "Yes_Habit": MessageLookupByLibrary.simpleMessage("Yes Habit"),
    "Yield_Strength": MessageLookupByLibrary.simpleMessage("Streckgrenze"),
  };
}
