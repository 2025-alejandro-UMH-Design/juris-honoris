import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Indicador de carga circular de Juris Honoris.
///
/// Muestra [CircularProgressIndicator] en azul primario.
/// Opcionalmente muestra un [message] debajo.
class LoadingIndicator extends StatelessWidget {
  final double size;
  final String? message;

  const LoadingIndicator({
    super.key,
    this.size = 48,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryBlue,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.subtitleGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
