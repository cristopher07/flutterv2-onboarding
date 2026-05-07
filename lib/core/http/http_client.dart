import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_exception.dart';

class HttpClient {
  final String baseUrl;
  final Duration timeout;
  final Map<String, String> defaultHeaders;

  HttpClient({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    Map<String, String>? defaultHeaders,
  }) : defaultHeaders = defaultHeaders ?? {'Content-Type': 'application/json'};

  /// GET request
  Future<T> get<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$endpoint'),
            headers: {...defaultHeaders, ...?headers},
          )
          .timeout(timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<T> post<T>({
    required String endpoint,
    required dynamic body,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {...defaultHeaders, ...?headers},
            body: jsonEncode(body),
          )
          .timeout(timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<T> put<T>({
    required String endpoint,
    required dynamic body,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: {...defaultHeaders, ...?headers},
            body: jsonEncode(body),
          )
          .timeout(timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<T> delete<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: {...defaultHeaders, ...?headers},
          )
          .timeout(timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }


  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    switch (response.statusCode) {
      case 200:
      case 201:
        final jsonResponse = jsonDecode(response.body);
        return fromJson(jsonResponse);
      case 400:
        throw BadRequestException();
      case 401:
        throw UnauthorizedException();
      case 403:
        throw ForbiddenException();
      case 404:
        throw NotFoundException();
      case 500:
      case 502:
      case 503:
        throw ServerException(
          message: 'Error del servidor',
          statusCode: response.statusCode,
        );
      default:
        throw ApiException(
          message: 'Error HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
    }
  }

  
  ApiException _handleError(dynamic error) {
    if (error is TimeoutException ||
        error is http.ClientException &&
            error.toString().contains('timed out')) {
      return TimeoutException();
    }
    return NetworkException(
      message: error.toString(),
    );
  }
}
