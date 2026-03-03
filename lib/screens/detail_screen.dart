import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/media_provider.dart';
import '../providers/download_provider.dart';
import '../models/media_item.dart';
import '../models/enums.dart';
import '../widgets/error_widget.dart';

/// Pantalla de detalles
class DetailScreen extends StatelessWidget {
  final String mediaId;

  const DetailScreen({
    super.key,
    required this.mediaId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Consumer<MediaProvider>(
        builder: (context, mediaProvider, child) {
          final item = mediaProvider.getById(mediaId);

          if (item == null) {
            return CustomErrorWidget(
              message: 'Elemento no encontrado',
              onRetry: () {
                Navigator.pop(context);
              },
            );
          }

          return CustomScrollView(
            slivers: [
              // App bar con imagen de fondo
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primaryContainer,
                          theme.colorScheme.secondaryContainer,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getIconForType(item.type),
                        size: 120,
                        color: theme.colorScheme.onPrimaryContainer
                            .withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      item.isFavorite ? Icons.favorite : Icons.favorite_border,
                    ),
                    onPressed: () {
                      mediaProvider.toggleFavorite(mediaId);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      _shareItem(context, item);
                    },
                  ),
                ],
              ),
              // Contenido
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        item.title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Metadata
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (item.year != null)
                            Chip(
                              avatar:
                                  const Icon(Icons.calendar_today, size: 16),
                              label: Text('${item.year}'),
                            ),
                          if (item.quality != Quality.unknown)
                            Chip(
                              avatar: const Icon(Icons.hd, size: 16),
                              label: Text(item.quality.value),
                            ),
                          if (item.language != null)
                            Chip(
                              avatar: const Icon(Icons.language, size: 16),
                              label: Text(item.language!),
                            ),
                          if (item.size != null)
                            Chip(
                              avatar: const Icon(Icons.storage, size: 16),
                              label: Text(item.size!),
                            ),
                        ],
                      ),
                      // Géneros
                      if (item.genres.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: item.genres.map((genre) {
                            return FilterChip(
                              label: Text(genre),
                              onSelected: (selected) {},
                            );
                          }).toList(),
                        ),
                      ],
                      // Información adicional para series
                      if (item.type == MediaType.series) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (item.seasons != null) ...[
                              Icon(Icons.tv,
                                  size: 20, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text('${item.seasons} temporadas'),
                            ],
                            if (item.episodes != null) ...[
                              const SizedBox(width: 16),
                              Icon(Icons.playlist_play,
                                  size: 20, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text('${item.episodes} episodios'),
                            ],
                          ],
                        ),
                      ],
                      // Descripción
                      if (item.description != null &&
                          item.description!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Sinopsis',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.description!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                      // Botones de acción
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context
                                    .read<DownloadProvider>()
                                    .startDownload(item);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Descarga iniciada'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.download),
                              label: const Text('Descargar'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              _openUrl(context, item.downloadUrl);
                            },
                            icon: const Icon(Icons.open_in_browser),
                            label: const Text('Abrir'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ],
                      ),
                      // Información adicional
                      if (item.path != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Información técnica',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          leading: const Icon(Icons.folder),
                          title: const Text('Ruta'),
                          subtitle: Text(item.path!),
                          dense: true,
                        ),
                        if (item.lastModified != null)
                          ListTile(
                            leading: const Icon(Icons.access_time),
                            title: const Text('Última modificación'),
                            subtitle: Text(
                              '${item.lastModified!.day}/${item.lastModified!.month}/${item.lastModified!.year}',
                            ),
                            dense: true,
                          ),
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getIconForType(MediaType type) {
    switch (type) {
      case MediaType.movie:
        return Icons.movie;
      case MediaType.series:
        return Icons.tv;
      case MediaType.documentary:
        return Icons.video_library;
      case MediaType.animated:
        return Icons.animation;
      case MediaType.course:
        return Icons.school;
      case MediaType.other:
        return Icons.folder;
    }
  }

  void _shareItem(BuildContext context, MediaItem item) {
    // Share functionality to be implemented in future versions
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compartir próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el enlace'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
