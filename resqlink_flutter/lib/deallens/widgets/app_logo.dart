import 'package:flutter/material.dart';

/// Renders the official DealLens app logo with rounded corners and subtle shadow.
class AppLogo extends StatelessWidget {
  final double size;
  final double borderRadius;
  final bool showShadow;

  const AppLogo({
    super.key,
    this.size = 56,
    this.borderRadius = 16,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: const Color(0xFF0066FF).withValues(alpha: 0.25),
                  blurRadius: (size * 0.2).clamp(4.0, 20.0),
                  offset: Offset(0, (size * 0.06).clamp(2.0, 8.0)),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          'assets/images/app_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: const Color(0xFF0066FF),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white,
                size: size * 0.55,
              ),
            );
          },
        ),
      ),
    );
  }
}
