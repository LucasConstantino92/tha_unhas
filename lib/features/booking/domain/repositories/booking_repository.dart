import '../entities/appointment_entity.dart';

abstract class BookingRepository {
  Future<List<AppointmentEntity>> getBookings(String userId);
  Future<AppointmentEntity> createBooking(AppointmentEntity booking);
  Future<void> cancelBooking(String bookingId);
}
