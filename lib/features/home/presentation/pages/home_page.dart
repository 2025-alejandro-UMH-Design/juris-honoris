import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/badge_widget.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../widgets/lawyer_card.dart';
import '../../../tasks/presentation/pages/tasks_page.dart';
import 'package:dio/dio.dart';
import '../../../tasks/presentation/pages/task_detail_page.dart';
import '../../../lawyers/presentation/pages/lawyer_profile_page.dart';
import '../../../profile/presentation/pages/upgrade_page.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../tasks/presentation/bloc/cases_cubit.dart';
import '../../../lawyers/presentation/bloc/lawyers_cubit.dart';
import '../../../chat/bloc/my_requests_cubit.dart';
import '../../../ai_chat/presentation/bloc/recommendations_cubit.dart';
import 'package:juris_honoris/injection_container.dart';
import 'package:juris_honoris/core/constants/api_config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTab = 0;
  List<TaskData> _cases = const [];
  List<LawyerData> _lawyers = const [];
  List<AcceptedRequest> _acceptedRequests = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CasesCubit>().loadCases();
      context.read<LawyersCubit>().loadLawyers();
      context.read<MyRequestsCubit>().load();
    });
  }

  void _openNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _NotificationsPanelSheet(dio: sl<Dio>()),
    );
  }

  void _onTabChanged(int index) {
    switch (index) {
      case 1:
        context.go('/chat-ia');
      case 2:
        context.go('/tasks');
      case 3:
        context.go('/dossier');
      case 4:
        context.go('/profile');
      default:
        setState(() => _currentTab = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().currentUser;
    final firstName = (user?.name ?? '').split(' ').first;
    final userName = firstName.isNotEmpty ? firstName : 'Bienvenido';
    final isPremium = user?.plan == UserPlan.premium;
    final solicitationsUsed = user?.solicitationsThisMonth ?? 0;

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Buenos días'
        : hour < 19
            ? 'Buenas tardes'
            : 'Buenas noches';

    return MultiBlocListener(
      listeners: [
        BlocListener<CasesCubit, CasesState>(
          listener: (_, state) {
            if (state is CasesLoaded) setState(() => _cases = state.cases);
          },
        ),
        BlocListener<LawyersCubit, LawyersState>(
          listener: (_, state) {
            if (state is LawyersLoaded) setState(() => _lawyers = state.lawyers);
          },
        ),
        BlocListener<MyRequestsCubit, MyRequestsState>(
          listener: (_, state) {
            if (state is MyRequestsLoaded) {
              setState(() => _acceptedRequests = state.requests);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$greeting, $userName',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.greyDark,
                ),
              ),
              const Text(
                'Juris Honoris',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.greyMedium,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.greyDark,
                    size: 26,
                  ),
                  onPressed: () => _openNotifications(context),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.errorRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.borderColor),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            // Card de bienvenida azul
            Container(
              margin: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                AppSizes.lg,
                AppSizes.pagePadding,
                0,
              ),
              padding: const EdgeInsets.all(AppSizes.xl),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
                ),
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '¿Necesitas ayuda legal?',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Consulta con nuestra IA legal gratuita',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xCCFFFFFF),
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        GestureDetector(
                          onTap: () => context.go('/chat-ia'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.lg,
                              vertical: AppSizes.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Consultar con IA',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: AppColors.primaryBlue,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  const Icon(
                    Icons.gavel_rounded,
                    size: 56,
                    color: Color(0x40FFFFFF),
                  ),
                ],
              ),
            ),

            // Accesos rápidos
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                AppSizes.lg,
                AppSizes.pagePadding,
                0,
              ),
              child: Row(
                children: [
                  _QuickAction(
                    icon: Icons.folder_open_rounded,
                    label: 'Mis archivos',
                    color: AppColors.primaryBlue,
                    onTap: () => context.go('/dossier'),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  _QuickAction(
                    icon: Icons.gavel_rounded,
                    label: 'Abogados',
                    color: const Color(0xFF7C3AED),
                    onTap: () => context.push('/lawyers'),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  _QuickAction(
                    icon: Icons.task_alt_rounded,
                    label: 'Mis casos',
                    color: AppColors.successGreen,
                    onTap: () => context.go('/tasks'),
                  ),
                ],
              ),
            ),

            // Mi Plan
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                AppSizes.lg,
                AppSizes.pagePadding,
                0,
              ),
              child: _PlanSection(
                isPremium: isPremium,
                used: solicitationsUsed,
                max: 3,
                onUpgrade: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UpgradePage()),
                ),
              ),
            ),

            // Tu abogado (solo si hay solicitudes aceptadas)
            if (_acceptedRequests.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSizes.pagePadding,
                  AppSizes.xl,
                  AppSizes.pagePadding,
                  AppSizes.sm,
                ),
                child: Text(
                  'Tu abogado',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greyDark,
                  ),
                ),
              ),
              ..._acceptedRequests.map(
                (req) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.pagePadding,
                    0,
                    AppSizes.pagePadding,
                    AppSizes.cardGap,
                  ),
                  child: _LawyerChatCard(
                    request: req,
                    onChat: () => context.go(
                      '/chat/${req.id}',
                      extra: {
                        'lawyerName': req.lawyerName,
                        'caseType': req.caseType,
                      },
                    ),
                  ),
                ),
              ),
            ],

            // Mis casos activos
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                AppSizes.xl,
                AppSizes.pagePadding,
                0,
              ),
              child: _SectionHeader(
                title: 'Mis casos activos',
                onVerTodo: () => context.go('/dossier'),
              ),
            ),
            _ActiveCasesScroll(
              tasks: _cases.where((t) => t.status != 'completed').toList(),
              onTapTask: (task) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider(create: (_) => sl<RecommendationsCubit>()),
                      BlocProvider(create: (_) => sl<CasesCubit>()),
                    ],
                    child: TaskDetailPage(task: task),
                  ),
                ),
              ),
            ),

            // Actividad reciente
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                AppSizes.xl,
                AppSizes.pagePadding,
                0,
              ),
              child: _SectionHeader(
                title: 'Actividad reciente',
                onVerTodo: () => context.go('/tasks'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                AppSizes.sm,
                AppSizes.pagePadding,
                0,
              ),
              child: _cases.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                      child: Text(
                        'Sin actividad reciente',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.greyMedium,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : Column(
                      children: _cases
                          .take(3)
                          .map(
                            (t) => _RecentActivityItem(
                              task: t,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MultiBlocProvider(
                                    providers: [
                                      BlocProvider(create: (_) => sl<RecommendationsCubit>()),
                                      BlocProvider(create: (_) => sl<CasesCubit>()),
                                    ],
                                    child: TaskDetailPage(task: t),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),

            // Abogados destacados
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                AppSizes.xl,
                AppSizes.pagePadding,
                0,
              ),
              child: _SectionHeader(
                title: 'Abogados destacados',
                onVerTodo: () => context.push('/lawyers'),
              ),
            ),
            SizedBox(
              height: 200,
              child: _lawyers.isEmpty
                  ? const Center(
                      child: Text(
                        'Cargando abogados...',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.greyMedium,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.pagePadding,
                        AppSizes.sm,
                        AppSizes.pagePadding,
                        AppSizes.sm,
                      ),
                      itemCount: _lawyers.length,
                      itemBuilder: (_, i) {
                        final lawyer = _lawyers[i];
                        return LawyerCard(
                          lawyer: lawyer,
                          compact: true,
                          onVerPerfil: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LawyerProfilePage(lawyer: lawyer),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: AppSizes.lg),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentTab,
          onTabChanged: _onTabChanged,
        ),
      ),
    );
  }
}

// ---------- Sección mi plan ----------

class _PlanSection extends StatelessWidget {
  final bool isPremium;
  final int used;
  final int max;
  final VoidCallback onUpgrade;

  const _PlanSection({
    required this.isPremium,
    required this.used,
    required this.max,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: isPremium
          ? const Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: AppColors.secondaryOrange,
                  size: 20,
                ),
                SizedBox(width: AppSizes.sm),
                Text(
                  'Plan Premium',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greyDark,
                  ),
                ),
                SizedBox(width: AppSizes.sm),
                BadgeWidget(label: 'Activo', variant: BadgeVariant.success),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Plan Gratuito',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greyDark,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$used/$max consultas disponibles',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.greyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: max > 0 ? used / max : 0,
                    backgroundColor: AppColors.greyLight,
                    color: used >= max
                        ? AppColors.errorRed
                        : AppColors.primaryBlue,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                GestureDetector(
                  onTap: onUpgrade,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.sm,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryBlue,
                          AppColors.primaryBlueDark,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Actualizar a Premium',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ---------- Encabezado de sección ----------

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onVerTodo;

  const _SectionHeader({required this.title, required this.onVerTodo});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.greyDark,
          ),
        ),
        TextButton(
          onPressed: onVerTodo,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Ver todo',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------- Scroll horizontal de casos activos ----------

class _ActiveCasesScroll extends StatelessWidget {
  final List<TaskData> tasks;
  final void Function(TaskData) onTapTask;

  const _ActiveCasesScroll({required this.tasks, required this.onTapTask});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.pagePadding,
          vertical: AppSizes.md,
        ),
        child: Text(
          'Sin casos activos',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.greyMedium,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSizes.pagePadding,
          AppSizes.sm,
          AppSizes.pagePadding,
          AppSizes.sm,
        ),
        itemCount: tasks.length,
        itemBuilder: (_, i) {
          final task = tasks[i];
          return GestureDetector(
            onTap: () => onTapTask(task),
            child: Container(
              width: 180,
              margin: const EdgeInsets.only(right: AppSizes.cardGap),
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                border: Border.all(color: AppColors.borderColor),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greyDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _statusBadge(task.status),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 11,
                        color: AppColors.greyMedium,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        task.dueDate,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.greyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusBadge(String status) {
    return switch (status) {
      'in_progress' =>
        const BadgeWidget(label: 'En progreso', variant: BadgeVariant.info),
      'completed' =>
        const BadgeWidget(label: 'Completado', variant: BadgeVariant.success),
      _ => const BadgeWidget(label: 'Pendiente', variant: BadgeVariant.gray),
    };
  }
}

// ---------- Actividad reciente ----------

class _RecentActivityItem extends StatelessWidget {
  final TaskData task;
  final VoidCallback onTap;

  const _RecentActivityItem({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.cardGap),
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _categoryColor(task.category).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                _categoryIcon(task.category),
                size: 18,
                color: _categoryColor(task.category),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.greyDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    task.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.greyMedium,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            _statusBadge(task.status),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    return switch (status) {
      'completed' =>
        const BadgeWidget(label: 'Listo', variant: BadgeVariant.success),
      'in_progress' =>
        const BadgeWidget(label: 'Activo', variant: BadgeVariant.info),
      _ => const BadgeWidget(label: 'Pendiente', variant: BadgeVariant.gray),
    };
  }

  Color _categoryColor(String cat) {
    return switch (cat) {
      'family' => AppColors.primaryBlue,
      'labor' => AppColors.secondaryOrange,
      'criminal' => AppColors.errorRed,
      'commercial' => AppColors.successGreen,
      _ => AppColors.greyMedium,
    };
  }

  IconData _categoryIcon(String cat) {
    return switch (cat) {
      'family' => Icons.family_restroom_rounded,
      'labor' => Icons.work_outline_rounded,
      'criminal' => Icons.gavel_rounded,
      'commercial' => Icons.business_outlined,
      _ => Icons.folder_outlined,
    };
  }
}

// ---------- Card de abogado asignado ----------

class _LawyerChatCard extends StatelessWidget {
  final AcceptedRequest request;
  final VoidCallback onChat;

  const _LawyerChatCard({required this.request, required this.onChat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.lawyerName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greyDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  request.caseType,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.greyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          ElevatedButton.icon(
            onPressed: onChat,
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
            label: const Text(
              'Chatear',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Panel de notificaciones
// ─────────────────────────────────────────────────────────────────────────────

class _AppNotif {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  _AppNotif({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  factory _AppNotif.fromJson(Map<String, dynamic> j) => _AppNotif(
        id: j['id']?.toString() ?? '',
        title: j['title']?.toString() ?? 'Notificación',
        body: j['body']?.toString() ?? '',
        isRead: j['is_read'] == true,
        createdAt: DateTime.tryParse(j['created_at']?.toString() ?? '') ?? DateTime.now(),
      );
}

class _NotificationsPanelSheet extends StatefulWidget {
  final Dio dio;
  const _NotificationsPanelSheet({required this.dio});

  @override
  State<_NotificationsPanelSheet> createState() => _NotificationsPanelSheetState();
}

class _NotificationsPanelSheetState extends State<_NotificationsPanelSheet> {
  List<_AppNotif> _notifs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await widget.dio.get(ApiConfig.notifications);
      final list = (res.data as List)
          .map((j) => _AppNotif.fromJson(j as Map<String, dynamic>))
          .toList();
      if (mounted) setState(() { _notifs = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'No se pudieron cargar las notificaciones'; _loading = false; });
    }
  }

  Future<void> _markAllRead() async {
    try {
      await widget.dio.put('${ApiConfig.notifications}/read-all');
      if (mounted) {
        setState(() {
          _notifs = _notifs.map((n) => _AppNotif(
            id: n.id, title: n.title, body: n.body,
            isRead: true, createdAt: n.createdAt,
          )).toList();
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifs.where((n) => !n.isRead).length;
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.greyLight, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.pagePadding, 0, AppSizes.pagePadding, AppSizes.sm),
            child: Row(
              children: [
                const Text('Notificaciones',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.greyDark)),
                const Spacer(),
                if (unread > 0)
                  TextButton(
                    onPressed: _markAllRead,
                    child: Text('Marcar todas ($unread)',
                        style: const TextStyle(fontSize: 12, color: AppColors.primaryBlue)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderColor),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue, strokeWidth: 2))
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.greyMedium)))
                    : _notifs.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.notifications_none_rounded, size: 48, color: AppColors.greyLight),
                                SizedBox(height: AppSizes.sm),
                                Text('Sin notificaciones',
                                    style: TextStyle(fontSize: 14, color: AppColors.greyMedium)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: controller,
                            itemCount: _notifs.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, color: AppColors.borderColor),
                            itemBuilder: (_, i) {
                              final n = _notifs[i];
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: n.isRead
                                      ? AppColors.greyVeryLight
                                      : AppColors.primaryBlue.withValues(alpha: 0.1),
                                  child: Icon(
                                    Icons.notifications_rounded,
                                    size: 20,
                                    color: n.isRead ? AppColors.greyMedium : AppColors.primaryBlue,
                                  ),
                                ),
                                title: Text(
                                  n.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                                    color: AppColors.greyDark,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (n.body.isNotEmpty)
                                      Text(n.body,
                                          style: const TextStyle(
                                              fontSize: 12, color: AppColors.greyMedium),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                    Text(
                                      _timeAgo(n.createdAt),
                                      style: const TextStyle(
                                          fontSize: 11, color: AppColors.hintGrey),
                                    ),
                                  ],
                                ),
                                trailing: n.isRead
                                    ? null
                                    : Container(
                                        width: 8, height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryBlue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                isThreeLine: n.body.isNotEmpty,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer';
    return 'Hace ${diff.inDays} días';
  }
}

// ─── Botón de acceso rápido ──────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(color: AppColors.borderColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greyDark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
