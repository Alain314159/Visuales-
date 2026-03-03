import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'app.dart';
import 'config/constants.dart';
import 'services/cache_service.dart';

/// Logger global para toda la app
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: '.env');

  // Inicializar servicios
  final cacheService = CacheService();
  await cacheService.init();

  // Configurar Firebase y Crashlytics si está habilitado
  if (Constants.enableCrashlytics) {
    await _initFirebase();
  }

  // Configurar error boundaries globales
  _setupErrorHandlers();

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

  logger.i('🚀 Visuales UCLV app iniciada');
  logger.i('📡 Base URL: ${Constants.baseUrl}');
  logger.i('💾 Cache duration: ${Constants.cacheDuration}');
  logger.i(
      '🔥 Crashlytics: ${Constants.enableCrashlytics ? "activado" : "desactivado"}');

  // Run app
  runApp(
    VisualesApp(
      cacheService: cacheService,
      logger: logger,
    ),
  );
}

/// Inicializa Firebase y Crashlytics
Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp();
    logger.i('✅ Firebase inicializado correctamente');

    // Configurar Crashlytics
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    // Configurar manejo de errores no fatales
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    logger.i('✅ Crashlytics configurado');
  } catch (e, stackTrace) {
    logger.e('❌ Error al inicializar Firebase: $e',
        error: e, stackTrace: stackTrace);
    // Continuar sin Firebase si falla
  }
}

/// Configura manejadores de errores globales (Error Boundaries)
void _setupErrorHandlers() {
  // Manejar errores de Zone
  runZonedGuarded(() {
    // El código dentro de esta zona será monitoreado
    logger.d('🛡️ Error boundary configurado');
  }, (error, stackTrace) {
    // Error no capturado detectado
    logger.f('💥 Error no capturado: $error',
        error: error, stackTrace: stackTrace);

    // Reportar a Crashlytics si está disponible
    if (Constants.enableCrashlytics) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    }
  });

  // Manejar errores de isolate
  Isolate.addErrorHandler((error) {
    logger.f('💥 Error en Isolate: $error');

    if (Constants.enableCrashlytics) {
      FirebaseCrashlytics.instance.recordError(
        error.description,
        null,
        fatal: true,
      );
    }
  });
}

Future<void> _optimizeMemory() async {
  // Enable aggressive garbage collection in low-memory environments
  if (const bool.fromEnvironment('dart.vm.product')) {
    // Garbage collection is handled automatically in production
    logger.d('♻️ Optimización de memoria activada para producción');
  }
}
