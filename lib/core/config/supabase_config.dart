// Configuração de inicialização do Supabase
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://nxgcgyldjnqmbasuienh.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54Z2NneWxkam5xbWJhc3VpZW5oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAwNDQxNTQsImV4cCI6MjA5NTYyMDE1NH0.Kqf7MDrmhPatmMs2OaaRJGqOrNVYW7o4gGhJhK0IRWM';

  static Future<void> initialize() async {
    await Supabase.initialize(url: url, publishableKey: anonKey);
  }
}
