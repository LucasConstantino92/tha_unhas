import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/color_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_error_formatter.dart';
import '../../../widgets/widgets.dart';
import '../providers/auth_provider.dart';

import '../../../navigation/presentation/pages/main_scaffold_page.dart';
import 'register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final user = await ref.read(authProvider.notifier).login(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );

        if (user != null) {
          if (mounted) {
            AppToast.success(context, message: 'Bem-vindo de volta!');
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainScaffoldPage()),
              (route) => false,
            );
          }
        } else {
          if (mounted) {
            AppToast.error(context, message: 'E-mail ou senha incorretos.');
          }
        }
      } catch (e) {
        if (mounted) {
          AppToast.error(context, message: AppErrorFormatter.format(e, prefix: 'Erro ao entrar'));
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
                  // Logo/Ícone do App Placeholder
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.appOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/icons/ic_app.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.spa_outlined,
                              size: 60,
                              color: AppTheme.primaryAccentColor,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Título principal
                  const AppText.titleLarge(
                    'Tha Unhas',
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  const AppText.bodyMedium(
                    'Agende seus horários com facilidade',
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
                  // Input Senha (obscureText: true ativa automaticamente o botão de toggle interno)
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
                  const SizedBox(height: 24),
                  // Botão de Login
                  _isLoading
                      ? const Center(child: AppLoading(color: AppTheme.primaryAccentColor))
                      : AppButton.filled(
                          text: 'Entrar',
                          onPressed: _submit,
                        ),
                  const SizedBox(height: 16),
                  // Botão de Cadastro
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    children: [
                      const AppText.bodyMedium(
                        'Não tem uma conta? ',
                        color: Colors.grey,
                      ),
                      AppButton.text(
                        text: 'Cadastre-se',
                        width: null,
                        height: 40,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegisterPage()),
                          );
                        },
                      ),
                    ],
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
