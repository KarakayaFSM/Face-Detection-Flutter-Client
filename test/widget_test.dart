// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/main.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  group("MainPage Navigation Tests", () {
    testWidgets("item is deleted from list and file system after swipe",
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      var firstItem = find.widgetWithText(ListTile, "a");

      await tester.drag(firstItem, Offset(500.0, 0.0));

      await tester.pumpAndSettle();

      expect(firstItem, findsNothing);
    });

    testWidgets('item is created on button click', (WidgetTester tester) async {
      /*TODO This test is incomplete
         To complete this test: https://iiro.dev/writing-widget-tests-for-navigation-events/
      */
      await tester.pumpWidget(MyApp());

      //String root = (await getApplicationDocumentsDirectory()).path;

      expect(find.byIcon(Icons.create_new_folder_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.create_new_folder_outlined));

      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), "ahmet");

      expect(find.widgetWithText(TextButton, "OK"), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, "OK"));
      await tester.pump();
    });

  });
}
