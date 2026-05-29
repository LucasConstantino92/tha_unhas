import '../entities/booking_entity.dart';

abstract class BookingRepository {
  Future<List<BookingEntity>> getBookings(String userId);
  Future<BookingEntity> createBooking(BookingEntity booking);
  Future<void> cancelBooking(String bookingId);
}
