// Configuração de inicialização do Supabase
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://ftjjjvbmwghfdkrjurbr.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ0ampqdmJtd2doZmRrcmp1cmJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk0NzQ3NzIsImV4cCI6MjEwNTA1MDc3Mn0._cbo8o6Owg6yT97RIfa9SSFw6j1r867kWWkhrwTHzfc';

  static Future<void> initialize() async {
    await Supabase.initialize(url: url, publishableKey: anonKey);
  }
}
