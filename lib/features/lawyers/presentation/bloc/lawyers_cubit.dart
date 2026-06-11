import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:juris_honoris/core/constants/api_config.dart';
import 'package:juris_honoris/features/home/presentation/widgets/lawyer_card.dart';

part 'lawyers_state.dart';

class LawyersCubit extends Cubit<LawyersState> {
  final Dio _dio;

  LawyersCubit({required Dio dio})
      : _dio = dio,
        super(const LawyersInitial());

  Future<void> loadLawyers({String? search, String? specialty}) async {
    emit(const LawyersLoading());
    try {
      final params = <String, dynamic>{};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (specialty != null && specialty.isNotEmpty) params['specialty'] = specialty;

      final res = await _dio.get(ApiConfig.lawyers, queryParameters: params);
      final lawyers = (res.data as List)
          .map((j) => LawyerData.fromJson(j as Map<String, dynamic>))
          .toList();
      emit(LawyersLoaded(lawyers));
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Error al cargar abogados';
      emit(LawyersError(msg.toString()));
    } catch (_) {
      emit(const LawyersError('Error al cargar abogados'));
    }
  }

  Future<void> loadProfile(String lawyerId) async {
    emit(const LawyersLoading());
    try {
      final res = await _dio.get('${ApiConfig.lawyers}/$lawyerId');
      final lawyer = LawyerData.fromJson(res.data as Map<String, dynamic>);
      emit(LawyerProfileLoaded(lawyer));
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Error al cargar perfil';
      emit(LawyersError(msg.toString()));
    } catch (_) {
      emit(const LawyersError('Error al cargar perfil'));
    }
  }

  Future<void> sendRequest({
    required String lawyerId,
    required String subject,
    required String description,
  }) async {
    emit(const LawyersLoading());
    try {
      await _dio.post(ApiConfig.requests, data: {
        'lawyer_id': lawyerId,
        'subject': subject,
        'description': description,
      });
      emit(const LawyerRequestSent());
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Error al enviar solicitud';
      emit(LawyersError(msg.toString()));
    } catch (_) {
      emit(const LawyersError('Error al enviar solicitud'));
    }
  }
}
