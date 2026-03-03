/// Contrato para operaciones de repositorio de medios
abstract class MediaRepository {
  /// Obtiene todos los elementos multimedia
  Future<List<MediaItem>> getAll();

  /// Obtiene un elemento por ID
  Future<MediaItem?> getById(String id);

  /// Obtiene elementos por tipo
  Future<List<MediaItem>> getByType(MediaType type);

  /// Busca elementos
  Future<List<MediaItem>> search(String query, {SearchFilters? filters});

  /// Obtiene favoritos
  Future<List<MediaItem>> getFavorites();

  /// Alterna favorito
  Future<void> toggleFavorite(String id);

  /// Verifica si es favorito
  Future<bool> isFavorite(String id);
}

/// Filtros de búsqueda
class SearchFilters {
  final MediaType? type;
  final Quality? quality;
  final int? year;
  final int? startYear;
  final int? endYear;
  final String? genre;

  const SearchFilters({
    this.type,
    this.quality,
    this.year,
    this.startYear,
    this.endYear,
    this.genre,
  });

  SearchFilters copyWith({
    MediaType? type,
    Quality? quality,
    int? year,
    int? startYear,
    int? endYear,
    String? genre,
  }) {
    return SearchFilters(
      type: type ?? this.type,
      quality: quality ?? this.quality,
      year: year ?? this.year,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      genre: genre ?? this.genre,
    );
  }
}
