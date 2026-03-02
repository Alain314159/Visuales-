import 'enums.dart';

/// Modelo principal para elementos multimedia
class MediaItem {
  final String id;
  final String title;
  final MediaType type;
  final String? description;
  final List<String> genres;
  final int? year;
  final Quality quality;
  final String? language;
  final String? size;
  final String downloadUrl;
  final String? coverUrl;
  final DateTime? dateAdded;
  final bool isFavorite;
  
  // Para series
  final int? seasons;
  final int? episodes;
  
  // Metadata adicional
  final String? path;
  final DateTime? lastModified;

  const MediaItem({
    required this.id,
    required this.title,
    required this.type,
    this.description,
    this.genres = const [],
    this.year,
    this.quality = Quality.unknown,
    this.language,
    this.size,
    required this.downloadUrl,
    this.coverUrl,
    this.dateAdded,
    this.isFavorite = false,
    this.seasons,
    this.episodes,
    this.path,
    this.lastModified,
  });

  /// Crea un MediaItem desde un mapa JSON
  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: (json['id'] as String?)?.trim() ?? '',
      title: (json['title'] as String?)?.trim() ?? 'Sin título',
      type: MediaTypeExtension.fromString(json['type'] as String? ?? ''),
      description: json['description'] as String?,
      genres: json['genres'] is List
          ? (json['genres'] as List).whereType<String>().toList()
          : [],
      year: json['year'] is int ? json['year'] as int : null,
      quality: QualityExtension.fromString(json['quality'] as String? ?? ''),
      language: json['language'] as String?,
      size: json['size'] as String?,
      downloadUrl: (json['downloadUrl'] as String?)?.trim() ?? '',
      coverUrl: json['coverUrl'] as String?,
      dateAdded: json['dateAdded'] != null
          ? DateTime.tryParse(json['dateAdded'] as String)
          : null,
      isFavorite: json['isFavorite'] as bool? ?? false,
      seasons: json['seasons'] as int?,
      episodes: json['episodes'] as int?,
      path: json['path'] as String?,
      lastModified: json['lastModified'] != null
          ? DateTime.tryParse(json['lastModified'] as String)
          : null,
    );
  }

  /// Convierte el MediaItem a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.value,
      'description': description,
      'genres': genres,
      'year': year,
      'quality': quality.value,
      'language': language,
      'size': size,
      'downloadUrl': downloadUrl,
      'coverUrl': coverUrl,
      'dateAdded': dateAdded?.toIso8601String(),
      'isFavorite': isFavorite,
      'seasons': seasons,
      'episodes': episodes,
      'path': path,
      'lastModified': lastModified?.toIso8601String(),
    };
  }

  /// Crea una copia del MediaItem con campos modificados
  MediaItem copyWith({
    String? id,
    String? title,
    MediaType? type,
    String? description,
    List<String>? genres,
    int? year,
    Quality? quality,
    String? language,
    String? size,
    String? downloadUrl,
    String? coverUrl,
    DateTime? dateAdded,
    bool? isFavorite,
    int? seasons,
    int? episodes,
    String? path,
    DateTime? lastModified,
  }) {
    return MediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      description: description ?? this.description,
      genres: genres ?? this.genres,
      year: year ?? this.year,
      quality: quality ?? this.quality,
      language: language ?? this.language,
      size: size ?? this.size,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      dateAdded: dateAdded ?? this.dateAdded,
      isFavorite: isFavorite ?? this.isFavorite,
      seasons: seasons ?? this.seasons,
      episodes: episodes ?? this.episodes,
      path: path ?? this.path,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  /// Obtiene el tamaño formateado
  String get formattedSize {
    if (size == null) return 'Desconocido';
    return size!;
  }

  /// Obtiene una descripción corta
  String get shortDescription {
    final parts = <String>[];
    if (year != null) parts.add(year.toString());
    if (quality != Quality.unknown) parts.add(quality.value);
    if (language != null) parts.add(language!);
    return parts.join(' • ');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MediaItem(id: $id, title: $title, type: ${type.value})';
  }
}
