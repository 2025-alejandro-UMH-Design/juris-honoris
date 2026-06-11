import 'package:flutter/material.dart';
import 'package:juris_honoris/core/constants/app_colors.dart';

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
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.gavel, size: 64, color: AppColors.greyLight),
            SizedBox(height: 16),
            Text(
              'Próximamente disponible',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.greyDark,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'La verificación de abogados estará\ndisponible en la próxima versión.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.greyMedium),
            ),
          ],
        ),
      ),
    );
  }
}
