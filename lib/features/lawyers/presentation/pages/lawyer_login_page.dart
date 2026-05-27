import 'package:flutter/material.dart';
import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/shared/widgets/app_button.dart';

import 'lawyer_dashboard_page.dart';
import 'lawyer_register_wizard.dart';

class LawyerLoginPage extends StatefulWidget {
  const LawyerLoginPage({super.key});

  @override
  State<LawyerLoginPage> createState() => _LawyerLoginPageState();
}

class _LawyerLoginPageState extends State<LawyerLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    // Demo: any credentials work
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LawyerDashboardPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePadding,
            vertical: AppSizes.xl2,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSizes.xl),

                // ── Header ────────────────────────────────────────────
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.balance,
                    color: AppColors.primaryBlue,
                    size: 36,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Text(
                  'Juris Honoris',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSizes.sm),

                // ── Lawyer badge ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ACCESO PARA ABOGADOS',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.xl3),

                Text(
                  'Bienvenido, Abogado',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.greyDark,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Inicia sesión para gestionar tus casos',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtitleGrey,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.xl3),

                // ── Email ─────────────────────────────────────────────
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu correo';
                    if (!v.contains('@')) return 'Correo inválido';
                    return null;
                  },
                  decoration: _inputDecoration(
                    label: 'Correo electrónico',
                    hint: 'abogado@ejemplo.com',
                    icon: Icons.email_outlined,
                  ),
                ),
                const SizedBox(height: AppSizes.md),

                // ── Password ──────────────────────────────────────────
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  enabled: !_isLoading,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                  decoration: _inputDecoration(
                    label: 'Contraseña',
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.greyMedium,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.xl2),

                // ── Submit ────────────────────────────────────────────
                AppButton(
                  label: 'Iniciar sesión como abogado',
                  onPressed: _isLoading ? null : _submit,
                  isLoading: _isLoading,
                  icon: Icons.login,
                ),
                const SizedBox(height: AppSizes.xl),

                // ── Register link ─────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Aún no eres parte de Juris Honoris? ',
                      style: TextStyle(
                        color: AppColors.subtitleGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LawyerRegisterWizard(),
                            ),
                          ),
                  child: const Text(
                    'Regístrate como abogado',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.xl),
                const Divider(color: AppColors.borderColor),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Demo: cualquier credencial válida funciona',
                  style: TextStyle(
                    color: AppColors.greyMedium,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.greyMedium),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.md,
      ),
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
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
      ),
    );
  }
}
