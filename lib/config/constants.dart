import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Constantes de la aplicación
class Constants {
  Constants._();

  // URLs del servidor (desde .env)
  static String get baseUrl =>
      dotenv.env['VISUALES_BASE_URL'] ?? 'https://visuales.uclv.cu';
  static String get listadoUrl =>
      dotenv.env['VISUALES_LISTADO_TXT'] ?? '$baseUrl/listado.txt';
  static String get listadoHtmlUrl =>
      dotenv.env['VISUALES_LISTADO_HTML'] ?? '$baseUrl/listado.html';

  // Rutas de categorías (desde .env)
  static String get rutasPeliculas =>
      dotenv.env['VISUALES_RUTA_PELICULAS'] ?? '/Peliculas/';
  static String get rutasSeries =>
      dotenv.env['VISUALES_RUTA_SERIES'] ?? '/Series/';
  static String get rutasDocumentales =>
      dotenv.env['VISUALES_RUTA_DOCUMENTALES'] ?? '/Documentales/';
  static String get rutasAnimados =>
      dotenv.env['VISUALES_RUTA_ANIMADOS'] ?? '/Animados/';
  static String get rutasCursos =>
      dotenv.env['VISUALES_RUTA_CURSOS'] ?? '/Cursos/';

  // Timeouts (desde .env)
  static Duration get connectionTimeout =>
      Duration(seconds: int.parse(dotenv.env['CONNECTION_TIMEOUT'] ?? '30'));
  static Duration get receiveTimeout =>
      Duration(seconds: int.parse(dotenv.env['RECEIVE_TIMEOUT'] ?? '30'));
  static Duration get sendTimeout =>
      Duration(seconds: int.parse(dotenv.env['SEND_TIMEOUT'] ?? '30'));

  // Cache
  static Duration get cacheDuration =>
      Duration(hours: int.parse(dotenv.env['CACHE_DURATION_HOURS'] ?? '24'));
  static const String cacheKeyName = 'media_list_cache';
  static const String cacheKeyTimestamp = 'cache_timestamp';
  static const String cacheKeyHash = 'cache_hash';

  // Hive
  static const String hiveBoxName = 'visuales_box';
  static const String hiveDownloadsBox = 'downloads_box';
  static const String hiveSettingsBox = 'settings_box';

  // Descargas (desde .env)
  static String get defaultDownloadPath =>
      dotenv.env['DOWNLOAD_PATH'] ?? '/Download/Visuales';
  static int get maxConcurrentDownloads =>
      int.parse(dotenv.env['MAX_CONCURRENT_DOWNLOADS'] ?? '3');
  static int get maxRetries => int.parse(dotenv.env['MAX_RETRIES'] ?? '3');
  static Duration get retryDelay =>
      Duration(seconds: int.parse(dotenv.env['RETRY_DELAY_SECONDS'] ?? '5'));

  // Búsqueda (desde .env)
  static int get searchHistoryLimit =>
      int.parse(dotenv.env['SEARCH_HISTORY_LIMIT'] ?? '20');
  static const String searchHistoryKey = 'search_history';
  static double get fuzzyMatchThreshold =>
      double.parse(dotenv.env['FUZZY_MATCH_THRESHOLD'] ?? '0.6');

  // UI (desde .env)
  static int get gridColumns => int.parse(dotenv.env['GRID_COLUMNS'] ?? '2');
  static int get gridColumnsTablet =>
      int.parse(dotenv.env['GRID_COLUMNS_TABLET'] ?? '4');
  static const double cardAspectRatio = 0.67;
  static const double coverAspectRatio = 0.67;

  // Permisos
  static const List<String> requiredPermissions = [
    'android.permission.WRITE_EXTERNAL_STORAGE',
    'android.permission.READ_EXTERNAL_STORAGE',
    'android.permission.INTERNET',
    'android.permission.ACCESS_NETWORK_STATE',
  ];

  // Notificaciones
  static const String notificationChannelId = 'visuales_downloads';
  static const String notificationChannelName = 'Descargas';
  static const int notificationId = 1001;

  // Analytics events
  static const String eventSearch = 'search';
  static const String eventDownload = 'download';
  static const String eventOpenMedia = 'open_media';
  static const String eventSync = 'sync';

  // Feature flags (desde .env)
  static bool get enableAnalytics =>
      dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';
  static bool get enableCrashlytics =>
      dotenv.env['ENABLE_CRASHLYTICS']?.toLowerCase() == 'true';
  static bool get enableRemoteConfig =>
      dotenv.env['ENABLE_REMOTE_CONFIG']?.toLowerCase() == 'true';

  // Errores
  static const String errorNoConnection = 'Sin conexión a internet';
  static const String errorParseFailed = 'Error al procesar los datos';
  static const String errorDownloadFailed = 'Error en la descarga';
  static const String errorPermissionDenied = 'Permisos denegados';
  static const String errorServerUnavailable = 'Servidor no disponible';
}
