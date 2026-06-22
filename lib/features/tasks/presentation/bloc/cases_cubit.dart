import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:juris_honoris/core/constants/api_config.dart';
import 'package:juris_honoris/features/tasks/presentation/pages/tasks_page.dart';

part 'cases_state.dart';

class CasesCubit extends Cubit<CasesState> {
  final Dio _dio;

  CasesCubit({required Dio dio})
      : _dio = dio,
        super(const CasesInitial());

  Future<void> loadCases() async {
    emit(const CasesLoading());
    try {
      final res = await _dio.get(ApiConfig.cases);
      final cases = (res.data as List)
          .map((j) => TaskData.fromJson(j as Map<String, dynamic>))
          .toList();
      emit(CasesLoaded(cases));
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Error al cargar casos';
      emit(CasesError(msg.toString()));
    } catch (_) {
      emit(const CasesError('Error al cargar casos'));
    }
  }

  Future<void> createCase({
    required String title,
    required String description,
    required String category,
    required String priority,
    String? dueDate,
  }) async {
    try {
      final res = await _dio.post(ApiConfig.cases, data: {
        'title': title,
        'description': description,
        'category': category,
        'priority': priority,
        if (dueDate != null) 'due_date': dueDate,
      });
      final created = TaskData.fromJson(res.data as Map<String, dynamic>);
      final current = state is CasesLoaded ? (state as CasesLoaded).cases : <TaskData>[];
      emit(CasesLoaded([created, ...current]));
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Error al crear caso';
      emit(CasesError(msg.toString()));
    } catch (_) {
      emit(const CasesError('Error al crear caso'));
    }
  }

  Future<void> updateStatus(String caseId, String status) async {
    try {
      await _dio.put('${ApiConfig.cases}/$caseId', data: {'status': status});
      await loadCases();
    } catch (_) {}
  }

  Future<bool> saveNotes(
    String caseId,
    String notes, {
    List<String>? completedSteps,
  }) async {
    try {
      await _dio.put('${ApiConfig.cases}/$caseId', data: {
        'notes': notes,
        if (completedSteps != null) 'completed_steps': completedSteps,
      });
      if (state is CasesLoaded) {
        final updated = (state as CasesLoaded).cases.map((c) {
          if (c.id == caseId) c.notes = notes;
          return c;
        }).toList();
        emit(CasesLoaded(updated));
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteCase(String caseId) async {
    try {
      await _dio.delete('${ApiConfig.cases}/$caseId');
      if (state is CasesLoaded) {
        final updated = (state as CasesLoaded).cases
            .where((c) => c.id != caseId)
            .toList();
        emit(CasesLoaded(updated));
      }
    } catch (_) {}
  }
}
