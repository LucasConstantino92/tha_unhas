// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminRemoteDatasourceHash() =>
    r'7c3ee655bedf6a84cbd9e925dd1678d5623dd900';

/// See also [adminRemoteDatasource].
@ProviderFor(adminRemoteDatasource)
final adminRemoteDatasourceProvider =
    AutoDisposeProvider<AdminRemoteDatasource>.internal(
      adminRemoteDatasource,
      name: r'adminRemoteDatasourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminRemoteDatasourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminRemoteDatasourceRef =
    AutoDisposeProviderRef<AdminRemoteDatasource>;
String _$adminRepositoryHash() => r'90514c32888245f8a647b13f659ee1a16935467e';

/// See also [adminRepository].
@ProviderFor(adminRepository)
final adminRepositoryProvider = AutoDisposeProvider<AdminRepository>.internal(
  adminRepository,
  name: r'adminRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminRepositoryRef = AutoDisposeProviderRef<AdminRepository>;
String _$adminStatsHash() => r'386d513ee2fff8c61765a8948a4456f1c73cc3d6';

/// See also [AdminStats].
@ProviderFor(AdminStats)
final adminStatsProvider =
    AutoDisposeAsyncNotifierProvider<AdminStats, AdminStatsEntity>.internal(
      AdminStats.new,
      name: r'adminStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdminStats = AutoDisposeAsyncNotifier<AdminStatsEntity>;
String _$workSchedulesListHash() => r'f043fb82e4e5b11d026ca1b50108166e95fc31ff';

/// See also [WorkSchedulesList].
@ProviderFor(WorkSchedulesList)
final workSchedulesListProvider =
    AutoDisposeAsyncNotifierProvider<
      WorkSchedulesList,
      List<WorkScheduleEntity>
    >.internal(
      WorkSchedulesList.new,
      name: r'workSchedulesListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$workSchedulesListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WorkSchedulesList =
    AutoDisposeAsyncNotifier<List<WorkScheduleEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
