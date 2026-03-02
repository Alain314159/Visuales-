import 'media_item.dart';
import 'enums.dart';

/// Resultado de una búsqueda
class SearchResult {
  final List<MediaItem> items;
  final String query;
  final int totalResults;
  final Duration searchDuration;
  final Map<String, int> filters;

  const SearchResult({
    required this.items,
    required this.query,
    required this.totalResults,
    required this.searchDuration,
    this.filters = const {},
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      items: json['items'] is List
          ? (json['items'] as List)
              .where((e) => e is Map<String, dynamic>)
              .map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      query: json['query'] as String? ?? '',
      totalResults: json['totalResults'] as int? ?? 0,
      searchDuration: Duration(
        milliseconds: json['searchDuration'] as int? ?? 0,
      ),
      filters: json['filters'] is Map<String, dynamic>
          ? (json['filters'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, v as int),
            )
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'query': query,
      'totalResults': totalResults,
      'searchDuration': searchDuration.inMilliseconds,
      'filters': filters,
    };
  }

  SearchResult copyWith({
    List<MediaItem>? items,
    String? query,
    int? totalResults,
    Duration? searchDuration,
    Map<String, int>? filters,
  }) {
    return SearchResult(
      items: items ?? this.items,
      query: query ?? this.query,
      totalResults: totalResults ?? this.totalResults,
      searchDuration: searchDuration ?? this.searchDuration,
      filters: filters ?? this.filters,
    );
  }

  /// Agrupa los resultados por tipo
  Map<String, List<MediaItem>> get groupedByType {
    final Map<String, List<MediaItem>> groups = {};
    for (final item in items) {
      final type = item.type.value;
      groups.putIfAbsent(type, () => []).add(item);
    }
    return groups;
  }

  /// Agrupa los resultados por año
  Map<int, List<MediaItem>> get groupedByYear {
    final Map<int, List<MediaItem>> groups = {};
    for (final item in items) {
      if (item.year != null) {
        groups.putIfAbsent(item.year!, () => []).add(item);
      }
    }
    return groups;
  }

  @override
  String toString() {
    return 'SearchResult(query: $query, totalResults: $totalResults, items: ${items.length})';
  }
}
