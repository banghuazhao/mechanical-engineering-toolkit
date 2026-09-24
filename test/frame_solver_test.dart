import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/favorites.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/recorded_inputs.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects.dart';
import 'package:mechanical_engineering_toolkit/home/statics/model/frame_solver.dart';
import 'package:mechanical_engineering_toolkit/home/statics/page/frame_analysis_page.dart';
import 'package:mechanical_engineering_toolkit/home/statics/page/frame_analysis_result_page.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('a two-bar bracket reduces to two-force members', () {
    // A horizontal bar from a wall pin at A to B, braced by a strut from C,
    // 3 m above A, down to B. 10 kN hangs from the pin at B.
    const joints = [
      FrameJoint(x: 0, y: 0, support: FrameSupport.pin), // A
      FrameJoint(x: 4, y: 0, fy: -10000), // B
      FrameJoint(x: 0, y: 3, support: FrameSupport.pin), // C
    ];
    const members = [
      FrameMember([0, 1]),
      FrameMember([2, 1]),
    ];
    final s = FrameSolver.solve(joints, members);
    expect(s.unknowns, s.equations);

    // Pin B: the strut's vertical component carries the whole load.
    expect(s.axialForce(1, joints, members), closeTo(16666.67, 0.01));
    expect(s.axialForce(0, joints, members), closeTo(-13333.33, 0.01));

    final a = s.reactions.firstWhere((r) => r.joint == 0);
    final c = s.reactions.firstWhere((r) => r.joint == 2);
    expect(a.fx, closeTo(13333.33, 0.01));
    expect(a.fy, closeTo(0, 1e-6));
    expect(c.fx, closeTo(-13333.33, 0.01));
    expect(c.fy, closeTo(10000, 0.01));
  });

  test('a lever on a strut: pin forces on a three-joint member', () {
    // Member ABC along the x-axis, pinned at A; strut from a ground pin at
    // D (0, 2) to B (2, 0); 6 kN down at the free end C (4, 0). Worked by
    // hand: T = 24/√2 kN in the strut, A = (12, −6) kN, D = (−12, 12) kN.
    const joints = [
      FrameJoint(x: 0, y: 0, support: FrameSupport.pin), // A
      FrameJoint(x: 2, y: 0), // B
      FrameJoint(x: 4, y: 0, fy: -6000), // C
      FrameJoint(x: 0, y: 2, support: FrameSupport.pin), // D
    ];
    const members = [
      FrameMember([0, 1, 2]),
      FrameMember([3, 1]),
    ];
    final s = FrameSolver.solve(joints, members);

    expect(s.axialForce(1, joints, members), closeTo(24000 / math.sqrt2, 0.01));
    // The three-joint lever is no two-force member.
    expect(s.axialForce(0, joints, members), isNull);

    final onLeverAtB = s.memberForces[0][1];
    expect(onLeverAtB.joint, 1);
    expect(onLeverAtB.fx, closeTo(-12000, 0.01));
    expect(onLeverAtB.fy, closeTo(12000, 0.01));

    final a = s.reactions.firstWhere((r) => r.joint == 0);
    expect(a.fx, closeTo(12000, 0.01));
    expect(a.fy, closeTo(-6000, 0.01));
    final d = s.reactions.firstWhere((r) => r.joint == 3);
    expect(d.fx, closeTo(-12000, 0.01));
    expect(d.fy, closeTo(12000, 0.01));
  });

  test('a fixed support takes a moment, and a couple is carried', () {
    // A 2 m cantilever with 5 kN down at the tip and a 1 kN·m couple.
    const joints = [
      FrameJoint(x: 0, y: 0, support: FrameSupport.fixed),
      FrameJoint(x: 2, y: 0, fy: -5000, couple: 1000),
    ];
    final s = FrameSolver.solve(joints, const [
      FrameMember([0, 1])
    ]);
    final wall = s.reactions.single;
    expect(wall.fy, closeTo(5000, 1e-6));
    expect(wall.fx, closeTo(0, 1e-6));
    // ΣM about the wall: M − 5000·2 + 1000 = 0.
    expect(wall.moment, closeTo(9000, 1e-6));
  });

  test('the whole structure stays in equilibrium', () {
    // A three-hinged frame: legs ACD and BCE crossing at a pin C, both feet
    // pinned (on a roller it would fold), a load on each leg and on the
    // crossing pin.
    const joints = [
      FrameJoint(x: 0, y: 0, support: FrameSupport.pin), // A
      FrameJoint(x: 4, y: 0, support: FrameSupport.pin), // B
      FrameJoint(x: 2, y: 2, fx: 300, fy: -800), // C, shared
      FrameJoint(x: 3, y: 3, fy: -500), // D, on ACD only
      FrameJoint(x: 1, y: 3, fx: 200), // E, on BCE only
    ];
    const members = [
      FrameMember([0, 2, 3]), // A–C–D
      FrameMember([1, 2, 4]), // B–C–E
    ];
    final s = FrameSolver.solve(joints, members);
    var sumX = 0.0, sumY = 0.0, sumM = 0.0;
    for (final j in joints) {
      sumX += j.fx;
      sumY += j.fy;
      sumM += j.x * j.fy - j.y * j.fx;
    }
    for (final r in s.reactions) {
      final j = joints[r.joint];
      sumX += r.fx;
      sumY += r.fy;
      sumM += j.x * r.fy - j.y * r.fx + r.moment;
    }
    expect(sumX, closeTo(0, 1e-6));
    expect(sumY, closeTo(0, 1e-6));
    expect(sumM, closeTo(0, 1e-6));

    // Each member on its own is in equilibrium under its pin forces.
    for (final forces in s.memberForces) {
      expect(forces.fold<double>(0, (t, p) => t + p.fx), closeTo(0, 1e-6));
      expect(forces.fold<double>(0, (t, p) => t + p.fy), closeTo(0, 1e-6));
    }
  });

  group('refuses', () {
    test('a mechanism', () {
      expect(
        () => FrameSolver.solve(const [
          FrameJoint(x: 0, y: 0, support: FrameSupport.rollerY),
          FrameJoint(x: 2, y: 0, support: FrameSupport.rollerY),
        ], const [
          FrameMember([0, 1])
        ]),
        throwsA(isA<FormatException>()
            .having((e) => e.message, 'message', contains('mechanism'))),
      );
    });

    test('an indeterminate frame', () {
      expect(
        () => FrameSolver.solve(const [
          FrameJoint(x: 0, y: 0, support: FrameSupport.fixed),
          FrameJoint(x: 2, y: 0, support: FrameSupport.pin),
        ], const [
          FrameMember([0, 1])
        ]),
        throwsA(isA<FormatException>()
            .having((e) => e.message, 'message', contains('indeterminate'))),
      );
    });

    test('three parallel reactions, which count right but cannot stand', () {
      expect(
        () => FrameSolver.solve(const [
          FrameJoint(x: 0, y: 0, support: FrameSupport.rollerY),
          FrameJoint(x: 2, y: 0, support: FrameSupport.rollerY),
          FrameJoint(x: 4, y: 0, support: FrameSupport.rollerY, fx: 1),
        ], const [
          FrameMember([0, 1, 2])
        ]),
        throwsA(isA<FormatException>()
            .having((e) => e.message, 'message', contains('unstable'))),
      );
    });

    test('a couple on a pin between members', () {
      expect(
        () => FrameSolver.solve(const [
          FrameJoint(x: 0, y: 0, support: FrameSupport.pin),
          FrameJoint(x: 1, y: 0, couple: 5),
          FrameJoint(x: 2, y: 0, support: FrameSupport.pin),
        ], const [
          FrameMember([0, 1]),
          FrameMember([1, 2]),
        ]),
        throwsFormatException,
      );
    });

    test('a joint on no member', () {
      expect(
        () => FrameSolver.solve(const [
          FrameJoint(x: 0, y: 0, support: FrameSupport.fixed),
          FrameJoint(x: 1, y: 0),
          FrameJoint(x: 5, y: 5),
        ], const [
          FrameMember([0, 1])
        ]),
        throwsFormatException,
      );
    });
  });

  group('the page', () {
    // The lever on a strut, as the page records it.
    const lever = {
      'J0 x': '0.0',
      'J0 y': '0.0',
      'J0 support': 'pin',
      'J0 Fx': '',
      'J0 Fy': '',
      'J0 M': '',
      'J1 x': '2.0',
      'J1 y': '0.0',
      'J1 support': 'none',
      'J1 Fx': '',
      'J1 Fy': '',
      'J1 M': '',
      'J2 x': '4.0',
      'J2 y': '0.0',
      'J2 support': 'none',
      'J2 Fx': '',
      'J2 Fy': '-6000.0',
      'J2 M': '',
      'J3 x': '0.0',
      'J3 y': '2.0',
      'J3 support': 'pin',
      'J3 Fx': '',
      'J3 Fy': '',
      'J3 M': '',
      'Member1': '0,1,2',
      'Member2': '3,1',
    };

    Future<ToolHistory> pumpPage(WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      await SharedPreferencesHelper.init();
      final history = ToolHistory();
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => RemoveAdsService()),
          ChangeNotifierProvider(create: (_) => Favorites()),
          ChangeNotifierProvider(create: (_) => NumberPrecisionHelper()),
          ChangeNotifierProvider(create: (_) => UnitSystemPreference()),
          ChangeNotifierProvider.value(value: history),
          ChangeNotifierProvider(create: (_) => SavedProjects()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: const FrameAnalysisPage(
            title: 'Frames and Machines',
            toolId: 404,
            initialInputs: lever,
          ),
        ),
      ));
      await tester.pumpAndSettle();
      return history;
    }

    testWidgets('restores a frame, solves it, and records it back the same',
        (tester) async {
      final history = await pumpPage(tester);
      await tester.scrollUntilVisible(
          find.byKey(const Key('addFrameMember')), 300,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('Along the member: J1 → J2 → J3'), findsOneWidget);

      await tester.tap(find.byKey(const Key('calculateButton')));
      await tester.pumpAndSettle();

      expect(find.byType(FrameAnalysisResultPage), findsOneWidget);
      final results = find.descendant(
          of: find.byType(FrameAnalysisResultPage),
          matching: find.byType(Scrollable));
      await tester.scrollUntilVisible(
          find.text('Two-force member: tension'), 300,
          scrollable: results.first);
      expect(find.text('Two-force member: tension'), findsOneWidget);
      expect(history.entries.first.inputs, lever);
    });

    testWidgets('a history row reads members as joints, not indices',
        (tester) async {
      await pumpPage(tester);
      final context = tester.element(find.byType(FrameAnalysisPage));
      final shown = displayInputs(context, lever);
      expect(shown['Member 1'], 'J1 → J2 → J3');
      expect(shown['Member 2'], 'J4 → J2');
    });

    testWidgets('says why a frame will not solve', (tester) async {
      await pumpPage(tester);
      await tester.scrollUntilVisible(
          find.byKey(const Key('addFrameMember')), 300,
          scrollable: find.byType(Scrollable).first);
      // Take the strut away, leaving its ground pin J4 on nothing. Its
      // remove button is the last one; bring it up clear of the Calculate
      // button floating over the bottom of the list.
      final removeStrut = find.byIcon(Icons.remove_circle_outline_rounded).last;
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
      await tester.pumpAndSettle();
      await tester.tap(removeStrut);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('calculateButton')));
      await tester.pumpAndSettle();
      expect(find.text('J4 is not on any member.'), findsOneWidget);
      expect(find.byType(FrameAnalysisResultPage), findsNothing);
    });
  });
}
