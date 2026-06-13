import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/neon_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        title: const Text("SafeStreet"),
      ),

      body: Center(
        child: NeonCard(
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Icon(
                Icons.security,
                color: AppTheme.neonPurple,
                size: 80,
              ),

              SizedBox(height: 20),

              Text(
                "Emergency Protection Active",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),

              SizedBox(height: 10),

              Text(
                "Your safety network is ready.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}