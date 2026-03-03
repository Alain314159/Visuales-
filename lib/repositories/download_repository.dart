/// Contrato para operaciones de repositorio de descargas
abstract class DownloadRepository {
  /// Inicia una descarga
  Future<DownloadTask> startDownload(MediaItem item, {String? savePath});

  /// Pausa una descarga
  Future<void> pauseDownload(String id);

  /// Reanuda una descarga
  Future<void> resumeDownload(String id);

  /// Cancela una descarga
  Future<void> cancelDownload(String id);

  /// Elimina una tarea
  Future<void> removeTask(String id);

  /// Reintenta una descarga
  Future<void> retryDownload(String id);

  /// Obtiene todas las tareas
  List<DownloadTask> getAllTasks();

  /// Obtiene tareas activas
  List<DownloadTask> getActiveTasks();

  /// Obtiene tareas completadas
  List<DownloadTask> getCompletedTasks();

  /// Limpia tareas completadas
  Future<void> clearCompleted();

  /// Stream de progreso
  Stream<DownloadTask> get progressStream;

  /// Verifica si está descargando
  bool isDownloading(String mediaId);

  /// Verifica permisos de almacenamiento
  Future<bool> checkStoragePermission();

  /// Obtiene ruta de descargas
  Future<String> getDownloadPath();
}
