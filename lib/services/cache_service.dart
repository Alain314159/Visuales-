import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/media_item.dart';
import '../config/constants.dart';

/// Servicio de caché local usando Hive (10x más rápido que SharedPreferences)
class CacheService {
  late Box<dynamic> _cacheBox;
  late Box<dynamic> _settingsBox;
  final List<void Function()> _listeners = [];

  /// Inicializa Hive y abre las cajas
  Future<void> init() async {
    await Hive.initFlutter();

    // Registrar adaptadores si es necesario
    // Hive.registerAdapter(MediaItemAdapter());

    // Abrir cajas
    _cacheBox = await Hive.openBox(Constants.hiveBoxName);
    _settingsBox = await Hive.openBox(Constants.hiveSettingsBox);
  }

  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Guarda la lista de elementos en caché
  Future<void> saveMediaList(List<MediaItem> items) async {
    final jsonList = items.map((item) => item.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    await _cacheBox.put(Constants.cacheKeyName, jsonString);
    await _cacheBox.put(
        Constants.cacheKeyTimestamp, DateTime.now().millisecondsSinceEpoch);
    _notifyListeners();
  }

  /// Obtiene la lista de elementos desde caché
  List<MediaItem>? getMediaList() {
    final jsonString = _cacheBox.get(Constants.cacheKeyName) as String?;
    if (jsonString == null) return null;

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => MediaItem.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }

  /// Obtiene el timestamp de la caché
  DateTime? getCacheTimestamp() {
    final timestamp = _cacheBox.get(Constants.cacheKeyTimestamp) as int?;
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Verifica si la caché está expirada
  bool isCacheExpired() {
    final timestamp = getCacheTimestamp();
    if (timestamp == null) return true;

    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference > Constants.cacheDuration;
  }

  /// Verifica si hay caché disponible
  bool hasCache() {
    return _cacheBox.containsKey(Constants.cacheKeyName);
  }

  /// Guarda el hash del contenido
  Future<void> saveHash(String hash) async {
    await _cacheBox.put(Constants.cacheKeyHash, hash);
  }

  /// Obtiene el hash guardado
  String? getHash() {
    return _cacheBox.get(Constants.cacheKeyHash) as String?;
  }

  /// Limpia la caché
  Future<void> clearCache() async {
    await _cacheBox.delete(Constants.cacheKeyName);
    await _cacheBox.delete(Constants.cacheKeyTimestamp);
    await _cacheBox.delete(Constants.cacheKeyHash);
    _notifyListeners();
  }

  /// Guarda el historial de búsquedas
  Future<void> saveSearchHistory(List<String> history) async {
    await _cacheBox.put(Constants.searchHistoryKey, history);
  }

  /// Obtiene el historial de búsquedas
  List<String> getSearchHistory() {
    return (_cacheBox.get(Constants.searchHistoryKey) as List?)
            ?.cast<String>() ??
        [];
  }

  /// Guarda un elemento como favorito
  Future<void> setFavorite(String id, bool isFavorite) async {
    final favorites = getFavorites();
    if (isFavorite) {
      favorites.add(id);
    } else {
      favorites.remove(id);
    }
    await _cacheBox.put('favorites', favorites);
    _notifyListeners();
  }

  /// Obtiene los IDs de elementos favoritos
  List<String> getFavorites() {
    return (_cacheBox.get('favorites') as List?)?.cast<String>() ?? [];
  }

  /// Verifica si un elemento es favorito
  bool isFavorite(String id) {
    final favorites = getFavorites();
    return favorites.contains(id);
  }

  /// Guarda la configuración de la app
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    for (final entry in settings.entries) {
      await _settingsBox.put(entry.key, entry.value);
    }
  }

  /// Obtiene un valor de configuración
  T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  /// Limpia todas las cajas
  Future<void> clearAll() async {
    await _cacheBox.clear();
    await _settingsBox.clear();
    _notifyListeners();
  }

  /// Cierra las cajas
  Future<void> close() async {
    await _cacheBox.close();
    await _settingsBox.close();
  }
}
