import 'enums.dart';

/// Modelo para categorías de contenido
class Category {
  final String id;
  final String name;
  final MediaType type;
  final String icon;
  final int itemCount;
  final String? path;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    this.itemCount = 0,
    this.path,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: MediaTypeExtension.fromString(json['type'] as String? ?? ''),
      icon: json['icon'] as String? ?? '📁',
      itemCount: json['itemCount'] as int? ?? 0,
      path: json['path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.value,
      'icon': icon,
      'itemCount': itemCount,
      'path': path,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    MediaType? type,
    String? icon,
    int? itemCount,
    String? path,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      itemCount: itemCount ?? this.itemCount,
      path: path ?? this.path,
    );
  }

  /// Categorías predefinidas
  static const List<Category> defaults = [
    Category(
      id: 'peliculas',
      name: 'Películas',
      type: MediaType.movie,
      icon: '🎬',
      path: '/Peliculas/',
    ),
    Category(
      id: 'series',
      name: 'Series',
      type: MediaType.series,
      icon: '📺',
      path: '/Series/',
    ),
    Category(
      id: 'documentales',
      name: 'Documentales',
      type: MediaType.documentary,
      icon: '🎥',
      path: '/Documentales/',
    ),
    Category(
      id: 'animados',
      name: 'Animados',
      type: MediaType.animated,
      icon: '🎭',
      path: '/Animados/',
    ),
    Category(
      id: 'cursos',
      name: 'Cursos',
      type: MediaType.course,
      icon: '📚',
      path: '/Cursos/',
    ),
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Category(id: $id, name: $name, type: ${type.value})';
  }
}
