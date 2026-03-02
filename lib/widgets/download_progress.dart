import 'package:flutter/material.dart';
import '../models/download_task.dart';

/// Widget para mostrar el progreso de una descarga
class DownloadProgress extends StatelessWidget {
  final DownloadTask task;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  final bool showActions;

  const DownloadProgress({
    super.key,
    required this.task,
    this.onPause,
    this.onResume,
    this.onCancel,
    this.onRetry,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = task.status == DownloadStatus.completed;
    final isFailed = task.status == DownloadStatus.failed;
    final isPaused = task.status == DownloadStatus.paused;
    final isDownloading = task.status == DownloadStatus.downloading;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título y estado
            Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(theme),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.media.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _getStatusText(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(theme),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Barra de progreso
            LinearProgressIndicator(
              value: isDownloading || isCompleted ? task.progress : null,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(theme),
              ),
            ),
            const SizedBox(height: 8),
            // Información de progreso
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${task.downloadedFormatted} / ${task.totalFormatted}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  '${task.progressPercent}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // Acciones
            if (showActions && !isCompleted) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isDownloading)
                    IconButton(
                      icon: const Icon(Icons.pause),
                      onPressed: onPause,
                      tooltip: 'Pausar',
                    ),
                  if (isPaused)
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: onResume,
                      tooltip: 'Reanudar',
                    ),
                  IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: onCancel,
                    tooltip: 'Cancelar',
                    color: Colors.red,
                  ),
                  if (isFailed && onRetry != null)
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: onRetry,
                      tooltip: 'Reintentar',
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (task.status) {
      case DownloadStatus.queued:
        return Icons.schedule;
      case DownloadStatus.downloading:
        return Icons.file_download;
      case DownloadStatus.paused:
        return Icons.pause_circle;
      case DownloadStatus.completed:
        return Icons.check_circle;
      case DownloadStatus.failed:
        return Icons.error;
      case DownloadStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(ThemeData theme) {
    switch (task.status) {
      case DownloadStatus.queued:
        return theme.colorScheme.secondary;
      case DownloadStatus.downloading:
        return theme.colorScheme.primary;
      case DownloadStatus.paused:
        return theme.colorScheme.tertiary;
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.failed:
        return Colors.red;
      case DownloadStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (task.status) {
      case DownloadStatus.queued:
        return 'En cola...';
      case DownloadStatus.downloading:
        return 'Descargando...';
      case DownloadStatus.paused:
        return 'Pausada';
      case DownloadStatus.completed:
        return 'Completada';
      case DownloadStatus.failed:
        return task.errorMessage ?? 'Error en la descarga';
      case DownloadStatus.cancelled:
        return 'Cancelada';
    }
  }
}
