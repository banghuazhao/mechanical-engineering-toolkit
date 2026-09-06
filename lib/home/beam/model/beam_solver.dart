/// A general Euler–Bernoulli beam solver: any of six support arrangements,
/// carrying any number of point loads, distributed loads and applied couples.
///
/// ## Why a stiffness solve rather than a formula
///
/// The closed forms in a textbook cover one load on one support arrangement.
/// Three of the arrangements offered here — propped cantilever, fixed–fixed,
/// and an overhang whose supports are inset — are statically indeterminate, so
/// the reactions cannot be found from equilibrium alone at all. Meshing the
/// beam into two-node Hermite elements and solving `K·d = F` handles every
/// case with one piece of code, and superposing loads costs nothing.
///
/// ## Sign conventions
///
/// Positions run left to right from the left end. Everything the caller passes
/// in and reads back uses engineering signs:
///
///  * a **load** is positive downward, which is how a load is quoted;
///  * a **reaction** is positive upward;
///  * a **couple** is positive counter-clockwise;
///  * a **bending moment** is positive sagging (tension in the bottom fibre);
///  * a **deflection** is positive downward, so a sagging beam reads positive.
///
/// Internally the solve runs in true SI with y measured upward, because that
/// is the convention the element matrices are written in. The flip happens
/// once, at the boundary of [BeamSolver.solve].
library;

import 'dart:math' as math;

/// How a support holds the beam.
///
/// A pin and a roller are the same thing here: this is a bending model with no
/// axial degree of freedom, so both restrain deflection and neither restrains
/// rotation. Offering them as separate choices would imply a distinction the
/// analysis does not make.
enum BeamSupportType {
  /// Deflection held, free to rotate — a pin or a roller.
  simple,

  /// Deflection and rotation both held — built in.
  fixed,
}

/// The support arrangements the tool offers.
enum BeamSupportCase {
  simplySupported,
  cantileverLeft,
  cantileverRight,
  overhang,
  proppedCantilever,
  fixedFixed,
}

class BeamSupport {
  const BeamSupport(this.position, this.type);

  /// Distance from the left end, m.
  final double position;
  final BeamSupportType type;
}

sealed class BeamLoad {
  const BeamLoad();
}

/// A concentrated force, positive downward, kN.
class BeamPointLoad extends BeamLoad {
  const BeamPointLoad({required this.position, required this.magnitude});

  /// Distance from the left end, m.
  final double position;

  /// kN, positive downward.
  final double magnitude;
}

/// A distributed load, positive downward, kN/m.
///
/// Uniform when both intensities are equal, triangular when one is zero, and
/// trapezoidal otherwise — one shape covers all three, so the UI needs only
/// two intensity fields rather than three load types.
class BeamDistributedLoad extends BeamLoad {
  const BeamDistributedLoad({
    required this.start,
    required this.end,
    required this.startIntensity,
    required this.endIntensity,
  });

  /// Left and right limits of the loaded length, m.
  final double start;
  final double end;

  /// kN/m at [start] and at [end], positive downward.
  final double startIntensity;
  final double endIntensity;

  bool get isUniform => startIntensity == endIntensity;
}

/// A concentrated couple, positive counter-clockwise, kN·m.
class BeamAppliedMoment extends BeamLoad {
  const BeamAppliedMoment({required this.position, required this.magnitude});

  /// Distance from the left end, m.
  final double position;

  /// kN·m, positive counter-clockwise.
  final double magnitude;
}

class BeamInput {
  const BeamInput({
    required this.span,
    required this.supports,
    required this.loads,
    required this.elasticModulus,
    required this.secondMoment,
    this.extremeFibreDistance,
  });

  /// Overall length, m.
  final double span;

  final List<BeamSupport> supports;
  final List<BeamLoad> loads;

  /// Young's modulus, GPa.
  final double elasticModulus;

  /// Second moment of area about the bending axis, mm⁴.
  final double secondMoment;

  /// Distance from the neutral axis to the extreme fibre, c, mm.
  ///
  /// Optional: given, the result carries the bending stress that goes with the
  /// largest moment. Left null, the tool reports deflections and internal
  /// actions only, which is all the section property above can support.
  final double? extremeFibreDistance;

  /// Flexural rigidity EI in N·m², from GPa and mm⁴.
  double get flexuralRigidity => elasticModulus * 1e9 * secondMoment * 1e-12;
}

/// What one support carries.
class BeamReaction {
  const BeamReaction({
    required this.position,
    required this.type,
    required this.force,
    required this.moment,
  });

  /// Distance from the left end, m.
  final double position;
  final BeamSupportType type;

  /// kN, positive upward.
  final double force;

  /// kN·m, positive counter-clockwise. Always zero at a simple support.
  final double moment;
}

class BeamDiagramPoint {
  const BeamDiagramPoint(this.x, this.value);
  final double x;
  final double value;
}

/// A diagram's largest value and where it occurs.
class BeamExtreme {
  const BeamExtreme(this.value, this.position);

  final double value;

  /// Distance from the left end, m.
  final double position;
}

class BeamResult {
  const BeamResult({
    required this.reactions,
    required this.maximumShear,
    required this.maximumSaggingMoment,
    required this.maximumHoggingMoment,
    required this.maximumMoment,
    required this.maximumDeflection,
    required this.bendingStress,
    required this.shear,
    required this.moment,
    required this.deflection,
    required this.isDeterminate,
  });

  final List<BeamReaction> reactions;

  /// Largest shear by magnitude, kN, with its sign kept.
  final BeamExtreme maximumShear;

  /// Largest sagging (positive) moment, kN·m. Zero when the beam never sags.
  final BeamExtreme maximumSaggingMoment;

  /// Largest hogging (negative) moment, kN·m — the one over a fixed end or an
  /// interior support. Zero when the beam never hogs.
  ///
  /// Reported separately from [maximumSaggingMoment] because they size
  /// different things: a hogging peak puts the top fibre in tension, which is
  /// where a reinforced or an unsymmetric section needs its material.
  final BeamExtreme maximumHoggingMoment;

  /// Whichever of the two above is larger in magnitude, kN·m.
  final BeamExtreme maximumMoment;

  /// Largest deflection by magnitude, mm, positive downward.
  final BeamExtreme maximumDeflection;

  /// Bending stress at [maximumMoment], MPa — null when no extreme-fibre
  /// distance was supplied.
  final double? bendingStress;

  final List<BeamDiagramPoint> shear;
  final List<BeamDiagramPoint> moment;
  final List<BeamDiagramPoint> deflection;

  /// Whether equilibrium alone could have found the reactions.
  ///
  /// False for the propped cantilever, the fixed–fixed beam and any
  /// arrangement with more than two supports — cases where the answer depends
  /// on EI, and so on the section and material being right.
  final bool isDeterminate;
}

/// How finely the beam is meshed.
///
/// Nodes are forced at every support, every point load, every couple, and
/// every end of a distributed load; the rest are spread through the gaps to
/// reach roughly this many elements. Enough for a deflection curve that reads
/// smoothly at any span, and small enough that the banded solve stays
/// instantaneous on a phone.
const int _targetElements = 120;

/// Positions closer together than this are the same point, m.
///
/// Loads land on round numbers, so this only ever merges a load that sits on
/// a support with the support itself — which is exactly what should happen.
const double _positionTolerance = 1e-9;

abstract final class BeamSolver {
  static BeamResult solve(BeamInput input) {
    _validate(input);

    final nodes = _meshPositions(input);
    final ei = input.flexuralRigidity;

    // Internally: metres, newtons, y upward. Loads arrive downward-positive.
    final forces = <({double x, double value})>[
      for (final load in input.loads)
        if (load is BeamPointLoad)
          (x: load.position, value: -load.magnitude * 1000),
    ];
    final couples = <({double x, double value})>[
      for (final load in input.loads)
        if (load is BeamAppliedMoment) (x: load.position, value: load.magnitude * 1000),
    ];
    final distributed = <BeamDistributedLoad>[
      for (final load in input.loads)
        if (load is BeamDistributedLoad) load,
    ];

    final displacement =
        _solveDisplacements(nodes, ei, forces, couples, distributed, input);

    final reactions = _reactions(
        nodes, ei, forces, couples, distributed, input, displacement);

    final diagrams =
        _diagrams(nodes, forces, couples, distributed, reactions, displacement);

    return _assemble(input, reactions, diagrams);
  }

  // -- setup ---------------------------------------------------------------

  static void _validate(BeamInput input) {
    if (input.span <= 0) {
      throw const FormatException('Span must be greater than zero.');
    }
    if (input.elasticModulus <= 0 || input.secondMoment <= 0) {
      throw const FormatException(
          'Elastic modulus and second moment must be positive.');
    }
    final c = input.extremeFibreDistance;
    if (c != null && c <= 0) {
      throw const FormatException(
          'Distance to the extreme fibre must be positive.');
    }
    if (input.supports.isEmpty) {
      throw const FormatException('The beam needs at least one support.');
    }
    for (final support in input.supports) {
      if (support.position < -_positionTolerance ||
          support.position > input.span + _positionTolerance) {
        throw const FormatException('A support sits outside the span.');
      }
    }
    for (var i = 1; i < input.supports.length; i++) {
      for (var j = 0; j < i; j++) {
        if ((input.supports[i].position - input.supports[j].position).abs() <
            _positionTolerance) {
          throw const FormatException('Two supports share the same position.');
        }
      }
    }
    if (input.loads.isEmpty) {
      throw const FormatException('Enter at least one load.');
    }
    for (final load in input.loads) {
      switch (load) {
        case BeamPointLoad():
          _requireInSpan(load.position, input.span, 'A point load');
        case BeamAppliedMoment():
          _requireInSpan(load.position, input.span, 'An applied moment');
        case BeamDistributedLoad():
          _requireInSpan(load.start, input.span, 'A distributed load');
          _requireInSpan(load.end, input.span, 'A distributed load');
          if (load.end - load.start <= _positionTolerance) {
            throw const FormatException(
                'A distributed load must end after it starts.');
          }
      }
    }
    // A support arrangement that leaves the beam free to move or spin is a
    // mechanism, and the solve would come back as a division by zero rather
    // than as anything a reader could act on.
    final restraints = input.supports.fold<int>(
        0, (sum, s) => sum + (s.type == BeamSupportType.fixed ? 2 : 1));
    if (restraints < 2) {
      throw const FormatException(
          'The supports leave the beam free to move. Add a support, or fix '
          'the one it has.');
    }
  }

  static void _requireInSpan(double position, double span, String what) {
    if (position < -_positionTolerance ||
        position > span + _positionTolerance) {
      throw FormatException('$what sits outside the span.');
    }
  }

  /// Node positions: every point the model has to resolve exactly, plus
  /// enough filler for a smooth curve between them.
  static List<double> _meshPositions(BeamInput input) {
    final keyPoints = <double>{0, input.span};
    for (final support in input.supports) {
      keyPoints.add(support.position.clamp(0, input.span));
    }
    for (final load in input.loads) {
      switch (load) {
        case BeamPointLoad():
          keyPoints.add(load.position.clamp(0, input.span));
        case BeamAppliedMoment():
          keyPoints.add(load.position.clamp(0, input.span));
        case BeamDistributedLoad():
          keyPoints.add(load.start.clamp(0, input.span));
          keyPoints.add(load.end.clamp(0, input.span));
      }
    }

    final anchors = keyPoints.toList()..sort();
    // Merge anchors that a float has split into two.
    final merged = <double>[anchors.first];
    for (final value in anchors.skip(1)) {
      if (value - merged.last > _positionTolerance) merged.add(value);
    }

    // Fill each gap in proportion to its length, so a short overhang is not
    // meshed more coarsely than the main span.
    final nodes = <double>[merged.first];
    for (var i = 1; i < merged.length; i++) {
      final from = merged[i - 1];
      final to = merged[i];
      final divisions =
          math.max(1, (_targetElements * (to - from) / input.span).round());
      for (var step = 1; step <= divisions; step++) {
        nodes.add(from + (to - from) * step / divisions);
      }
    }
    return nodes;
  }

  // -- the stiffness solve -------------------------------------------------

  /// Nodal deflections and rotations, in metres and radians, y upward.
  static List<double> _solveDisplacements(
    List<double> nodes,
    double ei,
    List<({double x, double value})> forces,
    List<({double x, double value})> couples,
    List<BeamDistributedLoad> distributed,
    BeamInput input,
  ) {
    final dofCount = nodes.length * 2;
    final stiffness = _assembleStiffness(nodes, ei);
    final load = _assembleLoads(nodes, forces, couples, distributed);

    // Constrained degrees of freedom, from the supports.
    final held = List<bool>.filled(dofCount, false);
    for (final support in input.supports) {
      final node = _nearestNode(nodes, support.position);
      held[node * 2] = true;
      if (support.type == BeamSupportType.fixed) held[node * 2 + 1] = true;
    }

    // Condense to the free degrees of freedom and solve there. Zeroing the
    // held rows in place would work too, but this keeps the reduced matrix
    // positive definite, which is what lets the solve skip pivoting.
    final freeIndex = <int>[];
    final mapping = List<int>.filled(dofCount, -1);
    for (var i = 0; i < dofCount; i++) {
      if (!held[i]) {
        mapping[i] = freeIndex.length;
        freeIndex.add(i);
      }
    }

    final n = freeIndex.length;
    final reduced = List.generate(n, (_) => List<double>.filled(n, 0));
    final rhs = List<double>.filled(n, 0);
    for (var i = 0; i < n; i++) {
      rhs[i] = load[freeIndex[i]];
      for (var j = 0; j < n; j++) {
        reduced[i][j] = stiffness[freeIndex[i]][freeIndex[j]];
      }
    }

    final solved = _solveBanded(reduced, rhs);

    final displacement = List<double>.filled(dofCount, 0);
    for (var i = 0; i < n; i++) {
      displacement[freeIndex[i]] = solved[i];
    }
    return displacement;
  }

  static List<List<double>> _assembleStiffness(List<double> nodes, double ei) {
    final dofCount = nodes.length * 2;
    final k = List.generate(dofCount, (_) => List<double>.filled(dofCount, 0));
    for (var e = 0; e < nodes.length - 1; e++) {
      final l = nodes[e + 1] - nodes[e];
      final l2 = l * l;
      final l3 = l2 * l;
      final c = ei / l3;
      final local = [
        [12 * c, 6 * l * c, -12 * c, 6 * l * c],
        [6 * l * c, 4 * l2 * c, -6 * l * c, 2 * l2 * c],
        [-12 * c, -6 * l * c, 12 * c, -6 * l * c],
        [6 * l * c, 2 * l2 * c, -6 * l * c, 4 * l2 * c],
      ];
      final dofs = [e * 2, e * 2 + 1, e * 2 + 2, e * 2 + 3];
      for (var i = 0; i < 4; i++) {
        for (var j = 0; j < 4; j++) {
          k[dofs[i]][dofs[j]] += local[i][j];
        }
      }
    }
    return k;
  }

  /// The consistent nodal load vector, N and N·m, y upward.
  static List<double> _assembleLoads(
    List<double> nodes,
    List<({double x, double value})> forces,
    List<({double x, double value})> couples,
    List<BeamDistributedLoad> distributed,
  ) {
    final f = List<double>.filled(nodes.length * 2, 0);

    // Concentrated actions land on a node — the mesh put one there.
    for (final force in forces) {
      f[_nearestNode(nodes, force.x) * 2] += force.value;
    }
    for (final couple in couples) {
      f[_nearestNode(nodes, couple.x) * 2 + 1] += couple.value;
    }

    // A distributed load becomes the work-equivalent nodal forces and moments
    // of a linearly varying load over each element it covers.
    for (var e = 0; e < nodes.length - 1; e++) {
      final x0 = nodes[e];
      final x1 = nodes[e + 1];
      final l = x1 - x0;
      var w0 = 0.0;
      var w1 = 0.0;
      // Tested at the midpoint, not at the ends: the mesh puts a node at each
      // end of every distributed load, so an element is wholly in or wholly
      // out. Judging by the ends instead would hand the first element past a
      // load's edge a triangle of it, and quietly add load to the beam.
      final mid = (x0 + x1) / 2;
      for (final load in distributed) {
        if (mid < load.start || mid > load.end) continue;
        w0 += _intensityAt(load, x0);
        w1 += _intensityAt(load, x1);
      }
      if (w0 == 0 && w1 == 0) continue;
      // Downward-positive kN/m to upward-positive N/m.
      w0 = -w0 * 1000;
      w1 = -w1 * 1000;
      f[e * 2] += l * (7 * w0 + 3 * w1) / 20;
      f[e * 2 + 1] += l * l * (3 * w0 + 2 * w1) / 60;
      f[e * 2 + 2] += l * (3 * w0 + 7 * w1) / 20;
      f[e * 2 + 3] += -l * l * (2 * w0 + 3 * w1) / 60;
    }
    return f;
  }

  /// Intensity of [load] at [x], kN/m downward, or zero outside its extent.
  ///
  /// Evaluated at element ends rather than integrated: the mesh has a node at
  /// each end of every distributed load, so no element is ever half covered.
  static double _intensityAt(BeamDistributedLoad load, double x) {
    if (x < load.start - _positionTolerance ||
        x > load.end + _positionTolerance) {
      return 0;
    }
    final length = load.end - load.start;
    if (length <= _positionTolerance) return load.startIntensity;
    final t = ((x - load.start) / length).clamp(0.0, 1.0);
    return load.startIntensity +
        (load.endIntensity - load.startIntensity) * t;
  }

  /// Gaussian elimination without pivoting, restricted to the band.
  ///
  /// The reduced stiffness matrix is symmetric positive definite whenever the
  /// beam is properly restrained, so no pivoting is needed; and because the
  /// nodes are numbered along the beam, no entry sits more than three columns
  /// off the diagonal. That turns an O(n³) solve into an O(n) one, which is
  /// what keeps a 120-element mesh instant on a phone.
  static List<double> _solveBanded(List<List<double>> a, List<double> b) {
    const halfBand = 3;
    final n = b.length;
    if (n == 0) return const [];

    for (var i = 0; i < n; i++) {
      final pivot = a[i][i];
      // A zero pivot means the beam can move without the supports resisting.
      // Validation catches the obvious cases; this catches the rest.
      if (pivot.abs() < 1e-30) {
        throw const FormatException(
            'The supports leave the beam free to move. Check the support '
            'positions.');
      }
      final last = math.min(n - 1, i + halfBand);
      for (var r = i + 1; r <= last; r++) {
        final factor = a[r][i] / pivot;
        if (factor == 0) continue;
        for (var c = i; c <= math.min(n - 1, i + halfBand); c++) {
          a[r][c] -= factor * a[i][c];
        }
        b[r] -= factor * b[i];
      }
    }

    final x = List<double>.filled(n, 0);
    for (var i = n - 1; i >= 0; i--) {
      var sum = b[i];
      for (var c = i + 1; c <= math.min(n - 1, i + halfBand); c++) {
        sum -= a[i][c] * x[c];
      }
      x[i] = sum / a[i][i];
    }
    return x;
  }

  static int _nearestNode(List<double> nodes, double x) {
    var best = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < nodes.length; i++) {
      final distance = (nodes[i] - x).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        best = i;
      }
    }
    return best;
  }

  // -- reactions and internal actions --------------------------------------

  /// Support reactions, recovered as `K·d − F` at the held degrees of freedom.
  static List<BeamReaction> _reactions(
    List<double> nodes,
    double ei,
    List<({double x, double value})> forces,
    List<({double x, double value})> couples,
    List<BeamDistributedLoad> distributed,
    BeamInput input,
    List<double> displacement,
  ) {
    final stiffness = _assembleStiffness(nodes, ei);
    final load = _assembleLoads(nodes, forces, couples, distributed);

    final reactions = <BeamReaction>[];
    for (final support in input.supports) {
      final node = _nearestNode(nodes, support.position);
      double residual(int dof) {
        var sum = 0.0;
        for (var j = 0; j < displacement.length; j++) {
          if (displacement[j] != 0) sum += stiffness[dof][j] * displacement[j];
        }
        return sum - load[dof];
      }

      final force = residual(node * 2);
      final moment =
          support.type == BeamSupportType.fixed ? residual(node * 2 + 1) : 0.0;
      reactions.add(BeamReaction(
        position: nodes[node],
        type: support.type,
        // Back to kN and kN·m. The vertical residual is already upward
        // positive, which is how a reaction is quoted.
        force: force / 1000,
        moment: moment / 1000,
      ));
    }
    return reactions;
  }

  /// Shear, moment and deflection sampled along the beam.
  ///
  /// Shear and moment come from statics on the segment left of the cut rather
  /// than from the element matrices: with the reactions known, that is exact
  /// everywhere, and it puts the discontinuity at a point load exactly where
  /// it belongs instead of smearing it over an element.
  static ({
    List<BeamDiagramPoint> shear,
    List<BeamDiagramPoint> moment,
    List<BeamDiagramPoint> deflection,
  }) _diagrams(
    List<double> nodes,
    List<({double x, double value})> forces,
    List<({double x, double value})> couples,
    List<BeamDistributedLoad> distributed,
    List<BeamReaction> reactions,
    List<double> displacement,
  ) {
    // Every upward force acting on the beam: applied loads and reactions.
    final pointForces = <({double x, double value})>[
      ...forces,
      for (final reaction in reactions)
        (x: reaction.position, value: reaction.force * 1000),
    ];
    final pointCouples = <({double x, double value})>[
      ...couples,
      for (final reaction in reactions)
        if (reaction.moment != 0)
          (x: reaction.position, value: reaction.moment * 1000),
    ];

    double shearAt(double x, {required bool leftOfPoint}) {
      var v = 0.0;
      for (final force in pointForces) {
        final before = leftOfPoint
            ? force.x < x - _positionTolerance
            : force.x <= x + _positionTolerance;
        if (before) v += force.value;
      }
      for (final load in distributed) {
        v += _distributedResultant(load, x).area;
      }
      return v;
    }

    double momentAt(double x, {required bool leftOfPoint}) {
      var m = 0.0;
      for (final force in pointForces) {
        if (force.x <= x + _positionTolerance) {
          // A force acting at the cut has no lever arm, so which side it is
          // counted on makes no difference to the moment.
          m += force.value * (x - force.x);
        }
      }
      for (final couple in pointCouples) {
        // A couple does, though: the moment steps across it by its own size,
        // which is why the wall moment of a cantilever is read just inside
        // the support rather than at it, where the restraining couple would
        // cancel it to zero.
        final before = leftOfPoint
            ? couple.x < x - _positionTolerance
            : couple.x <= x + _positionTolerance;
        if (before) m -= couple.value;
      }
      for (final load in distributed) {
        final r = _distributedResultant(load, x);
        m += r.area * x - r.firstMoment;
      }
      return m;
    }

    final shear = <BeamDiagramPoint>[];
    final moment = <BeamDiagramPoint>[];
    final deflection = <BeamDiagramPoint>[];

    final last = nodes.length - 1;
    for (var i = 0; i < nodes.length; i++) {
      final x = nodes[i];
      // Two samples where a diagram steps — under a point load, over a
      // support, at an applied couple — so it draws as a vertical jump rather
      // than a ramp across the neighbouring element. The two ends take only
      // the sample from inside the beam: outside it, the reaction there has
      // already been counted and every diagram closes to zero, which is
      // equilibrium rather than anything the beam carries.
      if (i > 0) {
        shear.add(BeamDiagramPoint(x, shearAt(x, leftOfPoint: true) / 1000));
        moment.add(
            BeamDiagramPoint(x, momentAt(x, leftOfPoint: true) / 1000));
      }
      if (i < last) {
        shear.add(BeamDiagramPoint(x, shearAt(x, leftOfPoint: false) / 1000));
        moment.add(
            BeamDiagramPoint(x, momentAt(x, leftOfPoint: false) / 1000));
      }
      // Upward-positive metres to downward-positive millimetres.
      deflection.add(BeamDiagramPoint(x, -displacement[i * 2] * 1000));
    }

    return (
      shear: List.unmodifiable(shear),
      moment: List.unmodifiable(moment),
      deflection: List.unmodifiable(deflection),
    );
  }

  /// The part of [load] left of [x]: its resultant, N upward, and its first
  /// moment about the origin, N·m — everything the statics walk needs.
  static ({double area, double firstMoment}) _distributedResultant(
      BeamDistributedLoad load, double x) {
    final a = load.start;
    final b = math.min(load.end, x);
    if (b <= a) return (area: 0, firstMoment: 0);

    // Upward-positive N/m at the two ends of the covered part.
    final wa = -_intensityAt(load, a) * 1000;
    final wb = -_intensityAt(load, b) * 1000;
    final slope = (b - a) <= _positionTolerance ? 0.0 : (wb - wa) / (b - a);

    final area = (b - a) * (wa + wb) / 2;
    // ∫ w(ξ)·ξ dξ over [a, b], written out rather than as area × centroid so
    // that a load summing to zero does not divide by it.
    final firstMoment = wa * (b * b - a * a) / 2 +
        slope *
            ((b * b * b - a * a * a) / 3 - a * (b * b - a * a) / 2);
    return (area: area, firstMoment: firstMoment);
  }

  // -- packaging -----------------------------------------------------------

  static BeamResult _assemble(
    BeamInput input,
    List<BeamReaction> reactions,
    ({
      List<BeamDiagramPoint> shear,
      List<BeamDiagramPoint> moment,
      List<BeamDiagramPoint> deflection,
    }) diagrams,
  ) {
    final maxShear = _extremeByMagnitude(diagrams.shear);
    final sagging = _extremeSigned(diagrams.moment, positive: true);
    final hogging = _extremeSigned(diagrams.moment, positive: false);
    final maxMoment = sagging.value.abs() >= hogging.value.abs()
        ? sagging
        : hogging;
    final maxDeflection = _extremeByMagnitude(diagrams.deflection);

    double? stress;
    final c = input.extremeFibreDistance;
    if (c != null) {
      // kN·m to N·mm is ×1e6; N·mm × mm / mm⁴ is MPa.
      stress = maxMoment.value.abs() * 1e6 * c / input.secondMoment;
    }

    final restraints = input.supports.fold<int>(
        0, (sum, s) => sum + (s.type == BeamSupportType.fixed ? 2 : 1));

    return BeamResult(
      reactions: List.unmodifiable(reactions),
      maximumShear: maxShear,
      maximumSaggingMoment: sagging,
      maximumHoggingMoment: hogging,
      maximumMoment: maxMoment,
      maximumDeflection: maxDeflection,
      bendingStress: stress,
      shear: diagrams.shear,
      moment: diagrams.moment,
      deflection: diagrams.deflection,
      // Two restraints is exactly what plane bending equilibrium supplies;
      // anything more and the reactions depend on how stiff the beam is.
      isDeterminate: restraints <= 2,
    );
  }

  static BeamExtreme _extremeByMagnitude(List<BeamDiagramPoint> points) {
    var best = points.first;
    for (final point in points) {
      if (point.value.abs() > best.value.abs()) best = point;
    }
    return BeamExtreme(best.value, best.x);
  }

  /// The largest value of one sign, or zero at the origin when the diagram
  /// never takes that sign.
  ///
  /// "Never" is judged against the size of the diagram rather than against
  /// zero. A simply supported beam hogs nowhere, but the solve leaves a few
  /// parts in a billion of the opposite sign behind, and reporting those as a
  /// hogging moment of 1e-8 kN·m would be worse than saying none.
  static BeamExtreme _extremeSigned(List<BeamDiagramPoint> points,
      {required bool positive}) {
    var largest = 0.0;
    for (final point in points) {
      largest = math.max(largest, point.value.abs());
    }
    // A tenth of a part per million of the peak. Round-off from the solve
    // lands a little under that; a hogging moment that mattered never would.
    final floor = largest * 1e-7;

    BeamDiagramPoint? best;
    for (final point in points) {
      final qualifies =
          positive ? point.value > floor : point.value < -floor;
      if (!qualifies) continue;
      if (best == null || point.value.abs() > best.value.abs()) best = point;
    }
    return best == null
        ? const BeamExtreme(0, 0)
        : BeamExtreme(best.value, best.x);
  }
}

/// The supports [supportCase] puts on a beam of [span], with the two positions
/// an overhang needs.
List<BeamSupport> supportsFor(
  BeamSupportCase supportCase,
  double span, {
  double? leftSupport,
  double? rightSupport,
}) {
  switch (supportCase) {
    case BeamSupportCase.simplySupported:
      return [
        const BeamSupport(0, BeamSupportType.simple),
        BeamSupport(span, BeamSupportType.simple),
      ];
    case BeamSupportCase.cantileverLeft:
      return [const BeamSupport(0, BeamSupportType.fixed)];
    case BeamSupportCase.cantileverRight:
      return [BeamSupport(span, BeamSupportType.fixed)];
    case BeamSupportCase.overhang:
      return [
        BeamSupport(leftSupport ?? span * 0.2, BeamSupportType.simple),
        BeamSupport(rightSupport ?? span * 0.8, BeamSupportType.simple),
      ];
    case BeamSupportCase.proppedCantilever:
      return [
        const BeamSupport(0, BeamSupportType.fixed),
        BeamSupport(span, BeamSupportType.simple),
      ];
    case BeamSupportCase.fixedFixed:
      return [
        const BeamSupport(0, BeamSupportType.fixed),
        BeamSupport(span, BeamSupportType.fixed),
      ];
  }
}
