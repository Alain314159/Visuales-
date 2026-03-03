import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import '../config/constants.dart';

/// HTTP Service con connection pooling, retry con exponential backoff y logging
class ApiService {
  static final ApiService _instance = ApiService._internal();

  final Dio _dio;
  final Connectivity _connectivity;
  final Logger _logger;

  factory ApiService({Dio? dio, Connectivity? connectivity, Logger? logger}) {
    return _instance;
  }

  ApiService._internal({
    Dio? dio,
    Connectivity? connectivity,
    Logger? logger,
  })  : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: Constants.baseUrl,
              connectTimeout: Constants.connectionTimeout,
              receiveTimeout: Constants.receiveTimeout,
              sendTimeout: Constants.sendTimeout,
              headers: {
                'Accept': '*/*',
                'User-Agent': 'VisualesUCLV/1.0',
              },
            )),
        _connectivity = connectivity ?? Connectivity(),
        _logger = logger ?? Logger();

  /// Verifica si hay conexión a internet
  Future<bool> isConnected() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult
          .any((result) => result != ConnectivityResult.none);
    } catch (e) {
      _logger.e('Error al verificar conexión: $e');
      return false;
    }
  }

  /// Obtiene el tipo de conexión
  Future<ConnectivityResult> getConnectionType() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.isEmpty) {
        return ConnectivityResult.none;
      }
      return connectivityResult.first;
    } catch (e) {
      return ConnectivityResult.none;
    }
  }

  /// Escucha los cambios de conectividad
  Stream<ConnectivityResult> onConnectivityChanged() {
    return _connectivity.onConnectivityChanged.map(
        (results) => results.isEmpty ? ConnectivityResult.none : results.first);
  }

  /// Obtiene el listado principal (TXT) con retry
  Future<String> fetchListado() async {
    return _executeWithRetry(
      () async {
        final response = await _dio.get('/listado.txt');
        if (response.data is String) {
          return response.data as String;
        }
        return response.data.toString();
      },
      operationName: 'fetchListado',
      fallback: fetchListadoHtml,
    );
  }

  /// Obtiene el listado principal (HTML) con retry
  Future<String> fetchListadoHtml() async {
    return _executeWithRetry(
      () async {
        final response = await _dio.get('/listado.html');
        if (response.data is String) {
          return response.data as String;
        }
        return response.data.toString();
      },
      operationName: 'fetchListadoHtml',
    );
  }

  /// Obtiene el índice de una carpeta/categoría con retry
  Future<String> fetchDirectoryIndex(String path) async {
    return _executeWithRetry(
      () async {
        final response = await _dio.get(path);
        if (response.data is String) {
          return response.data as String;
        }
        return response.data.toString();
      },
      operationName: 'fetchDirectoryIndex',
    );
  }

  /// Obtiene los headers de un archivo (para tamaño)
  Future<Map<String, dynamic>> getFileHeaders(String url) async {
    return _executeWithRetry(
      () async {
        final response = await _dio.head(
          url.contains('http') ? url : '${Constants.baseUrl}$url',
        );
        return {
          'contentLength': response.headers.value('content-length'),
          'contentType': response.headers.value('content-type'),
          'lastModified': response.headers.value('last-modified'),
        };
      },
      operationName: 'getFileHeaders',
    );
  }

  /// Descarga un archivo y devuelve el stream de bytes
  Future<Response<ResponseBody>> downloadFile(String url) async {
    return await _dio.get<ResponseBody>(
      url.contains('http') ? url : '${Constants.baseUrl}$url',
      options: Options(
        responseType: ResponseType.stream,
      ),
    );
  }

  /// Verifica si una URL existe
  Future<bool> urlExists(String url) async {
    try {
      final response = await _dio.head(
        url.contains('http') ? url : '${Constants.baseUrl}$url',
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Ejecuta una operación con retry y exponential backoff
  ///
  /// [operation] - La operación a ejecutar
  /// [operationName] - Nombre de la operación para logging
  /// [maxRetries] - Número máximo de reintentos
  /// [fallback] - Función fallback si la operación principal falla
  Future<T> _executeWithRetry<T>({
    required Future<T> Function() operation,
    required String operationName,
    int maxRetries = 3,
    Future<T> Function()? fallback,
  }) async {
    int retryCount = 0;
    Exception? lastException;

    while (retryCount < maxRetries) {
      try {
        _logger.d('📡 $operationName (intento ${retryCount + 1}/$maxRetries)');
        final result = await operation();
        if (retryCount > 0) {
          _logger
              .i('✅ $operationName exitoso después de $retryCount reintentos');
        }
        return result;
      } on DioException catch (e) {
        lastException = _handleError(e);
        retryCount++;

        if (retryCount < maxRetries) {
          // Exponential backoff: 1s, 2s, 4s, 8s...
          final delay = Duration(seconds: 1 << retryCount);
          _logger.w(
              '⚠️ $operationName falló, reintentando en ${delay.inSeconds}s...');
          await Future.delayed(delay);
        }
      } catch (e) {
        lastException = Exception('Error en $operationName: $e');
        retryCount++;

        if (retryCount < maxRetries) {
          final delay = Duration(seconds: 1 << retryCount);
          await Future.delayed(delay);
        }
      }
    }

    // Si hay fallback, intentarlo
    if (fallback != null) {
      try {
        _logger.d('🔄 Usando fallback para $operationName');
        return await fallback();
      } catch (e) {
        _logger.e('❌ Fallback también falló: $e');
      }
    }

    throw lastException ?? Exception('Error desconocido en $operationName');
  }

  /// Maneja errores de Dio
  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Tiempo de espera agotado');
      case DioExceptionType.badResponse:
        switch (e.response?.statusCode) {
          case 404:
            return Exception('Recurso no encontrado');
          case 403:
            return Exception('Acceso denegado');
          case 500:
          case 502:
          case 503:
            return Exception('Servidor no disponible');
          default:
            return Exception('Error HTTP: ${e.response?.statusCode}');
        }
      case DioExceptionType.cancel:
        return Exception('Petición cancelada');
      case DioExceptionType.connectionError:
        return Exception('Error de conexión');
      case DioExceptionType.badCertificate:
        return Exception('Certificado inválido');
      case DioExceptionType.unknown:
      default:
        return Exception('Error desconocido: $e');
    }
  }

  /// Cancela todas las peticiones pendientes
  void cancelAll() {
    _dio.close(force: true);
  }
}
