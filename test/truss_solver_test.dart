import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/home/statics/model/truss_solver.dart';

void main() {
  group('TrussSolver', () {
    test('symmetric triangular truss with an apex load matches hand analysis',
        () {
      // Classic statics textbook setup: pin at A(0,0), roller at B(4,0),
      // apex C(2,3) carries a 1000 N downward load. By symmetry (isosceles
      // triangle, load on the axis of symmetry) Ay = By = 500 N, and the two
      // sloped members carry equal compressive force.
      final joints = [
        const TrussJoint(x: 0, y: 0, support: TrussSupport.pin), // A
        const TrussJoint(x: 4, y: 0, support: TrussSupport.rollerY), // B
        const TrussJoint(x: 2, y: 3, loadFy: -1000), // C
      ];
      final members = [
        const TrussMember(jointA: 0, jointB: 1), // AB
        const TrussMember(jointA: 1, jointB: 2), // BC
        const TrussMember(jointA: 0, jointB: 2), // AC
      ];

      final solution = TrussSolver.solve(joints, members);

      final expectedSloped = -500 * sqrt(13) / 3;
      expect(solution.memberForces[0], closeTo(1000 / 3, 1e-6)); // AB, tension
      expect(solution.memberForces[1], closeTo(expectedSloped, 1e-6)); // BC
      expect(solution.memberForces[2], closeTo(expectedSloped, 1e-6)); // AC

      final reactionA =
          solution.reactions.firstWhere((r) => r.jointIndex == 0);
      final reactionB =
          solution.reactions.firstWhere((r) => r.jointIndex == 1);
      expect(reactionA.fx, closeTo(0, 1e-6));
      expect(reactionA.fy, closeTo(500, 1e-6));
      expect(reactionB.fy, closeTo(500, 1e-6));
    });

    test('global equilibrium holds: reactions balance the applied load', () {
      final joints = [
        const TrussJoint(x: 0, y: 0, support: TrussSupport.pin),
        const TrussJoint(x: 4, y: 0, support: TrussSupport.rollerY),
        const TrussJoint(x: 2, y: 3, loadFy: -1000),
      ];
      final members = [
        const TrussMember(jointA: 0, jointB: 1),
        const TrussMember(jointA: 1, jointB: 2),
        const TrussMember(jointA: 0, jointB: 2),
      ];

      final solution = TrussSolver.solve(joints, members);
      final totalFy =
          solution.reactions.fold<double>(0, (sum, r) => sum + r.fy) - 1000;
      expect(totalFy, closeTo(0, 1e-6));
    });

    test('too few members (mechanism) is rejected', () {
      final joints = [
        const TrussJoint(x: 0, y: 0, support: TrussSupport.pin),
        const TrussJoint(x: 4, y: 0, support: TrussSupport.rollerY),
        const TrussJoint(x: 2, y: 3, loadFy: -1000),
      ];
      // Missing member AC: 2 members + 3 reaction dofs = 5 unknowns,
      // but 2*3 = 6 equations -> unstable.
      final members = [
        const TrussMember(jointA: 0, jointB: 1),
        const TrussMember(jointA: 1, jointB: 2),
      ];

      expect(() => TrussSolver.solve(joints, members),
          throwsA(isA<FormatException>()));
    });

    test('too many members (indeterminate) is rejected', () {
      final joints = [
        const TrussJoint(x: 0, y: 0, support: TrussSupport.pin),
        const TrussJoint(x: 4, y: 0, support: TrussSupport.rollerY),
        const TrussJoint(x: 2, y: 3, loadFy: -1000),
        const TrussJoint(x: 2, y: -3),
      ];
      // Two triangles sharing edge AB, all 5 members present -> 5 members +
      // 3 reaction dofs = 8 unknowns vs 2*4 = 8 equations... make it
      // indeterminate by adding a redundant diagonal too.
      final members = [
        const TrussMember(jointA: 0, jointB: 1),
        const TrussMember(jointA: 1, jointB: 2),
        const TrussMember(jointA: 0, jointB: 2),
        const TrussMember(jointA: 0, jointB: 3),
        const TrussMember(jointA: 1, jointB: 3),
        const TrussMember(jointA: 2, jointB: 3),
      ];

      expect(() => TrussSolver.solve(joints, members),
          throwsA(isA<FormatException>()));
    });
  });
}
