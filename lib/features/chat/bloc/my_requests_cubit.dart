import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:juris_honoris/core/constants/api_config.dart';

class AcceptedRequest extends Equatable {
  final String id;
  final String lawyerName;
  final String lawyerId;
  final String caseType;
  final DateTime createdAt;

  const AcceptedRequest({
    required this.id,
    required this.lawyerName,
    required this.lawyerId,
    required this.caseType,
    required this.createdAt,
  });

  factory AcceptedRequest.fromJson(Map<String, dynamic> j) => AcceptedRequest(
        id: j['id']?.toString() ?? '',
        lawyerName: j['lawyer_name']?.toString() ?? 'Abogado',
        lawyerId: j['lawyer_id']?.toString() ?? '',
        caseType: j['case_type']?.toString() ?? 'Caso legal',
        createdAt: j['created_at'] != null
            ? DateTime.tryParse(j['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );

  @override
  List<Object?> get props => [id];
}

abstract class MyRequestsState extends Equatable {
  const MyRequestsState();
  @override
  List<Object?> get props => [];
}

class MyRequestsInitial extends MyRequestsState {
  const MyRequestsInitial();
}

class MyRequestsLoaded extends MyRequestsState {
  final List<AcceptedRequest> requests;
  const MyRequestsLoaded(this.requests);
  @override
  List<Object?> get props => [requests];
}

class MyRequestsError extends MyRequestsState {
  final String message;
  const MyRequestsError(this.message);
  @override
  List<Object?> get props => [message];
}

class MyRequestsCubit extends Cubit<MyRequestsState> {
  final Dio _dio;

  MyRequestsCubit({required Dio dio})
      : _dio = dio,
        super(const MyRequestsInitial());

  Future<void> load() async {
    try {
      final res = await _dio.get(
        ApiConfig.requests,
        queryParameters: {'status': 'accepted'},
      );
      final list = (res.data as List)
          .map((j) => AcceptedRequest.fromJson(j as Map<String, dynamic>))
          .toList();
      emit(MyRequestsLoaded(list));
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Error al cargar solicitudes';
      emit(MyRequestsError(msg.toString()));
    } catch (_) {
      emit(const MyRequestsError('Error al cargar solicitudes'));
    }
  }
}
