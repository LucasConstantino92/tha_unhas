import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_error_formatter.dart';
import '../../../widgets/widgets.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../../admin/presentation/providers/nail_colors_provider.dart';

class NewBookingPage extends ConsumerStatefulWidget {
  const NewBookingPage({super.key});

  @override
  ConsumerState<NewBookingPage> createState() => _NewBookingPageState();
}

class _NewBookingPageState extends ConsumerState<NewBookingPage> {
  final List<ServiceEntity> _selectedServices = [];
  DateTime _selectedDay = DateTime.now().add(const Duration(days: 1)); // Amanhã por padrão
  DateTime _focusedDay = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  String? _selectedColorId;
  bool _isLoading = false;

  List<String> _availableSlots = [];
  bool _isLoadingSlots = false;

  Future<void> _fetchAvailableSlots() async {
    final totalDuration = _selectedServices.fold(0, (sum, service) => sum + service.durationMinutes);
    if (totalDuration == 0) {
      setState(() {
        _availableSlots = [];
      });
      return;
    }

    setState(() {
      _isLoadingSlots = true;
      _selectedTime = null; // Reseta horário selecionado
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDay);
      final List<dynamic> response = await Supabase.instance.client.rpc(
        'get_available_slots',
        params: {
          'p_date': dateStr,
          'p_duration_minutes': totalDuration,
        },
      );

      setState(() {
        _availableSlots = response.map((item) {
          if (item is Map) {
            return (item['slot_time'] ?? '').toString();
          }
          return item.toString();
        }).toList();
      });
    } catch (e) {
      debugPrint('Erro ao buscar horários disponíveis: $e');
      setState(() {
        _availableSlots = [];
      });
    } finally {
      setState(() {
        _isLoadingSlots = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesListProvider);
    final user = ref.sb;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Agendamento'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Passo 1: Selecionar Serviço
              const AppText.titleMedium(
                '1. Escolha os serviços',
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 12),
              servicesAsync.when(
                data: (services) {
                  if (services.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: AppText.bodyMedium(
                          'Nenhum serviço disponível no momento.',
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: services.map((service) {
                      final isSelected = _selectedServices.any((s) => s.id == service.id);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedServices.removeWhere((s) => s.id == service.id);
                            } else {
                              _selectedServices.add(service);
                            }
                          });
                          _fetchAvailableSlots();
                        },
                        child: AppCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          backgroundColor: isSelected
                              ? AppTheme.primaryAccentColor.withValues(alpha: 0.1)
                              : Colors.white,
                          showBorder: isSelected,
                          borderColor: AppTheme.primaryAccentColor,
                          child: Row(
                            children: [
                              Icon(
                                Icons.spa_outlined,
                                color: isSelected
                                    ? AppTheme.primaryAccentColor
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText.bodyMedium(
                                      service.name,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    AppText.bodySmall(
                                      '${service.durationMinutes} minutos',
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                              AppText.bodyMedium(
                                'R\$ ${service.price.toStringAsFixed(2).replaceAll('.', ',')}',
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryAccentColor,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: AppText.bodyMedium(
                    AppErrorFormatter.format(error, prefix: 'Erro ao carregar serviços'),
                    color: Colors.red,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Passo 2: Selecionar Data
              const AppText.titleMedium(
                '2. Escolha o dia',
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 12),
              AppCalendar(
                selectedDay: _selectedDay,
                focusedDay: _focusedDay,
                firstDay: DateTime.now(), // Não pode agendar no passado
                lastDay: DateTime.now().add(const Duration(days: 60)), // Limite de 60 dias
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _fetchAvailableSlots();
                },
                enabledDayPredicate: (day) {
                  return day.weekday != DateTime.sunday;
                },
              ),

              const SizedBox(height: 32),

              // Passo 3: Selecionar Horário
              const AppText.titleMedium(
                '3. Escolha o horário',
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 12),
              if (_selectedServices.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: AppText.bodyMedium(
                      'Selecione pelo menos um serviço para ver os horários.',
                      color: Colors.grey,
                    ),
                  ),
                )
              else if (_isLoadingSlots)
                const Center(child: AppLoading(color: AppTheme.primaryAccentColor))
              else if (_availableSlots.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: AppText.bodyMedium(
                      'Nenhum horário disponível para a duração selecionada neste dia.',
                      color: Colors.grey,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _availableSlots.map((time) {
                    final isSelected = _selectedTime == time;
                    return ChoiceChip(
                      label: Text(
                        time,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTime = selected ? time : null;
                        });
                      },
                      selectedColor: AppTheme.primaryAccentColor,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.primaryAccentColor
                            : Colors.grey.withValues(alpha: 0.2),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 32),

              // Passo 4: Preferência de Cor
              const AppText.titleMedium(
                '4. Preferência de Cor (Opcional)',
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 8),
              const AppText.bodySmall(
                'Selecione uma cor para a manicure. Você pode mudar de ideia na hora ou deixar em branco se não souber.',
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              ref.watch(nailColorsListProvider).when(
                data: (colors) {
                  final availableColors = colors.where((c) => c.isAvailable).toList();
                  if (availableColors.isEmpty) {
                    return const AppText.bodyMedium(
                      'Nenhuma cor cadastrada no momento.',
                      color: Colors.grey,
                    );
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Opção: Não sei / Nenhuma
                        GestureDetector(
                          onTap: () => setState(() => _selectedColorId = null),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedColorId == null ? AppTheme.primaryAccentColor : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: const Icon(Icons.close, color: Colors.grey),
                          ),
                        ),
                        ...availableColors.map((color) {
                          final hexInt = int.tryParse(color.hexCode.replaceFirst('#', '0xff')) ?? 0xFFCCCCCC;
                          final isSelected = _selectedColorId == color.id;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColorId = color.id),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(hexInt),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppTheme.primaryAccentColor : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: AppTheme.primaryAccentColor.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    )
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox(),
              ),

              const SizedBox(height: 40),

              // Resumo e Confirmação
              if (_selectedServices.isNotEmpty && _selectedTime != null) ...[
                AppCard(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: AppTheme.primaryBackgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText.bodyMedium(
                        'Resumo do Agendamento',
                        fontWeight: FontWeight.bold,
                      ),
                      const Divider(height: 24),
                      _buildSummaryRow(
                        'Serviços',
                        _selectedServices.map((s) => s.name).join(', '),
                      ),
                      _buildSummaryRow(
                        'Data',
                        DateFormat('dd/MM/yyyy').format(_selectedDay),
                      ),
                      _buildSummaryRow('Horário', _selectedTime!),
                      _buildSummaryRow(
                        'Duração Total',
                        '${_selectedServices.fold(0, (sum, s) => sum + s.durationMinutes)} min',
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AppText.bodyLarge(
                            'Valor Total',
                            fontWeight: FontWeight.bold,
                          ),
                          AppText.titleMedium(
                            'R\$ ${_selectedServices.fold(0.0, (sum, s) => sum + s.price).toStringAsFixed(2).replaceAll('.', ',')}',
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryAccentColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              AppButton.filled(
                text: 'Confirmar Agendamento',
                isLoading: _isLoading,
                onPressed: (_selectedServices.isEmpty ||
                        _selectedTime == null ||
                        user == null ||
                        _isLoading)
                    ? null
                    : () async {
                        setState(() => _isLoading = true);
                        try {
                          // Parse date and time to create start_time and end_time
                          final timeParts = _selectedTime!.split(':');
                          final startHour = int.parse(timeParts[0]);
                          final startMin = int.parse(timeParts[1]);

                          var currentStartTime = DateTime(
                            _selectedDay.year,
                            _selectedDay.month,
                            _selectedDay.day,
                            startHour,
                            startMin,
                          );

                          // Criar agendamento sequencial para cada serviço selecionado
                          for (final service in _selectedServices) {
                            final currentEndTime = currentStartTime.add(
                              Duration(minutes: service.durationMinutes),
                            );

                            final appointment = AppointmentEntity(
                              id: '', // Supabase gera o ID
                              userId: user.id,
                              serviceId: service.id,
                              startTime: currentStartTime,
                              endTime: currentEndTime,
                              status: 'pending',
                              paidPrice: service.price,
                              colorId: _selectedColorId,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            );

                            await ref
                                .read(bookingsListProvider.notifier)
                                .createBooking(appointment);

                            // Avança o horário de início para o próximo serviço sequencial
                            currentStartTime = currentEndTime;
                          }

                          if (context.mounted) {
                            AppToast.success(
                              context,
                              message: 'Agendamento solicitado com sucesso!',
                            );
                            Navigator.of(context).pop(); // Volta para a tela anterior
                          }
                        } catch (e) {
                          if (context.mounted) {
                            AppToast.error(
                              context,
                              message: AppErrorFormatter.format(e, prefix: 'Erro ao criar agendamento'),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText.bodyMedium(label, color: Colors.grey),
          Expanded(
            child: AppText.bodyMedium(
              value,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
