import 'package:flutter/foundation.dart';
import '../config/constants.dart';
import '../services/cache_service.dart';

/// Provider para la configuración de la app
class SettingsProvider extends ChangeNotifier {
  final CacheService _cacheService;

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
    required CacheService cacheService,
  }) : _cacheService = cacheService {
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
        _cacheService.getSetting<int>('maxConcurrentDownloads') ??
            _maxConcurrentDownloads;
    _downloadPath =
        _cacheService.getSetting<String>('downloadPath') ?? _downloadPath;
    _wifiOnly = _cacheService.getSetting<bool>('wifiOnly') ?? _wifiOnly;
    _autoRetry = _cacheService.getSetting<bool>('autoRetry') ?? _autoRetry;
    _maxRetries = _cacheService.getSetting<int>('maxRetries') ?? _maxRetries;
    _searchHistoryLimit = _cacheService.getSetting<int>('searchHistoryLimit') ??
        _searchHistoryLimit;
    _enableFuzzySearch = _cacheService.getSetting<bool>('enableFuzzySearch') ??
        _enableFuzzySearch;
    _cacheDurationHours = _cacheService.getSetting<int>('cacheDurationHours') ??
        _cacheDurationHours;
    _autoSyncOnStart =
        _cacheService.getSetting<bool>('autoSyncOnStart') ?? _autoSyncOnStart;
    _isDarkMode = _cacheService.getSetting<bool>('isDarkMode') ?? _isDarkMode;
    _showCoverImages =
        _cacheService.getSetting<bool>('showCoverImages') ?? _showCoverImages;
    _gridColumns = _cacheService.getSetting<int>('gridColumns') ?? _gridColumns;
  }

  /// Guarda la configuración
  Future<void> saveSettings() async {
    await _cacheService.saveSettings({
      'maxConcurrentDownloads': _maxConcurrentDownloads,
      'downloadPath': _downloadPath,
      'wifiOnly': _wifiOnly,
      'autoRetry': _autoRetry,
      'maxRetries': _maxRetries,
      'searchHistoryLimit': _searchHistoryLimit,
      'enableFuzzySearch': _enableFuzzySearch,
      'cacheDurationHours': _cacheDurationHours,
      'autoSyncOnStart': _autoSyncOnStart,
      'isDarkMode': _isDarkMode,
      'showCoverImages': _showCoverImages,
      'gridColumns': _gridColumns,
    });
    notifyListeners();
  }

  /// Establece el número máximo de descargas simultáneas
  Future<void> setMaxConcurrentDownloads(int value) async {
    if (_maxConcurrentDownloads == value) return;
    _maxConcurrentDownloads = value;
    await _cacheService.saveSettings({'maxConcurrentDownloads': value});
    notifyListeners();
  }

  /// Establece la ruta de descargas
  Future<void> setDownloadPath(String value) async {
    if (_downloadPath == value) return;
    _downloadPath = value;
    await _cacheService.saveSettings({'downloadPath': value});
    notifyListeners();
  }

  /// Establece si solo descargar por WiFi
  Future<void> setWifiOnly(bool value) async {
    if (_wifiOnly == value) return;
    _wifiOnly = value;
    await _cacheService.saveSettings({'wifiOnly': value});
    notifyListeners();
  }

  /// Establece si reintentar automáticamente
  Future<void> setAutoRetry(bool value) async {
    if (_autoRetry == value) return;
    _autoRetry = value;
    await _cacheService.saveSettings({'autoRetry': value});
    notifyListeners();
  }

  /// Establece el número máximo de reintentos
  Future<void> setMaxRetries(int value) async {
    if (_maxRetries == value) return;
    _maxRetries = value;
    await _cacheService.saveSettings({'maxRetries': value});
    notifyListeners();
  }

  /// Establece el límite del historial de búsquedas
  Future<void> setSearchHistoryLimit(int value) async {
    if (_searchHistoryLimit == value) return;
    _searchHistoryLimit = value;
    await _cacheService.saveSettings({'searchHistoryLimit': value});
    notifyListeners();
  }

  /// Establece si habilitar búsqueda fuzzy
  Future<void> setEnableFuzzySearch(bool value) async {
    if (_enableFuzzySearch == value) return;
    _enableFuzzySearch = value;
    await _cacheService.saveSettings({'enableFuzzySearch': value});
    notifyListeners();
  }

  /// Establece la duración de la caché
  Future<void> setCacheDurationHours(int value) async {
    if (_cacheDurationHours == value) return;
    _cacheDurationHours = value;
    await _cacheService.saveSettings({'cacheDurationHours': value});
    notifyListeners();
  }

  /// Establece si sincronizar automáticamente al iniciar
  Future<void> setAutoSyncOnStart(bool value) async {
    if (_autoSyncOnStart == value) return;
    _autoSyncOnStart = value;
    await _cacheService.saveSettings({'autoSyncOnStart': value});
    notifyListeners();
  }

  /// Establece el modo oscuro
  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    await _cacheService.saveSettings({'isDarkMode': value});
    notifyListeners();
  }

  /// Establece si mostrar portadas
  Future<void> setShowCoverImages(bool value) async {
    if (_showCoverImages == value) return;
    _showCoverImages = value;
    await _cacheService.saveSettings({'showCoverImages': value});
    notifyListeners();
  }

  /// Establece el número de columnas de la cuadrícula
  Future<void> setGridColumns(int value) async {
    if (_gridColumns == value) return;
    _gridColumns = value;
    await _cacheService.saveSettings({'gridColumns': value});
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

    await _cacheService.saveSettings({});
    notifyListeners();
  }
}
