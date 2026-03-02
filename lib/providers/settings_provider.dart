import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

/// Provider para la configuración de la app
class SettingsProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  // Descargas
  int _maxConcurrentDownloads = Constants.maxConcurrentDownloads;
  String _downloadPath = Constants.defaultDownloadPath;
  bool _wifiOnly = true;
  bool _autoRetry = true;
  int _maxRetries = Constants.maxRetries;

  // Búsqueda
  int _searchHistoryLimit = Constants.searchHistoryLimit;
  bool _enableFuzzySearch = true;

  // Cache
  int _cacheDurationHours = 24;
  bool _autoSyncOnStart = true;

  // UI
  bool _isDarkMode = false;
  bool _showCoverImages = true;
  int _gridColumns = Constants.gridColumns;

  SettingsProvider({
    required SharedPreferences prefs,
  }) : _prefs = prefs {
    _loadSettings();
  }

  // Getters
  int get maxConcurrentDownloads => _maxConcurrentDownloads;
  String get downloadPath => _downloadPath;
  bool get wifiOnly => _wifiOnly;
  bool get autoRetry => _autoRetry;
  int get maxRetries => _maxRetries;
  int get searchHistoryLimit => _searchHistoryLimit;
  bool get enableFuzzySearch => _enableFuzzySearch;
  int get cacheDurationHours => _cacheDurationHours;
  bool get autoSyncOnStart => _autoSyncOnStart;
  bool get isDarkMode => _isDarkMode;
  bool get showCoverImages => _showCoverImages;
  int get gridColumns => _gridColumns;

  /// Carga la configuración guardada
  void _loadSettings() {
    _maxConcurrentDownloads =
        _prefs.getInt('maxConcurrentDownloads') ?? _maxConcurrentDownloads;
    _downloadPath = _prefs.getString('downloadPath') ?? _downloadPath;
    _wifiOnly = _prefs.getBool('wifiOnly') ?? _wifiOnly;
    _autoRetry = _prefs.getBool('autoRetry') ?? _autoRetry;
    _maxRetries = _prefs.getInt('maxRetries') ?? _maxRetries;
    _searchHistoryLimit =
        _prefs.getInt('searchHistoryLimit') ?? _searchHistoryLimit;
    _enableFuzzySearch = _prefs.getBool('enableFuzzySearch') ?? _enableFuzzySearch;
    _cacheDurationHours =
        _prefs.getInt('cacheDurationHours') ?? _cacheDurationHours;
    _autoSyncOnStart = _prefs.getBool('autoSyncOnStart') ?? _autoSyncOnStart;
    _isDarkMode = _prefs.getBool('isDarkMode') ?? _isDarkMode;
    _showCoverImages = _prefs.getBool('showCoverImages') ?? _showCoverImages;
    _gridColumns = _prefs.getInt('gridColumns') ?? _gridColumns;
  }

  /// Guarda la configuración
  Future<void> saveSettings() async {
    await _prefs.setInt('maxConcurrentDownloads', _maxConcurrentDownloads);
    await _prefs.setString('downloadPath', _downloadPath);
    await _prefs.setBool('wifiOnly', _wifiOnly);
    await _prefs.setBool('autoRetry', _autoRetry);
    await _prefs.setInt('maxRetries', _maxRetries);
    await _prefs.setInt('searchHistoryLimit', _searchHistoryLimit);
    await _prefs.setBool('enableFuzzySearch', _enableFuzzySearch);
    await _prefs.setInt('cacheDurationHours', _cacheDurationHours);
    await _prefs.setBool('autoSyncOnStart', _autoSyncOnStart);
    await _prefs.setBool('isDarkMode', _isDarkMode);
    await _prefs.setBool('showCoverImages', _showCoverImages);
    await _prefs.setInt('gridColumns', _gridColumns);
    notifyListeners();
  }

  /// Establece el número máximo de descargas simultáneas
  Future<void> setMaxConcurrentDownloads(int value) async {
    _maxConcurrentDownloads = value;
    await _prefs.setInt('maxConcurrentDownloads', value);
    notifyListeners();
  }

  /// Establece la ruta de descargas
  Future<void> setDownloadPath(String value) async {
    _downloadPath = value;
    await _prefs.setString('downloadPath', value);
    notifyListeners();
  }

  /// Establece si solo descargar por WiFi
  Future<void> setWifiOnly(bool value) async {
    _wifiOnly = value;
    await _prefs.setBool('wifiOnly', value);
    notifyListeners();
  }

  /// Establece si reintentar automáticamente
  Future<void> setAutoRetry(bool value) async {
    _autoRetry = value;
    await _prefs.setBool('autoRetry', value);
    notifyListeners();
  }

  /// Establece el número máximo de reintentos
  Future<void> setMaxRetries(int value) async {
    _maxRetries = value;
    await _prefs.setInt('maxRetries', value);
    notifyListeners();
  }

  /// Establece el límite del historial de búsquedas
  Future<void> setSearchHistoryLimit(int value) async {
    _searchHistoryLimit = value;
    await _prefs.setInt('searchHistoryLimit', value);
    notifyListeners();
  }

  /// Establece si habilitar búsqueda fuzzy
  Future<void> setEnableFuzzySearch(bool value) async {
    _enableFuzzySearch = value;
    await _prefs.setBool('enableFuzzySearch', value);
    notifyListeners();
  }

  /// Establece la duración de la caché
  Future<void> setCacheDurationHours(int value) async {
    _cacheDurationHours = value;
    await _prefs.setInt('cacheDurationHours', value);
    notifyListeners();
  }

  /// Establece si sincronizar automáticamente al iniciar
  Future<void> setAutoSyncOnStart(bool value) async {
    _autoSyncOnStart = value;
    await _prefs.setBool('autoSyncOnStart', value);
    notifyListeners();
  }

  /// Establece el modo oscuro
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  /// Establece si mostrar portadas
  Future<void> setShowCoverImages(bool value) async {
    _showCoverImages = value;
    await _prefs.setBool('showCoverImages', value);
    notifyListeners();
  }

  /// Establece el número de columnas de la cuadrícula
  Future<void> setGridColumns(int value) async {
    _gridColumns = value;
    await _prefs.setInt('gridColumns', value);
    notifyListeners();
  }

  /// Restablece la configuración a los valores predeterminados
  Future<void> resetToDefaults() async {
    _maxConcurrentDownloads = Constants.maxConcurrentDownloads;
    _downloadPath = Constants.defaultDownloadPath;
    _wifiOnly = true;
    _autoRetry = true;
    _maxRetries = Constants.maxRetries;
    _searchHistoryLimit = Constants.searchHistoryLimit;
    _enableFuzzySearch = true;
    _cacheDurationHours = 24;
    _autoSyncOnStart = true;
    _isDarkMode = false;
    _showCoverImages = true;
    _gridColumns = Constants.gridColumns;

    await _prefs.clear();
    notifyListeners();
  }
}
