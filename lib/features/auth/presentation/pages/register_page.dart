import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/widgets.dart';
import '../providers/auth_provider.dart';
import 'profile_setup_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();

        // 1. Sign Up in Supabase Auth
        final userId = await ref.read(authProvider.notifier).signUp(email, password);

        if (userId != null) {
          if (mounted) {
            AppToast.success(context, message: 'Conta criada! Agora preencha seu perfil.');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ProfileSetupPage(
                  userId: userId,
                  email: email,
                ),
              ),
            );
          }
        } else {
          if (mounted) {
            AppToast.error(context, message: 'Falha ao criar conta. Tente novamente.');
          }
        }
      } catch (e) {
        if (mounted) {
          AppToast.error(context, message: 'Erro ao cadastrar: $e');
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
        title: const Text('Criar Conta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                    'Comece sua Jornada',
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  const AppText.bodyMedium(
                    'Crie sua conta para começar a agendar',
                    textAlign: TextAlign.center,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 40),
                  // Input Email
                  AppTextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    labelText: 'E-mail',
                    prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryAccentColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu e-mail';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Insira um e-mail válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Input Senha
                  AppTextField(
                    controller: _passwordController,
                    obscureText: true,
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outlined, color: AppTheme.primaryAccentColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira sua senha';
                      }
                      if (value.length < 6) {
                        return 'A senha precisa ter no mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Input Confirmar Senha
                  AppTextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    labelText: 'Confirmar Senha',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryAccentColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, confirme sua senha';
                      }
                      if (value != _passwordController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  // Botão de Cadastro
                  _isLoading
                      ? const Center(child: AppLoading(color: AppTheme.primaryAccentColor))
                      : AppButton.filled(
                          text: 'Próximo Passo',
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
