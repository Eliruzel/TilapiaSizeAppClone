import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tilapiasizeclone/widgets/mobile_farmer_shell.dart';

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(640, 360),
  ]) {
    testWidgets('Mobile tabs fit $size without fabricated data', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(useMaterial3: true),
          home: const MobileFarmerShell(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(Scrollable), findsNothing);
      expect(find.text('No batches to display'), findsOneWidget);

      for (final title in ['My Batches', 'History', 'Profile']) {
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(title),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(NavigationBar), findsOneWidget);
        if (title == 'Profile') {
          expect(find.byType(Scrollable), findsNothing);
          expect(find.text('Your profile'), findsOneWidget);
        } else {
          expect(find.byType(ListView), findsOneWidget);
        }
      }
    });
  }

  testWidgets('Upload overlay does not create fake results', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: const MobileFarmerShell(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Images'));
    await tester.pumpAndSettle();
    final analyze = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Analyze Images'),
    );
    expect(analyze.onPressed, isNull);
    expect(find.text('No images selected'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
