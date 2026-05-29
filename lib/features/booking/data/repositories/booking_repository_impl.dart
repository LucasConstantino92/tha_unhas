import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';
import '../models/booking_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDatasource remoteDatasource;

  BookingRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<BookingEntity>> getBookings(String userId) {
    return remoteDatasource.getBookings(userId);
  }

  @override
  Future<BookingEntity> createBooking(BookingEntity booking) {
    final model = BookingModel(
      id: booking.id,
      userId: booking.userId,
      dateTime: booking.dateTime,
      serviceName: booking.serviceName,
      status: booking.status,
    );
    return remoteDatasource.createBooking(model);
  }

  @override
  Future<void> cancelBooking(String bookingId) {
    return remoteDatasource.cancelBooking(bookingId);
  }
}
