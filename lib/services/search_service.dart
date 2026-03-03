import '../models/media_item.dart';
import '../models/enums.dart';
import '../config/constants.dart';

/// Servicio de búsqueda y filtrado
class SearchService {
  late List<MediaItem> _allItems;
  final List<String> _searchHistory = [];

  SearchService(List<MediaItem> initialItems) {
    _allItems = List.from(initialItems);
  }

  /// Actualiza la lista de elementos
  void updateItems(List<MediaItem> items) {
    _allItems = List.from(items);
  }

  /// Busca por texto con búsqueda fuzzy
  List<MediaItem> search(String query, {bool fuzzy = true}) {
    if (query.isEmpty) return _allItems;

    final normalizedQuery = query.toLowerCase().trim();
    _addToHistory(normalizedQuery);

    final results = _allItems.where((item) {
      final title = item.title.toLowerCase();
      final description = item.description?.toLowerCase() ?? '';

      // Búsqueda exacta
      if (title.contains(normalizedQuery) ||
          description.contains(normalizedQuery)) {
        return true;
      }

      // Búsqueda fuzzy
      if (fuzzy) {
        return _fuzzyMatch(normalizedQuery, title);
      }

      return false;
    }).toList();

    // Ordenar por relevancia
    results.sort((a, b) {
      final aScore = _relevanceScore(a, normalizedQuery);
      final bScore = _relevanceScore(b, normalizedQuery);
      return bScore.compareTo(aScore);
    });

    return results;
  }

  /// Filtra elementos por tipo
  List<MediaItem> filterByType(MediaType type) {
    return _allItems.where((item) => item.type == type).toList();
  }

  /// Filtra elementos por calidad
  List<MediaItem> filterByQuality(Quality quality) {
    if (quality == Quality.unknown) return _allItems;
    return _allItems.where((item) => item.quality == quality).toList();
  }

  /// Filtra elementos por género
  List<MediaItem> filterByGenre(String genre) {
    return _allItems
        .where((item) =>
            item.genres.any((g) => g.toLowerCase() == genre.toLowerCase()))
        .toList();
  }

  /// Filtra elementos por año
  List<MediaItem> filterByYear(int year) {
    return _allItems.where((item) => item.year == year).toList();
  }

  /// Filtra elementos por rango de años
  List<MediaItem> filterByYearRange(int startYear, int endYear) {
    return _allItems
        .where((item) =>
            item.year != null &&
            item.year! >= startYear &&
            item.year! <= endYear)
        .toList();
  }

  /// Búsqueda avanzada con múltiples filtros
  List<MediaItem> advancedSearch({
    String? query,
    MediaType? type,
    Quality? quality,
    String? genre,
    int? year,
    int? startYear,
    int? endYear,
    bool fuzzy = true,
  }) {
    List<MediaItem> results = List.from(_allItems);

    // Filtrar por texto
    if (query != null && query.isNotEmpty) {
      results = search(query, fuzzy: fuzzy);
    }

    // Filtrar por tipo
    if (type != null) {
      results = results.where((item) => item.type == type).toList();
    }

    // Filtrar por calidad
    if (quality != null && quality != Quality.unknown) {
      results = results.where((item) => item.quality == quality).toList();
    }

    // Filtrar por género
    if (genre != null && genre.isNotEmpty) {
      results = results
          .where((item) =>
              item.genres.any((g) => g.toLowerCase() == genre.toLowerCase()))
          .toList();
    }

    // Filtrar por año específico
    if (year != null) {
      results = results.where((item) => item.year == year).toList();
    }

    // Filtrar por rango de años
    if (startYear != null && endYear != null) {
      results = results
          .where((item) =>
              item.year != null &&
              item.year! >= startYear &&
              item.year! <= endYear)
          .toList();
    }

    return results;
  }

  /// Obtiene todos los géneros únicos
  List<String> getAllGenres() {
    final genres = <String>{};
    for (final item in _allItems) {
      genres.addAll(item.genres.map((g) => g.toLowerCase()));
    }
    return genres.toList()..sort();
  }

  /// Obtiene todos los años únicos
  List<int> getAllYears() {
    final years = <int>{};
    for (final item in _allItems) {
      if (item.year != null) {
        years.add(item.year!);
      }
    }
    return years.toList()..sort((a, b) => b.compareTo(a));
  }

  /// Obtiene el historial de búsquedas
  List<String> get searchHistory => List.unmodifiable(_searchHistory);

  /// Limpia el historial de búsquedas
  void clearHistory() {
    _searchHistory.clear();
  }

  /// Añade una búsqueda al historial
  void _addToHistory(String query) {
    if (query.isEmpty) return;

    // Remover si ya existe
    _searchHistory.remove(query);

    // Añadir al inicio
    _searchHistory.insert(0, query);

    // Limitar tamaño
    while (_searchHistory.length > Constants.searchHistoryLimit) {
      _searchHistory.removeLast();
    }
  }

  /// Calcula puntuación de relevancia
  int _relevanceScore(MediaItem item, String query) {
    int score = 0;
    final title = item.title.toLowerCase();

    // Coincidencia exacta al inicio
    if (title.startsWith(query)) {
      score += 100;
    }

    // Coincidencia exacta en el título
    if (title.contains(query)) {
      score += 50;
    }

    // Coincidencia en descripción
    if (item.description?.toLowerCase().contains(query) ?? false) {
      score += 25;
    }

    // Coincidencia en géneros
    if (item.genres.any((g) => g.toLowerCase().contains(query))) {
      score += 15;
    }

    // Búsqueda fuzzy
    if (_fuzzyMatch(query, title)) {
      score += 10;
    }

    return score;
  }

  /// Búsqueda fuzzy simple
  bool _fuzzyMatch(String query, String text) {
    // Remover espacios y caracteres especiales
    final normalizedQuery = query.replaceAll(RegExp(r'[^a-z0-9]'), '');
    final normalizedText = text.replaceAll(RegExp(r'[^a-z0-9]'), '');

    // Evitar división por cero
    if (normalizedQuery.isEmpty) return false;
    if (normalizedText.isEmpty) return false;

    // Verificar si los caracteres de la query aparecen en orden en el texto
    int queryIndex = 0;
    for (int i = 0;
        i < normalizedText.length && queryIndex < normalizedQuery.length;
        i++) {
      if (normalizedText[i] == normalizedQuery[queryIndex]) {
        queryIndex++;
      }
    }

    // Calcular porcentaje de coincidencia
    final matchRatio = queryIndex / normalizedQuery.length;
    return matchRatio >= Constants.fuzzyMatchThreshold;
  }

  /// Obtiene elementos recientes
  List<MediaItem> getRecentItems({int limit = 20}) {
    final sorted = List<MediaItem>.from(_allItems)
      ..sort((a, b) {
        if (a.dateAdded == null && b.dateAdded == null) return 0;
        if (a.dateAdded == null) return 1;
        if (b.dateAdded == null) return -1;
        return b.dateAdded!.compareTo(a.dateAdded!);
      });

    return sorted.take(limit).toList();
  }

  /// Obtiene elementos favoritos
  List<MediaItem> getFavorites() {
    return _allItems.where((item) => item.isFavorite).toList();
  }
}
