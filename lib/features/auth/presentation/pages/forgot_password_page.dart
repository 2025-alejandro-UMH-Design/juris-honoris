import 'package:flutter/material.dart';

import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/core/utils/validators.dart';
import 'package:juris_honoris/shared/widgets/app_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.greyDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePadding,
            vertical: AppSizes.xl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset_outlined,
                      color: AppColors.primaryBlue,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.xl2),
                Text(
                  'Recuperar contraseña',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.greyDark,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Ingresa tu correo y te enviaremos instrucciones para restablecer tu contraseña.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtitleGrey,
                      ),
                ),
                const SizedBox(height: AppSizes.xl3),
                if (_sent) ...[
                  _SuccessBanner(email: _emailController.text.trim()),
                  const SizedBox(height: AppSizes.xl2),
                ],
                if (!_sent) ...[
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    enabled: !_isLoading,
                    validator: Validators.email,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      hintText: 'correo@ejemplo.com',
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.greyMedium,
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.lg,
                        vertical: AppSizes.md,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.inputRadius),
                        borderSide:
                            const BorderSide(color: AppColors.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.inputRadius),
                        borderSide:
                            const BorderSide(color: AppColors.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.inputRadius),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.inputRadius),
                        borderSide: const BorderSide(color: AppColors.errorRed),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.inputRadius),
                        borderSide: const BorderSide(
                          color: AppColors.errorRed,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  AppButton(
                    label: 'Enviar instrucciones',
                    onPressed: _isLoading ? null : _submit,
                    isLoading: _isLoading,
                  ),
                ],
                if (_sent) ...[
                  AppButton(
                    label: 'Volver al inicio de sesión',
                    variant: ButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  final String email;

  const _SuccessBanner({required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: AppColors.successGreen.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.successGreen,
            size: 22,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              'Si el correo $email existe en nuestro sistema, recibirás instrucciones para restablecer tu contraseña.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.successGreen,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
