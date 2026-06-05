import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../admin/presentation/providers/admin_provider.dart';
import '../../data/datasources/booking_remote_datasource.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/booking_repository.dart';

part 'booking_provider.g.dart';

@riverpod
BookingRemoteDatasource bookingRemoteDatasource(BookingRemoteDatasourceRef ref) {
  return BookingRemoteDatasourceImpl();
}

@riverpod
BookingRepository bookingRepository(BookingRepositoryRef ref) {
  return BookingRepositoryImpl(
    remoteDatasource: ref.watch(bookingRemoteDatasourceProvider),
  );
}

@riverpod
class BookingsList extends _$BookingsList {
  @override
  FutureOr<List<AppointmentEntity>> build() async {
    final user = ref.watch(authProvider);
    if (user == null) return [];
    return ref.watch(bookingRepositoryProvider).getBookings(user.id);
  }

  Future<void> createBooking(AppointmentEntity booking) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(bookingRepositoryProvider).createBooking(booking);
      final user = ref.read(authProvider);
      if (user == null) return [];
      return ref.read(bookingRepositoryProvider).getBookings(user.id);
    });
  }

  Future<void> cancelBooking(String bookingId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(bookingRepositoryProvider).cancelBooking(bookingId);
      final user = ref.read(authProvider);
      if (user == null) return [];
      return ref.read(bookingRepositoryProvider).getBookings(user.id);
    });
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    state = const AsyncLoading<List<AppointmentEntity>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await ref.read(adminRepositoryProvider).updateBookingStatus(bookingId, status);
      final user = ref.read(authProvider);
      if (user == null) return [];
      return ref.read(bookingRepositoryProvider).getBookings(user.id);
    });
  }
}
