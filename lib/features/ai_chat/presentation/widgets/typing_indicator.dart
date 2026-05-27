import 'package:flutter/material.dart';
import 'package:juris_honoris/core/constants/app_colors.dart';

/// Indicador animado de 3 puntos que representa que la IA está escribiendo.
/// Los puntos rebotan con animación staggered de 300ms entre cada uno.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  static const _dotCount = 3;
  static const _dotSize = 8.0;
  static const _staggerDelayMs = 300;
  static const _animationDurationMs = 600;

  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      _dotCount,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: _animationDurationMs),
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: -8).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startStaggeredAnimation();
  }

  void _startStaggeredAnimation() async {
    for (int i = 0; i < _dotCount; i++) {
      await Future.delayed(Duration(milliseconds: i * _staggerDelayMs));
      if (mounted) {
        _controllers[i].repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_dotCount, (i) {
          return Padding(
            padding: EdgeInsets.only(right: i < _dotCount - 1 ? 6 : 0),
            child: AnimatedBuilder(
              animation: _animations[i],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _animations[i].value),
                  child: child,
                );
              },
              child: Container(
                width: _dotSize,
                height: _dotSize,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
