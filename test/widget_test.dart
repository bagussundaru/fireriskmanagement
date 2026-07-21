import 'package:flutter_test/flutter_test.dart';

import 'package:fire_risk_flutter/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FireRiskApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'),
        findsNothing); // Removed counter logic, so expect nothing or change test
    expect(find.text('1'), findsNothing);
  });
}
