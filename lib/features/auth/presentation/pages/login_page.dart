import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/core/utils/validators.dart';
import 'package:juris_honoris/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:juris_honoris/shared/widgets/app_button.dart';

import 'register_page.dart';
import 'forgot_password_page.dart';
import 'admin_pin_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().loginWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  void _loginWithGoogle() {
    context.read<AuthCubit>().loginWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
          // La navegación post-login la maneja el router del app.
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SafeArea(
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
                    // ── Header ─────────────────────────────────────────
                    const SizedBox(height: AppSizes.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.balance,
                          color: AppColors.primaryBlue,
                          size: 32,
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Text(
                          'Juris Honoris',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xl3),

                    // ── Titles ─────────────────────────────────────────
                    Text(
                      'Bienvenido de vuelta',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.greyDark,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      'Inicia sesión para continuar',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.subtitleGrey,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.xl3),

                    // ── Email ─────────────────────────────────────────
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      validator: Validators.email,
                      decoration: _inputDecoration(
                        label: 'Correo electrónico',
                        hint: 'correo@ejemplo.com',
                        icon: Icons.email_outlined,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),

                    // ── Password ──────────────────────────────────────
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      enabled: !isLoading,
                      validator: Validators.password,
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
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.xl),

                    // ── Primary Button ────────────────────────────────
                    AppButton(
                      label: 'Iniciar Sesión',
                      onPressed: isLoading ? null : _submit,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: AppSizes.xl),

                    // ── Divider ───────────────────────────────────────
                    _OrDivider(),
                    const SizedBox(height: AppSizes.xl),

                    // ── Google Button ─────────────────────────────────
                    AppButton(
                      label: 'Continuar con Google',
                      variant: ButtonVariant.secondary,
                      icon: Icons.g_mobiledata_rounded,
                      onPressed: isLoading ? null : _loginWithGoogle,
                      isLoading: false,
                    ),
                    const SizedBox(height: AppSizes.xl2),

                    // ── Links ─────────────────────────────────────────
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordPage(),
                                ),
                              ),
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: AppColors.primaryBlue),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿No tienes cuenta? ',
                          style: TextStyle(color: AppColors.subtitleGrey),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterPage(),
                                    ),
                                  ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Regístrate',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSizes.xl3),
                    const Divider(color: AppColors.borderColor),
                    const SizedBox(height: AppSizes.sm),

                    // ── Admin access ──────────────────────────────────
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AdminPinPage(),
                                ),
                              ),
                      child: const Text(
                        'Acceso Admin',
                        style: TextStyle(
                          color: AppColors.greyMedium,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
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

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.borderColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Text(
            'o continúa con',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.greyMedium,
                ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.borderColor)),
      ],
    );
  }
}
