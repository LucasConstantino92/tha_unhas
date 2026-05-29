import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() async {
  // Preserva a splash screen durante a inicialização
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    // Inicialização do Supabase usando a configuração definida
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Erro ao inicializar o Supabase: $e');
  }

  // Remove a splash screen nativa após as inicializações terminarem
  FlutterNativeSplash.remove();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tha Unhas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // Como solicitado, sempre inicia no tema Light
      themeMode: ThemeMode.light,
      home: const LoginPage(),
    );
  }
}
