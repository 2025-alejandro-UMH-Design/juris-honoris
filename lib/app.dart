import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:juris_honoris/injection_container.dart';
import 'package:juris_honoris/router/app_router.dart';
import 'package:juris_honoris/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:juris_honoris/features/auth/presentation/bloc/auth_state.dart';
import 'package:juris_honoris/core/constants/app_colors.dart';

class JurisHonorisApp extends StatefulWidget {
  const JurisHonorisApp({super.key});

  @override
  State<JurisHonorisApp> createState() => _JurisHonorisAppState();
}

class _JurisHonorisAppState extends State<JurisHonorisApp> {
  late final AuthCubit _authCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authCubit = sl<AuthCubit>();
    _router = createRouter(_authCubit);
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _router.go('/home');
          } else if (state is AuthUnauthenticated) {
            _router.go('/login');
          }
        },
        child: MaterialApp.router(
          title: 'Juris Honoris',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(),
          routerConfig: _router,
        ),
      ),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.secondaryOrange,
        error: AppColors.errorRed,
        surface: AppColors.white,
        background: AppColors.backgroundColor,
      ),
      scaffoldBackgroundColor: AppColors.backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.greyDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.greyDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        hintStyle: const TextStyle(color: AppColors.placeholder),
        labelStyle: const TextStyle(color: AppColors.greyMedium),
      ),
      cardTheme: CardTheme(
        color: AppColors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.borderColor),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderColor,
        thickness: 1,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.greyVeryLight,
        selectedColor: AppColors.primaryBlue.withOpacity(0.15),
        labelStyle: const TextStyle(fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.robotoTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.roboto(
          fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.greyDark),
        headlineMedium: GoogleFonts.roboto(
          fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.greyDark),
        headlineSmall: GoogleFonts.roboto(
          fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.greyDark),
        bodyLarge: GoogleFonts.roboto(
          fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.subtitleGrey),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.greyMedium),
        labelSmall: GoogleFonts.roboto(
          fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.subtitleGrey),
      ),
    );
  }
}
