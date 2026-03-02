/// Constantes de la aplicación
class Constants {
  Constants._();

  // URLs del servidor
  static const String baseUrl = 'https://visuales.uclv.cu';
  static const String listadoUrl = '$baseUrl/listado.txt';
  static const String listadoHtmlUrl = '$baseUrl/listado.html';
  
  // Rutas de categorías
  static const String rutasPeliculas = '/Peliculas/';
  static const String rutasSeries = '/Series/';
  static const String rutasDocumentales = '/Documentales/';
  static const String rutasAnimados = '/Animados/';
  static const String rutasCursos = '/Cursos/';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Cache
  static const Duration cacheDuration = Duration(hours: 24);
  static const String cacheKeyName = 'media_list_cache';
  static const String cacheKeyTimestamp = 'cache_timestamp';
  static const String cacheKeyHash = 'cache_hash';
  
  // Hive
  static const String hiveBoxName = 'visuales_box';
  static const String hiveDownloadsBox = 'downloads_box';
  static const String hiveSettingsBox = 'settings_box';
  
  // Descargas
  static const String defaultDownloadPath = '/Download/Visuales';
  static const int maxConcurrentDownloads = 3;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 5);
  
  // Búsqueda
  static const int searchHistoryLimit = 20;
  static const String searchHistoryKey = 'search_history';
  static const double fuzzyMatchThreshold = 0.6;
  
  // UI
  static const int gridColumns = 2;
  static const int gridColumnsTablet = 4;
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
  
  // Errores
  static const String errorNoConnection = 'Sin conexión a internet';
  static const String errorParseFailed = 'Error al procesar los datos';
  static const String errorDownloadFailed = 'Error en la descarga';
  static const String errorPermissionDenied = 'Permisos denegados';
  static const String errorServerUnavailable = 'Servidor no disponible';
}
