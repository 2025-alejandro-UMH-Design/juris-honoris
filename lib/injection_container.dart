import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import 'package:juris_honoris/features/admin/data/datasources/admin_local_datasource.dart';
import 'package:juris_honoris/features/admin/presentation/bloc/admin_cubit.dart';
import 'package:juris_honoris/features/ai_chat/data/datasources/ai_local_datasource.dart';
import 'package:juris_honoris/features/ai_chat/data/datasources/ai_remote_datasource.dart';
import 'package:juris_honoris/features/ai_chat/data/repositories/ai_repository_impl.dart';
import 'package:juris_honoris/features/ai_chat/domain/repositories/ai_repository.dart';
import 'package:juris_honoris/features/ai_chat/presentation/bloc/chat_ia_cubit.dart';
import 'package:juris_honoris/features/auth/presentation/bloc/auth_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── External ─────────────────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 10),
    ));
    return dio;
  });

  // ── Data sources ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<AILocalDatasource>(
    () => AILocalDatasource(sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<AIRemoteDatasource>(
    () => AIRemoteDatasourceImpl(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<AdminLocalDatasource>(
    () => AdminLocalDatasource(prefs: sl<SharedPreferences>()),
  );

  // ── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<AIRepository>(
    () => AIRepositoryImpl(
      remoteDatasource: sl<AIRemoteDatasource>(),
      localDatasource: sl<AILocalDatasource>(),
    ),
  );

  // ── Cubits ────────────────────────────────────────────────────────────────
  // AuthCubit: factory so each new session gets fresh state
  sl.registerFactory<AuthCubit>(() => AuthCubit());

  // ChatIACubit: factory so each page instance gets its own history
  sl.registerFactory<ChatIACubit>(
    () => ChatIACubit(repository: sl<AIRepository>()),
  );

  // AdminCubit: singleton so config persists across navigations
  sl.registerLazySingleton<AdminCubit>(
    () => AdminCubit(datasource: sl<AdminLocalDatasource>()),
  );
}
