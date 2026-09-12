import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
  });

  test('keeps the newest maxEntries calculations and evicts the oldest', () {
    final history = ToolHistory();
    for (var i = 0; i < ToolHistory.maxEntries + 3; i++) {
      history.record(100, inputs: {'n': '$i'});
    }

    final entries = history.entries;
    expect(entries, hasLength(ToolHistory.maxEntries));
    // Newest first: the last one recorded leads, and the three oldest are
    // the ones that went.
    expect(entries.first.inputs!['n'], '${ToolHistory.maxEntries + 2}');
    expect(entries.last.inputs!['n'], '3');
  });

  test('keeps far more than the fifty it used to', () {
    // The Premium copy promises a number; this is the floor that makes
    // "your last N calculations" worth saying.
    expect(ToolHistory.maxEntries, greaterThanOrEqualTo(500));
  });
}
