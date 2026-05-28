/// Excepción lanzada por la capa de datos (repositorios / fuentes remotas).
/// Se convierte a [Failure] en la capa de dominio.
library;

/// Error HTTP o de parseo de respuesta del servidor.
class ServerException implements Exception {
  final String message;
  const ServerException({required this.message});

  @override
  String toString() => 'ServerException: $message';
}

/// Sin acceso a la red.
class NetworkException implements Exception {
  final String message;
  const NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}

/// Credenciales inválidas o token expirado.
class AuthException implements Exception {
  final String message;
  const AuthException({required this.message});

  @override
  String toString() => 'AuthException: $message';
}

/// Error al leer o escribir en el almacenamiento local.
class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}
