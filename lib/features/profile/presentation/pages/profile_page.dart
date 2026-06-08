import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/phone_mask.dart';
import '../../../../core/utils/app_error_formatter.dart';
import '../../../widgets/widgets.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../booking/presentation/providers/booking_provider.dart';
import '../../../booking/domain/entities/appointment_entity.dart';
import '../../../auth/presentation/pages/login_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  String _appVersion = 'Carregando...';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      });
    } catch (_) {
      setState(() {
        _appVersion = '1.0.0+1'; // fallback
      });
    }
  }

  void _showEditProfileBottomSheet(BuildContext context, UserProfile user) {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    final emailController = TextEditingController(text: user.email);
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AppText.titleMedium('Editar Dados', fontWeight: FontWeight.bold),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: nameController,
                        labelText: 'Nome Completo',
                        prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primaryAccentColor),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Insira seu nome completo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: phoneController,
                        labelText: 'Telefone',
                        prefixIcon: const Icon(Icons.phone_outlined, color: AppTheme.primaryAccentColor),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          PhoneTextInputFormatter(),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Insira seu telefone';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: emailController,
                        labelText: 'E-mail',
                        enabled: false,
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      isSaving
                          ? const Center(child: AppLoading(color: AppTheme.primaryAccentColor))
                          : AppButton.filled(
                              text: 'Salvar Alterações',
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  setModalState(() => isSaving = true);
                                  try {
                                    await ref.read(authProvider.notifier).updateProfile(
                                          nameController.text.trim(),
                                          phoneController.text.trim(),
                                        );
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      AppToast.success(context, message: 'Dados atualizados com sucesso!');
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      AppToast.error(context, message: AppErrorFormatter.format(e, prefix: 'Erro ao atualizar'));
                                    }
                                  } finally {
                                    if (context.mounted) {
                                      setModalState(() => isSaving = false);
                                    }
                                  }
                                }
                              },
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteAccount(BuildContext context, UserProfile user, List<AppointmentEntity> bookings) {
    final activeBookings = bookings.where((b) {
      return b.userId == user.id &&
          (b.status == 'pending' || b.status == 'confirmed' || b.status == 'in_progress');
    }).toList();

    final hasBookings = activeBookings.isNotEmpty;
    final title = 'Excluir Conta';
    final message = hasBookings
        ? 'Existem ${activeBookings.length} agendamentos ativos. Deseja cancelar todos e excluir sua conta?'
        : 'Deseja mesmo excluir sua conta?';

    showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        confirmLabel: 'Sim, Excluir',
        cancelLabel: 'Voltar',
        isDestructive: true,
        onConfirm: () async {
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
            final idsToCancel = activeBookings.map((b) => b.id).toList();
            await ref.read(authProvider.notifier).softDeleteAccount(idsToCancel);

            if (context.mounted) {
              Navigator.of(context).pop(); // pop progress dialog
              AppToast.success(context, message: 'Conta excluída com sucesso.');
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.of(context).pop(); // pop progress dialog
              AppToast.error(context, message: AppErrorFormatter.format(e, prefix: 'Erro ao excluir conta'));
            }
          }
        },
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: 'Sair da Conta',
        message: 'Deseja realmente sair da sua conta?',
        confirmLabel: 'Sim, Sair',
        cancelLabel: 'Voltar',
        isDestructive: false,
        onConfirm: () async {
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
            await ref.read(authProvider.notifier).logout();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.of(context).pop(); // pop progress dialog
              AppToast.error(context, message: AppErrorFormatter.format(e, prefix: 'Erro ao sair da conta'));
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.sb;
    final bookingsAsync = ref.watch(bookingsListProvider);
    final bookings = bookingsAsync.valueOrNull ?? [];

    if (user == null) {
      return const Scaffold(
        body: Center(child: AppLoading()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryAccentColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primaryAccentColor, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            user.name.isEmpty ? 'C' : user.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryAccentColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: AppText.titleLarge(
                        user.name,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: AppBadge.primary(
                        label: user.role.toUpperCase(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Detalhes do usuário
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.email_outlined, 'E-mail', user.email),
                          const Divider(height: 24),
                          _buildDetailRow(Icons.phone_outlined, 'Telefone', user.phone.isEmpty ? 'Não cadastrado' : user.phone),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton.outlined(
                      text: 'Editar Dados',
                      icon: Icons.edit_outlined,
                      onPressed: () => _showEditProfileBottomSheet(context, user),
                    ),
                    const SizedBox(height: 12),
                    AppButton.outlined(
                      text: 'Excluir Conta',
                      textColor: Colors.red,
                      backgroundColor: Colors.red, // border color in AppButton.outlined
                      icon: Icons.delete_outline,
                      onPressed: () => _confirmDeleteAccount(context, user, bookings),
                    ),
                    const SizedBox(height: 12),
                    AppButton.filled(
                      text: 'Sair da Conta',
                      icon: Icons.logout_outlined,
                      backgroundColor: Colors.grey.shade800,
                      onPressed: () => _confirmLogout(context),
                    ),
                  ],
                ),
              ),
            ),
            // Versão do App
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AppText.bodySmall(
                'Versão $_appVersion',
                color: Colors.grey,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryAccentColor, size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.bodySmall(label, color: Colors.grey),
            const SizedBox(height: 2),
            AppText.bodyMedium(value, fontWeight: FontWeight.bold),
          ],
        ),
      ],
    );
  }
}
