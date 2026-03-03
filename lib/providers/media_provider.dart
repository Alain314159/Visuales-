import 'package:flutter/foundation.dart';
import '../models/media_item.dart';
import '../models/enums.dart';
import '../services/sync_service.dart';
import '../services/cache_service.dart';

/// Provider para el estado del contenido multimedia
class MediaProvider extends ChangeNotifier {
  final SyncService _syncService;
  final CacheService _cacheService;

  List<MediaItem> _mediaItems = [];
  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  String? _error;
  DateTime? _lastSync;

  MediaProvider({
    required SyncService syncService,
    required CacheService cacheService,
  })  : _syncService = syncService,
        _cacheService = cacheService;

  /// Lista completa de elementos
  List<MediaItem> get mediaItems => _mediaItems;

  /// Estado de carga
  bool get isLoading => _isLoading;

  /// Si ya se cargó al menos una vez
  bool get hasLoadedOnce => _hasLoadedOnce;

  /// Error actual
  String? get error => _error;

  /// Última sincronización
  DateTime? get lastSync => _lastSync;

  /// Elementos filtrados por tipo
  List<MediaItem> getByType(MediaType type) {
    return _mediaItems.where((item) => item.type == type).toList();
  }

  /// Obtiene un elemento por ID
  MediaItem? getById(String id) {
    try {
      return _mediaItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Elementos recientes
  List<MediaItem> get recentItems {
    final sorted = List<MediaItem>.from(_mediaItems)
      ..sort((a, b) {
        if (a.dateAdded == null && b.dateAdded == null) return 0;
        if (a.dateAdded == null) return 1;
        if (b.dateAdded == null) return -1;
        return b.dateAdded!.compareTo(a.dateAdded!);
      });
    return sorted.take(20).toList();
  }

  /// Elementos favoritos
  List<MediaItem> get favorites {
    return _mediaItems.where((item) => item.isFavorite).toList();
  }

  /// Inicializa el provider cargando desde caché
  Future<void> initialize() async {
    _loadFromCache();
  }

  /// Carga los elementos desde caché
  void _loadFromCache() {
    final cachedItems = _cacheService.getMediaList();
    if (cachedItems != null && cachedItems.isNotEmpty) {
      _mediaItems = cachedItems;
      _hasLoadedOnce = true;
      notifyListeners();
    }
  }

  /// Realiza la sincronización
  Future<void> sync() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _syncService.sync();

      if (result.success) {
        _mediaItems = _cacheService.getMediaList() ?? [];
        _lastSync = DateTime.now();
        _hasLoadedOnce = true;
        _error = null;
      } else {
        _error = result.error;
      }
    } catch (e) {
      _error = 'Error al sincronizar: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fuerza la sincronización
  Future<void> forceSync() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _syncService.forceSync();

      if (result.success) {
        _mediaItems = _cacheService.getMediaList() ?? [];
        _lastSync = DateTime.now();
        _hasLoadedOnce = true;
      } else {
        _error = result.error;
      }
    } catch (e) {
      _error = 'Error al sincronizar: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Marca un elemento como favorito
  Future<void> toggleFavorite(String id) async {
    final index = _mediaItems.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final item = _mediaItems[index];
    final isFavorite = !item.isFavorite;

    _mediaItems[index] = item.copyWith(isFavorite: isFavorite);
    _cacheService.setFavorite(id, isFavorite);
    notifyListeners();
  }

  /// Limpia el error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Recarga los datos
  Future<void> reload() async {
    _loadFromCache();
  }

  /// Limpia memoria (dispone de recursos cuando no se necesita)
  @override
  void dispose() {
    _mediaItems.clear();
    super.dispose();
  }
}
