import 'dart:convert';
import 'dart:convert' show html;
import '../models/media_item.dart';
import '../models/enums.dart';
import '../config/constants.dart';

/// Servicio para parsear el contenido del servidor
class ParserService {
  /// Sanitiza contenido HTML para prevenir XSS
  String _sanitizeHtml(String htmlContent) {
    // Remover scripts
    final scriptRegex = RegExp(r'(?i)<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>');
    var sanitized = htmlContent.replaceAllRegExp(scriptRegex, '');

    // Remover eventos onclick, onload, etc.
    final eventRegex = RegExp(r'(?i)\s+on\w+\s*=\s*["\'][^"\']*["\']');
    sanitized = sanitized.replaceAllRegExp(eventRegex, '');

    // Remover javascript: URLs
    final jsUrlRegex = RegExp(r'(?i)javascript\s*:');
    sanitized = sanitized.replaceAll(jsUrlRegex, '');

    return sanitized;
  }

  /// Parsea el archivo listado.txt
  List<MediaItem> parseTxtList(String content) {
    final items = <MediaItem>[];
    final lines = content.split('\n');

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) {
        continue;
      }

      final item = _parseLine(trimmedLine);
      if (item != null) {
        items.add(item);
      }
    }

    return items;
  }

  /// Parsea una línea del listado
  MediaItem? _parseLine(String line) {
    // Formato esperado: [CATEGORIA] Título | Calidad | Idioma | Tamaño | URL
    // O formatos variados según el servidor

    try {
      // Intentar parsear formato con pipe
      if (line.contains('|')) {
        return _parsePipeFormat(line);
      }

      // Intentar parsear formato de ruta
      if (line.contains('/')) {
        return _parsePathFormat(line);
      }

      // Formato simple: solo título (solo si no está vacío)
      if (line.trim().isNotEmpty) {
        return _parseSimpleFormat(line);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Parsea formato con pipes: Título | Calidad | Idioma | Tamaño
  MediaItem? _parsePipeFormat(String line) {
    final parts = line.split('|').map((e) => e.trim()).toList();
    
    if (parts.isEmpty) return null;
    
    final title = parts[0];
    String? quality;
    String? language;
    String? size;
    String? downloadUrl;
    
    // Extraer metadata de las partes
    for (int i = 1; i < parts.length; i++) {
      final part = parts[i];
      
      // Detectar calidad
      if (_isQuality(part)) {
        quality = part;
      }
      // Detectar idioma
      else if (_isLanguage(part)) {
        language = part;
      }
      // Detectar tamaño
      else if (_isSize(part)) {
        size = part;
      }
      // Detectar URL
      else if (part.startsWith('http') || part.startsWith('/')) {
        downloadUrl = part;
      }
    }
    
    // Si no hay URL, intentar construir una
    downloadUrl ??= _buildDownloadUrl(title);
    
    return MediaItem(
      id: _generateId(title),
      title: _cleanTitle(title),
      type: _detectType(title),
      quality: QualityExtension.fromString(quality ?? ''),
      language: language,
      size: size,
      downloadUrl: downloadUrl,
      year: _extractYear(title),
    );
  }

  /// Parsea formato de ruta: /Categoria/Subcategoria/Archivo
  MediaItem? _parsePathFormat(String line) {
    final parts = line.split('/');
    
    if (parts.length < 2) return null;
    
    final category = parts.firstWhere(
      (e) => e.isNotEmpty,
      orElse: () => '',
    );
    
    final fileName = parts.lastWhere(
      (e) => e.isNotEmpty && e.contains('.'),
      orElse: () => parts.last,
    );
    
    final title = _fileNameToTitle(fileName);
    final type = _detectTypeFromCategory(category);
    final downloadUrl = line.startsWith('http') ? line : '${Constants.baseUrl}$line';
    
    return MediaItem(
      id: _generateId(line),
      title: title,
      type: type,
      downloadUrl: downloadUrl,
      path: line,
      quality: _extractQualityFromFileName(fileName),
      year: _extractYear(title),
    );
  }

  /// Parsea formato simple: solo título
  MediaItem? _parseSimpleFormat(String line) {
    if (line.isEmpty) return null;
    
    final title = line.trim();
    final type = _detectType(title);
    final downloadUrl = _buildDownloadUrl(title);
    
    return MediaItem(
      id: _generateId(title),
      title: _cleanTitle(title),
      type: type,
      downloadUrl: downloadUrl,
      year: _extractYear(title),
    );
  }

  /// Parsea índice HTML de Apache
  List<MediaItem> parseHtmlIndex(String html, {String? basePath}) {
    final items = <MediaItem>[];

    // Sanitizar HTML para prevenir XSS
    final sanitizedHtml = _sanitizeHtml(html);

    // Patrón para enlaces en índice de Apache
    // <a href="...">...</a>
    final linkPattern = RegExp(r'<a\s+href="([^"]+)">([^<]+)</a>');
    
    for (final match in linkPattern.allMatches(sanitizedHtml)) {
      final href = match.group(1);
      final text = match.group(2);

      if (href == null || text == null) continue;

      // Saltar directorios padre y enlaces vacíos
      if (href == '?C=N;O=D' ||
          href == '?C=M;A=D' ||
          href == '?C=S;A=D' ||
          href == '?C=I;A=D' ||
          text == 'Parent Directory' ||
          text.trim().isEmpty) {
        continue;
      }
      
      // Es un directorio?
      final isDirectory = href.endsWith('/');
      
      if (isDirectory) {
        // Agregar como categoría o subcategoría
        items.add(MediaItem(
          id: _generateId(href),
          title: text.trim(),
          type: MediaType.other,
          downloadUrl: basePath != null ? '$basePath$href' : href,
          path: basePath != null ? '$basePath$href' : href,
        ));
      } else {
        // Es un archivo descargable
        final quality = _extractQualityFromFileName(text);
        final year = _extractYear(text);
        final type = _detectType(text);
        
        items.add(MediaItem(
          id: _generateId(href),
          title: _fileNameToTitle(text),
          type: type,
          quality: quality,
          year: year,
          downloadUrl: basePath != null ? '$basePath$href' : href,
          path: basePath != null ? '$basePath$href' : href,
          size: _extractSizeFromHtml(html, text),
        ));
      }
    }
    
    return items;
  }

  /// Detecta el tipo de contenido desde una categoría
  MediaType _detectTypeFromCategory(String category) {
    final lower = category.toLowerCase();
    
    if (lower.contains('pelicula') || lower.contains('movie')) {
      return MediaType.movie;
    } else if (lower.contains('serie') || lower.contains('series')) {
      return MediaType.series;
    } else if (lower.contains('documental') || lower.contains('documentary')) {
      return MediaType.documentary;
    } else if (lower.contains('animado') || 
               lower.contains('anime') || 
               lower.contains('animation')) {
      return MediaType.animated;
    } else if (lower.contains('curso') || lower.contains('course')) {
      return MediaType.course;
    }
    
    return MediaType.other;
  }

  /// Detecta el tipo de contenido desde el título
  MediaType _detectType(String title) {
    final lower = title.toLowerCase();
    
    // Patrones para series
    if (RegExp(r's\d+e\d+|temporada|season|capitulo|episode').hasMatch(lower)) {
      return MediaType.series;
    }
    
    // Patrones para películas
    if (RegExp(r'\d{4}.*1080p|\d{4}.*720p|bluray|dvdrip|hdrip').hasMatch(lower)) {
      return MediaType.movie;
    }
    
    // Patrones para documentales
    if (lower.contains('documental') || lower.contains('documentary')) {
      return MediaType.documentary;
    }
    
    // Patrones para animados
    if (lower.contains('anime') || 
        lower.contains('animado') ||
        RegExp(r's\d+e\d+.*720p|s\d+e\d+.*1080p').hasMatch(lower)) {
      return MediaType.animated;
    }
    
    // Patrones para cursos
    if (lower.contains('curso') || 
        lower.contains('course') ||
        lower.contains('tutorial') ||
        lower.contains('udemy')) {
      return MediaType.course;
    }
    
    return MediaType.other;
  }

  /// Verifica si un texto es una calidad
  bool _isQuality(String text) {
    final lower = text.toLowerCase();
    return RegExp(r'4k|2160p|1080p|720p|480p|360p|hd|sd|uhd|hdr|bluray|web-dl|webrip|hdtv').hasMatch(lower);
  }

  /// Verifica si un texto es un idioma
  bool _isLanguage(String text) {
    final lower = text.toLowerCase();
    return ['español', 'spanish', 'latino', 'english', 'ingles', 'dual', 'subtitulado', 'castellano']
        .any((lang) => lower.contains(lang));
  }

  /// Verifica si un texto es un tamaño
  bool _isSize(String text) {
    return RegExp(r'(?i)\d+(\.\d+)?\s*(gb|mb|kb|tb)').hasMatch(text);
  }

  /// Extrae calidad desde un nombre de archivo
  Quality _extractQualityFromFileName(String fileName) {
    final lower = fileName.toLowerCase();
    
    if (lower.contains('4k') || lower.contains('2160')) return Quality.hd4k;
    if (lower.contains('1080')) return Quality.hd1080;
    if (lower.contains('720')) return Quality.hd720;
    if (lower.contains('480')) return Quality.sd480;
    if (lower.contains('360')) return Quality.sd360;
    
    return Quality.unknown;
  }

  /// Extrae año desde un título
  int? _extractYear(String title) {
    final match = RegExp(r'\b(19|20)\d{2}\b').firstMatch(title);
    if (match != null) {
      return int.tryParse(match.group(0)!);
    }
    return null;
  }

  /// Extrae tamaño desde HTML
  String? _extractSizeFromHtml(String html, String fileName) {
    // Sanitizar HTML primero
    final sanitizedHtml = _sanitizeHtml(html);

    // Buscar el tamaño en la tabla de Apache
    final escapedFileName = RegExp.escape(fileName);
    final pattern = RegExp(r'(?i)>($escapedFileName.*?)</a>.*?(\d+(?:\.\d+)?\s*(?:GB|MB|KB))');
    final match = pattern.firstMatch(sanitizedHtml);
    if (match != null) {
      return match.group(2);
    }
    return null;
  }

  /// Convierte nombre de archivo a título legible
  String _fileNameToTitle(String fileName) {
    // Remover extensión
    var title = fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    
    // Reemplazar separadores
    title = title.replaceAll(RegExp(r'[._-]+'), ' ');
    
    // Remover tags de calidad
    title = title.replaceAll(RegExp(r'(?i)\b(1080p|720p|480p|4k|BluRay|WEB-DL|x264|x265|AAC|AC3)\b'), '');
    
    // Limpiar espacios
    title = title.trim();
    
    // Capitalizar
    title = _capitalizeTitle(title);
    
    return title;
  }

  /// Limpia el título
  String _cleanTitle(String title) {
    return title
        .replaceAll(RegExp(r'\[.*?\]'), '')  // Remover corchetes
        .replaceAll(RegExp(r'\(.*?\)'), '')  // Remover paréntesis
        .trim();
  }

  /// Capitaliza un título
  String _capitalizeTitle(String title) {
    return title.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Construye URL de descarga
  String _buildDownloadUrl(String title) {
    // Construir URL basada en el título
    // Esto depende de la estructura del servidor
    final encodedTitle = Uri.encodeComponent(title);
    
    // Intentar determinar la categoría
    final type = _detectType(title);
    String categoryPath = '';
    
    switch (type) {
      case MediaType.movie:
        categoryPath = Constants.rutasPeliculas;
        break;
      case MediaType.series:
        categoryPath = Constants.rutasSeries;
        break;
      case MediaType.documentary:
        categoryPath = Constants.rutasDocumentales;
        break;
      case MediaType.animated:
        categoryPath = Constants.rutasAnimados;
        break;
      case MediaType.course:
        categoryPath = Constants.rutasCursos;
        break;
      case MediaType.other:
        break;
    }
    
    if (categoryPath.isNotEmpty) {
      return '${Constants.baseUrl}$categoryPath$encodedTitle';
    }
    
    return '${Constants.baseUrl}/$encodedTitle';
  }

  /// Genera un ID único
  String _generateId(String input) {
    return input.hashCode.abs().toString();
  }

  /// Calcula hash del contenido
  String calculateHash(String content) {
    return content.hashCode.abs().toString();
  }
}
