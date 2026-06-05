import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/appointment_status.dart';
import '../../../widgets/widgets.dart';
import '../providers/auth_provider.dart';
import '../../../navigation/presentation/providers/navigation_provider.dart';
import '../../../booking/presentation/providers/booking_provider.dart';
import '../../../booking/presentation/pages/new_booking_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.sb;
    final bookingsAsync = ref.watch(bookingsListProvider);
    final bookings = bookingsAsync.valueOrNull ?? []; 

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${user.name}!'),
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
                  if (bookings.isNotEmpty)
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
              if (bookings.isEmpty)
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
                    bookings.length > 3 ? 3 : bookings.length,
                    (index) {
                      final booking = bookings[index];
                      final serviceName = booking.serviceName ?? 'Serviço';
                      final formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(booking.startTime.toLocal());
                      
                      // Definir cor/label do status
                      final statusEnum = AppointmentStatus.fromValue(booking.status);
                      Widget statusBadge;
                      switch (statusEnum) {
                        case AppointmentStatus.confirmed:
                          statusBadge = AppBadge.success(label: statusEnum.label);
                          break;
                        case AppointmentStatus.cancelled:
                          statusBadge = AppBadge.error(label: statusEnum.label);
                          break;
                        case AppointmentStatus.noShow:
                          statusBadge = AppBadge.secondary(label: statusEnum.label);
                          break;
                        case AppointmentStatus.inProgress:
                          statusBadge = AppBadge.primary(label: statusEnum.label);
                          break;
                        case AppointmentStatus.completed:
                          statusBadge = AppBadge.success(label: statusEnum.label);
                          break;
                        case AppointmentStatus.pending:
                          statusBadge = AppBadge.warning(label: statusEnum.label);
                      }

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
                                  AppText.bodyMedium(serviceName, fontWeight: FontWeight.bold),
                                  const SizedBox(height: 4),
                                  AppText.bodySmall(formattedDate, color: Colors.grey),
                                ],
                              ),
                            ),
                            statusBadge,
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
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NewBookingPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
