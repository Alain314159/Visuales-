import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../providers/search_provider.dart';
import '../providers/download_provider.dart';
import '../models/enums.dart';
import '../config/routes.dart';
import '../widgets/media_list_tile.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/category_chip.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';

/// Pantalla de búsqueda
class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({
    super.key,
    this.initialQuery,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final FocusNode _focusNode;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<SearchProvider>().search(widget.initialQuery!);
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      context.read<SearchProvider>().clearSearch();
    } else {
      context.read<SearchProvider>().search(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt_off : Icons.filter_alt),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: _showFilters ? 'Ocultar filtros' : 'Mostrar filtros',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomSearchBar(
              controller: _searchController,
              autofocus: widget.initialQuery == null,
              hintText: 'Buscar contenido...',
              onChanged: (value) {
                if (value.isEmpty) {
                  context.read<SearchProvider>().clearSearch();
                }
              },
              onSearch: (query) {
                context.read<SearchProvider>().search(query);
              },
              onClear: () {
                context.read<SearchProvider>().clearSearch();
              },
              suggestions: context.watch<SearchProvider>().searchHistory,
              onSuggestionTap: (suggestion) {
                context.read<SearchProvider>().search(suggestion);
              },
            ),
          ),
          // Filtros
          if (_showFilters) _buildFilters(),
          // Resultados
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final theme = Theme.of(context);
    final searchProvider = context.watch<SearchProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Filtro de tipo
              Expanded(
                child: DropdownButtonFormField<MediaType?>(
                  value: searchProvider.filterType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ...MediaType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.value),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    searchProvider.setFilterType(value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Filtro de calidad
              Expanded(
                child: DropdownButtonFormField<Quality?>(
                  value: searchProvider.filterQuality,
                  decoration: const InputDecoration(
                    labelText: 'Calidad',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todas')),
                    ...Quality.values.map((quality) {
                      return DropdownMenuItem(
                        value: quality,
                        child: Text(quality.value),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    searchProvider.setFilterQuality(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Filtro de año
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: searchProvider.filterYear,
                  decoration: const InputDecoration(
                    labelText: 'Año',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ...searchProvider.availableYears.take(20).map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    searchProvider.setFilterYear(value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Botón limpiar filtros
              ElevatedButton(
                onPressed: () {
                  searchProvider.clearFilters();
                  _searchController.clear();
                },
                child: const Text('Limpiar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Consumer2<SearchProvider, MediaProvider>(
      builder: (context, searchProvider, mediaProvider, child) {
        if (searchProvider.isSearching) {
          return const LoadingWidget(message: 'Buscando...');
        }

        final results = searchProvider.searchResults;

        if (results.isEmpty) {
          if (searchProvider.query.isEmpty) {
            return const EmptyStateWidget(
              message: 'Busca contenido',
              subtitle: 'Escribe para comenzar a buscar',
              icon: Icons.search,
            );
          }
          return EmptyStateWidget(
            message: 'No se encontraron resultados',
            subtitle: 'Intenta con otros términos o filtros',
            icon: Icons.search_off,
            onAction: () {
              searchProvider.clearFilters();
              _searchController.clear();
            },
            actionLabel: 'Limpiar filtros',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index];
            return MediaListTile(
              key: ValueKey(item.id),
              item: item,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.detail,
                  arguments: item.id,
                );
              },
              onDownload: () {
                context.read<DownloadProvider>().startDownload(item);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Descargando: ${item.title}'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              onFavorite: () {
                mediaProvider.toggleFavorite(item.id);
              },
            );
          },
        );
      },
    );
  }
}
