import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppErrorFormatter {
  /// Maps any exception/error object to a clean, user-friendly Portuguese message.
  static String format(Object? error, {String? prefix}) {
    String cleanMessage = 'Ocorreu um erro no servidor. Tente novamente mais tarde.';

    if (error != null) {
      if (error is AuthException) {
        final msg = error.message.toLowerCase();
        if (msg.contains('invalid login credentials') || 
            msg.contains('invalid credentials') || 
            msg.contains('email or password')) {
          cleanMessage = 'E-mail ou senha incorretos.';
        } else if (msg.contains('email not confirmed')) {
          cleanMessage = 'Por favor, confirme seu e-mail antes de entrar.';
        } else if (msg.contains('user already exists') || msg.contains('unique_email')) {
          cleanMessage = 'Este e-mail já está cadastrado.';
        } else if (msg.contains('password should be') || msg.contains('weak password')) {
          cleanMessage = 'A senha digitada é muito fraca.';
        } else if (msg.contains('rate limit')) {
          cleanMessage = 'Muitas tentativas em pouco tempo. Tente novamente mais tarde.';
        } else {
          cleanMessage = 'Falha na autenticação. Verifique os dados fornecidos.';
        }
      } else if (error is PostgrestException) {
        final code = error.code;
        // Postgres error codes: https://www.postgresql.org/docs/current/errcodes-appendix.html
        if (code == '23505') {
          cleanMessage = 'Este registro já está cadastrado no sistema.';
        } else if (code == '23503') {
          cleanMessage = 'Não foi possível realizar esta ação devido a uma restrição de vínculo.';
        } else {
          cleanMessage = 'Não foi possível processar a requisição no banco de dados.';
        }
      } else if (error is SocketException) {
        cleanMessage = 'Sem conexão com a internet. Verifique sua rede e tente novamente.';
      } else if (error is TimeoutException) {
        cleanMessage = 'O servidor demorou muito para responder. Tente novamente mais tarde.';
      } else if (error is String) {
        cleanMessage = sanitizeMessageString(error);
      } else {
        // For other exceptions, if toString() contains known terms, we map them.
        final errStr = error.toString();
        cleanMessage = sanitizeMessageString(errStr);
      }
    }

    if (prefix != null && prefix.isNotEmpty) {
      return '$prefix: $cleanMessage';
    }
    return cleanMessage;
  }

  /// Sanitizes string error messages that might contain raw exception names or database errors.
  static String sanitizeMessageString(String msg) {
    final lower = msg.toLowerCase();
    
    // Check if it's a concatenated error message containing standard server/db exception types
    if (lower.contains('authexception') ||
        lower.contains('postgrestexception') ||
        lower.contains('socketexception') ||
        lower.contains('timeoutexception') ||
        lower.contains('exception:') ||
        lower.contains('error:')) {
      
      // Try to parse the prefix if separated by colons
      final parts = msg.split(':');
      if (parts.length > 1) {
        final firstPart = parts[0].trim();
        // If the first part itself is not an exception class name, it's likely our custom prefix
        if (!firstPart.contains('Exception') && !firstPart.contains('Error')) {
          final rest = msg.substring(parts[0].length + 1).trim();
          return getCleanDetail(rest);
        }
      }
      return getCleanDetail(msg);
    }
    
    return msg;
  }

  /// Extracts a clean Portuguese detail string based on common English patterns in server/DB errors.
  static String getCleanDetail(String errorText) {
    final lower = errorText.toLowerCase();
    if (lower.contains('invalid login credentials') || 
        lower.contains('invalid credentials') || 
        lower.contains('email or password')) {
      return 'E-mail ou senha incorretos.';
    } else if (lower.contains('email not confirmed')) {
      return 'Confirme seu e-mail antes de entrar.';
    } else if (lower.contains('user already exists') || lower.contains('unique_email')) {
      return 'Este e-mail já está cadastrado.';
    } else if (lower.contains('password should be') || lower.contains('weak password')) {
      return 'A senha digitada é muito fraca.';
    } else if (lower.contains('rate limit') || lower.contains('too many requests')) {
      return 'Muitas tentativas em pouco tempo. Tente novamente mais tarde.';
    } else if (lower.contains('socketexception') || 
               lower.contains('connection failed') || 
               lower.contains('network_error') || 
               lower.contains('failed host lookup')) {
      return 'Sem conexão com a internet. Verifique sua rede.';
    } else if (lower.contains('timeoutexception') || lower.contains('timeout')) {
      return 'O servidor demorou muito para responder.';
    } else if (lower.contains('postgrestexception') || 
               lower.contains('database') || 
               lower.contains('violates unique constraint') || 
               lower.contains('duplicate key')) {
      return 'Não foi possível salvar os dados devido a um conflito ou erro no banco.';
    }
    return 'Ocorreu um erro no servidor. Tente novamente mais tarde.';
  }
}
