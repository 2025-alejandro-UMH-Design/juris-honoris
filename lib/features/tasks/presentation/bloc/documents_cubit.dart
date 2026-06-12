import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:juris_honoris/core/constants/api_config.dart';

part 'documents_state.dart';

class DocumentData {
  final String id;
  final String caseId;
  final String name;
  final String filePath;
  final String fileType;
  final int fileSizeBytes;
  final String uploadedByName;
  final DateTime createdAt;

  const DocumentData({
    required this.id,
    required this.caseId,
    required this.name,
    required this.filePath,
    required this.fileType,
    required this.fileSizeBytes,
    required this.uploadedByName,
    required this.createdAt,
  });

  factory DocumentData.fromJson(Map<String, dynamic> j) => DocumentData(
        id: j['id']?.toString() ?? '',
        caseId: j['case_id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        filePath: j['file_path']?.toString() ?? '',
        fileType: j['file_type']?.toString() ?? '',
        fileSizeBytes: (j['file_size_bytes'] as num?)?.toInt() ?? 0,
        uploadedByName: j['uploaded_by_name']?.toString() ?? '',
        createdAt: DateTime.tryParse(j['created_at']?.toString() ?? '') ??
            DateTime.now(),
      );

  bool get isImage => fileType.startsWith('image/');
}

class DocumentsCubit extends Cubit<DocumentsState> {
  final Dio _dio;

  DocumentsCubit({required Dio dio})
      : _dio = dio,
        super(const DocumentsInitial());

  Future<void> loadDocuments(String caseId) async {
    emit(const DocumentsLoading());
    try {
      final res = await _dio.get('${ApiConfig.cases}/$caseId/documents');
      final docs = (res.data as List)
          .map((j) => DocumentData.fromJson(j as Map<String, dynamic>))
          .toList();
      emit(DocumentsLoaded(docs));
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Error al cargar documentos';
      emit(DocumentsError(msg.toString()));
    } catch (_) {
      emit(const DocumentsError('Error al cargar documentos'));
    }
  }

  Future<void> uploadDocument({
    required String caseId,
    required String filePath,
    required String mimeType,
    required String fileName,
  }) async {
    final current = state is DocumentsLoaded
        ? (state as DocumentsLoaded).docs
        : <DocumentData>[];
    emit(DocumentsUploading(current));
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath,
            filename: fileName, contentType: DioMediaType.parse(mimeType)),
        'name': fileName,
      });
      final res = await _dio.post(
        '${ApiConfig.cases}/$caseId/documents',
        data: formData,
      );
      final created = DocumentData.fromJson(res.data as Map<String, dynamic>);
      emit(DocumentsLoaded([created, ...current]));
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Error al subir documento';
      emit(DocumentsError(msg.toString()));
      emit(DocumentsLoaded(current));
    } catch (_) {
      emit(const DocumentsError('Error al subir documento'));
      emit(DocumentsLoaded(current));
    }
  }

  Future<void> deleteDocument({
    required String caseId,
    required String docId,
  }) async {
    final current = state is DocumentsLoaded
        ? (state as DocumentsLoaded).docs
        : <DocumentData>[];
    try {
      await _dio.delete('${ApiConfig.cases}/$caseId/documents/$docId');
      final updated = current.where((d) => d.id != docId).toList();
      emit(DocumentsLoaded(updated));
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Error al eliminar documento';
      emit(DocumentsError(msg.toString()));
      emit(DocumentsLoaded(current));
    } catch (_) {
      emit(const DocumentsError('Error al eliminar documento'));
      emit(DocumentsLoaded(current));
    }
  }
}
