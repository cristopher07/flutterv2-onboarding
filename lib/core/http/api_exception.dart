/// Excepciones personalizadas para las llamadas HTTP
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException extends ApiException {
  NetworkException({String message = 'Error de conexión'})
      : super(message: message);
}

class ServerException extends ApiException {
  ServerException({
    required String message,
    required int statusCode,
  }) : super(message: message, statusCode: statusCode);
}

class BadRequestException extends ApiException {
  BadRequestException({String message = 'Solicitud inválida'})
      : super(message: message, statusCode: 400);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({String message = 'No autorizado'})
      : super(message: message, statusCode: 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException({String message = 'Acceso prohibido'})
      : super(message: message, statusCode: 403);
}

class NotFoundException extends ApiException {
  NotFoundException({String message = 'Recurso no encontrado'})
      : super(message: message, statusCode: 404);
}

class TimeoutException extends ApiException {
  TimeoutException({String message = 'Tiempo de espera agotado'})
      : super(message: message);
}
