import 'package:supabase_flutter/supabase_flutter.dart';
import 'sb_helpers.dart';

enum SBTables {
  userProfile('user_profiles'),
  services('services'),
  appointments('appointments'),
  adminStats('admin_stats'),
  workSchedules('work_schedules'),
  nailColors('nail_colors');

  const SBTables(this.tableName);
  final String tableName;
}

extension SBTablesExt on SBTables {
  SbHelpers helper(SupabaseClient supabase) => SbHelpers(supabase, this);
}
