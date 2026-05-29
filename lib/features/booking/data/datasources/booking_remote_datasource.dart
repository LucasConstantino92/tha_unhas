import '../models/booking_model.dart';

abstract class BookingRemoteDatasource {
  Future<List<BookingModel>> getBookings(String userId);
  Future<BookingModel> createBooking(BookingModel booking);
  Future<void> cancelBooking(String bookingId);
}

class BookingRemoteDatasourceImpl implements BookingRemoteDatasource {
  // SupabaseClient injetado futuramente
  
  @override
  Future<List<BookingModel>> getBookings(String userId) async {
    // Busca do Supabase
    return [];
  }

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    // Inserção no Supabase
    return booking;
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    // Atualização no Supabase
  }
}
