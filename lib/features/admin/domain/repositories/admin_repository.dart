import '../entities/admin_stats_entity.dart';

abstract class AdminRepository {
  Future<AdminStatsEntity> getStats(int year, int month);
  Future<void> sendNotificationToAllUsers(String title, String body);
  Future<void> updateBookingStatus(String bookingId, String status); // Aprovado / Rejeitado
}
