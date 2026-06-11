import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/features/admin/data/datasources/admin_local_datasource.dart';
import 'package:juris_honoris/features/admin/presentation/pages/admin_dashboard_page.dart';

class AdminPinPage extends StatefulWidget {
  const AdminPinPage({super.key});

  @override
  State<AdminPinPage> createState() => _AdminPinPageState();
}

class _AdminPinPageState extends State<AdminPinPage> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyPin() async {
    final pin = _pinController.text.trim();

    if (pin.length < 4) {
      setState(() => _errorMessage = 'El PIN debe tener 4 dígitos');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final datasource = AdminLocalDatasource(prefs: prefs);
      final isValid = await datasource.verifyPin(pin);

      if (!mounted) return;

      if (isValid) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const AdminDashboardPage(),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'PIN incorrecto. Inténtalo de nuevo.';
          _pinController.clear();
        });
        _focusNode.requestFocus();
      }
    } catch (e) {
      if (!mounted) return;
      setState(
          () => _errorMessage = 'Error al verificar PIN. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.greyDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Acceso Admin',
          style: TextStyle(
            color: AppColors.greyDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icono
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  size: 40,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: AppSizes.xl2),

              // Título
              const Text(
                'Panel de Administración',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.greyDark,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.sm),

              // Subtítulo
              const Text(
                'Ingresa el PIN de administrador',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.greyMedium,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: AppSizes.xl3),

              // Campo PIN
              TextField(
                controller: _pinController,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 12,
                  color: AppColors.greyDark,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '• • • •',
                  hintStyle: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 8,
                    color: AppColors.greyLight,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  errorText: _errorMessage,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.xl2,
                    vertical: AppSizes.lg,
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
                    borderSide: const BorderSide(
                      color: AppColors.primaryBlue,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                    borderSide: const BorderSide(color: AppColors.errorRed),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                    borderSide:
                        const BorderSide(color: AppColors.errorRed, width: 2),
                  ),
                ),
                onSubmitted: (_) => _verifyPin(),
              ),
              const SizedBox(height: AppSizes.xl2),

              // Botón Ingresar
              SizedBox(
                height: AppSizes.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyPin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    disabledBackgroundColor:
                        AppColors.primaryBlue.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.buttonRadius),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Ingresar',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // Nota PIN inicial
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.lg,
                  vertical: AppSizes.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                  border: Border.all(
                    color: AppColors.secondaryOrange.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.secondaryOrange,
                    ),
                    SizedBox(width: AppSizes.sm),
                    Text(
                      'PIN inicial: 1234',
                      style: TextStyle(
                        color: AppColors.secondaryOrange,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
