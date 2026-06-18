// PATH: creaont_flutter/test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // FIXED: MyApp requires both initialRoute and token
    await tester.pumpWidget(
      MyApp(initialRoute: '/login', token: ''),
    );

    // Verify the app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
