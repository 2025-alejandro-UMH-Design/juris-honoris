import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/core/utils/validators.dart';
import 'package:juris_honoris/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:juris_honoris/features/lawyers/presentation/pages/lawyer_login_page.dart';
import 'package:juris_honoris/shared/widgets/app_button.dart';
import 'package:juris_honoris/shared/widgets/google_sign_in_button.dart';

import 'register_page.dart';
import 'forgot_password_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          kIsWeb ? AppColors.webNavyDeep : AppColors.backgroundColor,
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
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return kIsWeb
              ? _WebLoginLayout(
                  formKey: _formKey,
                  isLoading: isLoading,
                  formFields: _buildFormFields(context, isLoading),
                )
              : SafeArea(
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
                          ..._buildFormFields(context, isLoading),
                        ],
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }

  /// Campos y acciones del formulario — compartidos entre el layout móvil
  /// (columna simple) y el layout web (tarjeta partida).
  List<Widget> _buildFormFields(BuildContext context, bool isLoading) {
    return [
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
      kIsWeb
          ? _WebPrimaryButton(
              label: 'Iniciar sesión',
              onPressed: isLoading ? null : _submit,
              isLoading: isLoading,
            )
          : AppButton(
              label: 'Iniciar Sesión',
              onPressed: isLoading ? null : _submit,
              isLoading: isLoading,
            ),
      const SizedBox(height: AppSizes.lg),

      // ── Divider ───────────────────────────────────────
      Row(
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
      ),
      const SizedBox(height: AppSizes.lg),

      // ── Google Sign-In ────────────────────────────────
      GoogleSignInButton(isLoading: isLoading),
      const SizedBox(height: AppSizes.md),

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
      const SizedBox(height: AppSizes.lg),
      const Divider(color: AppColors.borderColor),
      const SizedBox(height: AppSizes.sm),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.gavel,
            size: 16,
            color: AppColors.subtitleGrey,
          ),
          const SizedBox(width: AppSizes.xs),
          const Text(
            '¿Eres abogado? ',
            style: TextStyle(color: AppColors.subtitleGrey),
          ),
          TextButton(
            onPressed: isLoading
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LawyerLoginPage(),
                      ),
                    ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Inicia sesión aquí',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final radius = kIsWeb ? 4.0 : AppSizes.inputRadius;
    final focusColor = kIsWeb ? AppColors.webAccentBrass : AppColors.primaryBlue;

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
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: focusColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: AppColors.errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Web — layout de portal (panel institucional + tarjeta de formulario)
// ─────────────────────────────────────────────────────────────────────────────

class _WebLoginLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final List<Widget> formFields;

  const _WebLoginLayout({
    required this.formKey,
    required this.isLoading,
    required this.formFields,
  });

  Widget _formCard() {
    return ColoredBox(
      color: AppColors.backgroundColor,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
          child: Container(
            width: 400,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.borderColor),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: formFields,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _brandPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.webNavyDeep, Color(0xFF0F3350)],
        ),
      ),
      padding: const EdgeInsets.all(56),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            bottom: -40,
            child: Icon(
              Icons.balance_rounded,
              size: 320,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.webAccentBrass, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.balance_rounded,
                        color: AppColors.webAccentBrass, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'JURIS\nHONORIS',
                    style: GoogleFonts.sourceSerif4(
                      color: Colors.white,
                      fontSize: 22,
                      height: 1.05,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'Asistencia legal\ninteligente para\nHonduras',
                style: GoogleFonts.sourceSerif4(
                  color: Colors.white,
                  fontSize: 34,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 340,
                child: Text(
                  'Consulta con IA, gestiona tu expediente y conecta '
                  'con abogados verificados desde un mismo lugar.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14.5,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Navegador angosto (celular/tablet): una sola columna, sin panel.
        if (constraints.maxWidth < 860) return _formCard();

        return Row(
          children: [
            Expanded(flex: 5, child: _brandPanel()),
            Expanded(flex: 6, child: _formCard()),
          ],
        );
      },
    );
  }
}

/// Botón primario institucional para web: plano, esquinas rectas,
/// versalitas con tracking — en vez del botón redondeado tipo app móvil.
class _WebPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _WebPrimaryButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              disabled ? AppColors.greyLight : AppColors.webNavyDeep,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
      ),
    );
  }
}
