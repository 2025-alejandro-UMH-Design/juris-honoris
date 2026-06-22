import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/api_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../injection_container.dart';
import 'lawyer_case_dossier_page.dart';

class LawyerDossierListPage extends StatefulWidget {
  const LawyerDossierListPage({super.key});

  @override
  State<LawyerDossierListPage> createState() => _LawyerDossierListPageState();
}

class _LawyerDossierListPageState extends State<LawyerDossierListPage> {
  List<Map<String, dynamic>> _cases = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dio = sl<Dio>();
      final res = await dio.get(ApiConfig.requests,
          queryParameters: {'status': 'accepted'});
      if (!mounted) return;
      setState(() {
        _cases =
            (res.data as List).map<Map<String, dynamic>>((r) {
          return {
            'id': r['id']?.toString() ?? '',
            'case_id': r['case_id']?.toString() ?? '',
            'title': (r['case_title'] as String?)?.isNotEmpty == true
                ? r['case_title']
                : r['case_type'] ?? 'Caso legal',
            'client_name': r['client_name'] ?? 'Cliente',
            'description': r['description'] ?? '',
            'case_type': r['case_type'] ?? '',
            'created_at': r['created_at'] ?? '',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se pudo cargar los casos.';
          _isLoading = false;
        });
      }
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
        automaticallyImplyLeading: false,
        title: const Text(
          'Expedientes',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.greyDark),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderColor),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primaryBlue,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primaryBlue, strokeWidth: 2))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 40, color: AppColors.greyMedium),
                        const SizedBox(height: AppSizes.sm),
                        Text(_error!,
                            style: const TextStyle(
                                color: AppColors.subtitleGrey)),
                        const SizedBox(height: AppSizes.md),
                        ElevatedButton(
                          onPressed: _load,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: AppColors.white),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : _cases.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.folder_open_rounded,
                                    size: 60, color: AppColors.greyLight),
                                SizedBox(height: AppSizes.md),
                                Text('No tienes casos activos',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.greyMedium)),
                                SizedBox(height: AppSizes.xs),
                                Text(
                                    'Cuando aceptes un caso aparecerá aquí.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.subtitleGrey)),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSizes.pagePadding),
                        itemCount: _cases.length,
                        itemBuilder: (context, i) {
                          final c = _cases[i];
                          final dateStr = _formatDate(
                              c['created_at'] as String? ?? '');
                          final caseId = c['case_id'] as String;
                          return _CaseCard(
                            title: c['title'] as String,
                            clientName: c['client_name'] as String,
                            caseType: c['case_type'] as String,
                            date: dateStr,
                            // B1: guard — no navegar si no hay caso vinculado
                            onTap: caseId.isEmpty
                                ? null
                                : () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => LawyerCaseDossierPage(
                                          caseId: caseId,
                                          caseTitle: c['title'] as String,
                                          clientName:
                                              c['client_name'] as String,
                                          description:
                                              c['description'] as String,
                                          status: 'accepted',
                                        ),
                                      ),
                                    ),
                          );
                        },
                      ),
      ),
    );
  }

  String _formatDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return '';
    return DateFormat('dd MMM yyyy').format(dt);
  }
}

class _CaseCard extends StatelessWidget {
  final String title, clientName, caseType, date;
  final VoidCallback? onTap;

  const _CaseCard({
    required this.title,
    required this.clientName,
    required this.caseType,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.md),
        padding: const EdgeInsets.all(AppSizes.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 6,
                offset: Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.folder_special_rounded,
                  color: AppColors.primaryBlue, size: 24),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.greyDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded,
                          size: 13, color: AppColors.subtitleGrey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(clientName,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.subtitleGrey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (caseType.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FE),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(caseType,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(date,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.hintGrey)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.greyMedium),
          ],
        ),
      ),
    );
  }
}
