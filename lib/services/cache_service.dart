import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_item.dart';
import '../config/constants.dart';

/// Servicio de caché local
class CacheService {
  final SharedPreferences _prefs;
  final List<void Function()> _listeners = [];

  CacheService(this._prefs);

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
    await _prefs.setString(Constants.cacheKeyName, jsonString);
    await _prefs.setInt(Constants.cacheKeyTimestamp, DateTime.now().millisecondsSinceEpoch);
    _notifyListeners();
  }

  /// Obtiene la lista de elementos desde caché
  List<MediaItem>? getMediaList() {
    final jsonString = _prefs.getString(Constants.cacheKeyName);
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
    final timestamp = _prefs.getInt(Constants.cacheKeyTimestamp);
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
    return _prefs.containsKey(Constants.cacheKeyName);
  }

  /// Guarda el hash del contenido
  Future<void> saveHash(String hash) async {
    await _prefs.setString(Constants.cacheKeyHash, hash);
  }

  /// Obtiene el hash guardado
  String? getHash() {
    return _prefs.getString(Constants.cacheKeyHash);
  }

  /// Limpia la caché
  Future<void> clearCache() async {
    await _prefs.remove(Constants.cacheKeyName);
    await _prefs.remove(Constants.cacheKeyTimestamp);
    await _prefs.remove(Constants.cacheKeyHash);
    _notifyListeners();
  }

  /// Guarda el historial de búsquedas
  Future<void> saveSearchHistory(List<String> history) async {
    await _prefs.setStringList(Constants.searchHistoryKey, history);
  }

  /// Obtiene el historial de búsquedas
  List<String> getSearchHistory() {
    return _prefs.getStringList(Constants.searchHistoryKey) ?? [];
  }

  /// Guarda un elemento como favorito
  Future<void> setFavorite(String id, bool isFavorite) async {
    final favorites = getFavorites();
    if (isFavorite) {
      favorites.add(id);
    } else {
      favorites.remove(id);
    }
    await _prefs.setStringList('favorites', favorites);
    _notifyListeners();
  }

  /// Obtiene los IDs de elementos favoritos
  List<String> getFavorites() {
    return _prefs.getStringList('favorites') ?? [];
  }

  /// Verifica si un elemento es favorito
  bool isFavorite(String id) {
    final favorites = getFavorites();
    return favorites.contains(id);
  }

  /// Guarda la configuración de la app
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    for (final entry in settings.entries) {
      if (entry.value is bool) {
        await _prefs.setBool(entry.key, entry.value as bool);
      } else if (entry.value is int) {
        await _prefs.setInt(entry.key, entry.value as int);
      } else if (entry.value is String) {
        await _prefs.setString(entry.key, entry.value as String);
      } else if (entry.value is double) {
        await _prefs.setDouble(entry.key, entry.value as double);
      }
    }
  }

  /// Obtiene un valor de configuración
  T? getSetting<T>(String key) {
    if (T == bool) {
      return _prefs.getBool(key) as T?;
    } else if (T == int) {
      return _prefs.getInt(key) as T?;
    } else if (T == String) {
      return _prefs.getString(key) as T?;
    } else if (T == double) {
      return _prefs.getDouble(key) as T?;
    }
    return null;
  }
}
