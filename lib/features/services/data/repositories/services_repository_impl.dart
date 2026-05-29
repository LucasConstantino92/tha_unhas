import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasources/services_remote_datasource.dart';
import '../models/service_model.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesRemoteDatasource remoteDatasource;

  ServicesRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<ServiceEntity>> getActiveServices() {
    return remoteDatasource.getActiveServices();
  }

  @override
  Future<void> addService(ServiceEntity service) {
    final model = ServiceModel(
      id: service.id,
      name: service.name,
      price: service.price,
      durationMinutes: service.durationMinutes,
    );
    return remoteDatasource.addService(model);
  }

  @override
  Future<void> updateService(ServiceEntity service) {
    final model = ServiceModel(
      id: service.id,
      name: service.name,
      price: service.price,
      durationMinutes: service.durationMinutes,
    );
    return remoteDatasource.updateService(model);
  }

  @override
  Future<void> deleteService(String serviceId) {
    return remoteDatasource.deleteService(serviceId);
  }
}
