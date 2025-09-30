// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:delivery_app/main.dart';

/**
 * 🧪 TESTS WIDGET DE LA APLICACIÓN
 * 
 * Tests básicos para verificar el funcionamiento de la aplicación
 */

void main() {
  testWidgets('Delivery app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DeliveryApp());

    // Verify that the app loads and shows login screen
    expect(find.text('Delivery App'), findsOneWidget);
    expect(find.text('Inicia sesión para continuar'), findsOneWidget);
  });

  testWidgets('Login form validation works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DeliveryApp());

    // Tap the login button without entering credentials
    await tester.tap(find.text('Iniciar Sesión'));
    await tester.pump();

    // Verify that validation messages appear
    expect(find.text('Por favor ingresa tu email'), findsOneWidget);
  });
}
