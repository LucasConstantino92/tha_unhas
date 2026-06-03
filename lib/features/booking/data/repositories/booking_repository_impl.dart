import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';
import '../models/appointment_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDatasource remoteDatasource;

  BookingRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<AppointmentEntity>> getBookings(String userId) {
    return remoteDatasource.getBookings(userId);
  }

  @override
  Future<AppointmentEntity> createBooking(AppointmentEntity booking) {
    final model = AppointmentModel(
      id: booking.id,
      userId: booking.userId,
      serviceId: booking.serviceId,
      startTime: booking.startTime,
      endTime: booking.endTime,
      status: booking.status,
      paidPrice: booking.paidPrice,
      createdAt: booking.createdAt,
      updatedAt: booking.updatedAt,
    );
    return remoteDatasource.createBooking(model);
  }

  @override
  Future<void> cancelBooking(String bookingId) {
    return remoteDatasource.cancelBooking(bookingId);
  }
}
