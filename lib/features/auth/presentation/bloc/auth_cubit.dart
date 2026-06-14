import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:juris_honoris/core/constants/api_config.dart';
import 'package:juris_honoris/core/services/token_storage.dart';
import 'package:juris_honoris/features/auth/domain/entities/user_entity.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  static const _webClientId =
      '458412357656-oc6repf7lraquaca37i1gu6e79cujqh1.apps.googleusercontent.com';

  UserEntity? _currentUser;

  AuthCubit({required Dio dio, required TokenStorage tokenStorage})
      : _dio = dio,
        _tokenStorage = tokenStorage,
        super(const AuthInitial());

  UserEntity? get currentUser => _currentUser;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isLawyer => _currentUser?.role == UserRole.lawyer;

  /// Intenta restaurar sesión desde el token guardado.
  Future<void> tryRestoreSession() async {
    final token = _tokenStorage.token;
    if (token == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    try {
      final res = await _dio.get('${ApiConfig.auth}/me');
      final user = UserEntity.fromJson(res.data as Map<String, dynamic>);
      _currentUser = user;
      emit(AuthAuthenticated(user));
    } catch (_) {
      await _tokenStorage.clear();
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    emit(const AuthLoading());
    try {
      final res = await _dio.post(
        '${ApiConfig.auth}/login',
        data: {'email': email.trim(), 'password': password},
      );
      final token = res.data['token'] as String;
      await _tokenStorage.save(token);

      final user =
          UserEntity.fromJson(res.data['user'] as Map<String, dynamic>);
      _currentUser = user;
      emit(AuthAuthenticated(user));
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Credenciales incorrectas';
      emit(AuthError(msg.toString()));
    } catch (e) {
      emit(const AuthError('Error al iniciar sesión'));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    emit(const AuthLoading());
    try {
      final res = await _dio.post(
        '${ApiConfig.auth}/register',
        data: {
          'email': email.trim(),
          'password': password,
          'full_name': fullName,
          'phone': phone
        },
      );
      final token = res.data['token'] as String;
      await _tokenStorage.save(token);

      final user =
          UserEntity.fromJson(res.data['user'] as Map<String, dynamic>);
      _currentUser = user;
      emit(AuthAuthenticated(user));
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Error al crear cuenta';
      emit(AuthError(msg.toString()));
    } catch (e) {
      emit(const AuthError('Error al crear cuenta'));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      final googleSignIn = GoogleSignIn(serverClientId: _webClientId);
      final account = await googleSignIn.signIn();
      if (account == null) {
        emit(const AuthUnauthenticated());
        return;
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('No se pudo obtener token de Google');

      final res = await _dio.post(
        '${ApiConfig.auth}/google',
        data: {'id_token': idToken},
      );
      final token = res.data['token'] as String;
      await _tokenStorage.save(token);
      final user = UserEntity.fromJson(res.data['user'] as Map<String, dynamic>);
      _currentUser = user;
      emit(AuthAuthenticated(user));
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Error al iniciar con Google';
      emit(AuthError(msg.toString()));
    } catch (_) {
      emit(const AuthError('Error al iniciar sesión con Google'));
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    _currentUser = null;
    emit(const AuthUnauthenticated());
  }
}
