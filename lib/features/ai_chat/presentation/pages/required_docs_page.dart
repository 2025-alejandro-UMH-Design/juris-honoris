import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/features/ai_chat/presentation/bloc/recommendations_cubit.dart';

class RequiredDocsPage extends StatefulWidget {
  final String consultaSummary;

  const RequiredDocsPage({super.key, required this.consultaSummary});

  @override
  State<RequiredDocsPage> createState() => _RequiredDocsPageState();
}

class _RequiredDocsPageState extends State<RequiredDocsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationsCubit>().loadRecommendations(
            widget.consultaSummary,
          );
    });
  }

  Future<void> _openMaps(String query) async {
    final encoded = Uri.encodeComponent(query);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encoded',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
          'Documentos requeridos',
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
      body: BlocBuilder<RecommendationsCubit, RecommendationsState>(
        builder: (context, state) {
          if (state is RecommendationsLoading || state is RecommendationsInitial) {
            return const _LoadingView();
          }
          if (state is RecommendationsError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<RecommendationsCubit>()
                  .loadRecommendations(widget.consultaSummary),
            );
          }
          if (state is RecommendationsLoaded) {
            return _DocsListView(docs: state.docs, onOpenMaps: _openMaps);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primaryBlue),
          const SizedBox(height: AppSizes.lg),
          Text(
            'Analizando documentos necesarios...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.subtitleGrey,
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: AppColors.errorRed,
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.subtitleGrey),
            ),
            const SizedBox(height: AppSizes.xl),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocsListView extends StatelessWidget {
  final List<RequiredDoc> docs;
  final Future<void> Function(String query) onOpenMaps;

  const _DocsListView({required this.docs, required this.onOpenMaps});

  @override
  Widget build(BuildContext context) {
    if (docs.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron documentos específicos.\nConsulta con un abogado para más detalles.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.subtitleGrey),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        AppSizes.lg,
        AppSizes.pagePadding,
        AppSizes.xl2,
      ),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  'Lista generada por IA basada en tu consulta. Verifica con la institución correspondiente.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        ...docs.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.md),
                child: _DocCard(
                  index: e.key + 1,
                  doc: e.value,
                  onOpenMaps: onOpenMaps,
                ),
              ),
            ),
      ],
    );
  }
}

class _DocCard extends StatelessWidget {
  final int index;
  final RequiredDoc doc;
  final Future<void> Function(String query) onOpenMaps;

  const _DocCard({
    required this.index,
    required this.doc,
    required this.onOpenMaps,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    doc.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greyDark,
                    ),
                  ),
                ),
              ],
            ),

            if (doc.description.isNotEmpty) ...[
              const SizedBox(height: AppSizes.sm),
              Text(
                doc.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.subtitleGrey,
                  height: 1.4,
                ),
              ),
            ],

            const SizedBox(height: AppSizes.md),
            const Divider(height: 1, color: AppColors.borderColor),
            const SizedBox(height: AppSizes.md),

            if (doc.institution.isNotEmpty)
              _InfoRow(
                icon: Icons.account_balance_outlined,
                text: doc.institution,
              ),

            if (doc.address.isNotEmpty) ...[
              const SizedBox(height: AppSizes.xs),
              _InfoRow(
                icon: Icons.location_on_outlined,
                text: doc.address,
              ),
            ],

            if (doc.mapsQuery.isNotEmpty) ...[
              const SizedBox(height: AppSizes.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => onOpenMaps(doc.mapsQuery),
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: const Text('Ver en Google Maps'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.buttonRadius),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.greyMedium),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.greyMedium,
            ),
          ),
        ),
      ],
    );
  }
}
