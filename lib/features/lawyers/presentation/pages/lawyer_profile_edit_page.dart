import 'package:flutter/material.dart';
import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
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
  State<LawyerProfileEditPage> createState() =>
      _LawyerProfileEditPageState();
}

class _LawyerProfileEditPageState extends State<LawyerProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  // Mock pre-filled data
  final _nombreController =
      TextEditingController(text: 'Carlos Mendoza López');
  final _telefonoController =
      TextEditingController(text: '+504 9876-5432');
  final _bioController = TextEditingController(
    text:
        'Abogado con 8 años de experiencia en derecho de familia y civil. Especialista en mediación y resolución de conflictos.',
  );
  final _tarifaController = TextEditingController(text: '750');

  String? _selectedCity = 'Tegucigalpa';
  final Set<String> _selectedSpecialties = {'Familia', 'Civil'};
  bool _isSaving = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _bioController.dispose();
    _tarifaController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    Future.delayed(const Duration(milliseconds: 800), () {
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
      );
    });
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
      body: SingleChildScrollView(
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
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.primaryBlue,
                          child: const Text(
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
                                    content: Text(
                                        'Cambio de foto próximamente')),
                              );
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.borderColor,
                                    width: 1.5),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Color(0x1A000000),
                                      blurRadius: 4),
                                ],
                              ),
                              child: const Icon(Icons.camera_alt,
                                  size: 14,
                                  color: AppColors.primaryBlue),
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
                              content:
                                  Text('Cambio de foto próximamente')),
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
                        color: AppColors.successGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color:
                                AppColors.successGreen.withOpacity(0.3)),
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

              _FormLabel('Nombre completo'),
              const SizedBox(height: AppSizes.xs),
              _ProfileField(
                controller: _nombreController,
                hint: 'Tu nombre completo',
                prefixIcon: Icons.person_outline,
                validator: (v) => v == null || v.isEmpty
                    ? 'Ingresa tu nombre'
                    : null,
              ),
              const SizedBox(height: AppSizes.md),

              _FormLabel('Teléfono'),
              const SizedBox(height: AppSizes.xs),
              _ProfileField(
                controller: _telefonoController,
                hint: '+504 9999-9999',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSizes.md),

              _FormLabel('Descripción / Biografía'),
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
              Text(
                'Selecciona todas las que apliquen',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.subtitleGrey),
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
                        color: selected
                            ? AppColors.primaryBlue
                            : AppColors.white,
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
                          color: selected
                              ? AppColors.white
                              : AppColors.greyDark,
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
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

              _FormLabel('Ciudad / Departamento'),
              const SizedBox(height: AppSizes.xs),
              DropdownButtonFormField<String>(
                value: _selectedCity,
                onChanged: (v) => setState(() => _selectedCity = v),
                items: _cities
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                decoration: _dropdownDecoration(),
              ),
              const SizedBox(height: AppSizes.md),

              _FormLabel('Tarifa consulta inicial (L.)'),
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

              AppCard(
                child: Column(
                  children: [
                    _DocumentStatusRow(
                      title: 'Cédula de identidad',
                      status: 'Verificado',
                      isVerified: true,
                      icon: Icons.credit_card_outlined,
                    ),
                    const Divider(
                        color: AppColors.borderColor, height: 20),
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
                onPressed: _isSaving ? null : _saveChanges,
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
      prefixIcon: const Icon(Icons.location_on_outlined,
          color: AppColors.greyMedium),
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
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.greyDark),
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
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.greyDark),
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
        hintStyle:
            const TextStyle(color: AppColors.hintGrey, fontSize: 14),
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
            color: AppColors.primaryBlue.withOpacity(0.1),
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
              isVerified
                  ? Icons.check_circle
                  : Icons.hourglass_top_outlined,
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
