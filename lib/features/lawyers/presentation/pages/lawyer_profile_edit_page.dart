import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:juris_honoris/core/constants/api_config.dart';
import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:juris_honoris/injection_container.dart';
import 'package:juris_honoris/shared/widgets/app_button.dart';
import 'package:juris_honoris/shared/widgets/app_card.dart';

const List<String> _allSpecialties = [
  'Familia',
  'Penal',
  'Laboral',
  'Mercantil',
  'Civil',
  'Constitucional',
  'Administrativo',
];

const List<String> _cities = [
  'Tegucigalpa',
  'San Pedro Sula',
  'Comayagua',
  'La Ceiba',
  'Otras',
];

class LawyerProfileEditPage extends StatefulWidget {
  const LawyerProfileEditPage({super.key});

  @override
  State<LawyerProfileEditPage> createState() => _LawyerProfileEditPageState();
}

class _LawyerProfileEditPageState extends State<LawyerProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _bioController = TextEditingController();
  final _tarifaController = TextEditingController();

  String? _selectedCity;
  final Set<String> _selectedSpecialties = {};
  bool _isSaving = false;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = context.read<AuthCubit>().currentUser;
    _nombreController.text = user?.name ?? '';
    try {
      final dio = sl<Dio>();
      final res = await dio.get('${ApiConfig.lawyers}/me/profile');
      if (!mounted) return;
      final data = res.data as Map<String, dynamic>;
      _telefonoController.text = '';
      _bioController.text = data['about'] as String? ?? '';
      _tarifaController.text = data['hourly_rate']?.toString() ?? '';
      final city = data['city'] as String?;
      if (city != null && _cities.contains(city)) _selectedCity = city;
      final specs = data['specialties'];
      if (specs is List) {
        _selectedSpecialties
          ..clear()
          ..addAll(specs.cast<String>());
      }
    } catch (_) {
      // profile may not exist yet — leave fields empty
    }
    if (mounted) setState(() => _isLoadingProfile = false);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _bioController.dispose();
    _tarifaController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    try {
      final dio = sl<Dio>();
      await Future.wait([
        dio.put('${ApiConfig.auth}/me', data: {
          'full_name': _nombreController.text.trim(),
          if (_telefonoController.text.trim().isNotEmpty)
            'phone': _telefonoController.text.trim(),
        }),
        dio.put('${ApiConfig.lawyers}/me/profile', data: {
          'about': _bioController.text.trim(),
          'city': _selectedCity,
          'hourly_rate': double.tryParse(_tarifaController.text.trim()),
          'specialties': _selectedSpecialties.toList(),
        }),
      ]);
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.white, size: 18),
              SizedBox(width: AppSizes.sm),
              Text('Cambios guardados exitosamente'),
            ],
          ),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      final msg = (e.response?.data as Map<String, dynamic>?)?['error'] ?? 'Error al guardar';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.errorRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
              color: AppColors.greyDark,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar ─────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.primaryBlue,
                          child: Text(
                            'CM',
                            style: TextStyle(
                                color: AppColors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Cambio de foto próximamente')),
                              );
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.borderColor, width: 1.5),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Color(0x1A000000), blurRadius: 4),
                                ],
                              ),
                              child: const Icon(Icons.camera_alt,
                                  size: 14, color: AppColors.primaryBlue),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Cambio de foto próximamente')),
                        );
                      },
                      child: const Text(
                        'Cambiar foto',
                        style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                      ),
                    ),
                    // Verified badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md, vertical: AppSizes.xs),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color:
                                AppColors.successGreen.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified,
                              color: AppColors.successGreen, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Abogado verificado',
                            style: TextStyle(
                                color: AppColors.successGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // ── Form fields ────────────────────────────────────
              const _SectionTitle('Información personal'),
              const SizedBox(height: AppSizes.md),

              const _FormLabel('Nombre completo'),
              const SizedBox(height: AppSizes.xs),
              _ProfileField(
                controller: _nombreController,
                hint: 'Tu nombre completo',
                prefixIcon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingresa tu nombre' : null,
              ),
              const SizedBox(height: AppSizes.md),

              const _FormLabel('Teléfono'),
              const SizedBox(height: AppSizes.xs),
              _ProfileField(
                controller: _telefonoController,
                hint: '+504 9999-9999',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSizes.md),

              const _FormLabel('Descripción / Biografía'),
              const SizedBox(height: AppSizes.xs),
              _ProfileField(
                controller: _bioController,
                hint: 'Cuéntanos sobre tu experiencia...',
                prefixIcon: Icons.description_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: AppSizes.xl),

              // ── Specialties ────────────────────────────────────
              const _SectionTitle('Especialidades'),
              const SizedBox(height: AppSizes.xs),
              const Text(
                'Selecciona todas las que apliquen',
                style: TextStyle(fontSize: 12, color: AppColors.subtitleGrey),
              ),
              const SizedBox(height: AppSizes.sm),
              Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: _allSpecialties.map((s) {
                  final selected = _selectedSpecialties.contains(s);
                  return GestureDetector(
                    onTap: () => setState(() {
                      selected
                          ? _selectedSpecialties.remove(s)
                          : _selectedSpecialties.add(s);
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md, vertical: AppSizes.sm),
                      decoration: BoxDecoration(
                        color:
                            selected ? AppColors.primaryBlue : AppColors.white,
                        border: Border.all(
                          color: selected
                              ? AppColors.primaryBlue
                              : AppColors.borderColor,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          color:
                              selected ? AppColors.white : AppColors.greyDark,
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.xl),

              // ── City + rates ───────────────────────────────────
              const _SectionTitle('Zona y tarifas'),
              const SizedBox(height: AppSizes.md),

              const _FormLabel('Ciudad / Departamento'),
              const SizedBox(height: AppSizes.xs),
              DropdownButtonFormField<String>(
                initialValue: _selectedCity,
                onChanged: (v) => setState(() => _selectedCity = v),
                items: _cities
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                decoration: _dropdownDecoration(),
              ),
              const SizedBox(height: AppSizes.md),

              const _FormLabel('Tarifa consulta inicial (L.)'),
              const SizedBox(height: AppSizes.xs),
              _ProfileField(
                controller: _tarifaController,
                hint: '500',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSizes.xl),

              // ── Documents (read-only) ──────────────────────────
              const _SectionTitle('Documentos'),
              const SizedBox(height: AppSizes.md),

              const AppCard(
                child: Column(
                  children: [
                    _DocumentStatusRow(
                      title: 'Cédula de identidad',
                      status: 'Verificado',
                      isVerified: true,
                      icon: Icons.credit_card_outlined,
                    ),
                    Divider(color: AppColors.borderColor, height: 20),
                    _DocumentStatusRow(
                      title: 'Constancia Colegio de Abogados',
                      status: 'Verificado',
                      isVerified: true,
                      icon: Icons.workspace_premium_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.xl2),

              // ── Save button ────────────────────────────────────
              AppButton(
                label: 'Guardar cambios',
                onPressed: _isSaving ? null : () { _saveChanges(); },
                isLoading: _isSaving,
                icon: Icons.save_outlined,
              ),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      prefixIcon:
          const Icon(Icons.location_on_outlined, color: AppColors.greyMedium),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg, vertical: AppSizes.md),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.greyDark),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.greyDark),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _ProfileField({
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppColors.greyDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.hintGrey, fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.greyMedium, size: 20)
            : null,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg, vertical: AppSizes.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide:
              const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
      ),
    );
  }
}

class _DocumentStatusRow extends StatelessWidget {
  final String title;
  final String status;
  final bool isVerified;
  final IconData icon;

  const _DocumentStatusRow({
    required this.title,
    required this.status,
    required this.isVerified,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 18),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.greyDark),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVerified ? Icons.check_circle : Icons.hourglass_top_outlined,
              color: isVerified
                  ? AppColors.successGreen
                  : AppColors.secondaryOrange,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              status,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isVerified
                      ? AppColors.successGreen
                      : AppColors.secondaryOrange),
            ),
          ],
        ),
      ],
    );
  }
}
