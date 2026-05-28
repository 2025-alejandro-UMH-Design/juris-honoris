import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:juris_honoris/shared/widgets/app_button.dart';

/// Pantalla de acceso rápido al panel de administrador mediante PIN.
/// PIN por defecto (demo): 1234
class AdminPinPage extends StatefulWidget {
  const AdminPinPage({super.key});

  @override
  State<AdminPinPage> createState() => _AdminPinPageState();
}

class _AdminPinPageState extends State<AdminPinPage> {
  static const _correctPin = '1234';

  String _pin = '';
  bool _hasError = false;
  bool _isLoading = false;

  void _onKeyTap(String digit) {
    if (_pin.length >= 4 || _isLoading) return;
    setState(() {
      _pin += digit;
      _hasError = false;
    });
    if (_pin.length == 4) _verify();
  }

  void _onDelete() {
    if (_pin.isEmpty || _isLoading) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _verify() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    if (_pin == _correctPin) {
      // Loguea como admin
      await context.read<AuthCubit>().loginWithEmail('admin@juris.hn', 'demo');
    } else {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _pin = '';
      });
    }
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
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          // Cuando el login admin tiene éxito, la navegación la maneja el router.
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePadding * 2,
              vertical: AppSizes.xl,
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSizes.xl3),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueDark.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: AppColors.primaryBlueDark,
                    size: 32,
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                Text(
                  'Acceso Administrador',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.greyDark,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Ingresa el PIN de administrador',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtitleGrey,
                      ),
                ),
                const SizedBox(height: AppSizes.xl3),

                // ── PIN dots ─────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final filled = i < _pin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _hasError
                            ? AppColors.errorRed
                            : filled
                                ? AppColors.primaryBlue
                                : AppColors.greyLight,
                        border: Border.all(
                          color: _hasError
                              ? AppColors.errorRed
                              : filled
                                  ? AppColors.primaryBlue
                                  : AppColors.borderColor,
                        ),
                      ),
                    );
                  }),
                ),

                if (_hasError) ...[
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'PIN incorrecto. Intenta de nuevo.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.errorRed,
                        ),
                  ),
                ],

                const SizedBox(height: AppSizes.xl3),

                // ── Keypad ───────────────────────────────────────────
                if (_isLoading)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
                  )
                else
                  _Keypad(
                    onDigit: _onKeyTap,
                    onDelete: _onDelete,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  const _Keypad({required this.onDigit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];

    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key.isEmpty) return const SizedBox(width: 80, height: 64);
            if (key == 'del') {
              return SizedBox(
                width: 80,
                height: 64,
                child: IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.backspace_outlined,
                    color: AppColors.greyMedium,
                  ),
                ),
              );
            }
            return SizedBox(
              width: 80,
              height: 64,
              child: TextButton(
                onPressed: () => onDigit(key),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.greyDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                  ),
                ),
                child: Text(
                  key,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
