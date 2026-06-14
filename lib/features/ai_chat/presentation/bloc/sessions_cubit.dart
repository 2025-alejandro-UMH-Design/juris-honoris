import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:juris_honoris/core/constants/api_config.dart';

class AISession extends Equatable {
  final String id;
  final String title;
  final bool? needsLawyer;
  final DateTime updatedAt;

  const AISession({
    required this.id,
    required this.title,
    required this.needsLawyer,
    required this.updatedAt,
  });

  factory AISession.fromJson(Map<String, dynamic> j) => AISession(
        id: j['id']?.toString() ?? '',
        title: j['title']?.toString() ?? 'Consulta legal',
        needsLawyer: j['needs_lawyer'] == true
            ? true
            : j['needs_lawyer'] == false
                ? false
                : null,
        updatedAt: j['updated_at'] != null
            ? DateTime.tryParse(j['updated_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );

  @override
  List<Object?> get props => [id];
}

abstract class SessionsState extends Equatable {
  const SessionsState();
  @override
  List<Object?> get props => [];
}

class SessionsInitial extends SessionsState {
  const SessionsInitial();
}

class SessionsLoading extends SessionsState {
  const SessionsLoading();
}

class SessionsLoaded extends SessionsState {
  final List<AISession> sessions;
  const SessionsLoaded(this.sessions);
  @override
  List<Object?> get props => [sessions];
}

class SessionsError extends SessionsState {
  final String message;
  const SessionsError(this.message);
  @override
  List<Object?> get props => [message];
}

class SessionsCubit extends Cubit<SessionsState> {
  final Dio _dio;

  SessionsCubit({required Dio dio})
      : _dio = dio,
        super(const SessionsInitial());

  Future<void> load() async {
    emit(const SessionsLoading());
    try {
      final res = await _dio.get('${ApiConfig.aiChat}/sessions');
      final list = (res.data as List)
          .map((j) => AISession.fromJson(j as Map<String, dynamic>))
          .toList();
      emit(SessionsLoaded(list));
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Error al cargar historial';
      emit(SessionsError(msg.toString()));
    } catch (_) {
      emit(const SessionsError('Error al cargar historial'));
    }
  }

  Future<void> saveSession(String title, bool? needsLawyer) async {
    try {
      final cleanTitle = title.length > 80 ? '${title.substring(0, 77)}...' : title;
      final res = await _dio.post(
        '${ApiConfig.aiChat}/sessions',
        data: {'title': cleanTitle},
      );
      final id = res.data['id']?.toString();
      if (id != null && needsLawyer != null) {
        await _dio.put(
          '${ApiConfig.aiChat}/sessions/$id',
          data: {'needs_lawyer': needsLawyer},
        );
      }
    } catch (_) {}
  }
}
