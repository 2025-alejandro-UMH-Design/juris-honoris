import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/badge_widget.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../widgets/lawyer_card.dart';
import '../../../tasks/presentation/pages/tasks_page.dart';
import '../../../tasks/presentation/pages/task_detail_page.dart';
import '../../../lawyers/presentation/pages/lawyer_profile_page.dart';
import '../../../lawyers/presentation/pages/lawyer_directory_page.dart';
import '../../../profile/presentation/pages/upgrade_page.dart';
import 'dossier_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTab = 0;

  // Datos mock del usuario
  static const _userName = 'Ana';
  static const _isPremium = false;
  static const _solicitationsUsed = 1;
  static const _solicitationsMax = 3;

  void _onTabChanged(int index) {
    switch (index) {
      case 1:
        context.go('/chat-ia');
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TasksPage(
              currentNavIndex: 2,
              onNavChanged: (i) {
                Navigator.pop(context);
                if (i != 2) _onTabChanged(i);
              },
            ),
          ),
        );
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DossierPage(
              currentNavIndex: 3,
              onNavChanged: (i) {
                Navigator.pop(context);
                if (i != 3) _onTabChanged(i);
              },
            ),
          ),
        );
      default:
        setState(() => _currentTab = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Buenos días'
        : hour < 19
            ? 'Buenas tardes'
            : 'Buenas noches';

    return Scaffold(
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
              '$greeting, $_userName',
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
                onPressed: () {},
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
                  color: AppColors.primaryBlue.withOpacity(0.3),
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

          // Mi Plan
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePadding,
              AppSizes.xl,
              AppSizes.pagePadding,
              0,
            ),
            child: _PlanSection(
              isPremium: _isPremium,
              used: _solicitationsUsed,
              max: _solicitationsMax,
              onUpgrade: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UpgradePage()),
              ),
            ),
          ),

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
              onVerTodo: () => _onTabChanged(3),
            ),
          ),
          _ActiveCasesScroll(
            tasks: mockTasks.where((t) => t.status != 'completed').toList(),
            onTapTask: (task) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaskDetailPage(task: task),
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
              onVerTodo: () => _onTabChanged(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePadding,
              AppSizes.sm,
              AppSizes.pagePadding,
              0,
            ),
            child: Column(
              children: mockTasks
                  .take(3)
                  .map(
                    (t) => _RecentActivityItem(
                      task: t,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskDetailPage(task: t),
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
              onVerTodo: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LawyerDirectoryPage(),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                AppSizes.sm,
                AppSizes.pagePadding,
                AppSizes.sm,
              ),
              itemCount: mockLawyers.length,
              itemBuilder: (_, i) {
                final lawyer = mockLawyers[i];
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
                    value: used / max,
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
                color: _categoryColor(task.category).withOpacity(0.1),
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
