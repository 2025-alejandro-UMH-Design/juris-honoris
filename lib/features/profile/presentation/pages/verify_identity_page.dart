import 'package:flutter/material.dart';
import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/core/utils/validators.dart';
import 'package:juris_honoris/shared/widgets/app_button.dart';
import 'package:juris_honoris/shared/widgets/app_input_field.dart';
import 'package:juris_honoris/shared/widgets/app_header.dart';

class VerifyIdentityPage extends StatefulWidget {
  final VoidCallback? onVerified;
  const VerifyIdentityPage({super.key, this.onVerified});

  @override
  State<VerifyIdentityPage> createState() => _VerifyIdentityPageState();
}

class _VerifyIdentityPageState extends State<VerifyIdentityPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dniController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dniController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Identidad verificada exitosamente!'),
        backgroundColor: AppColors.successGreen,
      ),
    );
    widget.onVerified?.call();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppHeader(
        title: 'Verificar identidad',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: AppColors.primaryBlue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verificación requerida',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.greyDark),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Para solicitar un abogado, los abogados necesitan saber quién les envía casos.',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.subtitleGrey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppInputField(
                    label: 'Nombre completo',
                    hintText: 'Juan Antonio García López',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline,
                    validator: Validators.required,
                  ),
                  const SizedBox(height: AppSizes.md),
                  AppInputField(
                    label: 'DNI / Cédula de identidad',
                    hintText: '0801-1990-12345',
                    controller: _dniController,
                    prefixIcon: Icons.badge_outlined,
                    validator: Validators.dni,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: AppSizes.md),
                  AppInputField(
                    label: 'Teléfono',
                    hintText: '+504 9999-9999',
                    controller: _phoneController,
                    prefixIcon: Icons.phone_outlined,
                    validator: Validators.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tus datos están protegidos y solo serán compartidos con el abogado asignado.',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.subtitleGrey),
                  ),
                  const SizedBox(height: 28),
                  AppButton(
                    label: 'Verificar y continuar',
                    variant: ButtonVariant.primary,
                    isLoading: _isLoading,
                    icon: Icons.verified_outlined,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
