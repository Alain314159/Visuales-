/// Tipo de contenido multimedia
enum MediaType {
  movie, // Película
  series, // Serie
  documentary, // Documental
  animated, // Animado/Anime
  course, // Curso
  other, // Otro
}

/// Calidad del video
enum Quality {
  hd4k, // 4K
  hd1080, // 1080p
  hd720, // 720p
  sd480, // 480p
  sd360, // 360p
  unknown, // Desconocida
}

/// Estado de un elemento en la biblioteca
enum MediaStatus {
  available,
  downloading,
  downloaded,
  unavailable,
}

extension MediaTypeExtension on MediaType {
  String get value {
    switch (this) {
      case MediaType.movie:
        return 'Pelicula';
      case MediaType.series:
        return 'Serie';
      case MediaType.documentary:
        return 'Documental';
      case MediaType.animated:
        return 'Animado';
      case MediaType.course:
        return 'Curso';
      case MediaType.other:
        return 'Otro';
    }
  }

  static MediaType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pelicula':
      case 'película':
      case 'movie':
      case 'movies':
      case 'peliculas':
      case 'películas':
        return MediaType.movie;
      case 'serie':
      case 'series':
      case 'tv':
        return MediaType.series;
      case 'documental':
      case 'documentales':
      case 'documentary':
      case 'documentaries':
        return MediaType.documentary;
      case 'animado':
      case 'animados':
      case 'anime':
      case 'animation':
      case 'animated':
        return MediaType.animated;
      case 'curso':
      case 'cursos':
      case 'course':
      case 'courses':
        return MediaType.course;
      default:
        return MediaType.other;
    }
  }

  String get icon {
    switch (this) {
      case MediaType.movie:
        return '🎬';
      case MediaType.series:
        return '📺';
      case MediaType.documentary:
        return '🎥';
      case MediaType.animated:
        return '🎭';
      case MediaType.course:
        return '📚';
      case MediaType.other:
        return '📁';
    }
  }
}

extension QualityExtension on Quality {
  String get value {
    switch (this) {
      case Quality.hd4k:
        return '4K';
      case Quality.hd1080:
        return '1080p';
      case Quality.hd720:
        return '720p';
      case Quality.sd480:
        return '480p';
      case Quality.sd360:
        return '360p';
      case Quality.unknown:
        return 'Unknown';
    }
  }

  static Quality fromString(String value) {
    final lowerValue = value.toLowerCase();
    if (lowerValue.contains('4k') || lowerValue.contains('2160')) {
      return Quality.hd4k;
    } else if (lowerValue.contains('1080')) {
      return Quality.hd1080;
    } else if (lowerValue.contains('720')) {
      return Quality.hd720;
    } else if (lowerValue.contains('480')) {
      return Quality.sd480;
    } else if (lowerValue.contains('360')) {
      return Quality.sd360;
    }
    return Quality.unknown;
  }

  int get priority {
    switch (this) {
      case Quality.hd4k:
        return 5;
      case Quality.hd1080:
        return 4;
      case Quality.hd720:
        return 3;
      case Quality.sd480:
        return 2;
      case Quality.sd360:
        return 1;
      case Quality.unknown:
        return 0;
    }
  }
}
