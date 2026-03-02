import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/media_item.dart';
import '../models/download_task.dart';
import '../config/constants.dart';

/// Servicio de descargas
class DownloadService {
  final Dio _dio;
  final Map<String, DownloadTask> _tasks = {};
  final Map<String, CancelToken> _cancelTokens = {};
  final StreamController<DownloadTask> _progressController =
      StreamController<DownloadTask>.broadcast();

  DownloadService({Dio? dio}) : _dio = dio ?? Dio();

  /// Stream de progreso de descargas
  Stream<DownloadTask> get progressStream => _progressController.stream;

  /// Obtiene todas las tareas de descarga
  List<DownloadTask> get allTasks => _tasks.values.toList();

  /// Obtiene tareas activas
  List<DownloadTask> get activeTasks {
    return _tasks.values
        .where((t) =>
            t.status == DownloadStatus.downloading ||
            t.status == DownloadStatus.queued)
        .toList();
  }

  /// Obtiene tareas completadas
  List<DownloadTask> get completedTasks {
    return _tasks.values.where((t) => t.status == DownloadStatus.completed).toList();
  }

  /// Obtiene tareas fallidas
  List<DownloadTask> get failedTasks {
    return _tasks.values.where((t) => t.status == DownloadStatus.failed).toList();
  }

  /// Verifica permisos de almacenamiento
  Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final requested = await Permission.storage.request();
        return requested.isGranted;
      }
      return status.isGranted;
    }
    return true;
  }

  /// Obtiene la ruta de descargas
  Future<String> getDownloadPath() async {
    Directory? directory;
    
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
      if (directory != null) {
        final path = '${directory.path}/../..${Constants.defaultDownloadPath}';
        final dir = Directory(path);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        return path;
      }
    }
    
    directory = await getDownloadsDirectory();
    if (directory != null) {
      final path = '${directory.path}/Visuales';
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return path;
    }
    
    return Constants.defaultDownloadPath;
  }

  /// Inicia una descarga
  Future<DownloadTask> startDownload(
    MediaItem item, {
    String? savePath,
  }) async {
    final path = savePath ?? await getDownloadPath();
    final taskId = item.id;
    
    // Verificar si ya existe una descarga
    if (_tasks.containsKey(taskId)) {
      final existingTask = _tasks[taskId]!;
      if (existingTask.status == DownloadStatus.downloading) {
        return existingTask;
      }
    }

    // Crear tarea
    final task = DownloadTask(
      id: taskId,
      media: item,
      savePath: path,
      status: DownloadStatus.queued,
      startTime: DateTime.now(),
    );

    _tasks[taskId] = task;
    _progressController.add(task);

    // Iniciar descarga en segundo plano
    _downloadFile(task, item.downloadUrl, path);

    return task;
  }

  /// Descarga un archivo
  Future<void> _downloadFile(
    DownloadTask task,
    String url,
    String savePath,
  ) async {
    final cancelToken = CancelToken();
    _cancelTokens[task.id] = cancelToken;

    try {
      // Actualizar estado a descargando
      _updateTask(task.id, status: DownloadStatus.downloading);

      // Nombre del archivo
      final fileName = _sanitizeFileName(task.media.title);
      final filePath = '$savePath/$fileName';

      // Obtener tamaño del archivo
      final response = await _dio.head(url);
      final totalBytes = int.tryParse(
            response.headers.value('content-length') ?? '0',
          ) ??
          0;

      _updateTask(task.id, totalBytes: totalBytes);

      // Descargar archivo
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _updateTask(
              task.id,
              downloadedBytes: received,
              totalBytes: total,
            );
          }
        },
        cancelToken: cancelToken,
      );

      // Descarga completada
      _updateTask(
        task.id,
        status: DownloadStatus.completed,
        endTime: DateTime.now(),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        _updateTask(task.id, status: DownloadStatus.cancelled);
      } else {
        _updateTask(
          task.id,
          status: DownloadStatus.failed,
          errorMessage: e.message,
          endTime: DateTime.now(),
        );
      }
    } catch (e) {
      _updateTask(
        task.id,
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
        endTime: DateTime.now(),
      );
    } finally {
      _cancelTokens.remove(task.id);
    }
  }

  /// Actualiza una tarea de descarga
  void _updateTask(
    String id, {
    DownloadStatus? status,
    int? downloadedBytes,
    int? totalBytes,
    DateTime? endTime,
    String? errorMessage,
  }) {
    if (!_tasks.containsKey(id)) return;

    final task = _tasks[id]!;
    final updatedTask = task.copyWith(
      status: status,
      downloadedBytes: downloadedBytes,
      totalBytes: totalBytes,
      endTime: endTime,
      errorMessage: errorMessage,
    );

    _tasks[id] = updatedTask;
    _progressController.add(updatedTask);
  }

  /// Pausa una descarga
  void pauseDownload(String id) {
    if (!_tasks.containsKey(id)) return;
    
    final task = _tasks[id]!;
    if (task.status != DownloadStatus.downloading) return;

    // Cancelar la descarga
    _cancelTokens[id]?.cancel('Paused by user');
    _updateTask(id, status: DownloadStatus.paused);
  }

  /// Reanuda una descarga
  Future<void> resumeDownload(String id) async {
    if (!_tasks.containsKey(id)) return;

    final task = _tasks[id]!;
    if (task.status != DownloadStatus.paused) return;

    // Reiniciar descarga
    _downloadFile(task, task.media.downloadUrl, task.savePath);
  }

  /// Cancela una descarga
  void cancelDownload(String id) {
    if (!_tasks.containsKey(id)) return;

    final task = _tasks[id]!;
    if (task.status == DownloadStatus.completed ||
        task.status == DownloadStatus.cancelled) {
      return;
    }

    _cancelTokens[id]?.cancel('Cancelled by user');
    _updateTask(id, status: DownloadStatus.cancelled);
  }

  /// Elimina una tarea de descarga
  void removeTask(String id) {
    _tasks.remove(id);
    _cancelTokens.remove(id);
  }

  /// Reintenta una descarga fallida
  Future<void> retryDownload(String id) async {
    if (!_tasks.containsKey(id)) return;

    final task = _tasks[id]!;
    if (task.status != DownloadStatus.failed &&
        task.status != DownloadStatus.cancelled) {
      return;
    }

    // Reiniciar con retry count incrementado
    final newTask = task.copyWith(
      status: DownloadStatus.queued,
      retryCount: task.retryCount + 1,
      errorMessage: null,
      downloadedBytes: 0,
      startTime: DateTime.now(),
    );

    _tasks[id] = newTask;
    _downloadFile(newTask, task.media.downloadUrl, task.savePath);
  }

  /// Limpia tareas completadas
  void clearCompleted() {
    final completedIds =
        _tasks.values.where((t) => t.status == DownloadStatus.completed).map((t) => t.id);
    for (final id in completedIds) {
      _tasks.remove(id);
      _cancelTokens.remove(id);
    }
  }

  /// Obtiene una tarea por ID
  DownloadTask? getTask(String id) {
    return _tasks[id];
  }

  /// Verifica si un elemento está en descarga
  bool isDownloading(String mediaId) {
    final task = _tasks[mediaId];
    return task != null &&
        (task.status == DownloadStatus.downloading ||
            task.status == DownloadStatus.queued ||
            task.status == DownloadStatus.paused);
  }

  /// Sanitiza nombre de archivo
  String _sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }

  /// Cierra el servicio
  void dispose() {
    // Cancelar todas las descargas activas
    for (final token in _cancelTokens.values) {
      token.cancel('Service disposed');
    }
    _progressController.close();
  }
}
