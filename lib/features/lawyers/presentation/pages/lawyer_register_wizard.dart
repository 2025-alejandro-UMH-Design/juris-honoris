import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:juris_honoris/core/constants/api_config.dart';
import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:juris_honoris/injection_container.dart';
import 'package:juris_honoris/router/app_router.dart';
import 'package:juris_honoris/shared/widgets/app_button.dart';
import 'package:juris_honoris/shared/widgets/app_card.dart';

class LawyerRegisterWizard extends StatefulWidget {
  const LawyerRegisterWizard({super.key});

  @override
  State<LawyerRegisterWizard> createState() => _LawyerRegisterWizardState();
}

class _LawyerRegisterWizardState extends State<LawyerRegisterWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _submitted = false;

  // Step 1
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _telefonoController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Step 2
  final _dniController = TextEditingController();
  final _colegiacionController = TextEditingController();
  final _experienciaController = TextEditingController();
  final List<String> _allSpecialties = [
    'Familia',
    'Penal',
    'Laboral',
    'Mercantil',
    'Civil',
    'Constitucional',
    'Administrativo',
  ];
  final Set<String> _selectedSpecialties = {};

  // Step 4
  String? _selectedCity;
  bool _dispLunesViernes = false;
  bool _dispFdSemana = false;
  bool _dispUrgencias = false;

  // Step 5
  final _tarifaController = TextEditingController();
  bool _acceptedCommission = false;

  // Step 6
  bool _acceptedTerms = false;
  bool _isLoading = false;

  final List<String> _cities = [
    'Tegucigalpa',
    'San Pedro Sula',
    'Comayagua',
    'La Ceiba',
    'Otras',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _telefonoController.dispose();
    _dniController.dispose();
    _colegiacionController.dispose();
    _experienciaController.dispose();
    _tarifaController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goPrev() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit() async {
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una ciudad'), backgroundColor: AppColors.errorRed),
      );
      return;
    }
    if (_selectedSpecialties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una especialidad'), backgroundColor: AppColors.errorRed),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final dio = sl<Dio>();
      await dio.post(
        '${ApiConfig.auth}/register-lawyer',
        data: {
          'email': _emailController.text.trim().toLowerCase(),
          'password': _passwordController.text,
          'full_name': _nombreController.text.trim(),
          'phone': _telefonoController.text.trim(),
          'dni': _dniController.text.trim(),
          'colegiacion_number': _colegiacionController.text.trim(),
          'experience_years': int.tryParse(_experienciaController.text.trim()) ?? 0,
          'city': _selectedCity,
          'specialties': _selectedSpecialties.toList(),
        },
      );
      if (!mounted) return;
      // Auto-login para que el JWT quede activo antes de ir al dashboard
      await context.read<AuthCubit>().loginWithEmail(
        _emailController.text.trim().toLowerCase(),
        _passwordController.text,
      );
      if (!mounted) return;
      setState(() { _isLoading = false; _submitted = true; });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final msg = (e.response?.data as Map<String, dynamic>?)?['error'] ?? 'Error al registrar. Intenta de nuevo.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.errorRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return _SuccessScreen(
        onGoToDashboard: () => context.go(Routes.lawyerDashboard),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.greyDark),
                onPressed: _goPrev,
              )
            : IconButton(
                icon: const Icon(Icons.close, color: AppColors.greyDark),
                onPressed: () => Navigator.of(context).pop(),
              ),
        title: const Text(
          'Registro de Abogado',
          style: TextStyle(
            color: AppColors.greyDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _StepIndicator(currentStep: _currentStep, totalSteps: 6),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _StepPersonalData(
            nombreController: _nombreController,
            emailController: _emailController,
            passwordController: _passwordController,
            confirmPasswordController: _confirmPasswordController,
            telefonoController: _telefonoController,
            obscurePassword: _obscurePassword,
            obscureConfirm: _obscureConfirm,
            onTogglePassword: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            onToggleConfirm: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
            onNext: _goNext,
          ),
          _StepProfessionalData(
            dniController: _dniController,
            colegiacionController: _colegiacionController,
            experienciaController: _experienciaController,
            allSpecialties: _allSpecialties,
            selectedSpecialties: _selectedSpecialties,
            onToggleSpecialty: (s) => setState(() {
              _selectedSpecialties.contains(s)
                  ? _selectedSpecialties.remove(s)
                  : _selectedSpecialties.add(s);
            }),
            onNext: _goNext,
          ),
          _StepDocuments(onNext: _goNext),
          _StepWorkZone(
            cities: _cities,
            selectedCity: _selectedCity,
            dispLunesViernes: _dispLunesViernes,
            dispFdSemana: _dispFdSemana,
            dispUrgencias: _dispUrgencias,
            onCityChanged: (v) => setState(() => _selectedCity = v),
            onLunesViernesChanged: (v) =>
                setState(() => _dispLunesViernes = v ?? false),
            onFdSemanaChanged: (v) =>
                setState(() => _dispFdSemana = v ?? false),
            onUrgenciasChanged: (v) =>
                setState(() => _dispUrgencias = v ?? false),
            onNext: _goNext,
          ),
          _StepRates(
            tarifaController: _tarifaController,
            acceptedCommission: _acceptedCommission,
            onCommissionChanged: (v) =>
                setState(() => _acceptedCommission = v ?? false),
            onNext: _goNext,
          ),
          _StepConfirmation(
            nombre: _nombreController.text.isEmpty
                ? 'No ingresado'
                : _nombreController.text,
            email: _emailController.text.isEmpty
                ? 'No ingresado'
                : _emailController.text,
            telefono: _telefonoController.text.isEmpty
                ? 'No ingresado'
                : _telefonoController.text,
            dni: _dniController.text.isEmpty
                ? 'No ingresado'
                : _dniController.text,
            colegiacion: _colegiacionController.text.isEmpty
                ? 'No ingresado'
                : _colegiacionController.text,
            especialidades: _selectedSpecialties.isEmpty
                ? 'Ninguna'
                : _selectedSpecialties.join(', '),
            ciudad: _selectedCity ?? 'No seleccionada',
            tarifa: _tarifaController.text.isEmpty
                ? 'No ingresada'
                : 'L. ${_tarifaController.text}',
            acceptedTerms: _acceptedTerms,
            onTermsChanged: (v) => setState(() => _acceptedTerms = v ?? false),
            onSubmit: _acceptedTerms && !_isLoading ? () { _submit(); } : null,
          ),
        ],
      ),
    );
  }
}

// ── Step Indicator ─────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepIndicator({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg, vertical: AppSizes.sm),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final isCompleted = i < currentStep;
          final isActive = i == currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: i == 0
                      ? const SizedBox()
                      : Container(
                          height: 2,
                          color: isCompleted
                              ? AppColors.primaryBlue
                              : AppColors.greyLight,
                        ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? AppColors.primaryBlue
                        : AppColors.greyLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check,
                            color: AppColors.white, size: 14)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: isActive
                                  ? AppColors.white
                                  : AppColors.greyMedium,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                Expanded(
                  child: i == totalSteps - 1
                      ? const SizedBox()
                      : Container(
                          height: 2,
                          color: isCompleted
                              ? AppColors.primaryBlue
                              : AppColors.greyLight,
                        ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Step scaffold wrapper ──────────────────────────────────────────────────────

class _StepScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  final VoidCallback onNext;
  final String nextLabel;

  const _StepScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
    required this.onNext,
  }) : nextLabel = 'Siguiente';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSizes.md),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.greyDark,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: AppColors.subtitleGrey),
          ),
          const SizedBox(height: AppSizes.xl),
          ...children,
          const SizedBox(height: AppSizes.xl2),
          AppButton(label: nextLabel, onPressed: onNext),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

// ── Step 1: Datos personales ───────────────────────────────────────────────────

class _StepPersonalData extends StatelessWidget {
  final TextEditingController nombreController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController telefonoController;
  final bool obscurePassword;
  final bool obscureConfirm;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final VoidCallback onNext;

  const _StepPersonalData({
    required this.nombreController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.telefonoController,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Datos personales',
      subtitle: 'Información básica de tu cuenta',
      onNext: onNext,
      children: [
        const _FieldLabel('Nombre completo'),
        const SizedBox(height: AppSizes.xs),
        _Field(controller: nombreController, hint: 'Ej. Carlos Mendoza López'),
        const SizedBox(height: AppSizes.md),
        const _FieldLabel('Correo electrónico'),
        const SizedBox(height: AppSizes.xs),
        _Field(
          controller: emailController,
          hint: 'abogado@ejemplo.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: AppSizes.md),
        const _FieldLabel('Contraseña'),
        const SizedBox(height: AppSizes.xs),
        _Field(
          controller: passwordController,
          hint: '••••••••',
          obscureText: obscurePassword,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.greyMedium,
              size: 20,
            ),
            onPressed: onTogglePassword,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        const _FieldLabel('Confirmar contraseña'),
        const SizedBox(height: AppSizes.xs),
        _Field(
          controller: confirmPasswordController,
          hint: '••••••••',
          obscureText: obscureConfirm,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              obscureConfirm
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.greyMedium,
              size: 20,
            ),
            onPressed: onToggleConfirm,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        const _FieldLabel('Teléfono'),
        const SizedBox(height: AppSizes.xs),
        _Field(
          controller: telefonoController,
          hint: '+504 9999-9999',
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
        ),
      ],
    );
  }
}

// ── Step 2: Datos profesionales ────────────────────────────────────────────────

class _StepProfessionalData extends StatelessWidget {
  final TextEditingController dniController;
  final TextEditingController colegiacionController;
  final TextEditingController experienciaController;
  final List<String> allSpecialties;
  final Set<String> selectedSpecialties;
  final void Function(String) onToggleSpecialty;
  final VoidCallback onNext;

  const _StepProfessionalData({
    required this.dniController,
    required this.colegiacionController,
    required this.experienciaController,
    required this.allSpecialties,
    required this.selectedSpecialties,
    required this.onToggleSpecialty,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Datos profesionales',
      subtitle: 'Información de tu ejercicio legal',
      onNext: onNext,
      children: [
        const _FieldLabel('DNI / Identidad'),
        const SizedBox(height: AppSizes.xs),
        _Field(
            controller: dniController,
            hint: '0000-0000-00000',
            prefixIcon: Icons.badge_outlined),
        const SizedBox(height: AppSizes.md),
        const _FieldLabel('Número de colegiación'),
        const SizedBox(height: AppSizes.xs),
        _Field(
            controller: colegiacionController,
            hint: 'CAH-0000',
            prefixIcon: Icons.workspace_premium_outlined),
        const SizedBox(height: AppSizes.md),
        const _FieldLabel('Años de experiencia'),
        const SizedBox(height: AppSizes.xs),
        _Field(
          controller: experienciaController,
          hint: 'Ej. 5',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.timeline_outlined,
        ),
        const SizedBox(height: AppSizes.lg),
        const Text(
          'Especialidades',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.greyDark),
        ),
        const SizedBox(height: AppSizes.xs),
        const Text(
          'Selecciona todas las que apliquen',
          style: TextStyle(fontSize: 12, color: AppColors.subtitleGrey),
        ),
        const SizedBox(height: AppSizes.sm),
        Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          children: allSpecialties.map((s) {
            final selected = selectedSpecialties.contains(s);
            return GestureDetector(
              onTap: () => onToggleSpecialty(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md, vertical: AppSizes.sm),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryBlue : AppColors.white,
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
                    color: selected ? AppColors.white : AppColors.greyDark,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Step 3: Documentos ─────────────────────────────────────────────────────────

class _StepDocuments extends StatelessWidget {
  final VoidCallback onNext;
  const _StepDocuments({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Documentos',
      subtitle: 'Sube los documentos requeridos para verificar tu identidad',
      onNext: onNext,
      children: [
        const Text(
          'Formatos aceptados: JPG, PNG, PDF. Máximo 5MB',
          style: TextStyle(fontSize: 12, color: AppColors.subtitleGrey),
        ),
        const SizedBox(height: AppSizes.lg),
        const _DocumentUploadCard(
          title: 'Cédula de identidad',
          description: 'Foto o escaneo de tu DNI vigente',
          icon: Icons.credit_card_outlined,
        ),
        const SizedBox(height: AppSizes.md),
        const _DocumentUploadCard(
          title: 'Constancia del Colegio de Abogados',
          description: 'Documento que acredita tu colegiación activa',
          icon: Icons.workspace_premium_outlined,
        ),
        const SizedBox(height: AppSizes.md),
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border:
                Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 18),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  'Tus documentos serán revisados en 24-48 horas hábiles.',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.primaryBlueDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DocumentUploadCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;

  const _DocumentUploadCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  State<_DocumentUploadCard> createState() => _DocumentUploadCardState();
}

class _DocumentUploadCardState extends State<_DocumentUploadCard> {
  bool _uploaded = false;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    Icon(widget.icon, color: AppColors.primaryBlue, size: 20),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.greyDark),
                    ),
                    Text(
                      widget.description,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.subtitleGrey),
                    ),
                  ],
                ),
              ),
              if (_uploaded)
                const Icon(Icons.check_circle,
                    color: AppColors.successGreen, size: 20),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          OutlinedButton.icon(
            onPressed: () => setState(() => _uploaded = true),
            icon: Icon(_uploaded ? Icons.check : Icons.upload_file, size: 18),
            label: Text(
                _uploaded ? 'Archivo seleccionado' : 'Seleccionar foto/PDF'),
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  _uploaded ? AppColors.successGreen : AppColors.primaryBlue,
              side: BorderSide(
                  color: _uploaded
                      ? AppColors.successGreen
                      : AppColors.primaryBlue),
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 4: Zona de trabajo ────────────────────────────────────────────────────

class _StepWorkZone extends StatelessWidget {
  final List<String> cities;
  final String? selectedCity;
  final bool dispLunesViernes;
  final bool dispFdSemana;
  final bool dispUrgencias;
  final void Function(String?) onCityChanged;
  final void Function(bool?) onLunesViernesChanged;
  final void Function(bool?) onFdSemanaChanged;
  final void Function(bool?) onUrgenciasChanged;
  final VoidCallback onNext;

  const _StepWorkZone({
    required this.cities,
    required this.selectedCity,
    required this.dispLunesViernes,
    required this.dispFdSemana,
    required this.dispUrgencias,
    required this.onCityChanged,
    required this.onLunesViernesChanged,
    required this.onFdSemanaChanged,
    required this.onUrgenciasChanged,
    required this.onNext,
  });

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

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Zona de trabajo',
      subtitle: 'Define tu área de cobertura y disponibilidad',
      onNext: onNext,
      children: [
        const Text(
          'Ciudad / Departamento',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.greyDark),
        ),
        const SizedBox(height: AppSizes.sm),
        DropdownButtonFormField<String>(
          initialValue: selectedCity,
          hint: const Text('Selecciona una ciudad'),
          onChanged: onCityChanged,
          items: cities
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          decoration: _dropdownDecoration(),
        ),
        const SizedBox(height: AppSizes.xl),
        const Text(
          'Disponibilidad',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.greyDark),
        ),
        const SizedBox(height: AppSizes.sm),
        _CheckboxTile(
          title: 'Lunes a Viernes',
          subtitle: 'Horario laboral regular',
          value: dispLunesViernes,
          onChanged: onLunesViernesChanged,
          icon: Icons.work_outline,
        ),
        _CheckboxTile(
          title: 'Fines de semana',
          subtitle: 'Sábados y domingos',
          value: dispFdSemana,
          onChanged: onFdSemanaChanged,
          icon: Icons.weekend_outlined,
        ),
        _CheckboxTile(
          title: 'Urgencias',
          subtitle: 'Disponible fuera de horario habitual',
          value: dispUrgencias,
          onChanged: onUrgenciasChanged,
          icon: Icons.emergency_outlined,
        ),
      ],
    );
  }
}

class _CheckboxTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final void Function(bool?) onChanged;
  final IconData icon;

  const _CheckboxTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.sm),
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Icon(icon, color: AppColors.greyMedium, size: 20),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.greyDark)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.subtitleGrey)),
              ],
            ),
          ),
          Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primaryBlue),
        ],
      ),
    );
  }
}

// ── Step 5: Tarifas ────────────────────────────────────────────────────────────

class _StepRates extends StatelessWidget {
  final TextEditingController tarifaController;
  final bool acceptedCommission;
  final void Function(bool?) onCommissionChanged;
  final VoidCallback onNext;

  const _StepRates({
    required this.tarifaController,
    required this.acceptedCommission,
    required this.onCommissionChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Tarifas y comisión',
      subtitle: 'Define tu tarifa y conoce el modelo de comisión',
      onNext: onNext,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border:
                Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.primaryBlue, size: 18),
                  SizedBox(width: AppSizes.sm),
                  Text(
                    'Modelo de comisión',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlueDark,
                        fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.sm),
              Text(
                '• Tu primer caso en Juris Honoris es completamente GRATIS.',
                style: TextStyle(fontSize: 13, color: AppColors.greyDark),
              ),
              SizedBox(height: AppSizes.xs),
              Text(
                '• A partir del segundo caso: 10-15% por caso asignado.',
                style: TextStyle(fontSize: 13, color: AppColors.greyDark),
              ),
              SizedBox(height: AppSizes.xs),
              Text(
                '• La comisión se descuenta automáticamente al recibir el pago del cliente.',
                style: TextStyle(fontSize: 13, color: AppColors.greyDark),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.xl),
        const Text(
          'Tarifa consulta inicial',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.greyDark),
        ),
        const SizedBox(height: AppSizes.sm),
        TextFormField(
          controller: tarifaController,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 14, color: AppColors.greyDark),
          decoration: InputDecoration(
            hintText: '500',
            prefixText: 'L. ',
            prefixStyle: const TextStyle(
                color: AppColors.greyDark, fontWeight: FontWeight.w600),
            prefixIcon:
                const Icon(Icons.attach_money, color: AppColors.greyMedium),
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
          ),
        ),
        const SizedBox(height: AppSizes.xl),
        AppCard(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md, vertical: AppSizes.sm),
          onTap: () => onCommissionChanged(!acceptedCommission),
          child: Row(
            children: [
              Checkbox(
                value: acceptedCommission,
                onChanged: onCommissionChanged,
                activeColor: AppColors.primaryBlue,
              ),
              const Expanded(
                child: Text(
                  'Primer caso sin comisión — Acepto los términos de comisión del 15% a partir del segundo caso',
                  style: TextStyle(fontSize: 13, color: AppColors.greyDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Step 6: Confirmación ───────────────────────────────────────────────────────

class _StepConfirmation extends StatelessWidget {
  final String nombre;
  final String email;
  final String telefono;
  final String dni;
  final String colegiacion;
  final String especialidades;
  final String ciudad;
  final String tarifa;
  final bool acceptedTerms;
  final void Function(bool?) onTermsChanged;
  final VoidCallback? onSubmit;

  const _StepConfirmation({
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.dni,
    required this.colegiacion,
    required this.especialidades,
    required this.ciudad,
    required this.tarifa,
    required this.acceptedTerms,
    required this.onTermsChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSizes.md),
          const Text(
            'Confirmación',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.greyDark),
          ),
          const SizedBox(height: AppSizes.xs),
          const Text(
            'Revisa tus datos antes de enviar la solicitud',
            style: TextStyle(fontSize: 14, color: AppColors.subtitleGrey),
          ),
          const SizedBox(height: AppSizes.xl),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummarySection(title: 'Datos personales', items: {
                  'Nombre': nombre,
                  'Email': email,
                  'Teléfono': telefono,
                }),
                const Divider(color: AppColors.borderColor, height: 24),
                _SummarySection(title: 'Datos profesionales', items: {
                  'DNI': dni,
                  'Colegiación': colegiacion,
                  'Especialidades': especialidades,
                }),
                const Divider(color: AppColors.borderColor, height: 24),
                _SummarySection(title: 'Zona y tarifas', items: {
                  'Ciudad': ciudad,
                  'Tarifa consulta': tarifa,
                }),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          AppCard(
            onTap: () => onTermsChanged(!acceptedTerms),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md, vertical: AppSizes.sm),
            child: Row(
              children: [
                Checkbox(
                  value: acceptedTerms,
                  onChanged: onTermsChanged,
                  activeColor: AppColors.primaryBlue,
                ),
                const Expanded(
                  child: Text(
                    'Acepto los términos y condiciones de Juris Honoris',
                    style: TextStyle(fontSize: 13, color: AppColors.greyDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          AppButton(
            label: 'Enviar solicitud de registro',
            onPressed: onSubmit,
            icon: Icons.send_outlined,
          ),
          const SizedBox(height: AppSizes.md),
          const Center(
            child: Text(
              'Tu solicitud será revisada en 24-48 horas hábiles',
              style: TextStyle(fontSize: 12, color: AppColors.subtitleGrey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final String title;
  final Map<String, String> items;

  const _SummarySection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue),
        ),
        const SizedBox(height: AppSizes.sm),
        ...items.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: Text('${e.key}:',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.subtitleGrey)),
                ),
                Expanded(
                  child: Text(e.value,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.greyDark,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Success screen ─────────────────────────────────────────────────────────────

class _SuccessScreen extends StatelessWidget {
  final VoidCallback onGoToDashboard;
  const _SuccessScreen({required this.onGoToDashboard});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline,
                    color: AppColors.successGreen, size: 56),
              ),
              const SizedBox(height: AppSizes.xl2),
              const Text(
                'Solicitud enviada exitosamente',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greyDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.md),
              const Text(
                'Tu solicitud de registro como abogado en Juris Honoris ha sido recibida. Revisaremos tus documentos y te notificaremos en 24-48 horas hábiles.',
                style: TextStyle(
                    fontSize: 14, color: AppColors.subtitleGrey, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.xl3),
              AppButton(
                label: 'Ir al Dashboard',
                onPressed: onGoToDashboard,
                icon: Icons.dashboard_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.greyDark),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;

  const _Field({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: AppColors.greyDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.hintGrey, fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.greyMedium, size: 20)
            : null,
        suffixIcon: suffixIcon,
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
      ),
    );
  }
}
