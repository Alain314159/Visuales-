import 'dart:math' as math;

/// Extensiones de utilidades para String
extension StringExtensions on String {
  /// Capitaliza la primera letra
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  /// Capitaliza cada palabra
  String capitalizeWords() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Remueve los últimos caracteres si coinciden
  String removeSuffix(String suffix) {
    if (endsWith(suffix)) {
      return substring(0, length - suffix.length);
    }
    return this;
  }

  /// Remueve la extensión del archivo
  String removeExtension() {
    final lastDot = lastIndexOf('.');
    if (lastDot > 0) {
      return substring(0, lastDot);
    }
    return this;
  }

  /// Obtiene la extensión del archivo
  String get extension {
    final lastDot = lastIndexOf('.');
    if (lastDot > 0) {
      return substring(lastDot + 1);
    }
    return '';
  }

  /// Verifica si es una URL válida
  bool isValidUrl() {
    return startsWith('http://') || startsWith('https://');
  }

  /// Trunca el string a una longitud máxima
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return substring(0, maxLength - suffix.length) + suffix;
  }

  /// Remueve espacios en blanco extras
  String normalizeSpaces() {
    return trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Convierte a slug (URL-friendly)
  String toSlug() {
    return toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }

  /// Parsea tamaño de archivo a bytes
  int? parseFileSize() {
    final normalized = toLowerCase().trim();
    final match = RegExp(r'(\d+(?:\.\d+)?)\s*(kb|mb|gb|tb)?').firstMatch(normalized);
    if (match == null) return null;

    final value = double.tryParse(match.group(1) ?? '0') ?? 0;
    final unit = match.group(2) ?? 'b';

    switch (unit) {
      case 'kb':
        return (value * 1024).toInt();
      case 'mb':
        return (value * 1024 * 1024).toInt();
      case 'gb':
        return (value * 1024 * 1024 * 1024).toInt();
      case 'tb':
        return (value * 1024 * 1024 * 1024 * 1024).toInt();
      default:
        return value.toInt();
    }
  }

  /// Formatea bytes a tamaño legible
  static String formatBytes(int bytes) {
    if (bytes == 0) return '0 B';
    const k = 1024;
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (math.log(bytes) / math.log(k)).floor();
    return '${(bytes / math.pow(k, i)).toStringAsFixed(2)} ${units[i]}';
  }
}
