import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visuales_uclv/app.dart';
import 'package:visuales_uclv/screens/splash_screen.dart';
import 'package:visuales_uclv/screens/home_screen.dart';

void main() {
  group('Visuales UCLV App Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('Splash screen loads and displays app name', (WidgetTester tester) async {
      await tester.pumpWidget(VisualesApp(prefs: prefs));
      
      // Verify splash screen shows
      expect(find.text('Visuales UCLV'), findsOneWidget);
      expect(find.text('Tu contenido favorito'), findsOneWidget);
      
      // Wait for splash animation and navigation
      await tester.pumpAndSettle();
      
      // Should navigate to home screen
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Home screen displays search bar', (WidgetTester tester) async {
      await tester.pumpWidget(VisualesApp(prefs: prefs));
      await tester.pumpAndSettle();
      
      // Verify search bar is present
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Buscar películas, series...'), findsOneWidget);
    });

    testWidgets('Home screen displays category chips', (WidgetTester tester) async {
      await tester.pumpWidget(VisualesApp(prefs: prefs));
      await tester.pumpAndSettle();
      
      // Verify category chips are present
      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Películas'), findsOneWidget);
      expect(find.text('Series'), findsOneWidget);
      expect(find.text('Documentales'), findsOneWidget);
      expect(find.text('Animados'), findsOneWidget);
    });

    testWidgets('Home screen has bottom navigation', (WidgetTester tester) async {
      await tester.pumpWidget(VisualesApp(prefs: prefs));
      await tester.pumpAndSettle();
      
      // Verify bottom navigation
      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Descargas'), findsOneWidget);
      expect(find.text('Ajustes'), findsOneWidget);
    });

    testWidgets('App theme is configured', (WidgetTester tester) async {
      await tester.pumpWidget(VisualesApp(prefs: prefs));
      
      // Verify MaterialApp is configured
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
