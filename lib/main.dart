import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'services/supabase_service.dart';
import 'services/language_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const FireRiskApp());
}

class FireRiskApp extends StatelessWidget {
  const FireRiskApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder on the global lang notifier triggers full app rebuild on toggle
    return AnimatedBuilder(
      animation: lang,
      builder: (_, __) => MaterialApp(
        title: lang.t('app_title'),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainScreen(),
      ),
    );
  }
}
