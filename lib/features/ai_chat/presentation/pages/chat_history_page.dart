import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import '../bloc/sessions_cubit.dart';

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SessionsCubit>().load();
    });
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryBlue,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Historial de consultas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.greyDark,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderColor),
        ),
      ),
      body: BlocBuilder<SessionsCubit, SessionsState>(
        builder: (context, state) {
          if (state is SessionsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          if (state is SessionsError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.errorRed,
                    size: 48,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.greyMedium),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  TextButton(
                    onPressed: () => context.read<SessionsCubit>().load(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is SessionsLoaded) {
            if (state.sessions.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 64,
                      color: AppColors.greyLight,
                    ),
                    SizedBox(height: AppSizes.md),
                    Text(
                      'Sin consultas previas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greyDark,
                      ),
                    ),
                    SizedBox(height: AppSizes.xs),
                    Text(
                      'Tus consultas con Juris IA aparecerán aquí.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.greyMedium,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              itemCount: state.sessions.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSizes.cardGap),
              itemBuilder: (_, i) {
                final s = state.sessions[i];
                return _SessionItem(
                  session: s,
                  dateStr: _formatDate(s.updatedAt),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SessionItem extends StatelessWidget {
  final AISession session;
  final String dateStr;

  const _SessionItem({required this.session, required this.dateStr});

  @override
  Widget build(BuildContext context) {
    final nl = session.needsLawyer;

    Color iconBg;
    Color iconColor;
    IconData icon;

    if (nl == null) {
      iconBg = AppColors.greyVeryLight;
      iconColor = AppColors.greyMedium;
      icon = Icons.chat_bubble_outline_rounded;
    } else if (nl) {
      iconBg = AppColors.errorRed.withValues(alpha: 0.1);
      iconColor = AppColors.errorRed;
      icon = Icons.gavel_rounded;
    } else {
      iconBg = AppColors.successGreen.withValues(alpha: 0.1);
      iconColor = AppColors.successGreen;
      icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greyDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.greyMedium,
                  ),
                ),
              ],
            ),
          ),
          if (nl != null) ...[
            const SizedBox(width: AppSizes.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: nl
                    ? AppColors.errorRed.withValues(alpha: 0.1)
                    : AppColors.successGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                nl ? 'Abogado' : 'Auto',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: nl ? AppColors.errorRed : AppColors.successGreen,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
