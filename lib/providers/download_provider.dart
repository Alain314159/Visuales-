import 'package:flutter/foundation.dart';
import '../models/media_item.dart';
import '../models/download_task.dart';
import '../services/download_service.dart';

/// Provider para el estado de descargas
class DownloadProvider extends ChangeNotifier {
  final DownloadService _downloadService;

  Map<String, DownloadTask> _tasks = {};
  bool _isInitialized = false;

  DownloadProvider({
    required DownloadService downloadService,
  }) : _downloadService = downloadService;

  /// Todas las tareas
  Map<String, DownloadTask> get tasks => Map.unmodifiable(_tasks);

  /// Tareas activas
  List<DownloadTask> get activeTasks => _downloadService.activeTasks;

  /// Tareas completadas
  List<DownloadTask> get completedTasks => _downloadService.completedTasks;

  /// Tareas fallidas
  List<DownloadTask> get failedTasks => _downloadService.failedTasks;

  /// Número total de tareas
  int get totalTasks => _tasks.length;

  /// Número de tareas activas
  int get activeCount => activeTasks.length;

  /// Inicializa el provider
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Suscribirse al stream de progreso
    _downloadService.progressStream.listen((task) {
      _tasks[task.id] = task;
      notifyListeners();
    });

    _isInitialized = true;
  }

  /// Inicia una descarga
  Future<DownloadTask?> startDownload(MediaItem item) async {
    try {
      // Verificar permisos
      final hasPermission = await _downloadService.checkStoragePermission();
      if (!hasPermission) {
        throw Exception('Permisos de almacenamiento denegados');
      }

      // Verificar si ya está en descarga
      if (isDownloading(item.id)) {
        debugPrint('El elemento ya está en descarga: ${item.title}');
        return getTask(item.id);
      }

      return await _downloadService.startDownload(item);
    } catch (e) {
      debugPrint('Error al iniciar descarga: $e');
      return null;
    }
  }

  /// Pausa una descarga
  void pauseDownload(String id) {
    _downloadService.pauseDownload(id);
  }

  /// Reanuda una descarga
  Future<void> resumeDownload(String id) async {
    await _downloadService.resumeDownload(id);
  }

  /// Cancela una descarga
  void cancelDownload(String id) {
    _downloadService.cancelDownload(id);
  }

  /// Elimina una tarea
  void removeTask(String id) {
    _downloadService.removeTask(id);
    _tasks.remove(id);
    notifyListeners();
  }

  /// Reintenta una descarga fallida
  Future<void> retryDownload(String id) async {
    await _downloadService.retryDownload(id);
  }

  /// Limpia tareas completadas
  void clearCompleted() {
    _downloadService.clearCompleted();
    final completedIds = _tasks.values
        .where((t) => t.status == DownloadStatus.completed)
        .map((t) => t.id);
    for (final id in completedIds) {
      _tasks.remove(id);
    }
    notifyListeners();
  }

  /// Verifica si un elemento está en descarga
  bool isDownloading(String mediaId) {
    return _downloadService.isDownloading(mediaId);
  }

  /// Obtiene una tarea por ID
  DownloadTask? getTask(String id) {
    return _tasks[id];
  }

  /// Obtiene el progreso de una tarea
  double getProgress(String id) {
    final task = _tasks[id];
    return task?.progress ?? 0.0;
  }

  /// Cierra el provider
  @override
  void dispose() {
    _downloadService.dispose();
    super.dispose();
  }
}
