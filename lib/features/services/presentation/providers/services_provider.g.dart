// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'services_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$servicesRemoteDatasourceHash() =>
    r'3a1955c1e6b7269ca1283d2d6157c08064510bf3';

/// See also [servicesRemoteDatasource].
@ProviderFor(servicesRemoteDatasource)
final servicesRemoteDatasourceProvider =
    AutoDisposeProvider<ServicesRemoteDatasource>.internal(
      servicesRemoteDatasource,
      name: r'servicesRemoteDatasourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$servicesRemoteDatasourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ServicesRemoteDatasourceRef =
    AutoDisposeProviderRef<ServicesRemoteDatasource>;
String _$servicesRepositoryHash() =>
    r'76f07d88583a0583499ba9a4f605c2ac5903b1b0';

/// See also [servicesRepository].
@ProviderFor(servicesRepository)
final servicesRepositoryProvider =
    AutoDisposeProvider<ServicesRepository>.internal(
      servicesRepository,
      name: r'servicesRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$servicesRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ServicesRepositoryRef = AutoDisposeProviderRef<ServicesRepository>;
String _$servicesListHash() => r'8d8ee26b510b6cef3b40eb11c9034f5ee1fcbe97';

/// See also [ServicesList].
@ProviderFor(ServicesList)
final servicesListProvider =
    AutoDisposeAsyncNotifierProvider<
      ServicesList,
      List<ServiceEntity>
    >.internal(
      ServicesList.new,
      name: r'servicesListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$servicesListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ServicesList = AutoDisposeAsyncNotifier<List<ServiceEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
