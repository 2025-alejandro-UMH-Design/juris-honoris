import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:juris_honoris/features/auth/domain/entities/user_entity.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  UserEntity? _currentUser;

  static const _uuid = Uuid();

  AuthCubit() : super(const AuthInitial());

  UserEntity? get currentUser => _currentUser;

  bool get isAdmin => _currentUser?.role == UserRole.admin;

  bool get isLawyer => _currentUser?.role == UserRole.lawyer;

  /// Simula login por email/contraseña.
  /// Reglas demo:
  ///   email contiene 'admin'   → role=admin
  ///   email contiene 'abogado' → role=lawyer
  ///   cualquier otro           → role=client
  Future<void> loginWithEmail(String email, String password) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1200));

    try {
      final role = _roleFromEmail(email);
      final user = _buildMockUser(email: email, role: role);
      _currentUser = user;
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('Error al iniciar sesión: $e'));
    }
  }

  /// Demo: crea usuario client con Google.
  Future<void> loginWithGoogle() async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      const email = 'usuario.google@gmail.com';
      final user = _buildMockUser(
        email: email,
        role: UserRole.client,
        name: 'Usuario Google',
      );
      _currentUser = user;
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('Error al iniciar sesión con Google: $e'));
    }
  }

  /// Demo: crea usuario con rol según isLawyer.
  Future<void> register({
    required String email,
    required String password,
    required bool isLawyer,
  }) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1200));

    try {
      final role = isLawyer ? UserRole.lawyer : UserRole.client;
      final user = _buildMockUser(email: email, role: role);
      _currentUser = user;
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('Error al crear cuenta: $e'));
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    emit(const AuthUnauthenticated());
  }

  // ------------------------------------------------------------------ //
  //  Helpers privados
  // ------------------------------------------------------------------ //

  UserRole _roleFromEmail(String email) {
    final lower = email.toLowerCase();
    if (lower.contains('admin')) return UserRole.admin;
    if (lower.contains('abogado')) return UserRole.lawyer;
    return UserRole.client;
  }

  UserEntity _buildMockUser({
    required String email,
    required UserRole role,
    String? name,
  }) {
    return UserEntity(
      id: _uuid.v4(),
      email: email,
      name: name ?? email.split('@').first,
      role: role,
      plan: UserPlan.free,
      isVerified: true,
      solicitationsThisMonth: 0,
      createdAt: DateTime.now(),
    );
  }
}
