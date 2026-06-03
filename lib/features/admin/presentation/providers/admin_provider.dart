import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/admin_stats_entity.dart';

part 'admin_provider.g.dart';

@riverpod
class AdminStats extends _$AdminStats {
  @override
  AdminStatsEntity? build() {
    return null;
  }

  void updateStats(AdminStatsEntity stats) {
    state = stats;
  }
}
