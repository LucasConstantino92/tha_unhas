import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/services_remote_datasource.dart';
import '../../data/repositories/services_repository_impl.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/services_repository.dart';

part 'services_provider.g.dart';

@riverpod
ServicesRemoteDatasource servicesRemoteDatasource(ServicesRemoteDatasourceRef ref) {
  return ServicesRemoteDatasourceImpl();
}

@riverpod
ServicesRepository servicesRepository(ServicesRepositoryRef ref) {
  return ServicesRepositoryImpl(
    remoteDatasource: ref.watch(servicesRemoteDatasourceProvider),
  );
}

@riverpod
class ServicesList extends _$ServicesList {
  @override
  FutureOr<List<ServiceEntity>> build() async {
    return ref.watch(servicesRepositoryProvider).getActiveServices();
  }

  Future<void> addService(ServiceEntity service) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(servicesRepositoryProvider).addService(service);
      return ref.read(servicesRepositoryProvider).getActiveServices();
    });
  }

  Future<void> updateService(ServiceEntity service) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(servicesRepositoryProvider).updateService(service);
      return ref.read(servicesRepositoryProvider).getActiveServices();
    });
  }

  Future<void> deleteService(String serviceId) async {
    state = const AsyncLoading<List<ServiceEntity>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await ref.read(servicesRepositoryProvider).deleteService(serviceId);
      return ref.read(servicesRepositoryProvider).getActiveServices();
    });
  }
}
