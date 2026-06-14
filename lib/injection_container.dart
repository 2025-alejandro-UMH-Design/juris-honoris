import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:juris_honoris/core/services/token_storage.dart';
import 'package:juris_honoris/features/ai_chat/data/repositories/ai_repository_impl.dart';
import 'package:juris_honoris/features/ai_chat/domain/repositories/ai_repository.dart';
import 'package:juris_honoris/features/ai_chat/presentation/bloc/chat_ia_cubit.dart';
import 'package:juris_honoris/features/ai_chat/presentation/bloc/recommendations_cubit.dart';
import 'package:juris_honoris/features/tasks/presentation/bloc/documents_cubit.dart';
import 'package:juris_honoris/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:juris_honoris/features/chat/bloc/chat_cubit.dart';
import 'package:juris_honoris/features/lawyers/presentation/bloc/lawyers_cubit.dart';
import 'package:juris_honoris/features/tasks/presentation/bloc/cases_cubit.dart';
import 'package:juris_honoris/features/tasks/presentation/bloc/plan_cubit.dart';
import 'package:juris_honoris/features/chat/bloc/my_requests_cubit.dart';
import 'package:juris_honoris/features/ai_chat/presentation/bloc/sessions_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerSingleton<TokenStorage>(TokenStorage(prefs));

  // Dio con interceptor que inyecta el JWT en cada request
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout:    const Duration(seconds: 10),
  ));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = sl<TokenStorage>().token;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
  ));
  sl.registerSingleton<Dio>(dio);

  sl.registerLazySingleton<AIRepository>(
    () => AIRepositoryImpl(dio: sl<Dio>()),
  );

  // AuthCubit: factory — cada instancia usa el mismo Dio y TokenStorage
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(dio: sl<Dio>(), tokenStorage: sl<TokenStorage>()),
  );

  sl.registerFactory<ChatIACubit>(
    () => ChatIACubit(repository: sl<AIRepository>()),
  );

  sl.registerFactory<LawyersCubit>(
    () => LawyersCubit(dio: sl<Dio>()),
  );

  sl.registerFactory<CasesCubit>(
    () => CasesCubit(dio: sl<Dio>()),
  );

  sl.registerFactory<ChatCubit>(
    () => ChatCubit(dio: sl<Dio>()),
  );

  sl.registerFactory<RecommendationsCubit>(
    () => RecommendationsCubit(dio: sl<Dio>()),
  );

  sl.registerFactory<DocumentsCubit>(
    () => DocumentsCubit(dio: sl<Dio>()),
  );

  sl.registerFactory<PlanCubit>(
    () => PlanCubit(dio: sl<Dio>()),
  );

  sl.registerFactory<MyRequestsCubit>(
    () => MyRequestsCubit(dio: sl<Dio>()),
  );

  sl.registerFactory<SessionsCubit>(
    () => SessionsCubit(dio: sl<Dio>()),
  );
}
