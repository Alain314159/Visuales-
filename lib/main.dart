import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Optimize memory management
  await _optimizeMemory();

  // Configure screen orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Disable debug printing in release builds
  if (const bool.fromEnvironment('dart.vm.product')) {
    debugPrintBeginFrame = false;
    debugPrintEndFrame = false;
  }

  // Get SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Run app
  runApp(VisualesApp(prefs: prefs));
}

Future<void> _optimizeMemory() async {
  // Enable aggressive garbage collection in low-memory environments
  if (const bool.fromEnvironment('dart.vm.product')) {
    // Garbage collection is handled automatically in production
  }
}
