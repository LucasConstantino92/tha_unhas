import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/splash_page.dart';

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
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();

        final mediaQueryData = MediaQuery.of(context);
        final clampedTextScaler = mediaQueryData.textScaler.clamp(
          minScaleFactor: 0.8,
          maxScaleFactor: 1.25,
        );

        final double constrainedWidth = mediaQueryData.size.width > 800 ? 800 : mediaQueryData.size.width;
        final newSize = Size(constrainedWidth, mediaQueryData.size.height);

        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: clampedTextScaler,
            size: newSize,
          ),
          child: Container(
            color: mediaQueryData.size.width > 800
                ? (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1C1A16)
                    : const Color(0xFFEFEBE0))
                : null,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                decoration: mediaQueryData.size.width > 800
                    ? const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      )
                    : null,
                child: child,
              ),
            ),
          ),
        );
      },
      home: const SplashPage(),
    );
  }
}
