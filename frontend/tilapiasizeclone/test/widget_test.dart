import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tilapiasizeclone/app.dart';

void main() {
  testWidgets(
    'TilapiaSize app starts correctly',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const TilapiaSizeApp(),
      );

      expect(
        find.byType(MaterialApp),
        findsOneWidget,
      );
    },
  );
}
