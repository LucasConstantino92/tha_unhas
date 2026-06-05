import '../entities/admin_stats_entity.dart';
import '../entities/work_schedule_entity.dart';

abstract class AdminRepository {
  Future<AdminStatsEntity> getStats(int year, int month);
  Future<void> sendNotificationToAllUsers(String title, String body);
  Future<void> updateBookingStatus(String bookingId, String status); // Aprovado / Rejeitado
  Future<List<WorkScheduleEntity>> getWorkSchedules();
  Future<void> addWorkSchedule(WorkScheduleEntity model);
  Future<void> deleteWorkSchedule(String id);
}
