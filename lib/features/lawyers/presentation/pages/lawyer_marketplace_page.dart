import 'package:flutter/material.dart';
import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/shared/widgets/app_card.dart';

import 'accept_reject_case_page.dart';

const _mockCases = [
  {
    'id': 'c1',
    'title': 'Divorcio por mutuo acuerdo',
    'type': 'Derecho de Familia',
    'clientName': 'Juan G.',
    'date': '2026-05-27',
    'urgency': 'normal',
    'description':
        'Pareja desea separarse de mutuo acuerdo. Tienen 2 hijos menores. Necesitan acuerdo de custodia y pensión alimenticia.',
  },
  {
    'id': 'c2',
    'title': 'Demanda por despido injustificado',
    'type': 'Derecho Laboral',
    'clientName': 'María L.',
    'date': '2026-05-26',
    'urgency': 'urgent',
    'description':
        'Trabajadora despedida sin causa justificada después de 5 años. Solicita liquidación y daños.',
  },
  {
    'id': 'c3',
    'title': 'Proceso de herencia',
    'type': 'Derecho Civil',
    'clientName': 'Carlos R.',
    'date': '2026-05-25',
    'urgency': 'normal',
    'description': 'Sucesión testamentaria de bienes inmuebles. 3 herederos.',
  },
  {
    'id': 'c4',
    'title': 'Revisión contrato comercial',
    'type': 'Derecho Mercantil',
    'clientName': 'Ana M.',
    'date': '2026-05-24',
    'urgency': 'normal',
    'description':
        'Contrato de distribución exclusiva. Necesita revisión de cláusulas y asesoría.',
  },
];

const _filterOptions = [
  'Todos',
  'Familia',
  'Laboral',
  'Penal',
  'Mercantil',
  'Civil',
];

class LawyerMarketplacePage extends StatefulWidget {
  const LawyerMarketplacePage({super.key});

  @override
  State<LawyerMarketplacePage> createState() => _LawyerMarketplacePageState();
}

class _LawyerMarketplacePageState extends State<LawyerMarketplacePage> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'Todos';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredCases {
    return _mockCases.where((c) {
      final matchesFilter = _selectedFilter == 'Todos' ||
          (c['type'] as String).contains(_selectedFilter);
      final matchesSearch = _searchQuery.isEmpty ||
          (c['title'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (c['type'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Casos Disponibles',
          style: TextStyle(
              color: AppColors.greyDark,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.primaryBlue),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filtros avanzados próximamente')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────────────
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding, 0, AppSizes.pagePadding, AppSizes.md),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontSize: 14, color: AppColors.greyDark),
              decoration: InputDecoration(
                hintText: 'Buscar casos...',
                hintStyle:
                    const TextStyle(color: AppColors.hintGrey, fontSize: 14),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.greyMedium),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppColors.greyMedium, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.greyVeryLight,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.lg, vertical: AppSizes.sm),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                      color: AppColors.primaryBlue, width: 1.5),
                ),
              ),
            ),
          ),

          // ── Filter chips ───────────────────────────────────────
          Container(
            color: AppColors.white,
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePadding, vertical: 6),
              itemCount: _filterOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
              itemBuilder: (_, i) {
                final opt = _filterOptions[i];
                final selected = _selectedFilter == opt;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md, vertical: 4),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryBlue
                          : AppColors.greyVeryLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryBlue
                            : AppColors.borderColor,
                      ),
                    ),
                    child: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                        color: selected ? AppColors.white : AppColors.greyDark,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.borderColor),

          // ── Case list ──────────────────────────────────────────
          Expanded(
            child: _filteredCases.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSizes.pagePadding),
                    itemCount: _filteredCases.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSizes.sm),
                    itemBuilder: (_, i) =>
                        _CaseCard(caseData: _filteredCases[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Case card ──────────────────────────────────────────────────────────────────

class _CaseCard extends StatelessWidget {
  final Map<String, dynamic> caseData;
  const _CaseCard({required this.caseData});

  @override
  Widget build(BuildContext context) {
    final isUrgent = caseData['urgency'] == 'urgent';
    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AcceptRejectCasePage(caseData: caseData),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  caseData['title'] as String,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greyDark),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              _UrgencyBadge(isUrgent: isUrgent),
            ],
          ),
          const SizedBox(height: AppSizes.sm),

          // Type chip + client
          Row(
            children: [
              _TypeChip(label: caseData['type'] as String),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  'Cliente: ${caseData['clientName']}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.subtitleGrey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),

          // Date
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 12, color: AppColors.greyMedium),
              const SizedBox(width: 4),
              Text(
                'Fecha: ${caseData['date']}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.subtitleGrey),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),

          // Description (2 lines max)
          Text(
            caseData['description'] as String,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 13, color: AppColors.greyMedium, height: 1.4),
          ),
          const SizedBox(height: AppSizes.sm),

          // View button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AcceptRejectCasePage(caseData: caseData),
                ),
              ),
              icon: const Icon(Icons.arrow_forward, size: 14),
              label: const Text('Ver detalles'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  const _TypeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 11,
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _UrgencyBadge extends StatelessWidget {
  final bool isUrgent;
  const _UrgencyBadge({required this.isUrgent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 2),
      decoration: BoxDecoration(
        color: isUrgent ? AppColors.errorRed : AppColors.greyLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isUrgent ? 'Urgente' : 'Normal',
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isUrgent ? AppColors.white : AppColors.greyDark),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 56, color: AppColors.greyLight),
          SizedBox(height: AppSizes.md),
          Text(
            'No se encontraron casos',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.greyMedium),
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            'Intenta con otro filtro o búsqueda',
            style: TextStyle(fontSize: 13, color: AppColors.subtitleGrey),
          ),
        ],
      ),
    );
  }
}
