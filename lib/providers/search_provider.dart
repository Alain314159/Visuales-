import 'package:flutter/foundation.dart';
import '../models/media_item.dart';
import '../models/enums.dart';
import '../services/search_service.dart';
import '../services/cache_service.dart';

/// Provider para el estado de búsqueda
class SearchProvider extends ChangeNotifier {
  final SearchService _searchService;
  final CacheService _cacheService;

  List<MediaItem> _searchResults = [];
  List<MediaItem> _allItems = [];
  String _query = '';
  bool _isSearching = false;
  List<String> _searchHistory = [];
  
  // Filtros
  MediaType? _filterType;
  Quality? _filterQuality;
  String? _filterGenre;
  int? _filterYear;

  SearchProvider({
    required SearchService searchService,
    required CacheService cacheService,
  })  : _searchService = searchService,
        _cacheService = cacheService {
    _searchHistory = _cacheService.getSearchHistory();
  }

  /// Resultados de la búsqueda
  List<MediaItem> get searchResults => _searchResults;

  /// Query actual
  String get query => _query;

  /// Estado de búsqueda
  bool get isSearching => _isSearching;

  /// Historial de búsquedas
  List<String> get searchHistory => List.unmodifiable(_searchHistory);

  /// Filtro de tipo actual
  MediaType? get filterType => _filterType;

  /// Filtro de calidad actual
  Quality? get filterQuality => _filterQuality;

  /// Filtro de género actual
  String? get filterGenre => _filterGenre;

  /// Filtro de año actual
  int? get filterYear => _filterYear;

  /// Todos los géneros disponibles
  List<String> get availableGenres => _searchService.getAllGenres();

  /// Todos los años disponibles
  List<int> get availableYears => _searchService.getAllYears();

  /// Actualiza los elementos desde el provider de media
  void updateItems(List<MediaItem> items) {
    _allItems = List.from(items);
    _searchService.updateItems(_allItems);
    
    // Si hay una query, re-ejecutar búsqueda
    if (_query.isNotEmpty) {
      _performSearch();
    }
  }

  /// Ejecuta la búsqueda
  Future<void> search(String query) async {
    _query = query;
    _isSearching = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _performSearch();
  }

  /// Realiza la búsqueda interna
  void _performSearch() {
    if (_query.isEmpty &&
        _filterType == null &&
        _filterQuality == null &&
        _filterGenre == null &&
        _filterYear == null) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _searchResults = _searchService.advancedSearch(
      query: _query.isEmpty ? null : _query,
      type: _filterType,
      quality: _filterQuality,
      genre: _filterGenre,
      year: _filterYear,
    );

    _isSearching = false;
    notifyListeners();
  }

  /// Establece el filtro de tipo
  void setFilterType(MediaType? type) {
    _filterType = type;
    _performSearch();
  }

  /// Establece el filtro de calidad
  void setFilterQuality(Quality? quality) {
    _filterQuality = quality;
    _performSearch();
  }

  /// Establece el filtro de género
  void setFilterGenre(String? genre) {
    _filterGenre = genre;
    _performSearch();
  }

  /// Establece el filtro de año
  void setFilterYear(int? year) {
    _filterYear = year;
    _performSearch();
  }

  /// Limpia todos los filtros
  void clearFilters() {
    _filterType = null;
    _filterQuality = null;
    _filterGenre = null;
    _filterYear = null;
    _performSearch();
  }

  /// Limpia la búsqueda
  void clearSearch() {
    _query = '';
    _searchResults = [];
    notifyListeners();
  }

  /// Limpia el historial
  Future<void> clearHistory() async {
    _searchHistory.clear();
    await _cacheService.saveSearchHistory([]);
    notifyListeners();
  }

  /// Elimina una entrada del historial
  Future<void> removeHistoryItem(String item) async {
    _searchHistory.remove(item);
    await _cacheService.saveSearchHistory(_searchHistory);
    notifyListeners();
  }
}
