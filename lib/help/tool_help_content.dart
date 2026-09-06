import 'package:mechanical_engineering_toolkit/help/tool_help.dart';

/// Long-form explanations, keyed by the tool ids in `ToolLibrary.getTools`.
///
/// English only for now. The rest of the interface is localized through the
/// `.arb` files, but this is several thousand words of technical prose per
/// language, and a machine-translated derivation that gets a sign or a
/// qualifier wrong is worse than one the reader can see is in English. The
/// shape here — a map of plain data — is what a per-locale registry would
/// slot into when translations exist.
///
/// A tool with no entry simply shows no "?" button, so this can be filled in
/// without leaving dead controls behind.
const Map<int, ToolHelp> toolHelp = {
  // ---------------------------------------------------------------- 100-121
  // Mechanics of materials and beams.
  100: ToolHelp(
    summary: 'Uniaxial stress and strain in a prismatic bar under an axial '
        'load. Normal stress is the load spread over the resisting area, and '
        'strain follows from it through Hooke\'s law while the material stays '
        'elastic. This is the starting point for every other stress '
        'calculation: a tie rod, a hanger, a bolt in pure tension.',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{P}{A}',
        plain: 'σ = P / A',
        caption: 'Normal stress',
      ),
      HelpFormula(
        tex: r'\varepsilon = \frac{\sigma}{E} = \frac{\delta}{L}',
        plain: 'ε = σ / E = δ / L',
        caption: 'Strain, while elastic',
      ),
    ],
    symbols: [
      HelpSymbol('σ', 'Normal stress', 'MPa'),
      HelpSymbol('P', 'Axial force, tension positive', 'N'),
      HelpSymbol('A', 'Cross-sectional area', 'mm²'),
      HelpSymbol('E', "Young's modulus", 'MPa'),
      HelpSymbol('ε', 'Normal strain'),
    ],
    notes: [
      'Assumes the stress is uniform over the section, which holds away from '
          'load points, holes and section changes — Saint-Venant\'s principle. '
          'Near any of those, expect a stress concentration this does not show.',
      'Elastic only: once σ passes the proportional limit, ε = σ/E stops '
          'being true and the bar takes a permanent set.',
      'A compressive load on a slender member fails by buckling long before '
          'it reaches this stress. Check the column buckling tool as well.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 1–3',
      'Gere & Goodno, Mechanics of Materials, ch. 1',
    ],
    diagram: 'images/icon_bar_force.png',
  ),
  101: ToolHelp(
    summary: 'Axial extension of a prismatic bar, and the stiffness that goes '
        'with it. The bar behaves as a linear spring whose rate is AE/L, which '
        'is why this relation is the building block for bolted joints, tie '
        'systems and any structure solved by combining member stiffnesses.',
    formulas: [
      HelpFormula(
        tex: r'\delta = \frac{PL}{AE}',
        plain: 'δ = P·L / (A·E)',
        caption: 'Elongation',
      ),
      HelpFormula(
        tex: r'k = \frac{AE}{L}',
        plain: 'k = A·E / L',
        caption: 'Axial stiffness',
      ),
    ],
    symbols: [
      HelpSymbol('δ', 'Elongation, positive in tension', 'mm'),
      HelpSymbol('P', 'Axial force', 'N'),
      HelpSymbol('L', 'Original length', 'mm'),
      HelpSymbol('A', 'Cross-sectional area', 'mm²'),
      HelpSymbol('E', "Young's modulus", 'MPa'),
      HelpSymbol('k', 'Axial stiffness', 'N/mm'),
    ],
    notes: [
      'Valid for a prismatic bar with constant P, A and E over its length. '
          'For a stepped or tapered bar, or one carrying its own weight, split '
          'it into segments and add the elongations.',
      'Small-strain, linear-elastic theory. δ is computed on the original '
          'length, not the deformed one.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 4',
      'Gere & Goodno, Mechanics of Materials, ch. 2',
    ],
    diagram: 'images/bar_force_displacement.png',
  ),
  103: ToolHelp(
    summary: 'Shear stress in a circular shaft carrying pure torsion. The '
        'stress varies linearly from zero on the axis to a maximum at the '
        'surface, so a hollow shaft carries torque almost as well as a solid '
        'one of the same outside diameter while weighing far less.',
    formulas: [
      HelpFormula(
        tex: r'\tau = \frac{T\rho}{J}',
        plain: 'τ = T·ρ / J',
        caption: 'Shear stress at radius ρ',
      ),
      HelpFormula(
        tex: r'J_{\text{solid}} = \frac{\pi d^4}{32}, \quad '
            r'J_{\text{hollow}} = \frac{\pi (d_o^4 - d_i^4)}{32}',
        plain: 'J = π·d⁴/32  (solid),  J = π·(do⁴ − di⁴)/32  (hollow)',
        caption: 'Polar second moment of area',
      ),
    ],
    symbols: [
      HelpSymbol('τ', 'Shear stress', 'MPa'),
      HelpSymbol('T', 'Applied torque', 'N·mm'),
      HelpSymbol('ρ', 'Radius at the point of interest', 'mm'),
      HelpSymbol('J', 'Polar second moment of area', 'mm⁴'),
    ],
    notes: [
      'Circular sections only. A non-circular shaft warps out of plane when '
          'twisted, and this formula does not apply to it at all — square and '
          'rectangular bars need their own torsion constants.',
      'Linear-elastic and pure torsion. Combined bending and torsion needs the '
          'combined-loading tool, then a failure criterion.',
      'Keep T in N·mm when the other quantities are in mm and MPa.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 5',
      'Gere & Goodno, Mechanics of Materials, ch. 3',
    ],
    diagram: 'images/icon_bar_torsion.png',
  ),
  114: ToolHelp(
    summary: 'How far one end of a shaft rotates relative to the other under '
        'torque. Angle of twist governs whether a drive shaft feels stiff, '
        'whether a torsion bar gives the rate you wanted, and how torque '
        'divides between parallel paths in a statically indeterminate system.',
    formulas: [
      HelpFormula(
        tex: r'\phi = \frac{TL}{GJ}',
        plain: 'φ = T·L / (G·J)',
        caption: 'Angle of twist, radians',
      ),
      HelpFormula(
        tex: r'k_t = \frac{GJ}{L}',
        plain: 'kt = G·J / L',
        caption: 'Torsional stiffness',
      ),
    ],
    symbols: [
      HelpSymbol('φ', 'Angle of twist', 'rad'),
      HelpSymbol('T', 'Applied torque', 'N·mm'),
      HelpSymbol('L', 'Length over which the twist accumulates', 'mm'),
      HelpSymbol('G', 'Shear modulus', 'MPa'),
      HelpSymbol('J', 'Polar second moment of area', 'mm⁴'),
    ],
    notes: [
      'Prismatic circular shafts with constant T, G and J. Add the twists of '
          'each segment where any of those change along the length.',
      'G is not independent of E: for an isotropic material '
          'G = E / [2(1 + ν)], about 0.385·E for steel.',
      'The result is in radians. Multiply by 180/π for degrees.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 5',
      'Shigley, Mechanical Engineering Design, ch. 3',
    ],
    diagram: 'images/icon_bar_torsion.png',
  ),
  115: ToolHelp(
    summary: 'The torque a rotating shaft carries at a given power and speed, '
        'or the power a known torque delivers. Every shaft sizing starts here: '
        'the motor nameplate gives power and speed, and the shaft has to be '
        'designed for the torque those imply.',
    formulas: [
      HelpFormula(
        tex: r'P = T\omega, \quad \omega = \frac{2\pi n}{60}',
        plain: 'P = T·ω,  ω = 2π·n / 60',
        caption: 'Power from torque and speed',
      ),
      HelpFormula(
        tex: r'T = \frac{9549\,P_{\text{kW}}}{n}',
        plain: 'T [N·m] = 9549 · P [kW] / n [rpm]',
        caption: 'Practical form',
      ),
    ],
    symbols: [
      HelpSymbol('P', 'Transmitted power', 'W'),
      HelpSymbol('T', 'Torque', 'N·m'),
      HelpSymbol('ω', 'Angular velocity', 'rad/s'),
      HelpSymbol('n', 'Rotational speed', 'rpm'),
    ],
    notes: [
      'This is the torque transmitted at steady speed. Starting, braking and '
          'jammed-load torques can be several times higher — apply a service '
          'factor before sizing the shaft.',
      'Power in, power out: any losses across a drive have to be accounted '
          'for separately by dividing by its efficiency.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 7',
      'Hibbeler, Mechanics of Materials, ch. 5',
    ],
  ),
  109: ToolHelp(
    summary: 'Membrane stress in the wall of a thin spherical pressure vessel. '
        'A sphere is the most efficient shape for containing pressure: the '
        'stress is the same in every direction and half what the hoop stress '
        'would be in a cylinder of the same radius and wall.',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{pr}{2t}',
        plain: 'σ = p·r / (2·t)',
        caption: 'Membrane stress, equal in all directions',
      ),
    ],
    symbols: [
      HelpSymbol('σ', 'Membrane stress', 'MPa'),
      HelpSymbol('p', 'Internal gauge pressure', 'MPa'),
      HelpSymbol('r', 'Inside radius', 'mm'),
      HelpSymbol('t', 'Wall thickness', 'mm'),
    ],
    notes: [
      'Thin-wall theory, valid while r/t is greater than about 10. Below that '
          'the stress varies through the wall and a thick-wall (Lamé) solution '
          'is needed.',
      'Membrane stresses only. Nozzles, supports and the joint to any other '
          'shape raise local stresses well above this and are what pressure '
          'vessel codes spend their pages on.',
      'A design to a code such as ASME VIII adds a joint efficiency and a '
          'corrosion allowance; this is the bare mechanics.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 8',
      'ASME BPVC Section VIII, Division 1, UG-27',
    ],
    diagram: 'images/icon_spherical_shell_stress.png',
  ),
  110: ToolHelp(
    summary: 'Hoop and longitudinal membrane stresses in a thin-walled '
        'cylinder under internal pressure. The hoop stress is twice the '
        'longitudinal one, which is why a pressurised pipe splits along its '
        'length rather than around its circumference.',
    formulas: [
      HelpFormula(
        tex: r'\sigma_h = \frac{pr}{t}',
        plain: 'σh = p·r / t',
        caption: 'Hoop (circumferential) stress',
      ),
      HelpFormula(
        tex: r'\sigma_l = \frac{pr}{2t}',
        plain: 'σl = p·r / (2·t)',
        caption: 'Longitudinal (axial) stress',
      ),
    ],
    symbols: [
      HelpSymbol('σh', 'Hoop stress', 'MPa'),
      HelpSymbol('σl', 'Longitudinal stress', 'MPa'),
      HelpSymbol('p', 'Internal gauge pressure', 'MPa'),
      HelpSymbol('r', 'Inside radius', 'mm'),
      HelpSymbol('t', 'Wall thickness', 'mm'),
    ],
    notes: [
      'Thin-wall theory, valid while r/t is greater than about 10.',
      'The two stresses are principal stresses at the wall, with the third '
          'roughly zero. Feed them to the failure-criteria tool to get an '
          'equivalent stress.',
      'Longitudinal stress exists only if the cylinder is closed. An open '
          'pipe restrained some other way carries a different axial load.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 8',
      'ASME BPVC Section VIII, Division 1, UG-27',
    ],
    diagram: 'images/icon_cylindrical_pressure_stress.png',
  ),
  107: ToolHelp(
    summary: 'Rotates a plane stress state to any other set of axes. The same '
        'physical state of stress reads differently depending on the plane you '
        'look at, and the transformation is what lets you find the stress on a '
        'weld, a glue line or a grain direction that is not aligned with the '
        'part.',
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
      HelpSymbol('σx, σy', 'Normal stresses on the original axes', 'MPa'),
      HelpSymbol('τxy', 'Shear stress on the original axes', 'MPa'),
      HelpSymbol('θ', 'Rotation to the new axes, counter-clockwise positive',
          '°'),
    ],
    notes: [
      'Plane stress: the third principal stress is zero. That is a good model '
          'for a thin plate loaded in its own plane, and a poor one deep '
          'inside a thick body.',
      'Sign convention: tensile normal stress positive, and shear positive '
          'when it acts on the +x face in the +y direction. A sign slip here '
          'is the usual source of a wrong answer.',
      'Angles double in the transformation, which is exactly what Mohr\'s '
          'circle draws — the same relations, seen geometrically.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 9',
      'Gere & Goodno, Mechanics of Materials, ch. 7',
    ],
    diagram: 'images/icon_stress_element_inclined.png',
  ),
  108: ToolHelp(
    summary: 'The largest and smallest normal stresses at a point, and the '
        'planes they act on. Principal stresses are what most failure '
        'criteria are written in terms of, so this is usually the step between '
        'a stress analysis and a factor of safety.',
    formulas: [
      HelpFormula(
        tex: r'\sigma_{1,2} = \frac{\sigma_x+\sigma_y}{2} \pm '
            r'\sqrt{\left(\frac{\sigma_x-\sigma_y}{2}\right)^2 + \tau_{xy}^2}',
        plain: 'σ1,2 = (σx+σy)/2 ± √[ ((σx−σy)/2)² + τxy² ]',
        caption: 'Principal stresses',
      ),
      HelpFormula(
        tex: r'\tan 2\theta_p = \frac{2\tau_{xy}}{\sigma_x-\sigma_y}',
        plain: 'tan2θp = 2·τxy / (σx − σy)',
        caption: 'Orientation of the principal planes',
      ),
      HelpFormula(
        tex: r'\tau_{\max} = \frac{\sigma_1-\sigma_2}{2}',
        plain: 'τmax = (σ1 − σ2) / 2',
        caption: 'Maximum in-plane shear',
      ),
    ],
    symbols: [
      HelpSymbol('σ1, σ2', 'Principal stresses, σ1 ≥ σ2', 'MPa'),
      HelpSymbol('θp', 'Angle from x to the σ1 plane', '°'),
      HelpSymbol('τmax', 'Maximum in-plane shear stress', 'MPa'),
    ],
    notes: [
      'There is no shear stress on a principal plane — that is what defines '
          'it.',
      'In plane stress the third principal stress is zero, and it can still be '
          'the smallest of the three. The true maximum shear is '
          '(σmax − σmin)/2 taken over all three, which exceeds the in-plane '
          'value whenever σ1 and σ2 have the same sign.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 9',
      'Boresi & Schmidt, Advanced Mechanics of Materials, ch. 2',
    ],
    diagram: 'images/icon_stress_element.png',
  ),
  118: ToolHelp(
    summary: "Mohr's circle is the stress transformation drawn as geometry. "
        'Every plane through the point maps to one spot on a circle whose '
        'centre is the average normal stress and whose radius is the maximum '
        'in-plane shear, which makes the principal stresses and their '
        'orientation readable at a glance.',
    formulas: [
      HelpFormula(
        tex: r'C = \frac{\sigma_x+\sigma_y}{2}, \quad '
            r'R = \sqrt{\left(\frac{\sigma_x-\sigma_y}{2}\right)^2+\tau_{xy}^2}',
        plain: 'C = (σx+σy)/2,   R = √[ ((σx−σy)/2)² + τxy² ]',
        caption: 'Centre and radius',
      ),
      HelpFormula(
        tex: r'\sigma_{1,2} = C \pm R, \quad \tau_{\max} = R',
        plain: 'σ1,2 = C ± R,   τmax = R',
      ),
    ],
    symbols: [
      HelpSymbol('C', 'Circle centre, the average normal stress', 'MPa'),
      HelpSymbol('R', 'Circle radius, the maximum in-plane shear', 'MPa'),
      HelpSymbol('σx, σy, τxy', 'The stress state being drawn', 'MPa'),
    ],
    notes: [
      'One full turn around the circle is a 180° rotation of the physical '
          'element: angles on the circle are twice the real ones.',
      'Plane stress only. A full three-dimensional state draws as three '
          'circles, and the outermost one governs the maximum shear.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 9',
      'Gere & Goodno, Mechanics of Materials, ch. 7',
    ],
    diagram: 'images/icon_stress_element_inclined.png',
  ),
  116: ToolHelp(
    summary: 'Turns a two-dimensional stress state into a single equivalent '
        'stress that can be compared with the yield strength. Von Mises '
        '(distortion energy) is the standard choice for ductile metals; Tresca '
        '(maximum shear) is slightly more conservative and is what several '
        'pressure-vessel codes still use.',
    formulas: [
      HelpFormula(
        tex: r'\sigma_{VM} = \sqrt{\sigma_1^2 - \sigma_1\sigma_2 + \sigma_2^2}',
        plain: 'σVM = √(σ1² − σ1·σ2 + σ2²)',
        caption: 'Von Mises, plane stress',
      ),
      HelpFormula(
        tex: r'\sigma_{Tresca} = |\sigma_1 - \sigma_2|',
        plain: 'σTresca = |σ1 − σ2|',
        caption: 'Tresca equivalent stress',
      ),
      HelpFormula(
        tex: r'n = \frac{S_y}{\sigma_{eq}}',
        plain: 'n = Sy / σeq',
        caption: 'Factor of safety against yield',
      ),
    ],
    symbols: [
      HelpSymbol('σ1, σ2', 'Principal stresses', 'MPa'),
      HelpSymbol('σVM', 'Von Mises equivalent stress', 'MPa'),
      HelpSymbol('Sy', 'Yield strength', 'MPa'),
      HelpSymbol('n', 'Factor of safety'),
    ],
    notes: [
      'Both criteria predict yield in ductile materials. Brittle materials '
          'fail on maximum principal stress or by a Mohr–Coulomb criterion '
          'instead, and using von Mises on cast iron will mislead you.',
      'Tresca is the more conservative of the two, by up to about 15% — the '
          'two agree in pure tension and differ most in pure shear.',
      'Static yielding only. Fluctuating loads need a fatigue criterion.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 5',
      'Hibbeler, Mechanics of Materials, ch. 10',
    ],
  ),
  119: ToolHelp(
    summary: 'Factor of safety for a part carrying a fluctuating stress with a '
        'non-zero mean, by the modified Goodman criterion. A mean tensile '
        'stress makes fatigue worse than the alternating component alone '
        'suggests, and Goodman is the standard, mildly conservative way of '
        'accounting for that.',
    formulas: [
      HelpFormula(
        tex: r'\frac{\sigma_a}{S_e} + \frac{\sigma_m}{S_{ut}} = \frac{1}{n}',
        plain: 'σa/Se + σm/Sut = 1/n',
        caption: 'Modified Goodman line',
      ),
      HelpFormula(
        tex: r'\sigma_a = \frac{\sigma_{\max}-\sigma_{\min}}{2}, \quad '
            r'\sigma_m = \frac{\sigma_{\max}+\sigma_{\min}}{2}',
        plain: 'σa = (σmax − σmin)/2,   σm = (σmax + σmin)/2',
        caption: 'Alternating and mean components',
      ),
    ],
    symbols: [
      HelpSymbol('σa', 'Alternating stress amplitude', 'MPa'),
      HelpSymbol('σm', 'Mean stress', 'MPa'),
      HelpSymbol('Se', 'Corrected endurance limit', 'MPa'),
      HelpSymbol('Sut', 'Ultimate tensile strength', 'MPa'),
      HelpSymbol('n', 'Factor of safety against fatigue'),
    ],
    notes: [
      'Leaving Se blank uses 0.5·Sut, the usual first estimate for steel. It '
          'is an unmodified figure: a real design multiplies it by Marin '
          'factors for surface finish, size, loading, temperature and '
          'reliability, which typically cut it by half again.',
      'Non-ferrous metals and aluminium have no true endurance limit — they '
          'keep weakening with cycles, so a finite-life calculation is needed '
          'rather than this one.',
      'A compressive mean stress is not damaging in the same way. Goodman '
          'applied to negative σm is conservative to the point of being wrong; '
          'use σm = 0 for that case.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 6',
      'Norton, Machine Design, ch. 6',
    ],
  ),
  112: ToolHelp(
    summary: 'Free thermal expansion of a bar, and the stress that appears '
        'when that expansion is prevented. A fully restrained member develops '
        'stress that depends only on material and temperature change — not on '
        'its length or area, which is why long pipe runs need expansion loops '
        'rather than thicker walls.',
    formulas: [
      HelpFormula(
        tex: r'\delta_T = \alpha \, \Delta T \, L',
        plain: 'δT = α · ΔT · L',
        caption: 'Free expansion',
      ),
      HelpFormula(
        tex: r'\sigma_T = -E \alpha \, \Delta T',
        plain: 'σT = −E · α · ΔT',
        caption: 'Stress if fully restrained',
      ),
    ],
    symbols: [
      HelpSymbol('δT', 'Free change in length', 'mm'),
      HelpSymbol('α', 'Coefficient of thermal expansion', '1/°C'),
      HelpSymbol('ΔT', 'Temperature change', '°C'),
      HelpSymbol('L', 'Original length', 'mm'),
      HelpSymbol('σT', 'Thermal stress, compressive when heated', 'MPa'),
    ],
    notes: [
      'The restrained stress is independent of L and A. Making the member '
          'stouter does not reduce it — only allowing movement, or lowering '
          'ΔT, does.',
      'Full restraint is the worst case. Partial restraint gives a stress '
          'between zero and this, in proportion to how much movement is '
          'prevented.',
      'α varies with temperature; over a wide range use a mean value for the '
          'interval rather than the room-temperature figure.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 4',
      'Gere & Goodno, Mechanics of Materials, ch. 2',
    ],
  ),
  111: ToolHelp(
    summary: 'The axial load at which a slender column stops being stable and '
        'bows sideways. Buckling is a stiffness failure, not a strength one: '
        'the critical load depends on E and I, and barely on how strong the '
        'material is. A long column can buckle at a small fraction of the load '
        'that would yield it.',
    formulas: [
      HelpFormula(
        tex: r'P_{cr} = \frac{\pi^2 EI}{(KL)^2}',
        plain: 'Pcr = π²·E·I / (K·L)²',
        caption: 'Euler critical load',
      ),
      HelpFormula(
        tex: r'\sigma_{cr} = \frac{P_{cr}}{A}, \quad '
            r'\lambda = \frac{KL}{r}, \quad r = \sqrt{\frac{I}{A}}',
        plain: 'σcr = Pcr / A,   λ = K·L / r,   r = √(I/A)',
        caption: 'Critical stress and slenderness ratio',
      ),
    ],
    symbols: [
      HelpSymbol('Pcr', 'Critical (Euler) buckling load', 'N'),
      HelpSymbol('E', "Young's modulus", 'MPa'),
      HelpSymbol('I', 'Least second moment of area', 'mm⁴'),
      HelpSymbol('K', 'Effective length factor, set by the end conditions'),
      HelpSymbol('L', 'Unbraced length', 'mm'),
      HelpSymbol('λ', 'Slenderness ratio'),
    ],
    notes: [
      'Use the smallest I of the section: a column buckles about its weakest '
          'axis, whichever way you were expecting it to bend.',
      'Theoretical K is 1.0 pinned–pinned, 0.5 fixed–fixed, 0.7 fixed–pinned '
          'and 2.0 fixed–free. Design codes recommend larger values than the '
          'theoretical ones because real ends are never perfectly fixed.',
      'Euler applies to slender columns only. Once σcr exceeds about half the '
          'yield strength, inelastic buckling takes over and a Johnson '
          'parabola or a code column curve should be used instead.',
      'Assumes a perfectly straight, centrally loaded column. Real initial '
          'crookedness and load eccentricity reduce the capacity, which is '
          'what the factors of safety in codes cover.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 13',
      'AISC Steel Construction Manual, ch. E',
    ],
    diagram: 'images/buckling/icon_buckling_pinned_pinned.png',
  ),
  120: ToolHelp(
    summary: 'The three ways a bolted or riveted lap joint fails in the plate '
        'and the fastener: the bolt shearing, the plate crushing against the '
        'bolt, and the plate tearing out to the free edge. All three are '
        'checked at once, because a joint is only as good as its weakest one.',
    formulas: [
      HelpFormula(
        tex: r'\tau = \frac{P}{n\,m\,\frac{\pi d^2}{4}}',
        plain: 'τ = P / (n·m·π·d²/4)',
        caption: 'Bolt shear; m = 1 single shear, 2 double shear',
      ),
      HelpFormula(
        tex: r'\sigma_b = \frac{P}{n\,d\,t}',
        plain: 'σb = P / (n·d·t)',
        caption: 'Bearing stress on the projected area',
      ),
      HelpFormula(
        tex: r'\tau_{to} = \frac{P}{2n\left(e-\frac{d}{2}\right)t}',
        plain: 'τto = P / [2·n·(e − d/2)·t]',
        caption: 'Tear-out along two shear planes to the edge',
      ),
    ],
    symbols: [
      HelpSymbol('P', 'Load on the joint', 'N'),
      HelpSymbol('n', 'Number of fasteners'),
      HelpSymbol('m', 'Shear planes per fastener: 1 or 2'),
      HelpSymbol('d', 'Fastener diameter', 'mm'),
      HelpSymbol('t', 'Thinnest connected plate', 'mm'),
      HelpSymbol('e', 'Edge distance, hole centre to free edge', 'mm'),
    ],
    notes: [
      'A bearing-type joint: the load is carried by the fasteners bearing on '
          'the holes, not by friction. A slip-critical joint is designed on '
          'preload and friction instead, and these numbers do not govern it.',
      'Assumes the load divides equally between fasteners. That is reasonable '
          'for a short, compact group and optimistic for a long line of bolts, '
          'where the end fasteners take more.',
      'Tension through the net section of the plate is a fourth failure mode '
          'and is not checked here — subtract the hole area and check it '
          'separately.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 8',
      'AISC Steel Construction Manual, ch. J3',
    ],
  ),
  121: ToolHelp(
    summary: 'Combines axial, bending and torsional loads acting at the same '
        'point into one normal stress and one shear stress. Superposition is '
        'valid while everything stays linear-elastic, and the resulting pair '
        'is what a failure criterion needs.',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{P}{A} + \frac{Mc}{I}',
        plain: 'σ = P/A + M·c/I',
        caption: 'Normal stress: axial plus bending',
      ),
      HelpFormula(
        tex: r'\tau = \frac{Tr}{J}',
        plain: 'τ = T·r / J',
        caption: 'Shear stress from torsion',
      ),
    ],
    symbols: [
      HelpSymbol('P', 'Axial force, tension positive', 'N'),
      HelpSymbol('A', 'Cross-sectional area', 'mm²'),
      HelpSymbol('M', 'Bending moment', 'N·mm'),
      HelpSymbol('c', 'Distance from the neutral axis to the point', 'mm'),
      HelpSymbol('I', 'Second moment of area about the bending axis', 'mm⁴'),
      HelpSymbol('T', 'Torque', 'N·mm'),
      HelpSymbol('r', 'Radius to the point', 'mm'),
      HelpSymbol('J', 'Polar second moment of area', 'mm⁴'),
    ],
    notes: [
      'Superposition needs linear elasticity and small deflections. A slender '
          'member under axial compression also gets extra moment from the '
          'deflection itself (the P–δ effect), which this does not include.',
      'Transverse shear from the bending load is separate and is largest at '
          'the neutral axis, where the bending stress is zero. Check both '
          'points, not just the extreme fibre.',
      'Keep moments in N·mm alongside mm and MPa.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 8',
      'Shigley, Mechanical Engineering Design, ch. 3',
    ],
  ),

  // ---------------------------------------------------------------- beams
  102: ToolHelp(
    summary: 'Second moments of area for the standard cross-sections, about '
        'the centroidal axes. I is the geometric property that decides how '
        'stiff a section is in bending and how far the stress reaches at a '
        'given moment — it is what makes an I-beam efficient and a flat bar '
        'not.',
    formulas: [
      HelpFormula(
        tex: r'I_x = \frac{bh^3}{12}, \quad I_y = \frac{hb^3}{12}',
        plain: 'Ix = b·h³/12,   Iy = h·b³/12',
        caption: 'Rectangle, about its centroid',
      ),
      HelpFormula(
        tex: r'I = \frac{\pi d^4}{64}',
        plain: 'I = π·d⁴/64',
        caption: 'Solid circle',
      ),
      HelpFormula(
        tex: r'I = I_c + Ad^2',
        plain: 'I = Ic + A·d²',
        caption: 'Parallel-axis theorem, for shifting to another axis',
      ),
    ],
    symbols: [
      HelpSymbol('I', 'Second moment of area', 'mm⁴'),
      HelpSymbol('b, h', 'Width and height', 'mm'),
      HelpSymbol('A', 'Area', 'mm²'),
      HelpSymbol('d', 'Distance between the two parallel axes', 'mm'),
    ],
    notes: [
      'The depth term is cubed, so depth buys stiffness far faster than '
          'width: doubling h multiplies Ix by eight, doubling b only by two.',
      'The parallel-axis theorem only moves between an axis through the '
          'centroid and one parallel to it. Going between two non-centroidal '
          'axes means passing through the centroid on the way.',
      'These are area moments, in mm⁴ — not the mass moments of inertia used '
          'in dynamics, which are kg·m².',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix A',
      'Gere & Goodno, Mechanics of Materials, ch. 12',
    ],
    diagram: 'images/cross_section/icon_cs_rectangle.png',
  ),
  117: ToolHelp(
    summary: 'Centroid, area, second moments and the derived section moduli '
        'and radii of gyration for a cross-section. These are the numbers '
        'every beam and column calculation needs, and computing them together '
        'keeps them consistent with one another.',
    formulas: [
      HelpFormula(
        tex: r'\bar{y} = \frac{\sum A_i \bar{y}_i}{\sum A_i}',
        plain: 'ȳ = Σ(Ai·ȳi) / Σ Ai',
        caption: 'Centroid of a built-up section',
      ),
      HelpFormula(
        tex: r'S = \frac{I}{c}, \quad r = \sqrt{\frac{I}{A}}',
        plain: 'S = I / c,   r = √(I / A)',
        caption: 'Section modulus and radius of gyration',
      ),
    ],
    symbols: [
      HelpSymbol('ȳ', 'Centroid position from the reference edge', 'mm'),
      HelpSymbol('I', 'Second moment of area about the centroidal axis', 'mm⁴'),
      HelpSymbol('S', 'Section modulus', 'mm³'),
      HelpSymbol('c', 'Distance from the centroid to the extreme fibre', 'mm'),
      HelpSymbol('r', 'Radius of gyration', 'mm'),
    ],
    notes: [
      'Section modulus is what sizes a beam for strength (σ = M/S); the '
          'radius of gyration is what sizes a column for stability (λ = KL/r).',
      'For a section that is not symmetric about the bending axis, c differs '
          'top and bottom, so there are two section moduli. The smaller one '
          'governs.',
      'Properties computed from bare dimensions ignore rolled root fillets '
          'and weld metal, so they run a few percent under the published '
          'values for a rolled shape. Use the standard section library where '
          'the shape is a catalogue one.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix A',
      'AISC Steel Construction Manual, Part 1',
    ],
  ),
  104: ToolHelp(
    summary: 'Bending stress at any height in a beam cross-section. Stress '
        'varies linearly from zero at the neutral axis to a maximum at the '
        'extreme fibre, which is why material near the neutral axis carries '
        'almost nothing and why efficient sections put area far from it.',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{My}{I}',
        plain: 'σ = M·y / I',
        caption: 'Bending stress at distance y from the neutral axis',
      ),
      HelpFormula(
        tex: r'\sigma_{\max} = \frac{Mc}{I} = \frac{M}{S}',
        plain: 'σmax = M·c / I = M / S',
        caption: 'At the extreme fibre',
      ),
    ],
    symbols: [
      HelpSymbol('σ', 'Bending stress, tension positive', 'MPa'),
      HelpSymbol('M', 'Bending moment at the section', 'N·mm'),
      HelpSymbol('y', 'Distance from the neutral axis', 'mm'),
      HelpSymbol('I', 'Second moment of area about the bending axis', 'mm⁴'),
      HelpSymbol('c', 'Distance to the extreme fibre', 'mm'),
    ],
    notes: [
      'Euler–Bernoulli theory: plane sections stay plane, the material is '
          'linear-elastic, and the beam is straight and prismatic.',
      'The neutral axis passes through the centroid only for pure bending of '
          'a homogeneous section. An axial load moves it, and a composite '
          'section needs a transformed-section analysis.',
      'Bending about an axis that is not a principal axis produces unsymmetric '
          'bending, and this single-axis formula does not apply.',
      'Keep M in N·mm alongside mm and MPa.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 6',
      'Gere & Goodno, Mechanics of Materials, ch. 5',
    ],
    diagram: 'images/icon_beam_bending.png',
  ),
  113: ToolHelp(
    summary: 'Transverse shear stress across a beam section. It peaks at the '
        'neutral axis — exactly where the bending stress is zero — so the two '
        'have to be checked at different heights. It matters most for short, '
        'deep beams and for thin webs, where shear can govern over bending.',
    formulas: [
      HelpFormula(
        tex: r'\tau = \frac{VQ}{It}',
        plain: 'τ = V·Q / (I·t)',
        caption: 'Shear stress at the level where Q is taken',
      ),
      HelpFormula(
        tex: r'\tau_{\max} = \frac{3V}{2A} \;\text{(rectangle)}, \quad '
            r'\frac{4V}{3A} \;\text{(circle)}',
        plain: 'τmax = 3V/(2A) rectangle,  4V/(3A) circle',
        caption: 'Peak values for common solid sections',
      ),
    ],
    symbols: [
      HelpSymbol('τ', 'Transverse shear stress', 'MPa'),
      HelpSymbol('V', 'Shear force at the section', 'N'),
      HelpSymbol('Q', 'First moment of the area beyond the cut', 'mm³'),
      HelpSymbol('I', 'Second moment of area of the whole section', 'mm⁴'),
      HelpSymbol('t', 'Width of the section at the cut', 'mm'),
    ],
    notes: [
      'Q is the first moment of only the area on one side of the level being '
          'checked, taken about the neutral axis. It is largest at the neutral '
          'axis and zero at the extreme fibres.',
      'The formula assumes the shear stress is uniform across the width t. '
          'That is good for a narrow web and poor for a wide flange, where the '
          'real distribution varies across the width.',
      'For an I-beam, the common shortcut of V divided by the web area is '
          'within a few percent of the exact value and is what design codes '
          'use.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 7',
      'Gere & Goodno, Mechanics of Materials, ch. 5',
    ],
  ),
  105: ToolHelp(
    summary: 'Deflection and slope of a cantilever beam for the standard load '
        'cases, from the classical closed-form solutions. Useful for a quick '
        'stiffness check, and for building up more complicated loadings by '
        'superposition.',
    formulas: [
      HelpFormula(
        tex: r'\delta_{\max} = \frac{PL^3}{3EI}, \quad '
            r'\theta = \frac{PL^2}{2EI}',
        plain: 'δmax = P·L³/(3·E·I),   θ = P·L²/(2·E·I)',
        caption: 'End load P at the free end',
      ),
      HelpFormula(
        tex: r'\delta_{\max} = \frac{wL^4}{8EI}, \quad '
            r'\theta = \frac{wL^3}{6EI}',
        plain: 'δmax = w·L⁴/(8·E·I),   θ = w·L³/(6·E·I)',
        caption: 'Uniform load w over the full span',
      ),
    ],
    symbols: [
      HelpSymbol('δ', 'Deflection', 'mm'),
      HelpSymbol('θ', 'Slope', 'rad'),
      HelpSymbol('P', 'Point load', 'N'),
      HelpSymbol('w', 'Distributed load', 'N/mm'),
      HelpSymbol('L', 'Span from the fixed end', 'mm'),
      HelpSymbol('E·I', 'Flexural rigidity', 'N·mm²'),
    ],
    notes: [
      'Deflection goes as L³ or L⁴. Doubling the span of a cantilever under '
          'an end load makes it eight times as flexible — length dominates '
          'everything else.',
      'Small-deflection Euler–Bernoulli theory, ignoring shear deformation. '
          'Add a shear term for a stubby cantilever, roughly L/d under 10.',
      'Loads superpose: for several loads at once, add the deflections case '
          'by case.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix C',
      'Roark\'s Formulas for Stress and Strain, Table 8.1',
    ],
    diagram: 'images/cantilever_beam/icon_cantilever_beam.png',
  ),
  106: ToolHelp(
    summary: 'Deflection and slope of a simply supported beam for the standard '
        'load cases. The same closed-form solutions a handbook tabulates, for '
        'checking a span quickly or assembling a more complicated load case by '
        'superposition.',
    formulas: [
      HelpFormula(
        tex: r'\delta_{\max} = \frac{PL^3}{48EI}',
        plain: 'δmax = P·L³/(48·E·I)',
        caption: 'Central point load',
      ),
      HelpFormula(
        tex: r'\delta_{\max} = \frac{5wL^4}{384EI}',
        plain: 'δmax = 5·w·L⁴/(384·E·I)',
        caption: 'Uniform load over the full span',
      ),
    ],
    symbols: [
      HelpSymbol('δ', 'Deflection', 'mm'),
      HelpSymbol('P', 'Point load', 'N'),
      HelpSymbol('w', 'Distributed load', 'N/mm'),
      HelpSymbol('L', 'Span between supports', 'mm'),
      HelpSymbol('E·I', 'Flexural rigidity', 'N·mm²'),
    ],
    notes: [
      'For an off-centre point load the maximum deflection is not under the '
          'load, and it is not at midspan either — though midspan is within '
          'about 2.5% of it, which is why handbooks quote midspan.',
      'Small-deflection theory, pinned one end and roller the other, so no '
          'axial restraint. A beam held axially at both ends stiffens as it '
          'deflects and this overstates the movement.',
      'Serviceability limits are usually a fraction of span — L/360 under live '
          'load is a common floor criterion — rather than a stress limit.',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix C',
      'Roark\'s Formulas for Stress and Strain, Table 8.1',
    ],
    diagram: 'images/simple_beam/icon_simple_beam.png',
  ),
  401: ToolHelp(
    summary: 'Support reactions, shear, bending moment and deflection along a beam '
        'held in any of six ways and carrying any number of loads. Point loads, '
        'uniform, triangular or trapezoidal distributed loads and applied couples '
        'superpose freely. The shear and moment diagrams are what tell you where '
        'to check the section, and what M to use when you get there.',
    formulas: [
      HelpFormula(
        tex: r'\sum F_y = 0, \quad \sum M = 0',
        plain: 'ΣFy = 0,   ΣM = 0',
        caption: 'Equilibrium, which settles the determinate cases on its own',
      ),
      HelpFormula(
        tex: r'\mathbf{K}\mathbf{d} = \mathbf{F}',
        plain: 'K·d = F',
        caption: 'The stiffness solve, which settles the rest',
      ),
      HelpFormula(
        tex: r'\frac{dV}{dx} = -w(x), \quad \frac{dM}{dx} = V(x)',
        plain: 'dV/dx = −w(x),   dM/dx = V(x)',
        caption: 'Shear and moment along the span',
      ),
      HelpFormula(
        tex: r'EI\frac{d^2v}{dx^2} = M(x), \quad \sigma = \frac{Mc}{I}',
        plain: 'EI·d²v/dx² = M(x),   σ = M·c/I',
        caption: 'Deflection, and the stress the moment causes',
      ),
    ],
    symbols: [
      HelpSymbol('R', 'Support reaction, upward positive', 'N'),
      HelpSymbol('V', 'Shear force', 'N'),
      HelpSymbol('M', 'Bending moment, sagging positive', 'N·m'),
      HelpSymbol('w', 'Distributed load intensity, downward positive', 'N/m'),
      HelpSymbol('L', 'Span', 'm'),
      HelpSymbol('EI', 'Flexural rigidity', 'N·m²'),
      HelpSymbol('v', 'Deflection, downward positive', 'mm'),
      HelpSymbol('c', 'Neutral axis to the extreme fibre', 'mm'),
    ],
    notes: [
      'Three of the six arrangements are statically indeterminate — the propped '
          'cantilever, the fixed-ended beam, and an overhang whose supports are set '
          'in from the ends. Their reactions depend on EI, so an E or an I that is '
          'wrong moves the reactions, not just the deflection.',
      'A pin and a roller are the same support here. This is a bending model '
          'with no axial degree of freedom, so neither restrains anything the other '
          'does not.',
      'The moment is largest where the shear passes through zero. That is the '
          'section to design, and it is not at midspan for anything but a symmetric '
          'load case.',
      'Sagging and hogging peaks are reported separately because they put '
          'different fibres in tension. On a continuous or fixed-ended beam the '
          'hogging peak over the support is usually the larger of the two.',
      'Self-weight is not included unless you enter it as a distributed load.',
      'Shear deformation is neglected, as Euler–Bernoulli theory does. On a '
          'deep beam — span less than about ten times the depth — the real '
          'deflection is larger than this reports.',
    ],
    references: [
      'Hibbeler, Structural Analysis, ch. 4 and 11',
      'Gere & Goodno, Mechanics of Materials, ch. 4 and 9',
      'Cook et al., Concepts and Applications of Finite Element Analysis, ch. 2',
    ],
    diagram: 'images/simple_beam/icon_simple_beam.png',
  ),
  // ---------------------------------------------------------------- statics
  400: ToolHelp(
    summary: 'Adds concurrent forces in a plane into a single resultant, with '
        'its magnitude and direction. The first step in almost any statics '
        'problem: replace a set of forces by the one force that does the same '
        'thing.',
    formulas: [
      HelpFormula(
        tex: r'R_x = \sum F_i\cos\theta_i, \quad R_y = \sum F_i\sin\theta_i',
        plain: 'Rx = Σ Fi·cosθi,   Ry = Σ Fi·sinθi',
        caption: 'Components',
      ),
      HelpFormula(
        tex: r'R = \sqrt{R_x^2+R_y^2}, \quad '
            r'\theta_R = \operatorname{atan2}(R_y, R_x)',
        plain: 'R = √(Rx² + Ry²),   θR = atan2(Ry, Rx)',
        caption: 'Magnitude and direction',
      ),
    ],
    symbols: [
      HelpSymbol('F', 'Magnitude of each force', 'N'),
      HelpSymbol('θ', 'Direction of each force, from the +x axis', '°'),
      HelpSymbol('R', 'Resultant magnitude', 'N'),
      HelpSymbol('θR', 'Resultant direction', '°'),
    ],
    notes: [
      'Concurrent forces only — all lines of action meeting at one point. '
          'Forces that do not concur also produce a couple, and replacing them '
          'by a single force at the wrong place loses it.',
      'atan2 is used rather than arctan so the quadrant comes out right; '
          'plain arctan cannot tell 30° from 210°.',
    ],
    references: [
      'Hibbeler, Engineering Mechanics: Statics, ch. 2',
      'Beer & Johnston, Vector Mechanics for Engineers, ch. 2',
    ],
  ),
  402: ToolHelp(
    summary: 'Centroid of an area built from rectangles, circles and '
        'triangles, including holes. The centroid is where the area\'s first '
        'moment vanishes, and it is the axis every bending calculation is '
        'referred to — get it wrong and every stress after it is wrong too.',
    formulas: [
      HelpFormula(
        tex: r'\bar{x} = \frac{\sum A_i \bar{x}_i}{\sum A_i}, \quad '
            r'\bar{y} = \frac{\sum A_i \bar{y}_i}{\sum A_i}',
        plain: 'x̄ = Σ(Ai·x̄i)/ΣAi,   ȳ = Σ(Ai·ȳi)/ΣAi',
        caption: 'Area-weighted average of the parts',
      ),
    ],
    symbols: [
      HelpSymbol('Ai', 'Area of each part, negative for a hole', 'mm²'),
      HelpSymbol('x̄i, ȳi', "Each part's own centroid", 'mm'),
      HelpSymbol('x̄, ȳ', 'Centroid of the whole', 'mm'),
    ],
    notes: [
      'Treat a hole as a negative area with its own centroid. The arithmetic '
          'then handles it without a special case.',
      'The centroid lies on any axis of symmetry, which is often enough to '
          'write one coordinate down without computing it.',
      'Centroid and centre of mass coincide only when the density is uniform.',
    ],
    references: [
      'Hibbeler, Engineering Mechanics: Statics, ch. 9',
      'Beer & Johnston, Vector Mechanics for Engineers, ch. 5',
    ],
  ),
  403: ToolHelp(
    summary: 'Solves a planar pin-jointed truss by the method of joints: each '
        'joint is a concurrent force system in equilibrium, so working joint '
        'by joint yields every member force. Positive is tension, negative '
        'compression.',
    formulas: [
      HelpFormula(
        tex: r'\sum F_x = 0, \quad \sum F_y = 0 \;\text{at every joint}',
        plain: 'ΣFx = 0 and ΣFy = 0 at every joint',
        caption: 'Equilibrium, two equations per joint',
      ),
      HelpFormula(
        tex: r'm + r = 2j',
        plain: 'm + r = 2·j',
        caption: 'Statical determinacy check',
      ),
    ],
    symbols: [
      HelpSymbol('m', 'Number of members'),
      HelpSymbol('r', 'Number of support reactions'),
      HelpSymbol('j', 'Number of joints'),
    ],
    notes: [
      'Assumes frictionless pins and loads applied only at joints, so every '
          'member carries pure axial force. A load applied mid-member also '
          'bends it, and that bending is outside this model.',
      'm + r < 2j is a mechanism and cannot stand; m + r > 2j is '
          'indeterminate and needs member stiffnesses as well as equilibrium.',
      'A determinate truss can still be unstable if the geometry is bad — '
          'three collinear reactions, for instance. The count is necessary, '
          'not sufficient.',
      'Compression members must also be checked for buckling, which this does '
          'not do.',
    ],
    references: [
      'Hibbeler, Structural Analysis, ch. 3',
      'Beer & Johnston, Vector Mechanics for Engineers, ch. 6',
    ],
  ),

  // ------------------------------------------------------ theory of elasticity
  200: ToolHelp(
    summary: 'The generalized Hooke\'s law for an isotropic material in three '
        'dimensions. Stress in one direction strains the other two through '
        "Poisson's ratio, so the six components are coupled and cannot be "
        'treated one at a time.',
    formulas: [
      HelpFormula(
        tex: r'\varepsilon_x = \frac{1}{E}\left[\sigma_x - '
            r'\nu(\sigma_y+\sigma_z)\right]',
        plain: 'εx = [σx − ν(σy + σz)] / E',
        caption: 'Normal strain, one of three',
      ),
      HelpFormula(
        tex: r'\gamma_{xy} = \frac{\tau_{xy}}{G}, \quad '
            r'G = \frac{E}{2(1+\nu)}',
        plain: 'γxy = τxy / G,   G = E / [2(1 + ν)]',
        caption: 'Shear strain, and the modulus relation',
      ),
    ],
    symbols: [
      HelpSymbol('ε', 'Normal strain'),
      HelpSymbol('γ', 'Engineering shear strain'),
      HelpSymbol('σ, τ', 'Normal and shear stress', 'MPa'),
      HelpSymbol('E', "Young's modulus", 'MPa'),
      HelpSymbol('ν', "Poisson's ratio"),
      HelpSymbol('G', 'Shear modulus', 'MPa'),
    ],
    notes: [
      'Isotropic, homogeneous, linear-elastic material. Composites, rolled '
          'sheet with strong texture and wood are none of those.',
      'Only two of E, G and ν are independent for an isotropic material — the '
          'third follows. Supplying all three inconsistently is a common way '
          'to get a quietly wrong answer.',
      'Thermodynamic stability puts ν between −1 and 0.5. Real metals sit near '
          '0.3, and 0.5 means incompressible, which rubber approaches.',
    ],
    references: [
      'Timoshenko & Goodier, Theory of Elasticity, ch. 1',
      'Boresi & Schmidt, Advanced Mechanics of Materials, ch. 3',
    ],
  ),
  201: ToolHelp(
    summary: 'Converts between a full three-dimensional stress state and the '
        'strain state it produces, in either direction. The inverse form is '
        'what finite-element post-processing needs: strains are what a mesh '
        'gives you, stresses are what a criterion wants.',
    formulas: [
      HelpFormula(
        tex: r'\sigma_x = \frac{E}{(1+\nu)(1-2\nu)}\left[(1-\nu)'
            r'\varepsilon_x + \nu(\varepsilon_y+\varepsilon_z)\right]',
        plain: 'σx = E/[(1+ν)(1−2ν)] · [(1−ν)εx + ν(εy + εz)]',
        caption: 'Stress from strain',
      ),
      HelpFormula(
        tex: r'\tau_{xy} = G\gamma_{xy}',
        plain: 'τxy = G · γxy',
        caption: 'Shear, which stays uncoupled',
      ),
    ],
    symbols: [
      HelpSymbol('σ, τ', 'Normal and shear stress', 'MPa'),
      HelpSymbol('ε, γ', 'Normal and engineering shear strain'),
      HelpSymbol('E', "Young's modulus", 'MPa'),
      HelpSymbol('ν', "Poisson's ratio"),
    ],
    notes: [
      'The stress-from-strain form blows up as ν approaches 0.5: the '
          '(1 − 2ν) in the denominator goes to zero because an incompressible '
          'material has no unique pressure for a given strain. Nearly '
          'incompressible materials need a mixed formulation.',
      'Engineering shear strain γ is twice the tensor shear strain. Mixing '
          'the two conventions is a factor-of-two error that is easy to miss.',
    ],
    references: [
      'Timoshenko & Goodier, Theory of Elasticity, ch. 1',
      'Sadd, Elasticity: Theory, Applications and Numerics, ch. 4',
    ],
  ),
  // ---------------------------------------------------------------- composites
  305: ToolHelp(
    summary: 'Estimates the stiffness and density of a unidirectional ply from '
        'its fibre and matrix properties. Along the fibres the two phases '
        'strain together and stiffness averages by volume; across them they '
        'share load and the compliances average instead, which is why '
        'transverse stiffness is so much lower.',
    formulas: [
      HelpFormula(
        tex: r'E_1 = E_f V_f + E_m(1-V_f)',
        plain: 'E1 = Ef·Vf + Em·(1 − Vf)',
        caption: 'Longitudinal — the rule of mixtures',
      ),
      HelpFormula(
        tex: r'\frac{1}{E_2} = \frac{V_f}{E_f} + \frac{1-V_f}{E_m}',
        plain: '1/E2 = Vf/Ef + (1 − Vf)/Em',
        caption: 'Transverse — the inverse rule of mixtures',
      ),
      HelpFormula(
        tex: r'\nu_{12} = \nu_f V_f + \nu_m(1-V_f)',
        plain: 'ν12 = νf·Vf + νm·(1 − Vf)',
        caption: 'Major Poisson ratio',
      ),
    ],
    symbols: [
      HelpSymbol('E1', 'Stiffness along the fibres', 'MPa'),
      HelpSymbol('E2', 'Stiffness across the fibres', 'MPa'),
      HelpSymbol('Vf', 'Fibre volume fraction'),
      HelpSymbol('Ef, Em', 'Fibre and matrix modulus', 'MPa'),
    ],
    notes: [
      'E1 is reliable; the inverse rule for E2 is optimistic and real '
          'measurements usually fall below it. Halpin–Tsai is the standard '
          'improvement when transverse stiffness matters.',
      'Volume fraction, not weight fraction. Suppliers often quote weight — '
          'convert with the two densities before using it here.',
      'Practical Vf tops out near 0.65 for well-consolidated laminates; above '
          'that there is not enough matrix to wet the fibres.',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 3',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 3',
    ],
    diagram: 'images/lamina.png',
  ),
  301: ToolHelp(
    summary: 'The four independent engineering constants of an orthotropic '
        'ply — two moduli, a shear modulus and a Poisson ratio — and the '
        'compliance matrix they assemble into. These are what every laminate '
        'calculation starts from.',
    formulas: [
      HelpFormula(
        tex: r'\frac{\nu_{12}}{E_1} = \frac{\nu_{21}}{E_2}',
        plain: 'ν12 / E1 = ν21 / E2',
        caption: 'Reciprocity, which makes the compliance matrix symmetric',
      ),
      HelpFormula(
        tex: r'Q_{11} = \frac{E_1}{1-\nu_{12}\nu_{21}}, \quad '
            r'Q_{22} = \frac{E_2}{1-\nu_{12}\nu_{21}}, \quad Q_{66} = G_{12}',
        plain: 'Q11 = E1/(1 − ν12·ν21),  Q22 = E2/(1 − ν12·ν21),  Q66 = G12',
        caption: 'Reduced stiffnesses',
      ),
    ],
    symbols: [
      HelpSymbol('E1, E2', 'Longitudinal and transverse modulus', 'MPa'),
      HelpSymbol('G12', 'In-plane shear modulus', 'MPa'),
      HelpSymbol('ν12', 'Major Poisson ratio'),
      HelpSymbol('Q', 'Reduced stiffness matrix terms', 'MPa'),
    ],
    notes: [
      'Only four of the constants are independent in plane stress; ν21 '
          'follows from reciprocity. Entering an independently measured ν21 '
          'that disagrees makes the matrix non-symmetric and unphysical.',
      'ν12 is the contraction in 2 caused by a load along 1. The subscript '
          'order is the most common source of confusion in composites, and '
          'some texts reverse it.',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 4',
    ],
    diagram: 'images/lamina.png',
  ),
  300: ToolHelp(
    summary: 'Stress and strain in a single ply, in either the material axes '
        'or a rotated set. Because a ply is far stiffer along the fibres than '
        'across them, rotating it does more than rotate the numbers: an '
        'off-axis ply couples normal stress to shear strain.',
    formulas: [
      HelpFormula(
        tex: r'\begin{bmatrix}\sigma_1\\\sigma_2\\\tau_{12}\end{bmatrix} = '
            r'[Q]\begin{bmatrix}\varepsilon_1\\\varepsilon_2\\'
            r'\gamma_{12}\end{bmatrix}',
        plain: '{σ1, σ2, τ12} = [Q] · {ε1, ε2, γ12}',
        caption: 'In the material axes',
      ),
      HelpFormula(
        tex: r'[\bar{Q}] = [T]^{-1}[Q][T]^{-T}',
        plain: '[Q̄] = [T]⁻¹ [Q] [T]⁻ᵀ',
        caption: 'Transformed to the laminate axes',
      ),
    ],
    symbols: [
      HelpSymbol('σ1, σ2', 'Stress along and across the fibres', 'MPa'),
      HelpSymbol('τ12', 'In-plane shear stress', 'MPa'),
      HelpSymbol('[Q]', 'Reduced stiffness matrix', 'MPa'),
      HelpSymbol('θ', 'Ply angle from the laminate x-axis', '°'),
    ],
    notes: [
      'Plane stress in the ply: through-thickness stresses are neglected, '
          'which is fine in the interior of a thin laminate and wrong at a '
          'free edge, where delamination starts.',
      'For any θ other than 0 or 90 the transformed matrix has non-zero Q̄16 '
          'and Q̄26 terms, which is the shear–extension coupling. It is a real '
          'effect, not a numerical artefact.',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 5',
    ],
    diagram: 'images/lamina.png',
  ),
  302: ToolHelp(
    summary: 'Classical lamination theory: assembles the plies into the A, B '
        'and D matrices and relates in-plane forces and moments to mid-plane '
        'strains and curvatures. This is what turns a stack of plies into a '
        'structural material with predictable behaviour.',
    formulas: [
      HelpFormula(
        tex: r'\begin{bmatrix}N\\M\end{bmatrix} = '
            r'\begin{bmatrix}A & B\\B & D\end{bmatrix}'
            r'\begin{bmatrix}\varepsilon^0\\\kappa\end{bmatrix}',
        plain: '{N, M} = [[A, B], [B, D]] · {ε⁰, κ}',
        caption: 'The laminate constitutive relation',
      ),
      HelpFormula(
        tex: r'A_{ij}=\sum \bar{Q}_{ij}(z_k-z_{k-1}), \quad '
            r'B_{ij}=\tfrac{1}{2}\sum \bar{Q}_{ij}(z_k^2-z_{k-1}^2), \quad '
            r'D_{ij}=\tfrac{1}{3}\sum \bar{Q}_{ij}(z_k^3-z_{k-1}^3)',
        plain: 'Aij = ΣQ̄ij·(zk − zk−1);  Bij = ½ΣQ̄ij·(zk² − zk−1²);  '
            'Dij = ⅓ΣQ̄ij·(zk³ − zk−1³)',
        caption: 'Extensional, coupling and bending stiffness',
      ),
    ],
    symbols: [
      HelpSymbol('N', 'In-plane force per unit width', 'N/mm'),
      HelpSymbol('M', 'Moment per unit width', 'N·mm/mm'),
      HelpSymbol('ε⁰', 'Mid-plane strain'),
      HelpSymbol('κ', 'Curvature', '1/mm'),
      HelpSymbol('z', 'Ply boundary height from the mid-plane', 'mm'),
    ],
    notes: [
      'B is zero if and only if the stack is symmetric about its mid-plane. A '
          'non-zero B couples stretching to bending, so the part warps as it '
          'cools from cure — which is why almost every practical laminate is '
          'laid up symmetric.',
      'Classical lamination theory ignores transverse shear, so it overstates '
          'the stiffness of thick laminates and of sandwich panels with soft '
          'cores.',
      'Residual thermal stresses from cure are not included and can be a '
          'large fraction of the first-ply-failure load.',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 4',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 7',
    ],
    diagram: 'images/laminate.png',
  ),
  303: ToolHelp(
    summary: 'Effective in-plane engineering constants for a laminate — the '
        'moduli you would measure if you tested the stack as if it were a '
        'homogeneous sheet. Useful for comparing a layup against metal, and '
        'for feeding a laminate into an analysis that expects one material.',
    formulas: [
      HelpFormula(
        tex: r'E_x = \frac{1}{h\,a_{11}}, \quad E_y = \frac{1}{h\,a_{22}}, '
            r'\quad G_{xy} = \frac{1}{h\,a_{66}}',
        plain: 'Ex = 1/(h·a11),   Ey = 1/(h·a22),   Gxy = 1/(h·a66)',
        caption: 'From the inverted extensional stiffness, [a] = [A]⁻¹',
      ),
      HelpFormula(
        tex: r'\nu_{xy} = -\frac{a_{12}}{a_{11}}',
        plain: 'νxy = −a12 / a11',
      ),
    ],
    symbols: [
      HelpSymbol('Ex, Ey', 'Effective in-plane moduli', 'MPa'),
      HelpSymbol('Gxy', 'Effective in-plane shear modulus', 'MPa'),
      HelpSymbol('h', 'Total laminate thickness', 'mm'),
      HelpSymbol('[a]', 'Inverse of the A matrix', 'mm/N'),
    ],
    notes: [
      'These describe in-plane behaviour only. Bending stiffness comes from '
          'D, and for the same plies in a different order it will differ even '
          'though A does not — stacking sequence matters for bending and not '
          'for stretching.',
      'Meaningful only for a symmetric laminate. With a non-zero B matrix the '
          'stack does not behave like a homogeneous sheet at all.',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 4',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 7',
    ],
    diagram: 'images/laminate.png',
  ),
  304: ToolHelp(
    summary: 'Three-dimensional effective properties of a laminate, including '
        'the through-thickness terms that classical lamination theory leaves '
        'out. Needed when a part is thick, when out-of-plane loads matter, or '
        'when feeding a solid finite-element model.',
    formulas: [
      HelpFormula(
        tex: r'[C] = [S]^{-1}',
        plain: '[C] = [S]⁻¹',
        caption: 'Stiffness as the inverse of the assembled compliance',
      ),
    ],
    symbols: [
      HelpSymbol('[C]', '6×6 stiffness matrix', 'MPa'),
      HelpSymbol('[S]', '6×6 compliance matrix', '1/MPa'),
      HelpSymbol('E3', 'Through-thickness modulus', 'MPa'),
      HelpSymbol('G13, G23', 'Transverse shear moduli', 'MPa'),
    ],
    notes: [
      'Through-thickness properties are matrix-dominated and low — often two '
          'orders of magnitude below E1. That is why composites delaminate '
          'rather than yield.',
      'Effective 3D properties smear the laminate into one homogeneous '
          'anisotropic solid. That is fine for overall stiffness and useless '
          'for interlaminar stresses at a free edge, which need a ply-by-ply '
          'model.',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Herakovich, Mechanics of Fibrous Composites, ch. 3',
    ],
    diagram: 'images/laminate.png',
  ),
  306: ToolHelp(
    summary: 'First-ply-failure criteria for a unidirectional ply under '
        'combined stress. Tsai–Hill and Tsai–Wu are interactive quadratic '
        'criteria; maximum stress and maximum strain check each component '
        'separately and say which mode fails.',
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
        caption: 'Tsai–Wu, which distinguishes tension from compression',
      ),
    ],
    symbols: [
      HelpSymbol('X', 'Longitudinal strength', 'MPa'),
      HelpSymbol('Y', 'Transverse strength', 'MPa'),
      HelpSymbol('S', 'In-plane shear strength', 'MPa'),
      HelpSymbol('σ1, σ2, τ12', 'Ply stresses in the material axes', 'MPa'),
    ],
    notes: [
      'These predict first ply failure, not laminate failure. A laminate '
          'usually carries considerably more load after the first ply cracks, '
          'and a progressive-failure analysis is needed to find the real '
          'ultimate.',
      'Use the tensile or compressive strength according to the sign of the '
          'stress. Tsai–Hill in its plain form does not do this for you.',
      'Tsai–Wu needs the interaction term F12, which is hard to measure; '
          'F12 = −½√(F11·F22) is a common and reasonable default.',
      'None of these say *how* the ply failed. Maximum-stress does, which is '
          'why it is still worth running alongside.',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Tsai & Wu, "A General Theory of Strength for Anisotropic Materials", '
          'J. Composite Materials, 1971',
    ],
    diagram: 'images/lamina.png',
  ),

  // ----------------------------------------------------------- machine design
  701: ToolHelp(
    summary: 'Round-wire helical compression spring: spring index, the Wahl '
        'correction that accounts for curvature and direct shear, the rate, '
        'and the surge frequency. The index C is the number to watch — below '
        'about 4 a spring is hard to coil, above 12 it tangles and buckles.',
    formulas: [
      HelpFormula(
        tex: r'C = \frac{D}{d}, \quad '
            r'K_W = \frac{4C-1}{4C-4} + \frac{0.615}{C}',
        plain: 'C = D/d,   KW = (4C − 1)/(4C − 4) + 0.615/C',
        caption: 'Spring index and Wahl factor',
      ),
      HelpFormula(
        tex: r'\tau = K_W \frac{8FD}{\pi d^3}',
        plain: 'τ = KW · 8·F·D / (π·d³)',
        caption: 'Corrected shear stress in the wire',
      ),
      HelpFormula(
        tex: r'k = \frac{Gd^4}{8D^3N_a}',
        plain: 'k = G·d⁴ / (8·D³·Na)',
        caption: 'Spring rate',
      ),
    ],
    symbols: [
      HelpSymbol('d', 'Wire diameter', 'mm'),
      HelpSymbol('D', 'Mean coil diameter', 'mm'),
      HelpSymbol('C', 'Spring index'),
      HelpSymbol('Na', 'Number of active coils'),
      HelpSymbol('G', 'Shear modulus of the wire', 'MPa'),
      HelpSymbol('k', 'Spring rate', 'N/mm'),
    ],
    notes: [
      'D is the *mean* coil diameter, outside diameter less one wire '
          'diameter. Using the outside diameter overstates the rate by a '
          'noticeable margin.',
      'Active coils are fewer than total coils: squared and ground ends cost '
          'about two, plain ends about none.',
      'Keep the operating frequency well clear of the surge frequency — a '
          'factor of 15 to 20 is the usual guidance for valve springs. Surge '
          'is a wave travelling along the spring, not a rigid-body mode.',
      'Wire strength depends strongly on diameter: thin wire is much stronger '
          'than thick wire of the same alloy.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 10',
      'Wahl, Mechanical Springs',
    ],
  ),
  702: ToolHelp(
    summary: 'Geometry of a 20° full-depth involute spur gear pair — pitch '
        'diameters, centre distance and ratio — plus a Lewis bending-stress '
        'estimate and a simplified contact-stress figure. A first sizing pass, '
        'not an AGMA rating.',
    formulas: [
      HelpFormula(
        tex: r'd = mN, \quad C = \frac{d_1+d_2}{2}, \quad '
            r'i = \frac{N_2}{N_1}',
        plain: 'd = m·N,   C = (d1 + d2)/2,   i = N2/N1',
        caption: 'Pitch diameter, centre distance, ratio',
      ),
      HelpFormula(
        tex: r'\sigma = \frac{W_t}{b\,m\,Y}',
        plain: 'σ = Wt / (b·m·Y)',
        caption: 'Lewis bending stress at the tooth root',
      ),
    ],
    symbols: [
      HelpSymbol('m', 'Module', 'mm'),
      HelpSymbol('N', 'Number of teeth'),
      HelpSymbol('d', 'Pitch diameter', 'mm'),
      HelpSymbol('Wt', 'Tangential tooth load', 'N'),
      HelpSymbol('b', 'Face width', 'mm'),
      HelpSymbol('Y', 'Lewis form factor'),
    ],
    notes: [
      'The Lewis equation is a static cantilever model of one tooth. It '
          'ignores stress concentration at the root fillet, dynamic effects, '
          'load sharing between teeth and misalignment — all of which AGMA 2001 '
          'covers with explicit factors, and all of which matter for a real '
          'rating.',
      'A 20° full-depth pinion undercuts below 17 teeth. Fewer teeth than '
          'that needs profile shift.',
      'Contact (Hertzian) stress usually governs surface durability while '
          'bending governs tooth breakage. Both need checking; they fail in '
          'different ways.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 13–14',
      'ANSI/AGMA 2001-D04',
    ],
  ),
  703: ToolHelp(
    summary: 'Minimum shaft diameter for combined fluctuating bending and '
        'steady torsion, by the distortion-energy criterion combined with '
        'modified Goodman. This is the standard shaft-sizing equation for the '
        'common case of a rotating shaft: bending fully reversed, torque '
        'steady.',
    formulas: [
      HelpFormula(
        tex: r'd = \left(\frac{16n}{\pi}\left\{\frac{1}{S_e}\left[4(K_f '
            r'M_a)^2 + 3(K_{fs}T_a)^2\right]^{1/2} + \frac{1}{S_{ut}}'
            r'\left[4(K_f M_m)^2 + 3(K_{fs}T_m)^2\right]^{1/2}\right\}'
            r'\right)^{1/3}',
        plain: 'd = { (16n/π) · [ (1/Se)·√(4(Kf·Ma)² + 3(Kfs·Ta)²) '
            '+ (1/Sut)·√(4(Kf·Mm)² + 3(Kfs·Tm)²) ] }^(1/3)',
        caption: 'DE–Goodman shaft diameter',
      ),
    ],
    symbols: [
      HelpSymbol('Ma, Mm', 'Alternating and mean bending moment', 'N·m'),
      HelpSymbol('Ta, Tm', 'Alternating and mean torque', 'N·m'),
      HelpSymbol('Se', 'Corrected endurance limit', 'MPa'),
      HelpSymbol('Sut', 'Ultimate tensile strength', 'MPa'),
      HelpSymbol('Kf, Kfs', 'Fatigue stress-concentration factors'),
      HelpSymbol('n', 'Design factor'),
    ],
    notes: [
      'For a rotating shaft under a steady transverse load, the bending is '
          'fully reversed: Ma is the full moment and Mm is zero. Torque from a '
          'constant drive is the other way round — Tm only.',
      'Kf and Kfs are the fatigue factors at the critical feature, usually a '
          'shoulder fillet, keyway or press fit. Leaving them at 1 is '
          'optimistic; a sharp shoulder is easily 2.',
      'This sizes for fatigue strength only. Also check deflection, slope at '
          'the bearings, and critical speed — a shaft that passes this can '
          'still be unusable.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 7',
      'ANSI/ASME B106.1M, Design of Transmission Shafting',
    ],
  ),
  704: ToolHelp(
    summary: 'Basic rating life of a rolling bearing: the number of '
        'revolutions that 90% of a population survives under a given load. '
        'The exponent makes life extremely sensitive to load — halving the '
        'load multiplies ball-bearing life by eight.',
    formulas: [
      HelpFormula(
        tex: r'L_{10} = \left(\frac{C}{P}\right)^{p}',
        plain: 'L10 = (C/P)^p,   p = 3 ball, 10/3 roller',
        caption: 'Rating life, millions of revolutions',
      ),
      HelpFormula(
        tex: r'L_{10h} = \frac{10^6 L_{10}}{60n}',
        plain: 'L10h = 10⁶ · L10 / (60·n)',
        caption: 'Converted to hours',
      ),
    ],
    symbols: [
      HelpSymbol('C', 'Basic dynamic load rating, from the catalogue', 'N'),
      HelpSymbol('P', 'Equivalent dynamic bearing load', 'N'),
      HelpSymbol('n', 'Speed', 'rpm'),
      HelpSymbol('L10', 'Rating life', 'million rev'),
    ],
    notes: [
      'L10 means 10% are expected to have failed by then, not that the '
          'bearing lasts that long. Median life is roughly five times L10.',
      'P is the equivalent load, P = X·Fr + Y·Fa, combining radial and axial '
          'components with catalogue factors — not simply the radial load '
          'when there is thrust.',
      'The basic rating ignores lubrication, contamination and temperature. '
          'ISO 281 adds the a-ISO life-modification factor for those, and a '
          'poorly lubricated bearing can fall far short of L10.',
      'C must be the *dynamic* rating. The static rating C0 governs '
          'indentation in a stationary bearing and is a different number.',
    ],
    references: [
      'ISO 281, Rolling bearings — Dynamic load ratings and rating life',
      'Shigley, Mechanical Engineering Design, ch. 11',
    ],
  ),
  705: ToolHelp(
    summary: 'Open-belt or roller-chain drive geometry: speed ratio, belt '
        'length and the wrap angle on each pulley. The small pulley\'s wrap '
        'angle is what limits the torque a friction belt can transmit before '
        'it slips.',
    formulas: [
      HelpFormula(
        tex: r'i = \frac{D_2}{D_1} = \frac{n_1}{n_2}',
        plain: 'i = D2/D1 = n1/n2',
        caption: 'Speed ratio',
      ),
      HelpFormula(
        tex: r'L = 2C + \frac{\pi}{2}(D_1+D_2) + \frac{(D_2-D_1)^2}{4C}',
        plain: 'L = 2C + (π/2)(D1 + D2) + (D2 − D1)²/(4C)',
        caption: 'Open-belt length',
      ),
      HelpFormula(
        tex: r'\theta_1 = \pi - 2\arcsin\frac{D_2-D_1}{2C}',
        plain: 'θ1 = π − 2·arcsin[(D2 − D1)/(2C)]',
        caption: 'Wrap angle on the small pulley',
      ),
    ],
    symbols: [
      HelpSymbol('D1, D2', 'Small and large pulley pitch diameter', 'mm'),
      HelpSymbol('C', 'Centre distance', 'mm'),
      HelpSymbol('L', 'Belt length', 'mm'),
      HelpSymbol('θ1', 'Wrap angle on the small pulley', 'rad'),
    ],
    notes: [
      'The belt-length expression is the standard approximation and is very '
          'close for C greater than about (D1 + D2).',
      'Keep the small-pulley wrap above about 120°. Below that a flat or '
          'V-belt slips before it reaches its rated capacity, and an idler is '
          'usually the fix.',
      'For roller chain, use pitch diameters and round the length to an even '
          'number of pitches — an odd number needs an offset link, which is '
          'weaker.',
      'Geometry only: belt power capacity depends on the section, speed and '
          'service factor from the manufacturer\'s tables.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 17',
      'ANSI/ASME B29.1, Precision Power Transmission Roller Chains',
    ],
  ),
  706: ToolHelp(
    summary: 'The torque needed to reach a target bolt preload, by the '
        'short-form torque–tension relation. Preload is what actually holds a '
        'joint together, and torque is only a proxy for it — an imprecise one, '
        'which is why this number needs treating with care.',
    formulas: [
      HelpFormula(
        tex: r'T = K F_i d',
        plain: 'T = K · Fi · d',
        caption: 'Torque for a target preload',
      ),
      HelpFormula(
        tex: r'F_i \approx 0.75 A_t S_p \;\text{(reused)}, \quad '
            r'0.90 A_t S_p \;\text{(permanent)}',
        plain: 'Fi ≈ 0.75·At·Sp reused,  0.90·At·Sp permanent',
        caption: 'Usual preload targets',
      ),
    ],
    symbols: [
      HelpSymbol('T', 'Tightening torque', 'N·m'),
      HelpSymbol('K', 'Nut factor, about 0.20 for plain steel'),
      HelpSymbol('Fi', 'Target preload', 'N'),
      HelpSymbol('d', 'Nominal bolt diameter', 'mm'),
      HelpSymbol('At', 'Tensile stress area', 'mm²'),
      HelpSymbol('Sp', 'Proof strength', 'MPa'),
    ],
    notes: [
      'K lumps together thread and under-head friction and is the weak point '
          'of the method: it varies with plating, lubricant and reuse, and '
          'torque control alone typically scatters preload by ±25–30%.',
      'Roughly 90% of the input torque is lost to friction; only about 10% '
          'becomes tension. A small change in friction is therefore a large '
          'change in preload.',
      'Where preload really matters, measure it — angle control past snug, '
          'bolt elongation, or a load-indicating washer — rather than relying '
          'on torque.',
      'Use the tensile stress area At, not the shank area. For a coarse M10 '
          'that is 58 mm², against 78.5 mm² for the plain diameter.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 8',
      'Bickford, An Introduction to the Design and Behavior of Bolted Joints',
    ],
  ),
  707: ToolHelp(
    summary: 'Shear stress on the throat of a fillet weld. The throat is the '
        'smallest section through the weld and therefore the failure plane, '
        'and design practice treats every fillet weld as failing in shear on '
        'it regardless of how the joint is loaded.',
    formulas: [
      HelpFormula(
        tex: r'a = 0.707\,w, \quad \tau = \frac{F}{a L}',
        plain: 'a = 0.707·w,   τ = F / (a·L)',
        caption: 'Throat thickness and shear stress on it',
      ),
    ],
    symbols: [
      HelpSymbol('w', 'Leg size of the fillet', 'mm'),
      HelpSymbol('a', 'Effective throat, 0.707·w for an equal-leg weld', 'mm'),
      HelpSymbol('L', 'Effective weld length', 'mm'),
      HelpSymbol('F', 'Load on the weld group', 'N'),
    ],
    notes: [
      'Treating every fillet as failing in shear on the throat is the '
          'standard simplification. A transversely loaded fillet is actually '
          'about 50% stronger than a longitudinal one; codes let you take '
          'credit for that with a directional-strength factor.',
      'The 0.707 factor holds for an equal-leg weld with a flat face. A convex '
          'or unequal-leg weld has a different throat.',
      'Only concentric loading is covered here. An eccentric load adds a '
          'torsional or bending component on the weld group, which has to be '
          'combined vectorially with the direct shear.',
      'Weld metal is normally matched or slightly overmatched to the parent '
          'metal, so the weld rarely governs unless it is undersized.',
    ],
    references: [
      'AWS D1.1, Structural Welding Code — Steel',
      'Shigley, Mechanical Engineering Design, ch. 9',
    ],
  ),
  708: ToolHelp(
    summary: 'Contact pressure, hub hoop stress and shaft stress for a solid '
        'shaft pressed into a hub of the same material. Interference fits are '
        'how most gears and couplings are actually attached — no keyway, so no '
        'stress raiser in the shaft.',
    formulas: [
      HelpFormula(
        tex: r'p = \frac{E\delta}{2d}\left[\frac{d_o^2-d^2}{d_o^2}\right]',
        plain: 'p = (E·δ / 2d) · (do² − d²)/do²',
        caption: 'Contact pressure, same material both parts',
      ),
      HelpFormula(
        tex: r'\sigma_{h} = p\,\frac{d_o^2+d^2}{d_o^2-d^2}, \quad '
            r'\sigma_{\text{shaft}} = -p',
        plain: 'σh = p·(do² + d²)/(do² − d²),   σshaft = −p',
        caption: 'Hub bore hoop stress, and the shaft under uniform pressure',
      ),
    ],
    symbols: [
      HelpSymbol('δ', 'Diametral interference', 'mm'),
      HelpSymbol('d', 'Nominal interface diameter', 'mm'),
      HelpSymbol('do', 'Hub outside diameter', 'mm'),
      HelpSymbol('p', 'Contact pressure', 'MPa'),
      HelpSymbol('E', "Young's modulus, entered in GPa", 'GPa'),
    ],
    notes: [
      "Same material for shaft and hub, which is what lets Poisson's ratio "
          'cancel. Different materials need the general Lamé form, and a steel '
          'shaft in an aluminium hub loosens as it heats.',
      'The hoop stress at the hub bore is tensile and is the largest stress '
          'in the joint. It is what cracks a thin hub, not the pressure.',
      'Design the interference from the *fit*, not a nominal figure: the '
          'actual interference varies across the tolerance band, and both '
          'extremes need checking — minimum for torque capacity, maximum for '
          'hub stress.',
      'Surface roughness is smeared flat during assembly and reduces the '
          'effective interference; allow a few micrometres for it.',
      'The torque the joint can carry is μ·p·π·d²·L/2 and is not computed '
          'here — it needs a friction coefficient and an engagement length, '
          'neither of which this tool asks for.',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 3 and 7',
      'ISO 286-1, Geometrical product specifications: ISO code system',
    ],
  ),
  709: ToolHelp(
    summary: 'First lateral critical speed of a shaft carrying one rotor, '
        "combining the rotor's whirl frequency with the shaft's own "
        "distributed mass by Dunkerley's equation. Running at the critical "
        'speed lets a small unbalance build a large deflection.',
    formulas: [
      HelpFormula(
        tex: r'\omega_r = \sqrt{\frac{k}{m}}, \quad '
            r'\frac{1}{\omega_c^2} = \frac{1}{\omega_r^2} + '
            r'\frac{1}{\omega_s^2}',
        plain: 'ωr = √(k/m),   1/ωc² = 1/ωr² + 1/ωs²',
        caption: "Rotor and shaft combined by Dunkerley's equation",
      ),
      HelpFormula(
        tex: r'N_c = \frac{60\,\omega_c}{2\pi}',
        plain: 'Nc = 60·ωc / (2π)',
        caption: 'Critical speed in rpm',
      ),
    ],
    symbols: [
      HelpSymbol('k', 'Lateral stiffness at the rotor', 'N/mm'),
      HelpSymbol('m', 'Rotor mass', 'kg'),
      HelpSymbol('ωc', 'First critical angular frequency', 'rad/s'),
      HelpSymbol('Nc', 'First critical speed', 'rpm'),
    ],
    notes: [
      "Dunkerley's equation always errs low, so the critical speed reported "
          'is conservative. That is the useful direction to be wrong in.',
      'Keep the running speed clear by a comfortable margin — below about '
          '75% of the first critical, or above about 140% of it, is the usual '
          'rule. Passing through a critical on run-up is acceptable if it is '
          'done briskly.',
      'Bearing stiffness is assumed rigid. Soft bearings or a flexible '
          'housing lower the critical speed, sometimes a great deal.',
      'Gyroscopic effects, which split the critical into forward and backward '
          'whirl, are not included.',
    ],
    references: [
      'Rao, Mechanical Vibrations, ch. 10',
      'Shigley, Mechanical Engineering Design, ch. 7',
    ],
  ),
  710: ToolHelp(
    summary: 'Transverse natural frequencies of a uniform prismatic beam, for '
        'the first three bending modes across the standard end conditions. '
        'Natural frequency scales with the square root of stiffness over mass, '
        'and inversely with the square of the length.',
    formulas: [
      HelpFormula(
        tex: r'f_n = \frac{(\beta_n L)^2}{2\pi L^2}\sqrt{\frac{EI}{\rho A}}',
        plain: 'fn = (βn·L)² / (2π·L²) · √(E·I / (ρ·A))',
        caption: 'Euler–Bernoulli beam frequency',
      ),
    ],
    symbols: [
      HelpSymbol('fn', 'Natural frequency of mode n', 'Hz'),
      HelpSymbol('βnL', 'Eigenvalue set by the end conditions'),
      HelpSymbol('E·I', 'Flexural rigidity', 'N·mm²'),
      HelpSymbol('ρ·A', 'Mass per unit length', 'kg/m'),
      HelpSymbol('L', 'Span', 'mm'),
    ],
    notes: [
      'Euler–Bernoulli theory ignores shear deformation and rotary inertia, '
          'so frequencies run high for a stubby beam — L/d below about 10 — '
          'and for the higher modes. Timoshenko theory corrects both.',
      'Length dominates: halving the span raises every frequency by four.',
      'Added mass that is not part of the beam — a motor, a pipe full of '
          'water — lowers the frequency and is not included unless it is '
          'folded into ρA.',
      'Real end conditions are never perfectly fixed or perfectly pinned; the '
          'true frequency falls between the two idealisations.',
    ],
    references: [
      'Rao, Mechanical Vibrations, ch. 8',
      'Blevins, Formulas for Natural Frequency and Mode Shape',
    ],
  ),
  711: ToolHelp(
    summary: 'Fundamental torsional natural frequency of a round shaft '
        'carrying either one rotor against a fixed end or two rotors on a '
        'free shaft. Torsional resonance is invisible from outside and is a '
        'common cause of coupling and gear-tooth failures.',
    formulas: [
      HelpFormula(
        tex: r'k_t = \frac{GJ_p}{L}, \quad '
            r'\omega_n = \sqrt{\frac{k_t}{J_{\text{eff}}}}',
        plain: 'kt = G·Jp / L,   ωn = √(kt / Jeff)',
        caption: 'Torsional stiffness and frequency',
      ),
      HelpFormula(
        tex: r'J_{\text{eff}} = \frac{J_1 J_2}{J_1+J_2}',
        plain: 'Jeff = J1·J2 / (J1 + J2)',
        caption: 'Two rotors on a free shaft: the reduced inertia',
      ),
    ],
    symbols: [
      HelpSymbol('kt', 'Torsional stiffness', 'N·m/rad'),
      HelpSymbol('G', 'Shear modulus', 'MPa'),
      HelpSymbol('Jp', 'Polar second moment of area of the shaft', 'mm⁴'),
      HelpSymbol('J1, J2', 'Mass moments of inertia of the rotors', 'kg·m²'),
    ],
    notes: [
      "The shaft's own inertia is neglected. Where it is comparable with the "
          'rotors\', a multi-station (Holzer) analysis is needed instead.',
      'Jp is a section property in mm⁴; J1 and J2 are mass moments in kg·m². '
          'They are different quantities that share a letter, and confusing '
          'them is the usual error here.',
      'Excitation is rarely at shaft speed. Engine firing orders and gear '
          'mesh frequencies are multiples of it, and those are what usually '
          'meet the resonance.',
    ],
    references: [
      'Rao, Mechanical Vibrations, ch. 5 and 6',
      'Nestorides, A Handbook on Torsional Vibration',
    ],
  ),

  // --------------------------------------------------------- fluids & thermal
  800: ToolHelp(
    summary: 'Reynolds number for flow in a round pipe, and the flow regime it '
        'falls in. Re is the ratio of inertial to viscous forces, and it is '
        'the single number that decides whether a flow is orderly or chaotic — '
        'which in turn sets the friction factor and the heat transfer.',
    formulas: [
      HelpFormula(
        tex: r'Re = \frac{\rho V D}{\mu} = \frac{VD}{\nu}',
        plain: 'Re = ρ·V·D / μ = V·D / ν',
        caption: 'Reynolds number',
      ),
      HelpFormula(
        tex: r'V = \frac{Q}{A}, \quad A = \frac{\pi D^2}{4}',
        plain: 'V = Q / A,   A = π·D²/4',
        caption: 'Velocity from volumetric flow',
      ),
    ],
    symbols: [
      HelpSymbol('Re', 'Reynolds number'),
      HelpSymbol('ρ', 'Density', 'kg/m³'),
      HelpSymbol('V', 'Mean velocity', 'm/s'),
      HelpSymbol('D', 'Inside diameter', 'mm'),
      HelpSymbol('μ', 'Dynamic viscosity', 'Pa·s'),
      HelpSymbol('ν', 'Kinematic viscosity, μ/ρ', 'm²/s'),
    ],
    notes: [
      'For pipe flow: laminar below about 2300, turbulent above about 4000, '
          'and transitional between. The transition is not sharp and depends '
          'on inlet disturbances and roughness.',
      'D is the *inside* diameter of the pipe, not the nominal size. Use the '
          'pipe schedule reference to get it right.',
      'For a non-circular duct, substitute the hydraulic diameter 4A/P. That '
          'works well for turbulent flow and poorly for laminar.',
      'V is the mean velocity over the section. The centreline velocity is '
          'twice that in laminar flow and about 1.2 times in turbulent.',
    ],
    references: [
      'White, Fluid Mechanics, ch. 6',
      'Munson, Fundamentals of Fluid Mechanics, ch. 8',
    ],
  ),
  801: ToolHelp(
    summary: 'Darcy–Weisbach head loss and pressure drop for a full-running '
        'pipe, with the friction factor from the Colebrook equation and '
        'fitting losses added as velocity heads. This is the standard way of '
        'sizing a pipe run and choosing the pump that has to feed it.',
    formulas: [
      HelpFormula(
        tex: r'h_f = f\frac{L}{D}\frac{V^2}{2g}',
        plain: 'hf = f · (L/D) · V²/(2g)',
        caption: 'Darcy–Weisbach friction head',
      ),
      HelpFormula(
        tex: r'\frac{1}{\sqrt{f}} = -2\log_{10}\left(\frac{\varepsilon/D}'
            r'{3.7} + \frac{2.51}{Re\sqrt{f}}\right)',
        plain: '1/√f = −2·log₁₀[ (ε/D)/3.7 + 2.51/(Re·√f) ]',
        caption: 'Colebrook, solved iteratively',
      ),
      HelpFormula(
        tex: r'h_m = \sum K \frac{V^2}{2g}, \quad \Delta p = \rho g h',
        plain: 'hm = ΣK · V²/(2g),   Δp = ρ·g·h',
        caption: 'Minor losses and the pressure drop',
      ),
    ],
    symbols: [
      HelpSymbol('f', 'Darcy friction factor'),
      HelpSymbol('L', 'Pipe length', 'm'),
      HelpSymbol('D', 'Inside diameter', 'mm'),
      HelpSymbol('ε', 'Absolute wall roughness', 'mm'),
      HelpSymbol('ΣK', 'Sum of minor-loss coefficients'),
      HelpSymbol('hf', 'Head loss', 'm'),
    ],
    notes: [
      'The Darcy friction factor is four times the Fanning factor. Check '
          'which one a chart or correlation is quoting before using it — the '
          'factor of four is a classic error.',
      'Colebrook is valid for turbulent flow. In laminar flow use f = 64/Re, '
          'which does not depend on roughness at all.',
      'Typical absolute roughness: 0.045 mm for commercial steel, 0.0015 mm '
          'for drawn tubing, 0.26 mm for cast iron. Old pipe is far rougher '
          'than new and this is where most of the uncertainty lives.',
      'Assumes a full pipe of incompressible fluid at steady flow. Partially '
          'full gravity drains and compressible gas flow need different '
          'treatments.',
    ],
    references: [
      'White, Fluid Mechanics, ch. 6',
      'Crane Technical Paper No. 410, Flow of Fluids Through Valves, '
          'Fittings and Pipe',
    ],
  ),
  802: ToolHelp(
    summary: 'The power a pump or fan needs: the fluid receives pressure rise '
        'times flow, and the driver must supply that divided by the '
        'efficiency. Also reports the pressure rise as a head of the pumped '
        'fluid, which is how pump curves are drawn.',
    formulas: [
      HelpFormula(
        tex: r'P_{\text{fluid}} = \Delta p\,Q, \quad '
            r'P_{\text{shaft}} = \frac{\Delta p\,Q}{\eta}',
        plain: 'Pfluid = Δp·Q,   Pshaft = Δp·Q / η',
        caption: 'Hydraulic and shaft power',
      ),
      HelpFormula(
        tex: r'H = \frac{\Delta p}{\rho g}',
        plain: 'H = Δp / (ρ·g)',
        caption: 'Pressure rise expressed as head',
      ),
    ],
    symbols: [
      HelpSymbol('Δp', 'Pressure rise across the machine', 'kPa'),
      HelpSymbol('Q', 'Volumetric flow rate', 'm³/s'),
      HelpSymbol('η', 'Overall efficiency'),
      HelpSymbol('H', 'Head', 'm'),
    ],
    notes: [
      'Head is independent of density but pressure is not. A pump develops '
          'the same head on any liquid and a proportionally lower pressure on '
          'a lighter one — which is why pump curves are in metres.',
      'Efficiency here is the whole machine. If the motor efficiency is '
          'separate, divide again by it to get electrical input.',
      'Check NPSH available against the pump\'s NPSH required as well. A pump '
          'that cavitates will not deliver this power usefully however it is '
          'sized.',
      'For a fan moving air, treat the gas as incompressible only while the '
          'pressure rise is small — below roughly 3% of absolute pressure.',
    ],
    references: [
      'White, Fluid Mechanics, ch. 11',
      'Hydraulic Institute Standards, ANSI/HI 1.1-1.2',
    ],
  ),
  810: ToolHelp(
    summary: 'Steady one-dimensional conduction through a layered plane wall. '
        'Each layer is a thermal resistance and they add in series with the '
        'convection films on the two faces, giving the overall U-value, the '
        'heat flow, and the temperature at every interface.',
    formulas: [
      HelpFormula(
        tex: r'R_{\text{cond}} = \frac{t}{k}, \quad '
            r'R_{\text{conv}} = \frac{1}{h}',
        plain: 'Rcond = t/k,   Rconv = 1/h',
        caption: 'Resistance per unit area',
      ),
      HelpFormula(
        tex: r'U = \frac{1}{\sum R}, \quad q = U\,\Delta T',
        plain: 'U = 1 / ΣR,   q = U · ΔT',
        caption: 'Overall coefficient and heat flux',
      ),
    ],
    symbols: [
      HelpSymbol('t', 'Layer thickness', 'm'),
      HelpSymbol('k', 'Thermal conductivity', 'W/m·K'),
      HelpSymbol('h', 'Convection coefficient', 'W/m²·K'),
      HelpSymbol('U', 'Overall heat transfer coefficient', 'W/m²·K'),
      HelpSymbol('q', 'Heat flux', 'W/m²'),
    ],
    notes: [
      'Plane wall only — resistances add as t/k. A cylindrical or spherical '
          'shell has a logarithmic or reciprocal form instead, and using the '
          'plane form on a small-diameter pipe is noticeably wrong.',
      'The largest resistance governs. Adding insulation to a wall whose '
          'resistance is already dominated by a still-air film buys much less '
          'than the k value suggests.',
      'Contact resistance between layers is neglected, and it can matter for '
          'bolted or bonded metal joints.',
      'Steady state only: no thermal mass, so this says nothing about how '
          'long a wall takes to respond.',
    ],
    references: [
      'Incropera & DeWitt, Fundamentals of Heat and Mass Transfer, ch. 3',
      'ASHRAE Handbook — Fundamentals, ch. 25',
    ],
  ),
  811: ToolHelp(
    summary: 'Efficiency of a straight rectangular fin of uniform section, '
        'solved with an adiabatic tip and a corrected length. Fin efficiency '
        'is the fraction of the ideal heat flow a real fin achieves, given '
        'that its temperature falls along its length.',
    formulas: [
      HelpFormula(
        tex: r'm = \sqrt{\frac{2h}{kt}}, \quad L_c = L + \frac{t}{2}',
        plain: 'm = √(2h / (k·t)),   Lc = L + t/2',
        caption: 'Fin parameter and corrected length',
      ),
      HelpFormula(
        tex: r'\eta_f = \frac{\tanh(mL_c)}{mL_c}',
        plain: 'ηf = tanh(m·Lc) / (m·Lc)',
        caption: 'Fin efficiency',
      ),
    ],
    symbols: [
      HelpSymbol('h', 'Convection coefficient', 'W/m²·K'),
      HelpSymbol('k', 'Fin thermal conductivity', 'W/m·K'),
      HelpSymbol('t', 'Fin thickness', 'm'),
      HelpSymbol('L', 'Fin length', 'm'),
      HelpSymbol('ηf', 'Fin efficiency'),
    ],
    notes: [
      'The corrected length is the standard trick for an adiabatic-tip '
          'solution to account for tip convection. It is accurate while '
          'h·t/k stays small, which is the usual case.',
      'Efficiency falls as fins get longer: beyond mLc of about 2 the extra '
          'length adds weight and almost no heat. That is the practical limit '
          'on fin height.',
      'Fins only help when the surface resistance dominates. Adding fins to '
          'the water side of a heat exchanger, where h is already large, does '
          'very little.',
      'One-dimensional conduction along the fin, uniform h over the surface, '
          'and no radiation.',
    ],
    references: [
      'Incropera & DeWitt, Fundamentals of Heat and Mass Transfer, ch. 3',
      'Kraus, Aziz & Welty, Extended Surface Heat Transfer',
    ],
  ),
  812: ToolHelp(
    summary: 'Log mean temperature difference from the four terminal '
        'temperatures, and the surface area a given duty needs. The LMTD is '
        'the correct average driving temperature for a heat exchanger, because '
        'the local difference varies exponentially along its length rather '
        'than linearly.',
    formulas: [
      HelpFormula(
        tex: r'\Delta T_{lm} = \frac{\Delta T_1 - \Delta T_2}'
            r'{\ln(\Delta T_1/\Delta T_2)}',
        plain: 'ΔTlm = (ΔT1 − ΔT2) / ln(ΔT1/ΔT2)',
        caption: 'Log mean temperature difference',
      ),
      HelpFormula(
        tex: r'A = \frac{Q}{U\,\Delta T_{lm}}',
        plain: 'A = Q / (U · ΔTlm)',
        caption: 'Area for a given duty',
      ),
    ],
    symbols: [
      HelpSymbol('ΔT1, ΔT2', 'Terminal temperature differences', 'K'),
      HelpSymbol('U', 'Overall heat transfer coefficient', 'W/m²·K'),
      HelpSymbol('Q', 'Heat duty', 'W'),
      HelpSymbol('A', 'Heat transfer area', 'm²'),
    ],
    notes: [
      'Counter flow pairs each inlet with the opposite outlet; parallel flow '
          'pairs the two inlets. Counter flow always gives the larger LMTD and '
          'therefore the smaller exchanger, and it is the only arrangement '
          'that can bring the cold outlet above the hot outlet.',
      'For shell-and-tube or cross-flow arrangements, multiply by the '
          'correction factor F from the standard charts. An F below about 0.8 '
          'signals a poorly chosen configuration.',
      'Assumes constant U and constant specific heats along the exchanger, and '
          'no phase change. Condensing or boiling on one side needs zone-by-'
          'zone treatment.',
      'Fouling raises the resistance over time; design U should include a '
          'fouling allowance or the exchanger will be undersized within a year.',
    ],
    references: [
      'Incropera & DeWitt, Fundamentals of Heat and Mass Transfer, ch. 11',
      'TEMA Standards of the Tubular Exchanger Manufacturers Association',
    ],
  ),
  // ---------------------------------------------------------------- utilities
  500: ToolHelp(
    summary: 'Converts between units within a physical quantity — length, '
        'force, pressure, torque and the rest. Conversions are exact where the '
        'definition is exact, which for the inch-based units it mostly is: '
        'one inch has been exactly 25.4 mm since 1959.',
    formulas: [
      HelpFormula(
        tex: r'v_{\text{target}} = v_{\text{source}} \times '
            r'\frac{f_{\text{source}}}{f_{\text{target}}}',
        plain: 'target = source × (source factor / target factor)',
        caption: 'Every conversion goes through one SI base value',
      ),
    ],
    symbols: [
      HelpSymbol('f', 'Factor converting a unit to its SI base'),
    ],
    notes: [
      'Converting through a single SI base rather than unit-to-unit means '
          'there is one factor per unit rather than one per pair, so a table '
          'of n units cannot disagree with itself.',
      'Temperature is the exception: °C to °F has an offset as well as a '
          'scale, so a temperature *difference* converts differently from a '
          'temperature.',
      'Pound-force and pound-mass are different quantities that share a name. '
          'Check which one a figure means before converting it.',
    ],
    references: [
      'BIPM, The International System of Units (SI), 9th edition',
      'NIST Special Publication 811, Guide for the Use of the SI',
    ],
  ),
  501: ToolHelp(
    summary: 'Tap drill and clearance drill sizes for standard metric and '
        'inch threads. The tap drill leaves enough material for roughly 75% '
        'thread engagement — the practical compromise between thread strength '
        'and the torque needed to cut it.',
    formulas: [
      HelpFormula(
        tex: r'd_{\text{tap}} \approx D - P',
        plain: 'tap drill ≈ D − P   (metric, ≈75% thread)',
        caption: 'Major diameter less one pitch — the usual 75% rule',
      ),
    ],
    symbols: [
      HelpSymbol('D', 'Nominal thread major diameter', 'mm'),
      HelpSymbol('P', 'Thread pitch', 'mm'),
    ],
    notes: [
      'D − P is not the minor diameter: the basic minor is D − 1.0825·P, so '
          'the usual tap drill deliberately leaves a shallower thread.',
      'Going from 75% to 100% thread engagement adds only about 5% to the '
          'strength while roughly doubling the tapping torque. It is almost '
          'never worth it, and it breaks taps.',
      'Thread strength depends far more on engagement *length* than on '
          'percentage. In a soft material, use a longer thread rather than a '
          'deeper one.',
      'Clearance drills follow the close/normal/loose fit classes. Normal is '
          'the default unless the assembly needs adjustment.',
      'Form (roll) taps need a larger hole than cut taps — they displace '
          'material rather than removing it.',
    ],
    references: [
      'ISO 965-1, ISO general purpose metric screw threads — Tolerances',
      'Machinery\'s Handbook, Threads and Threading',
    ],
  ),
  502: ToolHelp(
    summary: 'ISO 286 limits and fits for the preferred hole-basis '
        'combinations. A fit is a pair of tolerance zones: the letter sets '
        'where the zone sits relative to the nominal size and the number sets '
        'how wide it is, so H7/g6 and H7/p6 differ in position, not precision.',
    formulas: [
      HelpFormula(
        tex: r'\text{clearance}_{\max} = \text{hole}_{\max} - '
            r'\text{shaft}_{\min}',
        plain: 'max clearance = max hole − min shaft',
        caption: 'And min clearance is min hole − max shaft',
      ),
    ],
    symbols: [
      HelpSymbol('H', 'Hole basis: lower deviation is zero'),
      HelpSymbol('IT', 'Tolerance grade — the width of the zone'),
      HelpSymbol('µm', 'Deviations are tabulated in micrometres'),
    ],
    notes: [
      'Hole basis is the usual choice: holes are made with fixed-size tools '
          'and shafts are easier to adjust, so it is cheaper to vary the '
          'shaft.',
      'A negative clearance is an interference. H7/p6 and tighter are press '
          'fits and need the press-fit tool to check hub stress.',
      'Tolerance width grows with size for the same IT grade — an IT7 zone is '
          '21 µm at 20 mm and 52 µm at 300 mm.',
      'The tables are limits only. Whether a shaft actually fits also depends '
          'on form: roundness and straightness errors eat into the clearance.',
    ],
    references: [
      'ISO 286-1 and ISO 286-2, Geometrical product specifications',
      'Machinery\'s Handbook, Allowances and Tolerances for Fits',
    ],
  ),
  503: ToolHelp(
    summary: 'Published dimensions and section properties for rolled '
        'structural shapes — AISC W shapes and European IPE and HEB. Published '
        'values include the root fillets that a bare-geometry calculation '
        'cannot see, which is worth a few percent of area and stiffness.',
    formulas: [
      HelpFormula(
        tex: r'S = \frac{I}{c}, \quad r = \sqrt{\frac{I}{A}}',
        plain: 'S = I / c,   r = √(I / A)',
        caption: 'Section modulus and radius of gyration, both derived here',
      ),
    ],
    symbols: [
      HelpSymbol('A', 'Cross-sectional area', 'mm²'),
      HelpSymbol('Ix, Iy', 'Second moments about the strong and weak axes',
          'mm⁴'),
      HelpSymbol('S', 'Elastic section modulus', 'mm³'),
      HelpSymbol('r', 'Radius of gyration', 'mm'),
    ],
    notes: [
      'Only area and the two second moments are stored; S and r are computed '
          'from them, so a transcription slip cannot make them disagree.',
      'The tables cover doubly symmetric I-shapes. Channels and angles have '
          'their centroid off mid-depth and are not included.',
      'These are elastic properties. Plastic design uses the plastic section '
          'modulus Z, which is larger — about 1.12 times S for a typical '
          'I-shape.',
      'Check a current mill or standard table before detailing: sections are '
          'occasionally revised or withdrawn.',
    ],
    references: [
      'AISC Steel Construction Manual, Part 1',
      'EN 10365, Hot rolled steel channels, I and H sections',
    ],
  ),
  504: ToolHelp(
    summary: 'Outside diameter, wall thickness and bore for ASME B36.10M '
        'steel pipe. Pipe is made to a fixed outside diameter so that the same '
        'fittings and threads suit every wall, which means a heavier schedule '
        'eats into the bore rather than growing the pipe.',
    formulas: [
      HelpFormula(
        tex: r'ID = OD - 2t, \quad A = \frac{\pi\,ID^2}{4}',
        plain: 'ID = OD − 2·t,   A = π·ID²/4',
        caption: 'Bore and flow area, both derived here',
      ),
    ],
    symbols: [
      HelpSymbol('NPS', 'Nominal pipe size — a name, not a measurement'),
      HelpSymbol('DN', 'The ISO nominal diameter, also a name'),
      HelpSymbol('OD', 'Outside diameter', 'mm'),
      HelpSymbol('t', 'Wall thickness', 'mm'),
    ],
    notes: [
      'NPS is not a dimension. NPS 2 pipe has neither a 2" bore nor a 2" '
          'outside diameter; only from NPS 14 up does the number equal the OD '
          'in inches.',
      'Use the bore, not the nominal size, for any flow calculation. At NPS 1 '
          'the difference is about 5%, and it goes as the fourth power in a '
          'pressure-drop calculation.',
      'STD and XS track Sch 40 and Sch 80 only up to NPS 10 and NPS 8 '
          'respectively; above that the weight classes stop thickening.',
      'These are nominal dimensions. Mill tolerance on wall is typically '
          '−12.5%, which matters for a pressure calculation.',
    ],
    references: [
      'ASME B36.10M, Welded and Seamless Wrought Steel Pipe',
      'ASME B31.3, Process Piping',
    ],
  ),
  505: ToolHelp(
    summary: 'One-dimensional tolerance stack-up over a chain of dimensions, '
        'by both the worst-case and the statistical (RSS) method. Reports the '
        'closing gap, whether it can go negative, and which dimension is '
        'responsible for most of the variation — which is where tightening a '
        'tolerance buys the most.',
    formulas: [
      HelpFormula(
        tex: r'g = \sum \pm d_i, \quad '
            r'T_{wc} = \sum t_i',
        plain: 'g = Σ ±di,   Twc = Σ ti',
        caption: 'Worst case: tolerances add arithmetically',
      ),
      HelpFormula(
        tex: r'T_{rss} = \sqrt{\sum t_i^2}',
        plain: 'Trss = √(Σ ti²)',
        caption: 'RSS: they add in quadrature',
      ),
    ],
    symbols: [
      HelpSymbol('di', 'Nominal of each dimension in the chain', 'mm'),
      HelpSymbol('ti', 'Equal-bilateral half-tolerance of each', 'mm'),
      HelpSymbol('g', 'Closing gap', 'mm'),
    ],
    notes: [
      'Worst case is arithmetic and unarguable: if it clears, the assembly '
          'always goes together. Size on it.',
      'RSS assumes the dimensions vary independently, sit centred in their '
          'bands and are roughly normal. It says nothing about a lot of five '
          'parts, and understates the spread when a process drifts or a '
          'supplier runs to one edge of the band.',
      'RSS shares go as the square of each tolerance, so they point much '
          'harder at the loosest dimension than the worst-case shares do. That '
          'is the one to tighten.',
      'An asymmetric tolerance shifts the statistical mean: 25 +0.10/−0.00 is '
          'really 25.05 ±0.05, and summing it as 25 biases the chain low.',
      'One-dimensional only. Angular effects, form errors and true-position '
          'tolerances need a full 3D tolerance analysis.',
    ],
    references: [
      'ASME Y14.5, Dimensioning and Tolerancing',
      'Fischer, Mechanical Tolerance Stackup and Analysis',
    ],
  ),
  506: ToolHelp(
    summary: 'Strength grades for threaded fasteners, and what they mean for '
        'assembly. Metric property classes come from ISO 898-1 and inch grades '
        'from SAE J429; the clamp load and tightening torque on each row are '
        'derived from the tabulated proof strength, so a grade and its torque '
        'can never drift apart. Use it to size a bolt, to identify one already '
        'in a joint from its head marking, or to set a torque wrench.',
    formulas: [
      HelpFormula(
        tex: r'A_s = \frac{\pi}{4}\left(d - 0.9382\,p\right)^2',
        plain: 'As = (π/4)(d − 0.9382·p)²',
        caption: 'Tensile stress area, metric coarse thread',
      ),
      HelpFormula(
        tex: r'F_i = 0.75\,A_s S_p',
        plain: 'Fi = 0.75·As·Sp',
        caption: 'Recommended clamp load, reusable connection',
      ),
      HelpFormula(
        tex: r'T = K F_i d',
        plain: 'T = K·Fi·d',
        caption: 'Tightening torque, short-form torque-tension relation',
      ),
    ],
    symbols: [
      HelpSymbol('As', 'Tensile stress area of the thread', 'mm²'),
      HelpSymbol('d', 'Nominal (major) thread diameter', 'mm'),
      HelpSymbol('p', 'Thread pitch', 'mm'),
      HelpSymbol('Sp', 'Proof strength of the grade', 'MPa'),
      HelpSymbol('Fi', 'Clamp load (preload)', 'N'),
      HelpSymbol('T', 'Tightening torque', 'N·m'),
      HelpSymbol('K', 'Nut factor, 0.2 here'),
    ],
    notes: [
      'Proof strength, not yield, is what a preload is set against. It is the '
          'stress the fastener carries with no measurable permanent set, and '
          'it sits a little below the yield figure in the same row.',
      'The 0.75 factor is practice, not a standard. 75% of proof is the usual '
          'figure for a joint that will be taken apart; 90% is common for a '
          'permanent one tightened once, and torque-to-yield fasteners are '
          'deliberately taken past it and then thrown away.',
      'K = 0.2 assumes a plain, unplated, unlubricated thread. Zinc plating, '
          'wax or anti-seize put it nearer 0.10–0.15, which for the same '
          'torque raises the preload by up to a factor of two — enough to snap '
          'the bolt. Where the preload matters, control it by angle, by bolt '
          'stretch, or with a load cell rather than by torque.',
      'ISO 898-1 derates class 8.8 above M16, and SAE J429 derates grade 2 '
          'above 3/4 in, because a thicker section cannot be hardened through. '
          'The table already applies the right band for each diameter.',
      'The stress area is smaller than the shank area the nominal diameter '
          'suggests — for M12 it is 84.3 mm² against 113 mm². Sizing a bolt on '
          'πd²/4 overstates its capacity by a quarter.',
      'These are static tension figures. A bolt under fluctuating load fails '
          'in fatigue at the first engaged thread, far below the tensile '
          'strength here; check the fatigue tools for that.',
    ],
    references: [
      'ISO 898-1, Mechanical properties of fasteners — bolts, screws and studs',
      'SAE J429, Mechanical and Material Requirements for Externally Threaded '
          'Fasteners',
      "Shigley's Mechanical Engineering Design, ch. 8",
    ],
  ),
  712: ToolHelp(
    summary: 'Torque to raise and to lower a load on a power screw, the efficiency '
        'that goes with it, and whether the screw holds the load on its own. This '
        'is the calculation behind a screw jack, a vice, a toggle clamp and the '
        'lead screw on a machine slide — anywhere rotation is turned into a large '
        'axial force.',
    formulas: [
      HelpFormula(
        tex: r'T_R = \frac{F d_m}{2}\left(\frac{l + \pi \mu d_m \sec\alpha}{\pi d_m - \mu l \sec\alpha}\right) + \frac{F \mu_c d_c}{2}',
        plain: 'TR = (F·dm/2)·(l + π·μ·dm·secα)/(π·dm − μ·l·secα) + F·μc·dc/2',
        caption: 'Torque to raise the load, thread plus collar',
      ),
      HelpFormula(
        tex: r'T_L = \frac{F d_m}{2}\left(\frac{\pi \mu d_m \sec\alpha - l}{\pi d_m + \mu l \sec\alpha}\right) + \frac{F \mu_c d_c}{2}',
        plain: 'TL = (F·dm/2)·(π·μ·dm·secα − l)/(π·dm + μ·l·secα) + F·μc·dc/2',
        caption: 'Torque to lower it; negative means it runs away',
      ),
      HelpFormula(
        tex: r'e = \frac{F l}{2\pi T_R}',
        plain: 'e = F·l / (2π·TR)',
        caption: 'Efficiency: work out over work in, per turn',
      ),
      HelpFormula(
        tex: r'\mu \sec\alpha > \tan\lambda = \frac{l}{\pi d_m}',
        plain: 'μ·secα > tanλ = l / (π·dm)',
        caption: 'Self-locking condition',
      ),
    ],
    symbols: [
      HelpSymbol('F', 'Axial load', 'N'),
      HelpSymbol('dm', 'Mean (pitch) diameter, d − p/2', 'mm'),
      HelpSymbol('l', 'Lead, the travel per turn: p × number of starts', 'mm'),
      HelpSymbol('p', 'Pitch, the distance between adjacent threads', 'mm'),
      HelpSymbol('λ', 'Lead angle, atan(l / π·dm)', 'deg'),
      HelpSymbol('α', 'Thread flank angle: 0 square, 14.5° ACME, 15° trapezoidal', 'deg'),
      HelpSymbol('μ', 'Coefficient of friction at the thread'),
      HelpSymbol('μc', 'Coefficient of friction at the thrust collar'),
      HelpSymbol('dc', 'Mean collar diameter', 'mm'),
      HelpSymbol('T', 'Torque', 'N·m'),
      HelpSymbol('e', 'Efficiency, 0 to 1'),
    ],
    notes: [
      'Lead is not pitch. A double-start thread has twice the lead of its '
          'pitch, travels twice as far per turn, and is markedly more efficient — '
          'and markedly less likely to be self-locking. Getting the two confused is '
          'the classic error here.',
      'Self-locking is a property of the thread, not of the assembly. A screw '
          'can fail the μ·secα > tanλ test and still hold the load because the '
          'collar makes up the difference, which is a far weaker guarantee: the '
          'collar is what wears, and what somebody eventually oils.',
      'Never rely on self-locking alone where a falling load would hurt '
          'someone. Vibration breaks static friction down, and the coefficient you '
          'assumed is not the one you will have in service.',
      'A square thread is the efficient one: the flank angle in ACME and '
          'trapezoidal threads wedges the load between the flanks and multiplies '
          'thread friction by sec α. ACME is used anyway because it is easier to '
          'cut and its wear can be taken up with a split nut.',
      'Efficiency rarely passes 50% for a self-locking screw, and it is often '
          'nearer 20%. That is inherent to the mechanism, not a sign of a bad '
          'design — the friction that wastes the work is the same friction that '
          'holds the load.',
      'This is the torque at the screw. It says nothing about buckling of a '
          'long screw in compression, thread bearing pressure, or the nut\'s thread '
          'shear — check those separately before sizing on this alone.',
    ],
    references: [
      "Shigley's Mechanical Engineering Design, ch. 8",
      'Norton, Machine Design: An Integrated Approach, ch. 15',
    ],
    diagram: 'images/icons/icon_power_screw.png',
  ),
};
