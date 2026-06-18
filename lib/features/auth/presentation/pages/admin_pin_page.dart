import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/features/auth/presentation/bloc/auth_cubit.dart';

/// Pantalla de acceso al panel de administrador.
/// Solo accesible para usuarios con rol admin (verificado en JWT).
class AdminPinPage extends StatelessWidget {
  const AdminPinPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.read<AuthCubit>().isAdmin;
    if (!isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).pop();
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
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
      body: const Center(
        child: Text(
          'Acceso administrativo verificado.\nUsa el panel web para administración.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.greyMedium, fontSize: 15),
        ),
      ),
    );
  }
}
