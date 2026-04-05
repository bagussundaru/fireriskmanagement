import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'factory_info_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo and Title
              const Icon(
                Icons.local_fire_department,
                size: 80,
                color: AppTheme.goldPrimary,
              ),
              const SizedBox(height: 16),
              const Text(
                'FIRE RISK',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.goldPrimary,
                ),
              ),
              const Text(
                'ASSESSMENT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.textSecondary,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              
              // Start Assessment Button
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Ready to start an inspection?',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FactoryInfoScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Factory / Start Assessment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.goldPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              // Footer
              const Text(
                'v1.0.0 • Fire Safety Compliance Tool',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

