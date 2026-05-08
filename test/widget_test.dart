import 'package:flutter_test/flutter_test.dart';

import 'package:elderly_companion_flutter/src/rafeeq_app.dart';

void main() {
  testWidgets('Rafeeq app starts on welcome screen', (tester) async {
    await tester.pumpWidget(const RafeeqApp());

    expect(find.byType(RafeeqApp), findsOneWidget);
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('Can open elderly login screen', (tester) async {
    await tester.pumpWidget(const RafeeqApp());

    final startButton = find.byType(PrimaryButton).first;
    await tester.tap(startButton);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
