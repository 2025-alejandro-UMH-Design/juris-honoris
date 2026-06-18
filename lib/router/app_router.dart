import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:juris_honoris/injection_container.dart';
import 'package:juris_honoris/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:juris_honoris/features/auth/domain/entities/user_entity.dart';
import 'package:juris_honoris/features/home/presentation/widgets/lawyer_card.dart';
import 'package:juris_honoris/features/ai_chat/presentation/bloc/chat_ia_cubit.dart';
import 'package:juris_honoris/features/chat/bloc/chat_cubit.dart';
import 'package:juris_honoris/features/lawyers/presentation/bloc/lawyers_cubit.dart';
import 'package:juris_honoris/features/tasks/presentation/bloc/cases_cubit.dart';
import 'package:juris_honoris/features/chat/bloc/my_requests_cubit.dart';
import 'package:juris_honoris/features/ai_chat/presentation/bloc/sessions_cubit.dart';
import 'package:juris_honoris/features/ai_chat/presentation/bloc/recommendations_cubit.dart';

// Auth
import 'package:juris_honoris/features/auth/presentation/pages/splash_page.dart';
import 'package:juris_honoris/features/auth/presentation/pages/login_page.dart';
import 'package:juris_honoris/features/auth/presentation/pages/register_page.dart';

// Home / Client
import 'package:juris_honoris/features/home/presentation/pages/home_page.dart';
import 'package:juris_honoris/features/home/presentation/pages/dossier_page.dart';

// Chat IA
import 'package:juris_honoris/features/ai_chat/presentation/pages/chat_ia_page.dart';
import 'package:juris_honoris/features/ai_chat/presentation/pages/ai_result_page.dart';

// Lawyers (client view)
import 'package:juris_honoris/features/lawyers/presentation/pages/lawyer_directory_page.dart';
import 'package:juris_honoris/features/lawyers/presentation/pages/lawyer_profile_page.dart';
import 'package:juris_honoris/features/lawyers/presentation/pages/lawyer_request_page.dart';

// Tasks
import 'package:juris_honoris/features/tasks/presentation/pages/tasks_page.dart';
import 'package:juris_honoris/features/tasks/presentation/pages/task_detail_page.dart';
import 'package:juris_honoris/features/tasks/presentation/pages/create_task_page.dart';

// Profile
import 'package:juris_honoris/features/profile/presentation/pages/profile_page.dart';
import 'package:juris_honoris/features/profile/presentation/pages/upgrade_page.dart';
import 'package:juris_honoris/features/profile/presentation/pages/verify_identity_page.dart';

// Chat client-lawyer
import 'package:juris_honoris/features/chat/client_lawyer_chat_page.dart';

// Lawyer (lawyer view)
import 'package:juris_honoris/features/lawyers/presentation/pages/lawyer_login_page.dart';
import 'package:juris_honoris/features/lawyers/presentation/pages/lawyer_register_wizard.dart';
import 'package:juris_honoris/features/lawyers/presentation/pages/lawyer_dashboard_page.dart';
import 'package:juris_honoris/features/lawyers/presentation/pages/lawyer_marketplace_page.dart';
import 'package:juris_honoris/features/lawyers/presentation/pages/accept_reject_case_page.dart';
import 'package:juris_honoris/features/lawyers/presentation/pages/lawyer_chat_page.dart';
import 'package:juris_honoris/features/lawyers/presentation/pages/lawyer_profile_edit_page.dart';

// ── Auth refresh notifier ──────────────────────────────────────────────────
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

// ── Route names ────────────────────────────────────────────────────────────
abstract class Routes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const dossier = '/dossier';
  static const chatIa = '/chat-ia';
  static const aiResult = '/ai-result';
  static const lawyers = '/lawyers';
  static const lawyerProfile = '/lawyers/:id';
  static const lawyerRequest = '/lawyers/:id/request';
  static const tasks = '/tasks';
  static const taskDetail = '/tasks/:id';
  static const createTask = '/tasks/new';
  static const profile = '/profile';
  static const upgrade = '/profile/upgrade';
  static const verifyIdentity = '/profile/verify';
  static const clientChat = '/chat/:requestId';
  static const lawyerLogin = '/lawyer/login';
  static const lawyerRegister = '/lawyer/register';
  static const lawyerDashboard = '/lawyer/dashboard';
  static const lawyerMarketplace = '/lawyer/marketplace';
  static const lawyerCase = '/lawyer/case/:id';
  static const lawyerChat = '/lawyer/chat/:id';
  static const lawyerProfileEdit = '/lawyer/profile';
}

/// Navegación del bottom nav bar usando GoRouter.
/// Usado en todas las páginas que son rutas directas (tasks, dossier, chat-ia).
void goNavBottom(BuildContext context, int index) {
  switch (index) {
    case 0: context.go('/home');
    case 1: context.go('/chat-ia');
    case 2: context.go('/tasks');
    case 3: context.go('/dossier');
    case 4: context.go('/profile');
  }
}

// ── Router factory ─────────────────────────────────────────────────────────
GoRouter createRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final authState = authCubit.state;
      final loc = state.matchedLocation;
      final isAuthPage = loc == Routes.login ||
          loc == Routes.register ||
          loc == Routes.splash ||
          loc.startsWith('/lawyer/login') ||
          loc.startsWith('/lawyer/register');

      // Authenticated on auth page → go to home
      if (authState is AuthAuthenticated && isAuthPage) {
        return authState.user.role == UserRole.lawyer
            ? Routes.lawyerDashboard
            : Routes.home;
      }
      // Not authenticated on protected page → go to login
      if (authState is AuthUnauthenticated && !isAuthPage) {
        return Routes.login;
      }
      return null;
    },
    routes: [
      // ── Splash ──────────────────────────────────────────────────────────
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // ── Auth ────────────────────────────────────────────────────────────
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterPage(),
      ),

      // ── Client shell ────────────────────────────────────────────────────
      GoRoute(
        path: Routes.home,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<CasesCubit>()),
            BlocProvider(create: (_) => sl<LawyersCubit>()),
            BlocProvider(create: (_) => sl<MyRequestsCubit>()),
          ],
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: Routes.dossier,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<CasesCubit>(),
          child: DossierPage(
            currentNavIndex: 3,
            onNavChanged: (i) => goNavBottom(context, i),
          ),
        ),
      ),
      GoRoute(
        path: Routes.chatIa,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<ChatIACubit>()),
            BlocProvider(create: (_) => sl<SessionsCubit>()),
          ],
          child: const ChatIAPage(),
        ),
      ),
      GoRoute(
        path: Routes.aiResult,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider(
            create: (_) => sl<CasesCubit>(),
            child: AIResultPage(
              consultaSummary: extra['summary'] as String? ?? '',
              needsLawyer: extra['needsLawyer'] as bool? ?? false,
            ),
          );
        },
      ),

      // ── Lawyers ─────────────────────────────────────────────────────────
      GoRoute(
        path: Routes.lawyers,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<LawyersCubit>(),
          child: const LawyerDirectoryPage(),
        ),
      ),
      GoRoute(
        path: '/lawyers/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final lawyer = (state.extra as LawyerData?) ??
              LawyerData(id: id, name: '', specialization: '', rating: 0, cases: 0, verified: false, city: '', about: '');
          return LawyerProfilePage(lawyer: lawyer);
        },
      ),
      GoRoute(
        path: '/lawyers/:id/request',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final lawyer = (state.extra as LawyerData?) ??
              LawyerData(id: id, name: '', specialization: '', rating: 0, cases: 0, verified: false, city: '', about: '');
          return BlocProvider(
            create: (_) => sl<LawyersCubit>(),
            child: LawyerRequestPage(lawyer: lawyer),
          );
        },
      ),

      // ── Tasks ────────────────────────────────────────────────────────────
      GoRoute(
        path: Routes.tasks,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<CasesCubit>(),
          child: TasksPage(
            currentNavIndex: 2,
            onNavChanged: (i) => goNavBottom(context, i),
          ),
        ),
      ),
      GoRoute(
        path: Routes.createTask,
        builder: (context, state) => const CreateTaskPage(),
      ),
      GoRoute(
        path: '/tasks/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final task = (state.extra as TaskData?) ??
              TaskData(id: id, title: '', description: '', status: 'pending', category: 'other', priority: 'medium', dueDate: '');
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<RecommendationsCubit>()),
              BlocProvider(create: (_) => sl<CasesCubit>()),
            ],
            child: TaskDetailPage(task: task),
          );
        },
      ),

      // ── Profile ──────────────────────────────────────────────────────────
      GoRoute(
        path: Routes.profile,
        builder: (context, state) => ProfilePage(
          currentNavIndex: 4,
          onNavChanged: (i) => goNavBottom(context, i),
        ),
      ),
      GoRoute(
        path: Routes.upgrade,
        builder: (context, state) => const UpgradePage(),
      ),
      GoRoute(
        path: Routes.verifyIdentity,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return VerifyIdentityPage(
            onVerified: extra['onVerified'] as VoidCallback?,
          );
        },
      ),

      // ── Chat client-lawyer ───────────────────────────────────────────────
      GoRoute(
        path: '/chat/:requestId',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider(
            create: (_) => sl<ChatCubit>(),
            child: ClientLawyerChatPage(
              requestId: state.pathParameters['requestId'] ?? '',
              lawyerName: extra['lawyerName'] as String? ?? 'Abogado',
              caseType: extra['caseType'] as String? ?? 'Caso legal',
            ),
          );
        },
      ),

      // ── Lawyer module ────────────────────────────────────────────────────
      GoRoute(
        path: Routes.lawyerLogin,
        builder: (context, state) => const LawyerLoginPage(),
      ),
      GoRoute(
        path: Routes.lawyerRegister,
        builder: (context, state) => const LawyerRegisterWizard(),
      ),
      GoRoute(
        path: Routes.lawyerDashboard,
        builder: (context, state) => const LawyerDashboardPage(),
      ),
      GoRoute(
        path: Routes.lawyerMarketplace,
        builder: (context, state) => const LawyerMarketplacePage(),
      ),
      GoRoute(
        path: '/lawyer/case/:id',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return AcceptRejectCasePage(caseData: extra);
        },
      ),
      GoRoute(
        path: '/lawyer/chat/:id',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return LawyerChatPage(
            caseId: state.pathParameters['id'] ?? '',
            clientName: extra['clientName'] as String? ?? 'Cliente',
            caseType: extra['caseType'] as String? ?? 'Caso legal',
          );
        },
      ),
      GoRoute(
        path: Routes.lawyerProfileEdit,
        builder: (context, state) => const LawyerProfileEditPage(),
      ),
    ],

    // ── Error page ──────────────────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFF44336)),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.error?.message ?? 'Ruta: ${state.uri}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(Routes.login),
              child: const Text('Ir al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
}
