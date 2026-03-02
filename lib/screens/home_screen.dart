import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../providers/download_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/search_provider.dart';
import '../models/enums.dart';
import '../config/routes.dart';
import '../widgets/media_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';

/// Pantalla principal (Home)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  MediaType? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Search provider se actualiza en _buildHomeContent usando Consumer2
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visuales UCLV'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              context.read<MediaProvider>().sync();
            },
            tooltip: 'Sincronizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header con búsqueda y categorías
          _buildHeader(),
          // Contenido
          Expanded(
            child: _selectedIndex == 0
                ? _buildHomeContent()
                : _selectedIndex == 1
                    ? _buildDownloadsPreview()
                    : _buildSettingsPreview(),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 1) {
            Navigator.pushNamed(context, AppRoutes.downloads);
          } else if (index == 2) {
            Navigator.pushNamed(context, AppRoutes.settings);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.download_outlined),
            selectedIcon: Icon(Icons.download),
            label: 'Descargas',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Barra de búsqueda
          CustomSearchBar(
            hintText: 'Buscar películas, series...',
            onSearch: (query) {
              Navigator.pushNamed(
                context,
                AppRoutes.search,
                arguments: query,
              );
            },
          ),
          const SizedBox(height: 16),
          // Categorías
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                CategoryChip(
                  label: 'Todos',
                  icon: Icons.apps,
                  isSelected: _selectedCategory == null,
                  onTap: () {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                CategoryChip(
                  label: 'Películas',
                  icon: Icons.movie,
                  isSelected: _selectedCategory == MediaType.movie,
                  onTap: () {
                    setState(() {
                      _selectedCategory = MediaType.movie;
                    });
                  },
                ),
                const SizedBox(width: 8),
                CategoryChip(
                  label: 'Series',
                  icon: Icons.tv,
                  isSelected: _selectedCategory == MediaType.series,
                  onTap: () {
                    setState(() {
                      _selectedCategory = MediaType.series;
                    });
                  },
                ),
                const SizedBox(width: 8),
                CategoryChip(
                  label: 'Documentales',
                  icon: Icons.video_library,
                  isSelected: _selectedCategory == MediaType.documentary,
                  onTap: () {
                    setState(() {
                      _selectedCategory = MediaType.documentary;
                    });
                  },
                ),
                const SizedBox(width: 8),
                CategoryChip(
                  label: 'Animados',
                  icon: Icons.animation,
                  isSelected: _selectedCategory == MediaType.animated,
                  onTap: () {
                    setState(() {
                      _selectedCategory = MediaType.animated;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    final theme = Theme.of(context);

    return Consumer2<MediaProvider, SearchProvider>(
      builder: (context, mediaProvider, searchProvider, child) {
        // Update search provider when media changes - usando addPostFrameCallback para evitar rebuild infinito
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mediaProvider.mediaItems.isNotEmpty) {
            searchProvider.updateItems(mediaProvider.mediaItems);
          }
        });

        if (mediaProvider.isLoading && !mediaProvider.hasLoadedOnce) {
          return const LoadingWidget(message: 'Cargando contenido...');
        }

        if (mediaProvider.error != null && mediaProvider.mediaItems.isEmpty) {
          return CustomErrorWidget(
            message: 'Error al cargar el contenido',
            details: mediaProvider.error,
            onRetry: () {
              mediaProvider.sync();
            },
          );
        }

        List items = mediaProvider.mediaItems;
        if (_selectedCategory != null) {
          items = mediaProvider.getByType(_selectedCategory!);
        }

        if (items.isEmpty) {
          return const EmptyStateWidget(
            message: 'No hay contenido disponible',
            subtitle: 'Intenta sincronizar nuevamente',
            icon: Icons.folder_open,
          );
        }

        return RefreshIndicator(
          onRefresh: () => mediaProvider.sync(),
          child: CustomScrollView(
            slivers: [
              // Últimos agregados
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory == null
                            ? 'Últimos Agregados'
                            : _selectedCategory!.value,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_selectedCategory != null) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.category,
                              arguments: _selectedCategory!.value,
                            );
                          }
                        },
                        child: const Text('Ver todo'),
                      ),
                    ],
                  ),
                ),
              ),
              // Grid de elementos
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      return MediaCard(
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
                      );
                    },
                    childCount: items.length > 20 ? 20 : items.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDownloadsPreview() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.download, size: 64),
          SizedBox(height: 16),
          Text('Abriendo descargas...'),
        ],
      ),
    );
  }

  Widget _buildSettingsPreview() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 64),
          SizedBox(height: 16),
          Text('Abriendo ajustes...'),
        ],
      ),
    );
  }
}
