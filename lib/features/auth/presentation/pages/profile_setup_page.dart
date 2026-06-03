import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/phone_mask.dart';
import '../../../widgets/widgets.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';

import '../../../navigation/presentation/pages/main_scaffold_page.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  final String userId;
  final String email;

  const ProfileSetupPage({
    super.key,
    required this.userId,
    required this.email,
  });

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final profile = UserProfile(
          id: widget.userId,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: widget.email,
          role: 'user', // Default 'user' role as requested
        );

        await ref.read(authProvider.notifier).createUserProfile(profile);

        if (mounted) {
          AppToast.success(context, message: 'Perfil configurado com sucesso!');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainScaffoldPage()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          AppToast.error(context, message: 'Erro ao salvar perfil: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completar Perfil'),
        automaticallyImplyLeading: false, // Prevent going back to sign up screen
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppText.titleLarge(
                    'Como devemos te chamar?',
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  const AppText.bodyMedium(
                    'Preencha seu nome para finalizar seu cadastro.',
                    textAlign: TextAlign.center,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 40),
                  AppTextField(
                    controller: _nameController,
                    labelText: 'Nome Completo',
                    prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primaryAccentColor),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, insira seu nome completo';
                      }
                      if (value.trim().length < 2) {
                        return 'O nome precisa ter pelo menos 2 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    labelText: 'Telefone',
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppTheme.primaryAccentColor),
                    inputFormatters: [
                      PhoneTextInputFormatter(),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, insira seu telefone';
                      }
                      if (value.replaceAll(RegExp(r'\D'), '').length < 10) {
                        return 'Telefone inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  // Button to Save Profile
                  _isLoading
                      ? const Center(child: AppLoading(color: AppTheme.primaryAccentColor))
                      : AppButton.filled(
                          text: 'Finalizar Cadastro',
                          onPressed: _submit,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
