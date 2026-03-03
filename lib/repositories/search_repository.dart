/// Contrato para operaciones de repositorio de búsqueda
abstract class SearchRepository {
  /// Busca elementos
  Future<List<MediaItem>> search(String query, {SearchFilters? filters});

  /// Obtiene historial de búsquedas
  List<String> getSearchHistory();

  /// Agrega búsqueda al historial
  Future<void> addToHistory(String query);

  /// Limpia historial
  Future<void> clearHistory();

  /// Obtiene sugerencias
  List<String> getSuggestions(String query);
}
