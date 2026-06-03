import 'package:riverpod_annotation/riverpod_annotation.dart';
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
  List<AppointmentEntity> build() {
    return [];
  }

  void setBookings(List<AppointmentEntity> list) {
    state = list;
  }
}
