import 'dart:math';

enum TrussSupport {
  /// No support — a free joint (loads only).
  none,

  /// Pin support — restrains both horizontal and vertical displacement.
  pin,

  /// Roller support that restrains horizontal displacement only
  /// (reaction acts horizontally).
  rollerX,

  /// Roller support that restrains vertical displacement only
  /// (reaction acts vertically). This is the common "roller on the ground"
  /// support seen in most textbook truss diagrams.
  rollerY,
}

class TrussJoint {
  const TrussJoint({
    required this.x,
    required this.y,
    this.support = TrussSupport.none,
    this.loadFx,
    this.loadFy,
  });

  final double x;
  final double y;
  final TrussSupport support;
  final double? loadFx;
  final double? loadFy;
}

class TrussMember {
  const TrussMember({required this.jointA, required this.jointB});

  /// Indices into the joints list this truss was solved with.
  final int jointA;
  final int jointB;
}

class TrussReaction {
  const TrussReaction({
    required this.jointIndex,
    required this.fx,
    required this.fy,
  });

  final int jointIndex;
  final double fx;
  final double fy;
}

class TrussSolution {
  const TrussSolution({required this.memberForces, required this.reactions});

  /// Axial force per member, parallel to the input members list.
  /// Positive = tension, negative = compression.
  final List<double> memberForces;

  final List<TrussReaction> reactions;
}

/// Solves a statically determinate, pin-jointed 2D truss by the method of
/// joints: two equilibrium equations (ΣFx = 0, ΣFy = 0) per joint, assembled
/// into one global linear system and solved by Gaussian elimination with
/// partial pivoting.
abstract final class TrussSolver {
  static TrussSolution solve(
    List<TrussJoint> joints,
    List<TrussMember> members,
  ) {
    if (joints.length < 2) {
      throw const FormatException('A truss needs at least 2 joints.');
    }
    if (members.isEmpty) {
      throw const FormatException('Add at least one member.');
    }
    for (final member in members) {
      if (member.jointA < 0 ||
          member.jointA >= joints.length ||
          member.jointB < 0 ||
          member.jointB >= joints.length) {
        throw const FormatException('A member references an unknown joint.');
      }
      if (member.jointA == member.jointB) {
        throw const FormatException(
            'A member cannot connect a joint to itself.');
      }
      final a = joints[member.jointA];
      final b = joints[member.jointB];
      if (a.x == b.x && a.y == b.y) {
        throw const FormatException(
            'Two joints share the same location — a member between them has zero length.');
      }
    }

    // Collect reaction unknowns: (jointIndex, isX) pairs.
    final reactionDofs = <(int jointIndex, bool isX)>[];
    for (var j = 0; j < joints.length; j++) {
      switch (joints[j].support) {
        case TrussSupport.pin:
          reactionDofs.add((j, true));
          reactionDofs.add((j, false));
        case TrussSupport.rollerX:
          reactionDofs.add((j, true));
        case TrussSupport.rollerY:
          reactionDofs.add((j, false));
        case TrussSupport.none:
          break;
      }
    }

    final n = joints.length;
    final m = members.length;
    final r = reactionDofs.length;
    final unknowns = m + r;
    final equations = 2 * n;

    if (unknowns != equations) {
      final relation = unknowns < equations
          ? 'fewer unknowns than equations — the truss is an unstable mechanism'
          : 'more unknowns than equations — the truss is statically indeterminate';
      throw FormatException(
          'm + r = $unknowns, 2n = $equations: $relation. Method of joints requires m + r = 2n.');
    }

    // Build the augmented matrix [A | b], size `equations` x (unknowns + 1).
    final a = List.generate(equations, (_) => List<double>.filled(unknowns + 1, 0));

    for (var mi = 0; mi < m; mi++) {
      final member = members[mi];
      final ja = joints[member.jointA];
      final jb = joints[member.jointB];
      final dx = jb.x - ja.x;
      final dy = jb.y - ja.y;
      final length = sqrt(dx * dx + dy * dy);
      final cosA = dx / length;
      final sinA = dy / length;

      // Member pulls jointA toward jointB when in tension.
      a[2 * member.jointA][mi] += cosA;
      a[2 * member.jointA + 1][mi] += sinA;
      // ...and pulls jointB toward jointA (opposite direction) when in tension.
      a[2 * member.jointB][mi] += -cosA;
      a[2 * member.jointB + 1][mi] += -sinA;
    }

    for (var ri = 0; ri < r; ri++) {
      final (jointIndex, isX) = reactionDofs[ri];
      a[2 * jointIndex + (isX ? 0 : 1)][m + ri] = 1;
    }

    for (var j = 0; j < n; j++) {
      a[2 * j][unknowns] = -(joints[j].loadFx ?? 0);
      a[2 * j + 1][unknowns] = -(joints[j].loadFy ?? 0);
    }

    final x = _solveLinearSystem(a, equations, unknowns);

    final memberForces = x.sublist(0, m);
    final reactions = <TrussReaction>[];
    for (var j = 0; j < n; j++) {
      if (joints[j].support == TrussSupport.none) continue;
      double fx = 0, fy = 0;
      for (var ri = 0; ri < r; ri++) {
        final (jointIndex, isX) = reactionDofs[ri];
        if (jointIndex != j) continue;
        if (isX) {
          fx = x[m + ri];
        } else {
          fy = x[m + ri];
        }
      }
      reactions.add(TrussReaction(jointIndex: j, fx: fx, fy: fy));
    }

    return TrussSolution(memberForces: memberForces, reactions: reactions);
  }

  /// Gaussian elimination with partial pivoting. `a` is the augmented
  /// [A | b] matrix (equations rows, unknowns + 1 columns); returns the
  /// solution vector of length `unknowns`.
  static List<double> _solveLinearSystem(
    List<List<double>> a,
    int equations,
    int unknowns,
  ) {
    const epsilon = 1e-9;
    for (var col = 0; col < unknowns; col++) {
      var pivotRow = col;
      var pivotValue = a[col][col].abs();
      for (var row = col + 1; row < equations; row++) {
        if (a[row][col].abs() > pivotValue) {
          pivotRow = row;
          pivotValue = a[row][col].abs();
        }
      }
      if (pivotValue < epsilon) {
        throw const FormatException(
            'Truss is unstable (mechanism) — the joint/member/support arrangement cannot resist load on some path.');
      }
      if (pivotRow != col) {
        final tmp = a[col];
        a[col] = a[pivotRow];
        a[pivotRow] = tmp;
      }
      for (var row = 0; row < equations; row++) {
        if (row == col) continue;
        final factor = a[row][col] / a[col][col];
        if (factor == 0) continue;
        for (var k = col; k <= unknowns; k++) {
          a[row][k] -= factor * a[col][k];
        }
      }
    }
    return List.generate(unknowns, (i) => a[i][unknowns] / a[i][i]);
  }
}
