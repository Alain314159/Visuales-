import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../config/constants.dart';

/// HTTP Service with connection pooling and memory optimization
class ApiService {
  static final ApiService _instance = ApiService._internal();
  
  final Dio _dio;
  final Connectivity _connectivity;

  factory ApiService({Dio? dio, Connectivity? connectivity}) {
    return _instance;
  }

  ApiService._internal({Dio? dio, Connectivity? connectivity})
      : _dio = dio ??
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
        _connectivity = connectivity ?? Connectivity();

  /// Verifica si hay conexión a internet
  Future<bool> isConnected() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult.any((result) => 
          result != ConnectivityResult.none);
    } catch (e) {
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
    return _connectivity.onConnectivityChanged
        .map((results) => results.isEmpty ? ConnectivityResult.none : results.first);
  }

  /// Obtiene el listado principal (TXT)
  Future<String> fetchListado() async {
    try {
      final response = await _dio.get('/listado.txt');
      if (response.data is String) {
        return response.data as String;
      }
      return response.data.toString();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Intenta con listado.html
        return fetchListadoHtml();
      }
      throw _handleError(e);
    } catch (e) {
      throw Exception('Error al obtener el listado: $e');
    }
  }

  /// Obtiene el listado principal (HTML)
  Future<String> fetchListadoHtml() async {
    try {
      final response = await _dio.get('/listado.html');
      if (response.data is String) {
        return response.data as String;
      }
      return response.data.toString();
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Error al obtener el listado HTML: $e');
    }
  }

  /// Obtiene el índice de una carpeta/categoría
  Future<String> fetchDirectoryIndex(String path) async {
    try {
      final response = await _dio.get(path);
      if (response.data is String) {
        return response.data as String;
      }
      return response.data.toString();
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Error al obtener el índice del directorio: $e');
    }
  }

  /// Obtiene los headers de un archivo (para tamaño)
  Future<Map<String, dynamic>> getFileHeaders(String url) async {
    try {
      final response = await _dio.head(
        url.contains('http') ? url : '${Constants.baseUrl}$url',
      );
      return {
        'contentLength': response.headers.value('content-length'),
        'contentType': response.headers.value('content-type'),
        'lastModified': response.headers.value('last-modified'),
      };
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Error al obtener información del archivo: $e');
    }
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
