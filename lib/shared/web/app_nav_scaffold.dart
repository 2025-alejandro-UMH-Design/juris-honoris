import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:juris_honoris/shared/widgets/bottom_nav_bar.dart';
import 'package:juris_honoris/shared/web/web_top_nav.dart';

/// Scaffold de las secciones principales (Inicio, Chat IA, Casos, Expediente,
/// Perfil). En móvil se comporta exactamente como antes (AppBar propio +
/// [BottomNavBar]). En web usa [WebTopNav] en vez de la barra inferior —
/// el resto del contenido de cada pantalla no cambia.
class AppNavScaffold extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTabChanged;
  final PreferredSizeWidget? mobileAppBar;
  final Widget body;
  final Color? backgroundColor;
  final Widget? floatingActionButton;

  const AppNavScaffold({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.body,
    this.mobileAppBar,
    this.backgroundColor,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Scaffold(
        backgroundColor: backgroundColor ?? AppColors.backgroundColor,
        appBar: mobileAppBar,
        body: body,
        bottomNavigationBar: BottomNavBar(
          currentIndex: currentIndex,
          onTabChanged: onTabChanged,
        ),
        floatingActionButton: floatingActionButton,
      );
    }

    final user = context.watch<AuthCubit>().currentUser;

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.backgroundColor,
      appBar: WebTopNav(
        currentIndex: currentIndex,
        onTabChanged: onTabChanged,
        user: user,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
