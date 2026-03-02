import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../models/enums.dart';

/// Widget de lista para elementos multimedia
class MediaListTile extends StatelessWidget {
  final MediaItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onFavorite;
  final bool showThumbnail;
  final bool showDownloadButton;

  const MediaListTile({
    super.key,
    required this.item,
    this.onTap,
    this.onDownload,
    this.onFavorite,
    this.showThumbnail = true,
    this.showDownloadButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: showThumbnail
          ? Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconForType(),
                color: theme.colorScheme.onPrimaryContainer.withOpacity(0.5),
              ),
            )
          : null,
      title: Text(
        item.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              if (item.year != null)
                Text(
                  '${item.year}',
                  style: theme.textTheme.bodySmall,
                ),
              if (item.quality != Quality.unknown) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('•'),
                ),
                Text(
                  item.quality.value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              if (item.size != null) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('•'),
                ),
                Text(
                  item.size!,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onFavorite != null)
            IconButton(
              icon: Icon(
                item.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: item.isFavorite ? Colors.red : null,
              ),
              onPressed: onFavorite,
            ),
          if (showDownloadButton)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: onDownload,
            ),
        ],
      ),
      onTap: onTap,
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
