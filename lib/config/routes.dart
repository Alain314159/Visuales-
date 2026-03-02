/// Rutas de la aplicación
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String search = '/search';
  static const String category = '/category';
  static const String detail = '/detail';
  static const String downloads = '/downloads';
  static const String settings = '/settings';

  /// Mapa de rutas con sus páginas
  static Map<String, dynamic> get routes {
    return {
      splash: 'SplashScreen',
      home: 'HomeScreen',
      search: 'SearchScreen',
      category: 'CategoryScreen',
      detail: 'DetailScreen',
      downloads: 'DownloadsScreen',
      settings: 'SettingsScreen',
    };
  }

  /// Obtiene la ruta inicial
  static String get initialRoute => splash;

  /// Genera la ruta para un detalle con ID
  static String detailWithId(String id) => '$detail/$id';

  /// Genera la ruta para una categoría
  static String categoryWithId(String categoryId) => '$category?id=$categoryId';
}
