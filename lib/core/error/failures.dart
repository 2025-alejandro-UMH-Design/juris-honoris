import 'package:equatable/equatable.dart';

/// Clase base para todos los fallos de dominio.
/// Representa errores recuperables de la capa de dominio.
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Error proveniente del servidor (HTTP 4xx / 5xx).
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

/// Sin conectividad de red.
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

/// Error de autenticación o autorización.
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

/// El recurso solicitado no existe.
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

/// Error no esperado ni clasificado.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message});
}
