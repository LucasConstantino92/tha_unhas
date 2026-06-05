import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart' show isSameDay;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/appointment_status.dart';
import '../../../widgets/widgets.dart';
import '../providers/booking_provider.dart';
import '../../domain/entities/appointment_entity.dart';

class BookingsPage extends ConsumerStatefulWidget {
  const BookingsPage({super.key});

  @override
  ConsumerState<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends ConsumerState<BookingsPage> {
  DateTime? _selectedFilterDate;
  bool _showCalendarFilter = false;

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Agendamentos'),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          IconButton(
            icon: Icon(
              _showCalendarFilter ? Icons.calendar_today : Icons.calendar_today_outlined,
              color: _selectedFilterDate != null ? AppTheme.primaryAccentColor : null,
            ),
            onPressed: () {
              setState(() {
                _showCalendarFilter = !_showCalendarFilter;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showCalendarFilter)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  AppCalendar(
                    selectedDay: _selectedFilterDate ?? DateTime.now(),
                    focusedDay: _selectedFilterDate ?? DateTime.now(),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedFilterDate = selectedDay;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  if (_selectedFilterDate != null)
                    TextButton.icon(
                      icon: const Icon(Icons.clear, size: 16, color: Colors.grey),
                      label: const Text('Limpar Filtro de Data', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        setState(() {
                          _selectedFilterDate = null;
                        });
                      },
                    ),
                  const Divider(height: 24),
                ],
              ),
            ),
          Expanded(
            child: bookingsAsync.when(
              data: (bookings) {
                // 1. Sort bookings from most recent (newest/future) to oldest (past)
                final sortedBookings = List<AppointmentEntity>.from(bookings)
                  ..sort((a, b) => b.startTime.compareTo(a.startTime));

                // 2. Filter bookings if a date is selected
                final filteredBookings = sortedBookings.where((booking) {
                  if (_selectedFilterDate == null) return true;
                  return isSameDay(booking.startTime, _selectedFilterDate!);
                }).toList();

                if (filteredBookings.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 72,
                            color: Colors.grey.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          AppText.bodyLarge(
                            _selectedFilterDate != null
                                ? 'Nenhum agendamento para este dia'
                                : 'Nenhum agendamento encontrado',
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 8),
                          AppText.bodyMedium(
                            _selectedFilterDate != null
                                ? 'Escolha outra data ou limpe o filtro para ver seus agendamentos.'
                                : 'Você ainda não realizou nenhum agendamento. Toque no botão "+" na tela inicial para marcar um horário!',
                            color: Colors.grey,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    final booking = filteredBookings[index];
                    final serviceName = booking.serviceName ?? 'Serviço';
                    final dateStr = DateFormat('dd/MM/yyyy').format(booking.startTime.toLocal());
                    final startStr = DateFormat('HH:mm').format(booking.startTime.toLocal());
                    final endStr = DateFormat('HH:mm').format(booking.endTime.toLocal());

                    // Definir cor/label do status
                    final statusEnum = AppointmentStatus.fromValue(booking.status);
                    Widget statusBadge;
                    bool canCancel = false;

                    switch (statusEnum) {
                      case AppointmentStatus.confirmed:
                        statusBadge = AppBadge.success(label: statusEnum.label);
                        canCancel = true;
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
                        canCancel = true;
                    }

                    return AppCard(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: AppText.bodyLarge(
                                  serviceName,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              statusBadge,
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryAccentColor),
                              const SizedBox(width: 8),
                              AppText.bodyMedium(dateStr),
                              const SizedBox(width: 24),
                              const Icon(Icons.access_time, size: 16, color: AppTheme.primaryAccentColor),
                              const SizedBox(width: 8),
                              AppText.bodyMedium('$startStr - $endStr'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText.bodySmall(
                                'Valor: R\$ ${booking.paidPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                                color: AppTheme.secondaryAccentColor,
                                fontWeight: FontWeight.bold,
                              ),
                              if (canCancel)
                                TextButton.icon(
                                  icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                                  label: const Text(
                                    'Cancelar',
                                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () => _confirmCancel(context, ref, booking.id),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: AppText.bodyMedium(
                  'Erro ao carregar agendamentos: $err',
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context, WidgetRef ref, String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: 'Cancelar Agendamento',
        message: 'Tem certeza que deseja cancelar este agendamento?',
        confirmLabel: 'Sim, Cancelar',
        cancelLabel: 'Voltar',
        isDestructive: true,
        onConfirm: () async {
          // Mostra carregamento
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: AppLoading(),
            ),
          );

          try {
            await ref.read(bookingsListProvider.notifier).cancelBooking(bookingId);
            if (context.mounted) {
              Navigator.pop(context); // Fecha o loading
              AppToast.success(context, message: 'Agendamento cancelado com sucesso!');
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.pop(context); // Fecha o loading
              AppToast.error(context, message: 'Erro ao cancelar: $e');
            }
          }
        },
      ),
    );
  }
}
