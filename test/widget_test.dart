// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/Project.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  group("MainPage CRUD Tests", () {
    testWidgets("item is deleted from list and file system after swipe",
        (WidgetTester tester) async {
      await tester.pumpWidget(FaceDetectionProject());

      var firstItem = find.widgetWithText(ListTile, "a");

      await tester.drag(firstItem, Offset(500.0, 0.0));

      await tester.pumpAndSettle();

      expect(firstItem, findsNothing);
    });

    testWidgets('item is created on button click', (WidgetTester tester) async {
      /*TODO This test is incomplete
         To complete this test: https://iiro.dev/writing-widget-tests-for-navigation-events/
      */
      await tester.pumpWidget(FaceDetectionProject());

      expect(find.byIcon(Icons.create_new_folder_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.create_new_folder_outlined));

      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      String folderName = "ahmet";
      await tester.enterText(find.byType(TextField), folderName);

      expect(find.widgetWithText(TextButton, "OK"), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, "OK"));
      await tester.pump();

      var root = (await getApplicationDocumentsDirectory()).path;

      expect(await Directory("$root/$folderName").exists(), true);
    });
  });
}
