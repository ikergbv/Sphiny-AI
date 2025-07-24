import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class BackgroundGradientWidget extends StatefulWidget {
  final Widget child;

  const BackgroundGradientWidget({
    super.key,
    required this.child,
  });

  @override
  State<BackgroundGradientWidget> createState() =>
      _BackgroundGradientWidgetState();
}

class _BackgroundGradientWidgetState extends State<BackgroundGradientWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));

    _gradientController.forward();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                _gradientAnimation.value * 0.5,
                _gradientAnimation.value,
                1.0,
              ],
              colors: [
                AppTheme.primaryDark,
                AppTheme.primaryLight,
                AppTheme.accentLight.withValues(alpha: 0.8),
                AppTheme.primaryDark,
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
