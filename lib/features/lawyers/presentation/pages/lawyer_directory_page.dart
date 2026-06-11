import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../home/presentation/widgets/lawyer_card.dart';
import '../bloc/lawyers_cubit.dart';
import 'lawyer_profile_page.dart';

class LawyerDirectoryPage extends StatefulWidget {
  const LawyerDirectoryPage({super.key});

  @override
  State<LawyerDirectoryPage> createState() => _LawyerDirectoryPageState();
}

class _LawyerDirectoryPageState extends State<LawyerDirectoryPage> {
  final _searchController = TextEditingController();
  String _filterSpec = 'Todos';
  String _query = '';
  List<LawyerData> _lawyers = const [];

  final _specs = ['Todos', 'Familia', 'Penal', 'Laboral', 'Mercantil'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LawyersCubit>().loadLawyers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LawyerData> get _filtered {
    return _lawyers.where((l) {
      final matchSpec = _filterSpec == 'Todos' ||
          l.specialization.toLowerCase().contains(_specKey(_filterSpec));
      final matchQuery = _query.isEmpty ||
          l.name.toLowerCase().contains(_query.toLowerCase()) ||
          l.specialization.toLowerCase().contains(_query.toLowerCase());
      return matchSpec && matchQuery;
    }).toList();
  }

  String _specKey(String spec) {
    const map = {
      'Familia': 'familia',
      'Penal': 'penal',
      'Laboral': 'laboral',
      'Mercantil': 'mercantil',
    };
    return map[spec]?.toLowerCase() ?? spec.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return BlocListener<LawyersCubit, LawyersState>(
      listener: (context, state) {
        if (state is LawyersLoaded) {
          setState(() => _lawyers = state.lawyers);
        }
      },
      child: Scaffold(
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
          'Directorio de Abogados',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.greyDark,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderColor),
        ),
      ),
      body: Column(
        children: [
          // SearchBar
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePadding,
              AppSizes.sm,
              AppSizes.pagePadding,
              0,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o especialidad',
                hintStyle: const TextStyle(
                  color: AppColors.greyMedium,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.greyMedium,
                ),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.greyVeryLight,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                ),
              ),
            ),
          ),

          // Filtros chips
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePadding,
              vertical: AppSizes.sm,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _specs.map((spec) {
                  final isSelected = spec == _filterSpec;
                  return GestureDetector(
                    onTap: () => setState(() => _filterSpec = spec),
                    child: Container(
                      margin: const EdgeInsets.only(right: AppSizes.sm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.greyVeryLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.borderColor,
                        ),
                      ),
                      child: Text(
                        spec,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.greyMedium,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Resultado contador
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePadding,
              AppSizes.sm,
              AppSizes.pagePadding,
              0,
            ),
            child: Row(
              children: [
                Text(
                  '${filtered.length} abogado${filtered.length != 1 ? 's' : ''} encontrado${filtered.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.greyMedium,
                  ),
                ),
              ],
            ),
          ),

          // Lista
          Expanded(
            child: filtered.isEmpty
                ? const _EmptyResults()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.pagePadding,
                      AppSizes.sm,
                      AppSizes.pagePadding,
                      AppSizes.xl2,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final lawyer = filtered[i];
                      return LawyerCard(
                        lawyer: lawyer,
                        onVerPerfil: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LawyerProfilePage(lawyer: lawyer),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.greyLight,
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'Sin resultados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.greyDark,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'Prueba con otro nombre o especialidad.',
            style: TextStyle(fontSize: 14, color: AppColors.greyMedium),
          ),
        ],
      ),
    );
  }
}
