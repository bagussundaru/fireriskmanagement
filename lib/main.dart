import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase (optional - will work without it)
  await SupabaseService.initialize();
  
  runApp(const FireRiskApp());
}

class FireRiskApp extends StatelessWidget {
  const FireRiskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fire Risk Assessment',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // It's actually light now
      home: const MainScreen(),
    );
  }
}
