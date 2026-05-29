import '../../domain/entities/admin_stats_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

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
}
