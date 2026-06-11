import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/features/admin/domain/entities/ai_provider_config.dart';
import 'package:juris_honoris/features/admin/presentation/bloc/admin_cubit.dart';

class AIProvidersPage extends StatefulWidget {
  const AIProvidersPage({super.key});

  @override
  State<AIProvidersPage> createState() => _AIProvidersPageState();
}

class _AIProvidersPageState extends State<AIProvidersPage> {
  // Mantenemos un Map de controladores por proveedor key
  final Map<String, TextEditingController> _apiKeyControllers = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Inicializar controllers con los valores cargados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initControllers();
    });
  }

  void _initControllers() {
    final cubit = context.read<AdminCubit>();
    final providers = cubit.currentProviders;
    for (final provider in providers) {
      if (!_apiKeyControllers.containsKey(provider.key)) {
        _apiKeyControllers[provider.key] =
            TextEditingController(text: provider.apiKey);
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (final ctrl in _apiKeyControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    final cubit = context.read<AdminCubit>();
    final currentProviders = cubit.currentProviders;

    // Construir lista final con los valores de los controllers
    final updatedProviders = currentProviders.map((provider) {
      final controller = _apiKeyControllers[provider.key];
      final apiKey = controller?.text.trim() ?? provider.apiKey;
      return provider.copyWith(apiKey: apiKey);
    }).toList();

    await cubit.saveAllChanges(updatedProviders);

    if (!mounted) return;

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.white, size: 18),
            SizedBox(width: AppSizes.sm),
            Text(
              'Configuración guardada correctamente',
              style: TextStyle(color: AppColors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.sm),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Proveedores de IA',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.sm),
            child: _isSaving
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.check, color: AppColors.white),
                    tooltip: 'Guardar cambios',
                    onPressed: _saveChanges,
                  ),
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.white, size: 18),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.errorRed,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.sm),
                ),
              ),
            );
          }
          // Cuando se carga o guarda, sincronizar los controllers
          if (state is AdminLoaded) {
            for (final provider in state.providers) {
              if (!_apiKeyControllers.containsKey(provider.key)) {
                _apiKeyControllers[provider.key] =
                    TextEditingController(text: provider.apiKey);
              }
            }
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          List<AIProviderConfig> providers = [];
          if (state is AdminLoaded) providers = state.providers;
          if (state is AdminSaved) providers = state.providers;

          return SafeArea(
            child: Column(
              children: [
                // Banner informativo
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(AppSizes.pagePadding),
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info,
                        color: AppColors.primaryBlue,
                        size: 18,
                      ),
                      SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          'El proveedor activo será usado por todos los usuarios en el Chat IA',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Advertencia si no hay proveedor activo
                if (providers.isNotEmpty && !providers.any((p) => p.isActive))
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(AppSizes.pagePadding, 0,
                        AppSizes.pagePadding, AppSizes.md),
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                      border: Border.all(
                        color: AppColors.secondaryOrange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.secondaryOrange,
                          size: 18,
                        ),
                        SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Text(
                            'Configura al menos un proveedor para que el Chat IA funcione',
                            style: TextStyle(
                              color: AppColors.secondaryOrange,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Lista de providers
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.pagePadding,
                      0,
                      AppSizes.pagePadding,
                      AppSizes.pagePadding,
                    ),
                    itemCount: providers.length,
                    itemBuilder: (context, index) {
                      final provider = providers[index];
                      return _ProviderCard(
                        provider: provider,
                        apiKeyController: _apiKeyControllers[provider.key] ??
                            TextEditingController(text: provider.apiKey),
                        onToggle: (enabled) {
                          context
                              .read<AdminCubit>()
                              .toggleProvider(provider.key, enabled);
                        },
                        onModelChanged: (model) {
                          context
                              .read<AdminCubit>()
                              .updateModel(provider.key, model);
                        },
                        onSetActive: () {
                          // Sincronizar apiKey del controller antes de activar
                          final ctrl = _apiKeyControllers[provider.key];
                          if (ctrl != null) {
                            context
                                .read<AdminCubit>()
                                .updateApiKey(provider.key, ctrl.text.trim());
                          }
                          context
                              .read<AdminCubit>()
                              .setActiveProvider(provider.key);
                        },
                      );
                    },
                  ),
                ),

                // Botón guardar fijo abajo
                Container(
                  padding: const EdgeInsets.all(AppSizes.pagePadding),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: const Border(
                      top: BorderSide(color: AppColors.borderColor),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveChanges,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save, color: AppColors.white),
                      label: Text(
                        _isSaving ? 'Guardando...' : 'Guardar cambios',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Provider Card widget
// ---------------------------------------------------------------------------

class _ProviderCard extends StatefulWidget {
  final AIProviderConfig provider;
  final TextEditingController apiKeyController;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onModelChanged;
  final VoidCallback onSetActive;

  const _ProviderCard({
    required this.provider,
    required this.apiKeyController,
    required this.onToggle,
    required this.onModelChanged,
    required this.onSetActive,
  });

  @override
  State<_ProviderCard> createState() => _ProviderCardState();
}

class _ProviderCardState extends State<_ProviderCard> {
  bool _obscureApiKey = true;

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final isActive = provider.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.cardGap),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: isActive ? AppColors.primaryBlue : AppColors.borderColor,
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? AppColors.primaryBlue.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: emoji + nombre + toggle
            Row(
              children: [
                Text(
                  provider.logoEmoji,
                  style: const TextStyle(fontSize: 26),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.name,
                        style: const TextStyle(
                          color: AppColors.greyDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        provider.description,
                        style: const TextStyle(
                          color: AppColors.greyMedium,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: provider.isEnabled,
                  onChanged: widget.onToggle,
                  activeThumbColor: AppColors.primaryBlue,
                  inactiveTrackColor: AppColors.greyLight,
                ),
              ],
            ),

            // Badge ACTIVO
            if (isActive) ...[
              const SizedBox(height: AppSizes.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.white, size: 14),
                    SizedBox(width: AppSizes.xs),
                    Text(
                      'PROVEEDOR ACTIVO',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Campos expandidos si está habilitado
            if (provider.isEnabled) ...[
              const SizedBox(height: AppSizes.lg),
              const Divider(height: 1, color: AppColors.borderColor),
              const SizedBox(height: AppSizes.lg),

              // Campo API Key
              const Text(
                'API Key',
                style: TextStyle(
                  color: AppColors.greyDark,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              TextField(
                controller: widget.apiKeyController,
                obscureText: _obscureApiKey,
                style: const TextStyle(
                  color: AppColors.greyDark,
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
                decoration: InputDecoration(
                  hintText: 'Ingresa tu API key aquí',
                  hintStyle: const TextStyle(
                    color: AppColors.greyMedium,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
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
                    borderSide: const BorderSide(
                        color: AppColors.primaryBlue, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureApiKey ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.greyMedium,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureApiKey = !_obscureApiKey),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Selector de modelo
              const Text(
                'Modelo',
                style: TextStyle(
                  color: AppColors.greyDark,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  border: Border.all(color: AppColors.borderColor),
                  borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: provider.availableModels.contains(provider.model)
                        ? provider.model
                        : provider.availableModels.first,
                    isExpanded: true,
                    icon: const Icon(Icons.expand_more,
                        color: AppColors.greyMedium),
                    dropdownColor: AppColors.white,
                    style: const TextStyle(
                      color: AppColors.greyDark,
                      fontSize: 14,
                    ),
                    items: provider.availableModels.map((model) {
                      return DropdownMenuItem(
                        value: model,
                        child: Text(
                          model,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) widget.onModelChanged(value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Botón "Usar como activo" o badge activo
              if (!isActive)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: widget.onSetActive,
                    icon: const Icon(Icons.radio_button_checked, size: 16),
                    label: const Text('Usar como proveedor activo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSizes.md),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.buttonRadius),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('ACTIVO ACTUALMENTE'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.successGreen,
                      side: const BorderSide(color: AppColors.successGreen),
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSizes.md),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.buttonRadius),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
