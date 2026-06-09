/// Excepciones personalizadas para las llamadas HTTP.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException({required this.message, this.statusCode, this.originalError});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException extends ApiException {
  NetworkException({super.message = 'Error de conexion'});
}

class ServerException extends ApiException {
  ServerException({required super.message, required super.statusCode});
}

class BadRequestException extends ApiException {
  BadRequestException({super.message = 'Solicitud invalida'})
    : super(statusCode: 400);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({super.message = 'No autorizado'})
    : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException({super.message = 'Acceso prohibido'})
    : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  NotFoundException({super.message = 'Recurso no encontrado'})
    : super(statusCode: 404);
}

class TimeoutException extends ApiException {
  TimeoutException({super.message = 'Tiempo de espera agotado'});
}
