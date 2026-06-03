import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/widgets.dart';
import '../providers/auth_provider.dart';
import '../../../navigation/presentation/providers/navigation_provider.dart';
import 'login_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    // Mock appointments for now, until we connect to the provider
    final mockAppointments = []; 

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${user?.name ?? "Cliente"}!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: AppTheme.secondaryAccentColor),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText.titleMedium(
                    'Histórico de Agendamentos',
                    fontWeight: FontWeight.bold,
                  ),
                  if (mockAppointments.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        // Change to AGENDA tab (index 1)
                        ref.read(navigationIndexProvider.notifier).setIndex(1);
                      },
                      child: const Text('Ver Todos', style: TextStyle(color: AppTheme.primaryAccentColor)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (mockAppointments.isEmpty)
                // Empty state
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
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
                      ],
                    ),
                  ),
                )
              else
                // Last 3 appointments
                Column(
                  children: List.generate(
                    mockAppointments.length > 3 ? 3 : mockAppointments.length,
                    (index) {
                      return AppCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.event, color: AppTheme.primaryAccentColor),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText.bodyMedium('Agendamento', fontWeight: FontWeight.bold),
                                  AppText.bodySmall('Detalhes em breve...', color: Colors.grey),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 32),
              AppButton.filled(
                text: 'Agendar Novo Horário',
                onPressed: () {
                  AppToast.info(context, message: 'Agendamento em breve!');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
