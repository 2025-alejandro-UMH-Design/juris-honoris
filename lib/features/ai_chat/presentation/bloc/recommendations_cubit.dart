import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:juris_honoris/core/constants/api_config.dart';

part 'recommendations_state.dart';

class RequiredDoc {
  final String name;
  final String description;
  final String institution;
  final String address;
  final String mapsQuery;

  const RequiredDoc({
    required this.name,
    required this.description,
    required this.institution,
    required this.address,
    required this.mapsQuery,
  });

  factory RequiredDoc.fromJson(Map<String, dynamic> j) => RequiredDoc(
        name: j['name']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        institution: j['institution']?.toString() ?? '',
        address: j['address']?.toString() ?? '',
        mapsQuery: j['maps_query']?.toString() ?? '',
      );
}

class RecommendationsCubit extends Cubit<RecommendationsState> {
  final Dio _dio;

  RecommendationsCubit({required Dio dio})
      : _dio = dio,
        super(const RecommendationsInitial());

  Future<void> loadRecommendations(String summary) async {
    emit(const RecommendationsLoading());
    try {
      final res = await _dio.post(
        '${ApiConfig.aiChat}/recommendations',
        data: {'summary': summary},
      );
      final docs = (res.data['documents'] as List? ?? [])
          .map((j) => RequiredDoc.fromJson(j as Map<String, dynamic>))
          .toList();
      emit(RecommendationsLoaded(docs));
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Error al cargar recomendaciones';
      emit(RecommendationsError(msg.toString()));
    } catch (_) {
      emit(const RecommendationsError('Error al cargar recomendaciones'));
    }
  }
}
