import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:juris_honoris/injection_container.dart';
import 'package:juris_honoris/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:juris_honoris/features/home/presentation/widgets/lawyer_card.dart';
import 'package:juris_honoris/features/ai_chat/presentation/bloc/chat_ia_cubit.dart';
import 'package:juris_honoris/features/chat/bloc/chat_cubit.dart';
import 'package:juris_honoris/features/lawyers/presentation/bloc/lawyers_cubit.dart';
import 'package:juris_honoris/features/tasks/presentation/bloc/cases_cubit.dart';

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
  static const clientChat = '/chat/:lawyerId';
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
    redirect: (context, state) {
      final authState = authCubit.state;
      final isLoggingIn = state.matchedLocation == Routes.login ||
          state.matchedLocation == Routes.register ||
          state.matchedLocation == Routes.splash ||
          state.matchedLocation.startsWith('/lawyer/login') ||
          state.matchedLocation.startsWith('/lawyer/register');

      // Not authenticated → redirect to login (except auth pages)
      if (authState is AuthUnauthenticated && !isLoggingIn) {
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
        builder: (context, state) => BlocProvider(
          create: (_) => sl<ChatIACubit>(),
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
          return TaskDetailPage(task: task);
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
        path: '/chat/:lawyerId',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider(
            create: (_) => sl<ChatCubit>(),
            child: ClientLawyerChatPage(
              lawyerId: state.pathParameters['lawyerId'] ?? '',
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
