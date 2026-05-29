import '../entities/service_entity.dart';

abstract class ServicesRepository {
  Future<List<ServiceEntity>> getActiveServices();
  Future<void> addService(ServiceEntity service);
  Future<void> updateService(ServiceEntity service);
  Future<void> deleteService(String serviceId);
}
