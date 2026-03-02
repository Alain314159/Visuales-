import '../models/media_item.dart';
import '../config/constants.dart';
import 'api_service.dart';
import 'parser_service.dart';
import 'cache_service.dart';

/// Resultado de la sincronización
class SyncResult {
  final bool success;
  final bool upToDate;
  final int newItemsCount;
  final int totalItems;
  final String? error;
  final List<MediaItem> newItems;

  SyncResult({
    required this.success,
    this.upToDate = false,
    this.newItemsCount = 0,
    this.totalItems = 0,
    this.error,
    this.newItems = const [],
  });

  factory SyncResult.success({
    required bool upToDate,
    required int newItemsCount,
    required int totalItems,
    required List<MediaItem> newItems,
  }) {
    return SyncResult(
      success: true,
      upToDate: upToDate,
      newItemsCount: newItemsCount,
      totalItems: totalItems,
      newItems: newItems,
    );
  }

  factory SyncResult.failure(String error) {
    return SyncResult(
      success: false,
      error: error,
    );
  }
}

/// Servicio de sincronización
class SyncService {
  final ApiService _apiService;
  final ParserService _parserService;
  final CacheService _cacheService;

  SyncService({
    required ApiService apiService,
    required ParserService parserService,
    required CacheService cacheService,
  })  : _apiService = apiService,
        _parserService = parserService,
        _cacheService = cacheService;

  /// Realiza la sincronización completa
  Future<SyncResult> sync() async {
    try {
      // 1. Verificar conexión
      if (!await _apiService.isConnected()) {
        return SyncResult.failure(Constants.errorNoConnection);
      }

      // 2. Obtener listado remoto
      String content;
      try {
        content = await _apiService.fetchListado();
      } catch (e) {
        return SyncResult.failure('Error al obtener el listado: $e');
      }

      // 3. Calcular hash
      final remoteHash = _parserService.calculateHash(content);
      final localHash = _cacheService.getHash();

      // 4. Comparar con caché
      if (remoteHash == localHash && _cacheService.hasCache()) {
        final cachedItems = _cacheService.getMediaList();
        if (cachedItems != null) {
          return SyncResult.success(
            upToDate: true,
            newItemsCount: 0,
            totalItems: cachedItems.length,
            newItems: [],
          );
        }
      }

      // 5. Parsear contenido
      List<MediaItem> items;
      try {
        items = _parserService.parseTxtList(content);
      } catch (e) {
        return SyncResult.failure(Constants.errorParseFailed);
      }

      // 6. Encontrar nuevos elementos
      final cachedItems = _cacheService.getMediaList() ?? [];
      final cachedIds = cachedItems.map((i) => i.id).toSet();
      final newItems = items.where((i) => !cachedIds.contains(i.id)).toList();

      // 7. Guardar en caché
      await _cacheService.saveMediaList(items);
      await _cacheService.saveHash(remoteHash);

      return SyncResult.success(
        upToDate: false,
        newItemsCount: newItems.length,
        totalItems: items.length,
        newItems: newItems,
      );
    } catch (e) {
      return SyncResult.failure('Error inesperado: $e');
    }
  }

  /// Sincroniza una categoría específica
  Future<List<MediaItem>> syncCategory(String categoryPath) async {
    try {
      final content = await _apiService.fetchDirectoryIndex(categoryPath);
      return _parserService.parseHtmlIndex(content, basePath: categoryPath);
    } catch (e) {
      return [];
    }
  }

  /// Verifica si hay conexión
  Future<bool> checkConnection() async {
    return _apiService.isConnected();
  }

  /// Obtiene información de un archivo
  Future<Map<String, dynamic>> getFileInfo(String url) async {
    return _apiService.getFileHeaders(url);
  }

  /// Limpia la caché
  Future<void> clearCache() async {
    await _cacheService.clearCache();
  }

  /// Fuerza la resincronización
  Future<SyncResult> forceSync() async {
    await clearCache();
    return sync();
  }
}
