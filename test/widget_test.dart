// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:caresight/main.dart';

void main() {
  testWidgets('CareSight app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CareSightApp());

    // Verify that the landing screen loads with the app name
    expect(find.text('CareSight'), findsOneWidget);
    expect(
      find.text('AI-Driven Risk Prediction for Chronic Care Patients'),
      findsOneWidget,
    );
    expect(find.text('Enter Dashboard'), findsOneWidget);

    // Verify the health icon is present
    expect(find.byIcon(Icons.health_and_safety), findsOneWidget);
  });
}
