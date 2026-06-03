// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookingRemoteDatasourceHash() =>
    r'41172ad23ff38312625a6976ea49ee228444c8e8';

/// See also [bookingRemoteDatasource].
@ProviderFor(bookingRemoteDatasource)
final bookingRemoteDatasourceProvider =
    AutoDisposeProvider<BookingRemoteDatasource>.internal(
      bookingRemoteDatasource,
      name: r'bookingRemoteDatasourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$bookingRemoteDatasourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BookingRemoteDatasourceRef =
    AutoDisposeProviderRef<BookingRemoteDatasource>;
String _$bookingRepositoryHash() => r'fbaf9f0303434ffba55c6b2fe2ba647904a7d376';

/// See also [bookingRepository].
@ProviderFor(bookingRepository)
final bookingRepositoryProvider =
    AutoDisposeProvider<BookingRepository>.internal(
      bookingRepository,
      name: r'bookingRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$bookingRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BookingRepositoryRef = AutoDisposeProviderRef<BookingRepository>;
String _$bookingsListHash() => r'b763fe1e8dcedba358f67ed9b4529ea12bde3d21';

/// See also [BookingsList].
@ProviderFor(BookingsList)
final bookingsListProvider =
    AutoDisposeNotifierProvider<BookingsList, List<AppointmentEntity>>.internal(
      BookingsList.new,
      name: r'bookingsListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$bookingsListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BookingsList = AutoDisposeNotifier<List<AppointmentEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
