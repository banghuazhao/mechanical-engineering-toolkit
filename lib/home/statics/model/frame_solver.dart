import 'dart:math' as math;

/// How a joint is held to the ground.
enum FrameSupport {
  none,

  /// Restrains both translations.
  pin,

  /// A roller on a vertical surface: the reaction is horizontal.
  rollerX,

  /// A roller on a horizontal surface: the reaction is vertical.
  rollerY,

  /// Built in: both translations and the rotation. Only a joint on a single
  /// member can be fixed — a pin that several members turn on cannot also
  /// stop them all turning.
  fixed,
}

/// A point of the structure: where members meet, where a load or support
/// acts, or a corner of a bent member.
class FrameJoint {
  const FrameJoint({
    required this.x,
    required this.y,
    this.support = FrameSupport.none,
    this.fx = 0,
    this.fy = 0,
    this.couple = 0,
  });

  /// Position — m.
  final double x, y;

  final FrameSupport support;

  /// Applied force — N. At a joint several members share, the load acts on
  /// the pin itself.
  final double fx, fy;

  /// Applied couple, counter-clockwise positive — N·m. Only on a joint that
  /// belongs to one member, since a frictionless pin cannot pass a couple.
  final double couple;
}

/// A rigid member through two or more joints, listed in order along it.
///
/// Two joints is a straight bar; three or more is a bent or branched member —
/// an L-shaped lever, the arm of a pair of pliers — that stays rigid between
/// them. The order only matters for drawing.
class FrameMember {
  const FrameMember(this.joints);

  final List<int> joints;
}

/// The force a joint's pin exerts on one member.
class PinForce {
  const PinForce({required this.joint, required this.fx, required this.fy});

  final int joint;

  /// N.
  final double fx, fy;

  double get magnitude => math.sqrt(fx * fx + fy * fy);

  /// Direction, counter-clockwise from +x — degrees.
  double get angleDegrees => math.atan2(fy, fx) * 180 / math.pi;
}

class FrameReaction {
  const FrameReaction({
    required this.joint,
    required this.support,
    required this.fx,
    required this.fy,
    this.moment = 0,
  });

  final int joint;
  final FrameSupport support;

  /// N.
  final double fx, fy;

  /// N·m, counter-clockwise positive. Zero unless [support] is fixed.
  final double moment;
}

class FrameSolution {
  const FrameSolution({
    required this.reactions,
    required this.memberForces,
    required this.unknowns,
    required this.equations,
  });

  final List<FrameReaction> reactions;

  /// Per member, in member order, the force each of its joints puts on it.
  final List<List<PinForce>> memberForces;

  final int unknowns, equations;

  /// The axial force in [member] if it is a two-force member — a straight
  /// bar with nothing acting on it between its two pins — positive in
  /// tension. Null for any other member.
  double? axialForce(
      int member, List<FrameJoint> joints, List<FrameMember> members) {
    final m = members[member];
    if (m.joints.length != 2) return null;
    final a = joints[m.joints[0]], b = joints[m.joints[1]];
    if (a.couple != 0 || b.couple != 0) return null;
    if (a.support == FrameSupport.fixed || b.support == FrameSupport.fixed) {
      return null;
    }
    final dx = b.x - a.x, dy = b.y - a.y;
    final length = math.sqrt(dx * dx + dy * dy);
    // The force at B, resolved along A→B: pulling B away from A is tension.
    final atB = memberForces[member][1];
    return (atB.fx * dx + atB.fy * dy) / length;
  }
}

/// Solves a statically determinate planar frame or machine by taking it
/// apart: every member is a rigid body in equilibrium (three equations), and
/// every joint is a pin in equilibrium with the members it connects, the
/// loads on it and its support (two equations). Solving the system at once
/// gives the pin force on each member at each of its joints — the answer a
/// frame problem asks for — along with the support reactions.
///
/// Treating each pin as a body of its own is what makes the method general:
/// a pin joining three members, a load applied at a pin, and a support at a
/// pin all fall out of the same two equations, with no special cases.
abstract final class FrameSolver {
  static FrameSolution solve(
      List<FrameJoint> joints, List<FrameMember> members) {
    if (joints.length < 2) {
      throw const FormatException('A frame needs at least two joints.');
    }
    if (members.isEmpty) {
      throw const FormatException('Add at least one member.');
    }

    // Which members meet at each joint.
    final membersAt = List.generate(joints.length, (_) => <int>[]);
    for (var b = 0; b < members.length; b++) {
      final list = members[b].joints;
      if (list.length < 2) {
        throw FormatException('Member ${b + 1} needs at least two joints.');
      }
      if (list.toSet().length != list.length) {
        throw FormatException('Member ${b + 1} lists a joint twice.');
      }
      for (final j in list) {
        if (j < 0 || j >= joints.length) {
          throw FormatException('Member ${b + 1} names a missing joint.');
        }
        membersAt[j].add(b);
      }
    }
    for (var j = 0; j < joints.length; j++) {
      final joint = joints[j];
      if (membersAt[j].isEmpty) {
        throw FormatException('J${j + 1} is not on any member.');
      }
      if (joint.support == FrameSupport.fixed && membersAt[j].length > 1) {
        throw FormatException(
            'J${j + 1} is fixed, but a fixed support can hold only one member.');
      }
      if (joint.couple != 0 && membersAt[j].length > 1) {
        throw FormatException(
            'J${j + 1} is a pin between members and cannot take a couple; '
            'apply it at a joint on one member.');
      }
    }
    for (var b = 0; b < members.length; b++) {
      final list = members[b].joints;
      for (var i = 0; i < list.length; i++) {
        for (var k = i + 1; k < list.length; k++) {
          final p = joints[list[i]], q = joints[list[k]];
          if (p.x == q.x && p.y == q.y) {
            throw FormatException(
                'J${list[i] + 1} and J${list[k] + 1} on member ${b + 1} are '
                'at the same point.');
          }
        }
      }
    }

    // Unknowns: two per member–joint attachment, then the reactions.
    final attachment = <(int, int), int>{};
    var unknowns = 0;
    for (var b = 0; b < members.length; b++) {
      for (final j in members[b].joints) {
        attachment[(b, j)] = unknowns;
        unknowns += 2;
      }
    }
    final reactionIndex = <int, int>{};
    for (var j = 0; j < joints.length; j++) {
      final count = switch (joints[j].support) {
        FrameSupport.none => 0,
        FrameSupport.pin => 2,
        FrameSupport.rollerX || FrameSupport.rollerY => 1,
        FrameSupport.fixed => 3,
      };
      if (count == 0) continue;
      reactionIndex[j] = unknowns;
      unknowns += count;
    }

    final equations = 3 * members.length + 2 * joints.length;
    if (unknowns != equations) {
      final kind = unknowns < equations
          ? 'fewer unknowns than equations, so it is a mechanism and will move'
          : 'more unknowns than equations, so it is statically indeterminate';
      throw FormatException(
          '$unknowns unknowns against $equations equations: $kind. Equilibrium '
          'alone solves only a frame where the two are equal.');
    }

    final a =
        List.generate(equations, (_) => List<double>.filled(unknowns + 1, 0));
    // Rows: member b is 3b, 3b + 1, 3b + 2; joint j is 3B + 2j and 3B + 2j + 1.
    final jointRow0 = 3 * members.length;

    for (var b = 0; b < members.length; b++) {
      // Moments about the member's first joint keep the numbers the size of
      // the member rather than of its distance from the origin.
      final ref = joints[members[b].joints.first];
      for (final j in members[b].joints) {
        final col = attachment[(b, j)]!;
        final p = joints[j];
        final rx = p.x - ref.x, ry = p.y - ref.y;
        // ΣFx, ΣFy on the member: the pin forces on it.
        a[3 * b][col] += 1;
        a[3 * b + 1][col + 1] += 1;
        // ΣM: r × F.
        a[3 * b + 2][col] += -ry;
        a[3 * b + 2][col + 1] += rx;
        // The pin feels the equal and opposite force.
        a[jointRow0 + 2 * j][col] -= 1;
        a[jointRow0 + 2 * j + 1][col + 1] -= 1;

        // A couple, or a fixed support's moment, acts on the one member at
        // that joint — validated above.
        a[3 * b + 2][unknowns] -= p.couple;
        if (p.support == FrameSupport.fixed) {
          a[3 * b + 2][reactionIndex[j]! + 2] += 1;
        }
      }
    }

    for (var j = 0; j < joints.length; j++) {
      final joint = joints[j];
      final row = jointRow0 + 2 * j;
      a[row][unknowns] -= joint.fx;
      a[row + 1][unknowns] -= joint.fy;
      final r = reactionIndex[j];
      switch (joint.support) {
        case FrameSupport.none:
          break;
        case FrameSupport.pin:
        case FrameSupport.fixed:
          a[row][r!] = 1;
          a[row + 1][r + 1] = 1;
        case FrameSupport.rollerX:
          a[row][r!] = 1;
        case FrameSupport.rollerY:
          a[row + 1][r!] = 1;
      }
    }

    final x = _solve(a, equations, unknowns);

    final memberForces = [
      for (var b = 0; b < members.length; b++)
        [
          for (final j in members[b].joints)
            PinForce(
              joint: j,
              fx: x[attachment[(b, j)]!],
              fy: x[attachment[(b, j)]! + 1],
            ),
        ],
    ];

    final reactions = <FrameReaction>[];
    for (var j = 0; j < joints.length; j++) {
      final r = reactionIndex[j];
      if (r == null) continue;
      final support = joints[j].support;
      reactions.add(FrameReaction(
        joint: j,
        support: support,
        fx: support == FrameSupport.rollerY ? 0 : x[r],
        fy: switch (support) {
          FrameSupport.rollerY => x[r],
          FrameSupport.rollerX => 0,
          _ => x[r + 1],
        },
        moment: support == FrameSupport.fixed ? x[r + 2] : 0,
      ));
    }

    return FrameSolution(
      reactions: reactions,
      memberForces: memberForces,
      unknowns: unknowns,
      equations: equations,
    );
  }

  /// Gaussian elimination with partial pivoting on the augmented matrix.
  static List<double> _solve(List<List<double>> a, int n, int unknowns) {
    // Scale-aware singularity test: a pivot this small relative to the
    // largest coefficient means the geometry, not the loads, has failed.
    var largest = 0.0;
    for (final row in a) {
      for (var k = 0; k < unknowns; k++) {
        largest = math.max(largest, row[k].abs());
      }
    }
    final epsilon = largest * 1e-10;
    for (var col = 0; col < unknowns; col++) {
      var pivot = col;
      for (var row = col + 1; row < n; row++) {
        if (a[row][col].abs() > a[pivot][col].abs()) pivot = row;
      }
      if (a[pivot][col].abs() <= epsilon) {
        throw const FormatException(
            'The frame is unstable: the counts balance, but the arrangement '
            'of members and supports cannot resist some load. Check for '
            'three reactions that meet at a point or are all parallel.');
      }
      if (pivot != col) {
        final tmp = a[col];
        a[col] = a[pivot];
        a[pivot] = tmp;
      }
      for (var row = 0; row < n; row++) {
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
