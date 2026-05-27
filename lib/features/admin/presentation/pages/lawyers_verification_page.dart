import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';

class LawyersVerificationPage extends StatelessWidget {
  const LawyersVerificationPage({super.key});

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
          'Verificación de Abogados',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.xl3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.greyLight.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.gavel,
                    size: 48,
                    color: AppColors.greyMedium,
                  ),
                ),
                const SizedBox(height: AppSizes.xl2),
                const Text(
                  'Sin abogados pendientes',
                  style: TextStyle(
                    color: AppColors.greyDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.sm),
                const Text(
                  'Los nuevos registros aparecerán aquí para revisión',
                  style: TextStyle(
                    color: AppColors.greyMedium,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
