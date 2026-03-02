import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/download_provider.dart';
import '../widgets/download_progress.dart';
import '../widgets/error_widget.dart';

/// Pantalla de descargas
class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Descargas'),
        actions: [
          Consumer<DownloadProvider>(
            builder: (context, downloadProvider, child) {
              if (downloadProvider.completedTasks.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: () {
                  _showClearDialog(context, downloadProvider);
                },
                tooltip: 'Limpiar completadas',
              );
            },
          ),
        ],
      ),
      body: Consumer<DownloadProvider>(
        builder: (context, downloadProvider, child) {
          final allTasks = downloadProvider.tasks.values.toList();

          if (allTasks.isEmpty) {
            return const EmptyStateWidget(
              message: 'No hay descargas',
              subtitle: 'Las descargas aparecerán aquí',
              icon: Icons.download_done,
            );
          }

          final activeTasks = downloadProvider.activeTasks;
          final completedTasks = downloadProvider.completedTasks;
          final failedTasks = downloadProvider.failedTasks;

          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              // En progreso
              if (activeTasks.isNotEmpty) ...[
                _buildSectionHeader(theme, 'En progreso (${activeTasks.length})'),
                ...activeTasks.map((task) {
                  return DownloadProgress(
                    task: task,
                    onPause: () {
                      downloadProvider.pauseDownload(task.id);
                    },
                    onResume: () {
                      downloadProvider.resumeDownload(task.id);
                    },
                    onCancel: () {
                      downloadProvider.cancelDownload(task.id);
                    },
                  );
                }),
              ],
              // Fallidas
              if (failedTasks.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionHeader(theme, 'Fallidas (${failedTasks.length})'),
                ...failedTasks.map((task) {
                  return DownloadProgress(
                    task: task,
                    showActions: true,
                    onRetry: () {
                      downloadProvider.retryDownload(task.id);
                    },
                    onCancel: () {
                      downloadProvider.removeTask(task.id);
                    },
                  );
                }),
              ],
              // Completadas
              if (completedTasks.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionHeader(theme, 'Completadas (${completedTasks.length})'),
                ...completedTasks.map((task) {
                  return DownloadProgress(
                    task: task,
                    showActions: false,
                  );
                }),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context, DownloadProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar descargas'),
        content: const Text('¿Eliminar todas las descargas completadas?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.clearCompleted();
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
