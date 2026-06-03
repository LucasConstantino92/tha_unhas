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
  List<ServiceEntity> build() {
    return [];
  }

  void setServices(List<ServiceEntity> list) {
    state = list;
  }
}
