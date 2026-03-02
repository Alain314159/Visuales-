import 'dart:math' as math;
import 'media_item.dart';

/// Estado de una tarea de descarga
enum DownloadStatus {
  queued,      // En cola
  downloading, // Descargando
  paused,      // Pausada
  completed,   // Completada
  failed,      // Fallida
  cancelled,   // Cancelada
}

/// Modelo para tareas de descarga
class DownloadTask {
  final String id;
  final MediaItem media;
  final String savePath;
  final int totalBytes;
  final int downloadedBytes;
  final DownloadStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final int retryCount;
  final String? taskId;
  final String? errorMessage;

  const DownloadTask({
    required this.id,
    required this.media,
    required this.savePath,
    this.totalBytes = 0,
    this.downloadedBytes = 0,
    this.status = DownloadStatus.queued,
    required this.startTime,
    this.endTime,
    this.retryCount = 0,
    this.taskId,
    this.errorMessage,
  });

  factory DownloadTask.fromJson(Map<String, dynamic> json) {
    return DownloadTask(
      id: (json['id'] as String?)?.trim() ?? '',
      media: json['media'] is Map<String, dynamic>
          ? MediaItem.fromJson(json['media'] as Map<String, dynamic>)
          : const MediaItem(
              id: '',
              title: 'Unknown',
              type: MediaType.other,
              downloadUrl: '',
            ),
      savePath: (json['savePath'] as String?)?.trim() ?? '',
      totalBytes: json['totalBytes'] as int? ?? 0,
      downloadedBytes: json['downloadedBytes'] as int? ?? 0,
      status: json['status'] != null
          ? DownloadStatus.values.firstWhere(
              (e) => e.name == json['status'],
              orElse: () => DownloadStatus.queued,
            )
          : DownloadStatus.queued,
      startTime: DateTime.tryParse(json['startTime'] as String) ?? DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'] as String)
          : null,
      retryCount: json['retryCount'] as int? ?? 0,
      taskId: json['taskId'] as String?,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'media': media.toJson(),
      'savePath': savePath,
      'totalBytes': totalBytes,
      'downloadedBytes': downloadedBytes,
      'status': status.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'retryCount': retryCount,
      'taskId': taskId,
      'errorMessage': errorMessage,
    };
  }

  DownloadTask copyWith({
    String? id,
    MediaItem? media,
    String? savePath,
    int? totalBytes,
    int? downloadedBytes,
    DownloadStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    int? retryCount,
    String? taskId,
    String? errorMessage,
  }) {
    return DownloadTask(
      id: id ?? this.id,
      media: media ?? this.media,
      savePath: savePath ?? this.savePath,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      retryCount: retryCount ?? this.retryCount,
      taskId: taskId ?? this.taskId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Progreso de la descarga (0.0 a 1.0)
  double get progress {
    if (totalBytes == 0) return 0.0;
    return downloadedBytes / totalBytes;
  }

  /// Progreso en porcentaje
  int get progressPercent {
    return (progress * 100).toInt();
  }

  /// Tamaño descargado formateado
  String get downloadedFormatted {
    return _formatBytes(downloadedBytes);
  }

  /// Tamaño total formateado
  String get totalFormatted {
    return _formatBytes(totalBytes);
  }

  /// Tamaño restante formateado
  String get remainingFormatted {
    return _formatBytes(totalBytes - downloadedBytes);
  }

  /// Tiempo restante estimado (requiere velocidad)
  String remainingTime(int bytesPerSecond) {
    if (bytesPerSecond == 0) return '--:--';
    final remaining = totalBytes - downloadedBytes;
    final seconds = remaining ~/ bytesPerSecond;
    return _formatDuration(seconds);
  }

  static String _formatBytes(int bytes) {
    if (bytes == 0) return '0 B';
    const k = 1024;
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (math.log(bytes) / math.log(k)).floor();
    return '${(bytes / math.pow(k, i)).toStringAsFixed(2)} ${units[i]}';
  }

  static String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DownloadTask && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DownloadTask(id: $id, title: ${media.title}, status: ${status.name}, progress: ${progressPercent}%)';
  }
}
