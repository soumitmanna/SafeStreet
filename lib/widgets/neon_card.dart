import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NeonCard extends StatelessWidget {
  final Widget child;

  const NeonCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 420,

      decoration: BoxDecoration(
        color: AppTheme.cardColor,

        borderRadius: BorderRadius.circular(30),

        border: Border.all(
          color: AppTheme.neonPurple,
          width: 2,
        ),

        boxShadow: [
          BoxShadow(
            color: AppTheme.neonPurple.withOpacity(0.7),
            blurRadius: 25,
            spreadRadius: 1,
          ),
        ],
      ),

      child: child,
    );
  }
}