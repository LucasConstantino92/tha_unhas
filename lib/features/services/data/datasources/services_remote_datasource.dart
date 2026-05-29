import '../models/service_model.dart';

abstract class ServicesRemoteDatasource {
  Future<List<ServiceModel>> getActiveServices();
  Future<void> addService(ServiceModel service);
  Future<void> updateService(ServiceModel service);
  Future<void> deleteService(String serviceId);
}

class ServicesRemoteDatasourceImpl implements ServicesRemoteDatasource {
  // SupabaseClient injetado futuramente
  
  @override
  Future<List<ServiceModel>> getActiveServices() async {
    // Busca do Supabase
    return [];
  }

  @override
  Future<void> addService(ServiceModel service) async {
    // Inserção no Supabase
  }

  @override
  Future<void> updateService(ServiceModel service) async {
    // Atualização no Supabase
  }

  @override
  Future<void> deleteService(String serviceId) async {
    // Deleção física ou lógica no Supabase
  }
}
