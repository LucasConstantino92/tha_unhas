import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_error_formatter.dart';
import '../../../widgets/widgets.dart';
import '../../../widgets/permission_dialog.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../../../booking/presentation/providers/booking_provider.dart';
import '../../../booking/domain/entities/appointment_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../core/utils/currency_mask.dart';
import '../providers/admin_provider.dart';
import '../providers/nail_colors_provider.dart';
import '../../domain/entities/nail_color_entity.dart';

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _bookingFilter = 'pending';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Administração'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryAccentColor,
          labelColor: AppTheme.primaryAccentColor,
          unselectedLabelColor: Colors.grey,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'Métricas'),
            Tab(icon: Icon(Icons.spa_outlined), text: 'Serviços'),
            Tab(icon: Icon(Icons.calendar_today_outlined), text: 'Agenda'),
            Tab(icon: Icon(Icons.block_outlined), text: 'Bloqueios'),
            Tab(icon: Icon(Icons.color_lens_outlined), text: 'Cores'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatsTab(),
          _buildServicesTab(),
          _buildBookingsTab(),
          _buildSchedulesTab(),
          _buildNailColorsTab(),
        ],
      ),
    );
  }

  // --- ABA 1: MÉTRICAS / ESTATÍSTICAS ---
  Widget _buildStatsTab() {
    final statsAsync = ref.watch(adminStatsProvider);

    return statsAsync.when(
      data: (stats) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppText.titleMedium(
                'Visão Geral do Negócio',
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 16),

              // Faturamento Mensal
              AppCard(
                padding: const EdgeInsets.all(24),
                backgroundColor: AppTheme.primaryAccentColor.withValues(
                  alpha: 0.08,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.monetization_on_outlined,
                          color: AppTheme.primaryAccentColor,
                        ),
                        SizedBox(width: 8),
                        AppText.bodyMedium(
                          'Receita Recebida (Este Mês)',
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppText.titleLarge(
                      'R\$ ${stats.monthlyRevenue.toStringAsFixed(2).replaceAll('.', ',')}',
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryAccentColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Faturamento Potencial
              AppCard(
                padding: const EdgeInsets.all(24),
                backgroundColor: Colors.orange.withValues(alpha: 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.pending_actions, color: Colors.orange),
                        SizedBox(width: 8),
                        AppText.bodyMedium(
                          'Receita Potencial (A Receber)',
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppText.titleLarge(
                      'R\$ ${stats.potentialMonthlyRevenue.toStringAsFixed(2).replaceAll('.', ',')}',
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Total de Agendamentos no Mês
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.event_available,
                          color: AppTheme.primaryAccentColor,
                        ),
                        SizedBox(width: 8),
                        AppText.bodyMedium(
                          'Agendamentos Solicitados (Este Mês)',
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppText.titleLarge(
                      '${stats.totalBookingsCount} agendamentos',
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Faturamento Anual
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.trending_up, color: Colors.green),
                        SizedBox(width: 8),
                        AppText.bodyMedium(
                          'Receita Acumulada no Ano',
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppText.titleLarge(
                      'R\$ ${stats.yearlyRevenue.toStringAsFixed(2).replaceAll('.', ',')}',
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              AppButton.outlined(
                text: 'Atualizar Métricas',
                onPressed: () {
                  final now = DateTime.now();
                  ref
                      .read(adminStatsProvider.notifier)
                      .fetchStats(now.year, now.month);
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: AppText.bodyMedium(
          AppErrorFormatter.format(error, prefix: 'Erro ao carregar métricas'),
          color: Colors.red,
        ),
      ),
    );
  }

  // --- ABA 2: GERENCIAMENTO DE SERVIÇOS ---
  Widget _buildServicesTab() {
    final servicesAsync = ref.watch(servicesListProvider);

    return Scaffold(
      body: servicesAsync.when(
        data: (services) {
          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.spa_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const AppText.bodyMedium(
                    'Nenhum serviço cadastrado.',
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showServiceForm(null),
                    child: const Text('Adicionar Primeiro Serviço'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.bodyLarge(
                            service.name,
                            fontWeight: FontWeight.bold,
                          ),
                          AppText.bodySmall(
                            '${service.durationMinutes} min • R\$ ${service.price.toStringAsFixed(2).replaceAll('.', ',')}',
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppTheme.primaryAccentColor,
                      ),
                      onPressed: () => _showServiceForm(service),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDeleteService(service),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: AppText.bodyMedium(
            AppErrorFormatter.format(
              error,
              prefix: 'Erro ao carregar serviços',
            ),
            color: Colors.red,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryAccentColor,
        onPressed: () => _showServiceForm(null),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showServiceForm(ServiceEntity? service) {
    final isEditing = service != null;
    final nameController = TextEditingController(text: service?.name ?? '');

    // Format the initial price using the same BRL currency mask
    final initialPriceText = service != null
        ? NumberFormat.currency(
            locale: 'pt_BR',
            symbol: 'R\$',
          ).format(service.price)
        : '';
    final priceController = TextEditingController(text: initialPriceText);
    final durationController = TextEditingController(
      text: service?.durationMinutes.toString() ?? '30',
    );

    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              isEditing ? 'Editar Serviço' : 'Novo Serviço',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      controller: nameController,
                      labelText: 'Nome do Serviço',
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Insira o nome'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: priceController,
                      labelText: 'Preço (R\$)',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [RealInputFormatter()],
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Insira o preço'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: durationController,
                      labelText: 'Duração (minutos)',
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Insira a duração'
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final name = nameController.text.trim();
                          final cleanPriceStr = priceController.text
                              .replaceAll(RegExp(r'[^\d,]'), '')
                              .replaceAll(',', '.');
                          final price = double.tryParse(cleanPriceStr) ?? 0.0;
                          final duration =
                              int.tryParse(durationController.text) ?? 30;

                          if (price <= 0 || duration <= 0) {
                            AppToast.error(
                              context,
                              message: 'Valores inválidos.',
                            );
                            return;
                          }

                          setDialogState(() => isSaving = true);

                          try {
                            final newService = ServiceEntity(
                              id: service?.id ?? '',
                              name: name,
                              price: price,
                              durationMinutes: duration,
                              createdAt: service?.createdAt ?? DateTime.now(),
                              updatedAt: DateTime.now(),
                            );

                            if (isEditing) {
                              await ref
                                  .read(servicesListProvider.notifier)
                                  .updateService(newService);
                              if (context.mounted) {
                                AppToast.success(
                                  context,
                                  message: 'Serviço atualizado!',
                                );
                              }
                            } else {
                              await ref
                                  .read(servicesListProvider.notifier)
                                  .addService(newService);
                              if (context.mounted) {
                                AppToast.success(
                                  context,
                                  message: 'Serviço adicionado!',
                                );
                              }
                            }
                            if (context.mounted) {
                              Navigator.pop(context); // Fecha o formulário
                            }
                          } catch (e) {
                            if (context.mounted) {
                              AppToast.error(
                                context,
                                message: AppErrorFormatter.format(
                                  e,
                                  prefix: 'Erro ao salvar serviço',
                                ),
                              );
                            }
                          } finally {
                            if (context.mounted) {
                              setDialogState(() => isSaving = false);
                            }
                          }
                        }
                      },
                      child: const Text('Salvar'),
                    ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteService(ServiceEntity service) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AppDialog(
        title: 'Excluir Serviço',
        message: 'Deseja realmente excluir o serviço "${service.name}"?',
        confirmLabel: 'Excluir',
        cancelLabel: 'Voltar',
        isDestructive: true,
        onConfirm: () async {
          BuildContext? loaderCtx;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (lCtx) {
              loaderCtx = lCtx;
              return const Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: AppLoading(),
              );
            },
          );

          try {
            await ref
                .read(servicesListProvider.notifier)
                .deleteService(service.id);
            if (mounted) {
              AppToast.success(context, message: 'Serviço excluído!');
            }
          } catch (e) {
            if (mounted) {
              AppToast.error(
                context,
                message: AppErrorFormatter.format(e, prefix: 'Erro ao excluir'),
              );
            }
          } finally {
            if (loaderCtx != null && loaderCtx!.mounted) {
              Navigator.pop(loaderCtx!); // Fecha loading
            }
          }
        },
      ),
    );
  }

  // --- ABA 3: AGENDA COMPLETA (ADMIN) ---
  Widget _buildBookingsTab() {
    final bookingsAsync = ref.watch(bookingsListProvider);
    final user = ref.watch(authProvider);

    return Scaffold(
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const AppText.bodyMedium(
                    'Nenhum agendamento registrado.',
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 24),
                  AppButton.filled(
                    text: 'Criar Agendamento de Teste',
                    onPressed: () => _createTestBooking(user),
                  ),
                ],
              ),
            );
          }

          var filteredBookings = bookings.where((b) {
            if (_bookingFilter == 'pending') return b.status == 'pending';
            if (_bookingFilter == 'scheduled') {
              return b.status == 'confirmed' || b.status == 'in_progress';
            }
            return b.status == 'completed' ||
                b.status == 'cancelled' ||
                b.status == 'rejected' ||
                b.status == 'no_show';
          }).toList();

          filteredBookings.sort((a, b) => b.startTime.compareTo(a.startTime));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'pending', label: Text('Pendentes')),
                    ButtonSegment(value: 'scheduled', label: Text('Agendados')),
                    ButtonSegment(value: 'history', label: Text('Histórico')),
                  ],
                  selected: {_bookingFilter},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _bookingFilter = newSelection.first;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 0,
                ),
                child: AppButton.outlined(
                  text: 'Criar Agendamento de Teste',
                  onPressed: () => _createTestBooking(user),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    final booking = filteredBookings[index];
                    final serviceName = booking.serviceName ?? 'Serviço';
                    final clientName =
                        booking.clientName ?? 'Cliente Desconhecido';
                    final clientPhone =
                        booking.clientPhone ?? 'Telefone não cadastrado';
                    final dateStr = DateFormat(
                      'dd/MM/yyyy',
                    ).format(booking.startTime.toLocal());
                    final startStr = DateFormat(
                      'HH:mm',
                    ).format(booking.startTime.toLocal());

                    Widget statusBadge;
                    bool isPending = booking.status == 'pending';

                    switch (booking.status) {
                      case 'completed':
                        statusBadge = const AppBadge.success(
                          label: 'Concluído',
                        );
                        break;
                      case 'confirmed':
                        statusBadge = const AppBadge.success(
                          label: 'Confirmado',
                        );
                        break;
                      case 'in_progress':
                        statusBadge = const AppBadge.secondary(
                          label: 'Em Andamento',
                        );
                        break;
                      case 'cancelled':
                        statusBadge = const AppBadge.error(label: 'Cancelado');
                        break;
                      case 'rejected':
                        statusBadge = const AppBadge.secondary(
                          label: 'Rejeitado',
                        );
                        break;
                      case 'no_show':
                        statusBadge = const AppBadge.secondary(label: 'Teste');
                        break;
                      case 'pending':
                      default:
                        statusBadge = const AppBadge.warning(label: 'Pendente');
                    }

                    return AppCard(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText.bodyLarge(
                                    clientName,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  AppText.bodySmall(
                                    clientPhone,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                              statusBadge,
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.spa_outlined,
                                    size: 16,
                                    color: AppTheme.primaryAccentColor,
                                  ),
                                  const SizedBox(width: 6),
                                  AppText.bodyMedium(
                                    serviceName,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                              AppText.bodySmall(
                                'R\$ ${booking.paidPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                                color: AppTheme.secondaryAccentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 16,
                                color: AppTheme.primaryAccentColor,
                              ),
                              const SizedBox(width: 6),
                              AppText.bodyMedium('$dateStr às $startStr'),
                            ],
                          ),
                          if (isPending) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      _updateStatus(booking.id, 'rejected'),
                                  child: const Text(
                                    'Rejeitar',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                  ),
                                  onPressed: () =>
                                      _updateStatus(booking.id, 'confirmed'),
                                  child: const Text(
                                    'Confirmar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else if (booking.status == 'confirmed' ||
                              booking.status == 'in_progress') ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      _updateStatus(booking.id, 'cancelled'),
                                  child: const Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                  ),
                                  onPressed: () =>
                                      _updateStatus(booking.id, 'completed'),
                                  child: const Text(
                                    'Concluir',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else if (booking.status == 'no_show') ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      _updateStatus(booking.id, 'cancelled'),
                                  child: const Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: AppText.bodyMedium(
            AppErrorFormatter.format(error, prefix: 'Erro ao carregar agenda'),
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  void _updateStatus(String bookingId, String status) async {
    BuildContext? loaderCtx;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (lCtx) {
        loaderCtx = lCtx;
        return const Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: AppLoading(),
        );
      },
    );

    try {
      await ref
          .read(bookingsListProvider.notifier)
          .updateBookingStatus(bookingId, status);

      // Também atualiza o painel de estatísticas admin
      final now = DateTime.now();
      ref.read(adminStatsProvider.notifier).fetchStats(now.year, now.month);

      if (mounted) {
        AppToast.success(context, message: 'Status atualizado com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(
          context,
          message: AppErrorFormatter.format(
            e,
            prefix: 'Erro ao atualizar status',
          ),
        );
      }
    } finally {
      if (loaderCtx != null && loaderCtx!.mounted) {
        Navigator.pop(loaderCtx!); // Fecha loading
      }
    }
  }

  void _createTestBooking(UserProfile? adminUser) async {
    if (adminUser == null) return;

    // Buscar lista de serviços ativos
    final services = ref.read(servicesListProvider).valueOrNull ?? [];
    if (services.isEmpty) {
      AppToast.error(
        context,
        message:
            'Crie ao menos um serviço antes de criar um agendamento de teste.',
      );
      return;
    }

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
      // Usar o primeiro serviço como padrão para o teste
      final service = services.first;
      final tomorrow = DateTime.now().add(const Duration(days: 1));

      // Agendar para amanhã às 10:00
      final startTime = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        10,
        0,
      );
      final endTime = startTime.add(Duration(minutes: service.durationMinutes));

      final testBooking = AppointmentEntity(
        id: '',
        userId: adminUser.id,
        serviceId: service.id,
        startTime: startTime,
        endTime: endTime,
        status: 'no_show',
        paidPrice: service.price,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(bookingsListProvider.notifier).createBooking(testBooking);

      // Recarregar estatísticas
      final now = DateTime.now();
      ref.read(adminStatsProvider.notifier).fetchStats(now.year, now.month);

      if (mounted) {
        AppToast.success(
          context,
          message: 'Agendamento de teste criado com sucesso!',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(
          context,
          message: AppErrorFormatter.format(
            e,
            prefix: 'Erro ao criar agendamento de teste',
          ),
        );
      }
    } finally {
      if (mounted) Navigator.pop(context); // Fecha loading
    }
  }

  // --- ABA 4: GERENCIAMENTO DE BLOQUEIOS (FOLGAS) ---
  Widget _buildSchedulesTab() {
    final schedulesAsync = ref.watch(workSchedulesListProvider);

    return Scaffold(
      body: schedulesAsync.when(
        data: (schedules) {
          if (schedules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.block_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const AppText.bodyMedium(
                    'Nenhum bloqueio de agenda cadastrado.',
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showScheduleForm(),
                    child: const Text('Bloquear Novo Horário'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              final dateStr = DateFormat(
                'dd/MM/yyyy',
              ).format(schedule.startTime.toLocal());
              final startStr = DateFormat(
                'HH:mm',
              ).format(schedule.startTime.toLocal());
              final endStr = DateFormat(
                'HH:mm',
              ).format(schedule.endTime.toLocal());
              final note = schedule.note ?? 'Folga / Bloqueio';

              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.bodyLarge(note, fontWeight: FontWeight.bold),
                          const SizedBox(height: 4),
                          AppText.bodySmall(
                            '$dateStr • das $startStr às $endStr',
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () =>
                          _confirmDeleteSchedule(schedule.id, note),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: AppText.bodyMedium(
            AppErrorFormatter.format(
              error,
              prefix: 'Erro ao carregar bloqueios',
            ),
            color: Colors.red,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryAccentColor,
        onPressed: () => _showScheduleForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatTime24h(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showScheduleForm() {
    DateTime selectedDate = DateTime.now().add(
      const Duration(days: 1),
    ); // Default tomorrow
    DateTime? endDate;
    TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 0);
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          DateFormat('dd/MM/yyyy').format(selectedDate);
          final startTimeStr = _formatTime24h(startTime);
          final endTimeStr = _formatTime24h(endTime);

          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'Bloquear Horário',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Campo Nota / Motivo
                    AppTextField(
                      controller: noteController,
                      labelText: 'Motivo (Ex: Médico, Férias)',
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Insira um motivo ou descrição'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Botão Selecionar Data
                    InkWell(
                      onTap: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          initialDateRange: DateTimeRange(
                            start: selectedDate,
                            end: endDate ?? selectedDate,
                          ),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked.start;
                            endDate = picked.end;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Data/Período:'),
                            Text(
                              endDate != null && endDate != selectedDate
                                  ? '${DateFormat('dd/MM').format(selectedDate)} - ${DateFormat('dd/MM').format(endDate!)}'
                                  : DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(selectedDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryAccentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Botão Selecionar Hora Início
                    InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                          builder: (context, child) {
                            return MediaQuery(
                              data: MediaQuery.of(
                                context,
                              ).copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() {
                            startTime = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Início:'),
                            Text(
                              startTimeStr,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryAccentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Botão Selecionar Hora Fim
                    InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: endTime,
                          builder: (context, child) {
                            return MediaQuery(
                              data: MediaQuery.of(
                                context,
                              ).copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() {
                            endTime = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Fim:'),
                            Text(
                              endTimeStr,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryAccentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final isMultiDay =
                              endDate != null && endDate != selectedDate;

                          // Calcular start DateTime e end DateTime
                          final startDateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            isMultiDay ? 0 : startTime.hour,
                            isMultiDay ? 0 : startTime.minute,
                          );

                          final endDateTime = DateTime(
                            endDate?.year ?? selectedDate.year,
                            endDate?.month ?? selectedDate.month,
                            endDate?.day ?? selectedDate.day,
                            isMultiDay ? 23 : endTime.hour,
                            isMultiDay ? 59 : endTime.minute,
                          );

                          if (!isMultiDay &&
                              (endDateTime.isBefore(startDateTime) ||
                                  endDateTime.isAtSameMomentAs(
                                    startDateTime,
                                  ))) {
                            AppToast.error(
                              context,
                              message:
                                  'Hora de fim deve ser após a hora de início.',
                            );
                            return;
                          }

                          setDialogState(() => isSaving = true);

                          try {
                            await ref
                                .read(workSchedulesListProvider.notifier)
                                .addBlock(
                                  startTime: startDateTime,
                                  endTime: endDateTime,
                                  note: noteController.text.trim(),
                                );
                            if (context.mounted) {
                              AppToast.success(
                                context,
                                message: 'Bloqueio adicionado com sucesso!',
                              );
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              AppToast.error(
                                context,
                                message: AppErrorFormatter.format(
                                  e,
                                  prefix: 'Erro ao adicionar bloqueio',
                                ),
                              );
                            }
                          } finally {
                            if (context.mounted) {
                              setDialogState(() => isSaving = false);
                            }
                          }
                        }
                      },
                      child: const Text('Bloquear'),
                    ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteSchedule(String id, String note) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AppDialog(
        title: 'Excluir Bloqueio',
        message: 'Deseja realmente remover o bloqueio "$note"?',
        confirmLabel: 'Excluir',
        cancelLabel: 'Voltar',
        isDestructive: true,
        onConfirm: () async {
          try {
            await ref.read(workSchedulesListProvider.notifier).deleteBlock(id);
            if (mounted) {
              AppToast.success(
                context,
                message: 'Bloqueio removido com sucesso!',
              );
            }
          } catch (e) {
            if (mounted) {
              AppToast.error(
                context,
                message: AppErrorFormatter.format(e, prefix: 'Erro ao remover'),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildNailColorsTab() {
    final colorsAsync = ref.watch(nailColorsListProvider);

    return Scaffold(
      body: colorsAsync.when(
        data: (colors) {
          if (colors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.color_lens_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const AppText.bodyMedium('Nenhuma cor cadastrada.', color: Colors.grey),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _startAddColorFlow(),
                    child: const Text('Adicionar Primeira Cor'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(24.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              final hexInt = int.tryParse(color.hexCode.replaceFirst('#', '0xff')) ?? 0xFFCCCCCC;
              return Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(color: Color(hexInt)),
                          if (!color.isAvailable)
                            Container(
                              color: Colors.black54,
                              child: const Center(
                                child: Text(
                                  'Indisponível',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Theme.of(context).colorScheme.surface,
                      child: Column(
                        children: [
                          AppText.bodySmall(
                            color.name?.isNotEmpty == true ? color.name! : color.hexCode,
                            fontWeight: FontWeight.bold,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Switch(
                            value: color.isAvailable,
                            onChanged: (val) {
                              final updated = NailColorEntity(
                                id: color.id,
                                name: color.name,
                                hexCode: color.hexCode,
                                imageUrl: color.imageUrl,
                                isAvailable: val,
                                createdAt: color.createdAt,
                              );
                              ref.read(nailColorsListProvider.notifier).updateNailColor(updated);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: AppText.bodyMedium(
            AppErrorFormatter.format(error, prefix: 'Erro ao carregar cores'),
            color: Colors.red,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryAccentColor,
        onPressed: () => _startAddColorFlow(),
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }

  Future<void> _startAddColorFlow() async {
    // Show dialog to choose Camera or Gallery
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar Cor'),
        content: const Text('De onde você quer selecionar a foto do esmalte?'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Galeria'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(ctx, ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Câmera'),
          ),
        ],
      ),
    );

    if (source == null) return;

    // Ask for permission gracefully
    if (!kIsWeb) {
      bool permissionGranted = false;
      if (source == ImageSource.camera) {
        var status = await Permission.camera.status;
        if (!status.isGranted) {
          if (!mounted) return;
          final shouldRequest = await showPermissionDialog(
            context: context,
            title: 'Permissão de Câmera',
            message: 'Precisamos acessar sua câmera para tirar a foto do esmalte. O acesso será usado apenas para isso.',
            icon: Icons.camera_alt,
          );
          if (shouldRequest) {
            status = await Permission.camera.request();
          }
        }
        permissionGranted = status.isGranted;
      } else {
        var status = await Permission.photos.status;
        if (!status.isGranted) {
          if (!mounted) return;
          final shouldRequest = await showPermissionDialog(
            context: context,
            title: 'Permissão de Galeria',
            message: 'Precisamos acessar sua galeria para você escolher a foto do esmalte.',
            icon: Icons.photo_library,
          );
          if (shouldRequest) {
            status = await Permission.photos.request();
          }
        }
        // In newer Android versions, READ_EXTERNAL_STORAGE might return permanentlyDenied, and we rely on ImagePicker's internal intent.
        // So we proceed even if not explicitly granted if it's gallery, or rely on ImagePicker to handle it.
        permissionGranted = true; // Let ImagePicker handle the intent
      }

      if (source == ImageSource.camera && !permissionGranted) {
        if (mounted) {
          AppToast.error(context, message: 'Permissão necessária não concedida.');
        }
        return;
      }
    }

    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: source, imageQuality: 80);
      
      if (photo == null) return;

      if (!mounted) return;
      
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: AppLoading(),
        ),
      );

      // Generate palette
      final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
        kIsWeb ? NetworkImage(photo.path) as ImageProvider : FileImage(File(photo.path)),
        maximumColorCount: 10,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      final colors = paletteGenerator.colors.toList();
      if (colors.isEmpty) {
        AppToast.error(context, message: 'Não foi possível extrair cores da imagem.');
        return;
      }

      // Show selection dialog
      final selectedColorInfo = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (ctx) => _PaletteSelectionDialog(colors: colors, imagePath: photo.path),
      );

      if (selectedColorInfo != null) {
        final hexCode = selectedColorInfo['hex'] as String;
        final name = selectedColorInfo['name'] as String?;
        final file = File(photo.path);

        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: AppLoading(),
          ),
        );

        await ref.read(nailColorsListProvider.notifier).addNailColor(
          hexCode, 
          name, 
          true, 
          imageFile: kIsWeb ? null : file,
        );

        if (mounted) {
          Navigator.pop(context); // Close loading
          AppToast.success(context, message: 'Cor salva com sucesso!');
        }
      }

    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Attempt to close loading if open
        AppToast.error(context, message: AppErrorFormatter.format(e, prefix: 'Erro ao processar imagem'));
      }
    }
  }
}

class _PaletteSelectionDialog extends StatefulWidget {
  final List<Color> colors;
  final String imagePath;

  const _PaletteSelectionDialog({required this.colors, required this.imagePath});

  @override
  State<_PaletteSelectionDialog> createState() => _PaletteSelectionDialogState();
}

class _PaletteSelectionDialogState extends State<_PaletteSelectionDialog> {
  Color? _selectedColor;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.colors.isNotEmpty) {
      _selectedColor = widget.colors.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecionar Cor do Esmalte'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Toque na cor que melhor representa o esmalte:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: widget.colors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryAccentColor : Colors.grey.shade300,
                        width: isSelected ? 4 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: AppTheme.primaryAccentColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            AppTextField(
              controller: _nameController,
              labelText: 'Nome do Esmalte (Opcional)',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _selectedColor == null
              ? null
              : () {
                  final hex = '#${_selectedColor!.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
                  Navigator.pop(context, {
                    'hex': hex,
                    'name': _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
                  });
                },
          child: const Text('Salvar Cor'),
        ),
      ],
    );
  }
}
