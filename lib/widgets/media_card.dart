import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../models/enums.dart';
import '../config/constants.dart';

/// Widget de tarjeta para elementos multimedia
class MediaCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onFavorite;
  final bool showDownloadButton;
  final double aspectRatio;

  const MediaCard({
    super.key,
    required this.item,
    this.onTap,
    this.onDownload,
    this.onFavorite,
    this.showDownloadButton = true,
    this.aspectRatio = Constants.cardAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDownloading = false; // TODO: Check from provider

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(4),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada/Imagen
            AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Placeholder con gradiente
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primaryContainer,
                          theme.colorScheme.secondaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      _getIconForType(),
                      size: 48,
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(0.5),
                    ),
                  ),
                  // Badge de tipo
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.type.value.substring(0, 1).toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Botón de favorito
                  if (onFavorite != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(
                          item.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: item.isFavorite
                              ? Colors.red
                              : theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        onPressed: onFavorite,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: const EdgeInsets.all(4),
                      ),
                    ),
                  // Badge de calidad
                  if (item.quality != Quality.unknown)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.quality.value,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Información
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    // Metadata
                    Row(
                      children: [
                        if (item.year != null)
                          Text(
                            '${item.year}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        if (item.year != null && item.size != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '•',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        if (item.size != null)
                          Expanded(
                            child: Text(
                              item.size!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Botón de descarga
            if (showDownloadButton)
              Padding(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onDownload,
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Descargar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType() {
    switch (item.type) {
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
}
