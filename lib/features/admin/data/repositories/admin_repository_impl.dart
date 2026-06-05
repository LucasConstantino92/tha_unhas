import '../../domain/entities/admin_stats_entity.dart';
import '../../domain/entities/work_schedule_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';
import '../models/work_schedule_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDatasource remoteDatasource;

  AdminRepositoryImpl({required this.remoteDatasource});

  @override
  Future<AdminStatsEntity> getStats(int year, int month) {
    return remoteDatasource.getStats(year, month);
  }

  @override
  Future<void> sendNotificationToAllUsers(String title, String body) {
    return remoteDatasource.sendNotificationToAllUsers(title, body);
  }

  @override
  Future<void> updateBookingStatus(String bookingId, String status) {
    return remoteDatasource.updateBookingStatus(bookingId, status);
  }

  @override
  Future<List<WorkScheduleEntity>> getWorkSchedules() {
    return remoteDatasource.getWorkSchedules();
  }

  @override
  Future<void> addWorkSchedule(WorkScheduleEntity entity) {
    final model = WorkScheduleModel(
      id: entity.id,
      startTime: entity.startTime,
      endTime: entity.endTime,
      isBlocked: entity.isBlocked,
      note: entity.note,
      createdAt: entity.createdAt,
    );
    return remoteDatasource.addWorkSchedule(model);
  }

  @override
  Future<void> deleteWorkSchedule(String id) {
    return remoteDatasource.deleteWorkSchedule(id);
  }
}
