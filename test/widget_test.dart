// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutterv2_onboarding/main.dart';

void main() {
  testWidgets('App shows onboarding flow', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    expect(
      find.text('Create a prototype in just\na few minutes'),
      findsOneWidget,
    );

    await tester.tap(find.text('Next').first);
    await tester.pumpAndSettle();

    expect(find.text('Personalise your\nexperience'), findsOneWidget);
    expect(find.text('User Interface'), findsOneWidget);
    expect(find.text('User Research'), findsOneWidget);

    await tester.drag(find.byType(Scrollable).last, const Offset(0, -320));
    await tester.pumpAndSettle();

    expect(find.text('Design Systems'), findsOneWidget);
  });
}
