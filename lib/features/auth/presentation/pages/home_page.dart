import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/widgets.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: AppTheme.secondaryAccentColor),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Card
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.primaryAccentColor.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.person_outline,
                            size: 32,
                            color: AppTheme.primaryAccentColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText.titleMedium(
                                'Olá, ${user?.name ?? "Cliente"}!',
                                fontWeight: FontWeight.bold,
                              ),
                              const SizedBox(height: 4),
                              AppText.bodySmall(
                                user?.email ?? '',
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppText.bodyMedium('Perfil:', fontWeight: FontWeight.w600),
                        AppBadge(
                          label: user?.role.toUpperCase() ?? 'USER',
                          backgroundColor: user?.role == 'admin'
                              ? Colors.red.withValues(alpha: 0.12)
                              : AppTheme.primaryAccentColor.withValues(alpha: 0.12),
                          textColor: user?.role == 'admin'
                              ? Colors.red
                              : AppTheme.primaryAccentColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const AppText.titleMedium(
                'Seus Agendamentos',
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 64,
                        color: Colors.grey.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      const AppText.bodyMedium(
                        'Nenhum agendamento marcado.',
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 24),
                      AppButton.filled(
                        text: 'Agendar Novo Horário',
                        width: 220,
                        onPressed: () {
                          AppToast.info(context, message: 'Agendamento em breve!');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
