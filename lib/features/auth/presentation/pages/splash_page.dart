import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/widgets.dart';
import '../providers/auth_provider.dart';

import '../../../navigation/presentation/pages/main_scaffold_page.dart';
import 'login_page.dart';
import 'profile_setup_page.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _initApp();
  }

  Future<void> _initApp() async {
    // Dá um tempo mínimo de exibição para a animação da splash
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final user = await ref.read(authProvider.notifier).checkSession();

    if (!mounted) return;

    if (user != null) {
      if (user.name.isEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ProfileSetupPage(
              userId: user.id,
              email: user.email,
            ),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScaffoldPage()),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const ClipOval(
                  child: Icon(
                    Icons.spa_outlined,
                    size: 80,
                    color: AppTheme.primaryAccentColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const AppText.titleLarge(
                'Tha Unhas',
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 8),
              const AppText.bodyMedium(
                'Sofisticação e Cuidado em cada detalhe',
                color: Colors.grey,
              ),
              const SizedBox(height: 48),
              const AppLoading(color: AppTheme.primaryAccentColor),
            ],
          ),
        ),
      ),
    );
  }
}
