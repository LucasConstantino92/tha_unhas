import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/entities/admin_stats_entity.dart';
import '../../domain/entities/work_schedule_entity.dart';

part 'admin_provider.g.dart';

@riverpod
AdminRemoteDatasource adminRemoteDatasource(AdminRemoteDatasourceRef ref) {
  return AdminRemoteDatasourceImpl();
}

@riverpod
AdminRepository adminRepository(AdminRepositoryRef ref) {
  return AdminRepositoryImpl(
    remoteDatasource: ref.watch(adminRemoteDatasourceProvider),
  );
}

@riverpod
class AdminStats extends _$AdminStats {
  @override
  FutureOr<AdminStatsEntity> build() async {
    final now = DateTime.now();
    return ref.watch(adminRepositoryProvider).getStats(now.year, now.month);
  }

  Future<void> fetchStats(int year, int month) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(adminRepositoryProvider).getStats(year, month);
    });
  }
}

@riverpod
class WorkSchedulesList extends _$WorkSchedulesList {
  @override
  FutureOr<List<WorkScheduleEntity>> build() async {
    return ref.watch(adminRepositoryProvider).getWorkSchedules();
  }

  Future<void> addBlock({
    required DateTime startTime,
    required DateTime endTime,
    String? note,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(adminRepositoryProvider);
      final entity = WorkScheduleEntity(
        id: '',
        startTime: startTime,
        endTime: endTime,
        isBlocked: true,
        note: note,
        createdAt: DateTime.now(),
      );
      await repo.addWorkSchedule(entity);
      return repo.getWorkSchedules();
    });
  }

  Future<void> deleteBlock(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(adminRepositoryProvider);
      await repo.deleteWorkSchedule(id);
      return repo.getWorkSchedules();
    });
  }
}
