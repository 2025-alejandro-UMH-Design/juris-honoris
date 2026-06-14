import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:juris_honoris/core/constants/api_config.dart';

class PlanStep {
  final int order;
  final String title;
  final String description;
  String status; // 'pending' | 'in_progress' | 'completed'

  PlanStep({
    required this.order,
    required this.title,
    required this.description,
    this.status = 'pending',
  });

  factory PlanStep.fromJson(Map<String, dynamic> j) => PlanStep(
        order: (j['order'] as num?)?.toInt() ?? 0,
        title: j['title']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
      );
}

class PlanData {
  final String title;
  final List<PlanStep> steps;
  const PlanData({required this.title, required this.steps});
  int get completedCount => steps.where((s) => s.status == 'completed').length;
  double get progress => steps.isEmpty ? 0.0 : completedCount / steps.length;
}

abstract class PlanState extends Equatable {
  const PlanState();
  @override
  List<Object?> get props => [];
}

class PlanInitial extends PlanState {
  const PlanInitial();
}

class PlanLoading extends PlanState {
  const PlanLoading();
}

class PlanLoaded extends PlanState {
  final PlanData plan;
  const PlanLoaded(this.plan);
  @override
  List<Object?> get props => [plan];
}

class PlanError extends PlanState {
  final String message;
  const PlanError(this.message);
  @override
  List<Object?> get props => [message];
}

class PlanCubit extends Cubit<PlanState> {
  final Dio _dio;

  PlanCubit({required Dio dio})
      : _dio = dio,
        super(const PlanInitial());

  Future<void> loadPlan(String summary) async {
    emit(const PlanLoading());
    try {
      final res = await _dio.post(
        '${ApiConfig.aiChat}/plan',
        data: {'summary': summary},
      );
      final steps = (res.data['steps'] as List? ?? [])
          .map((j) => PlanStep.fromJson(j as Map<String, dynamic>))
          .toList();
      emit(PlanLoaded(PlanData(
        title: res.data['title']?.toString() ?? 'Plan legal',
        steps: steps,
      )));
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Error al generar el plan';
      emit(PlanError(msg.toString()));
    } catch (_) {
      emit(const PlanError('Error al generar el plan'));
    }
  }

  void updateStepStatus(int order, String status) {
    if (state is! PlanLoaded) return;
    final current = (state as PlanLoaded).plan;
    for (final s in current.steps) {
      if (s.order == order) s.status = status;
    }
    emit(PlanLoaded(PlanData(title: current.title, steps: current.steps)));
  }
}
