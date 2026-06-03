import '../../../../core/utils/app_logger.dart';
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
    try {
      AppLogger.info('Buscando lista de serviços ativos', 'ServicesRemoteDatasource');
      // Busca do Supabase
      final list = <ServiceModel>[];
      AppLogger.success('Recuperados ${list.length} serviços ativos', 'ServicesRemoteDatasource');
      return list;
    } catch (e, stack) {
      AppLogger.error('Erro ao buscar lista de serviços ativos', e, stack, 'ServicesRemoteDatasource');
      rethrow;
    }
  }

  @override
  Future<void> addService(ServiceModel service) async {
    try {
      AppLogger.info('Tentando cadastrar novo serviço: ${service.name} (R\$ ${service.price})', 'ServicesRemoteDatasource');
      // Inserção no Supabase
      AppLogger.success('Serviço cadastrado com sucesso: ${service.name} | ID: ${service.id}', 'ServicesRemoteDatasource');
    } catch (e, stack) {
      AppLogger.error('Erro ao cadastrar novo serviço: ${service.name}', e, stack, 'ServicesRemoteDatasource');
      rethrow;
    }
  }

  @override
  Future<void> updateService(ServiceModel service) async {
    try {
      AppLogger.info('Tentando atualizar serviço: ${service.name} | ID: ${service.id}', 'ServicesRemoteDatasource');
      // Atualização no Supabase
      AppLogger.success('Serviço atualizado com sucesso: ${service.name} | ID: ${service.id}', 'ServicesRemoteDatasource');
    } catch (e, stack) {
      AppLogger.error('Erro ao atualizar serviço: ${service.name} | ID: ${service.id}', e, stack, 'ServicesRemoteDatasource');
      rethrow;
    }
  }

  @override
  Future<void> deleteService(String serviceId) async {
    try {
      AppLogger.info('Tentando deletar serviço ID: $serviceId', 'ServicesRemoteDatasource');
      // Deleção física ou lógica no Supabase
      AppLogger.success('Serviço ID: $serviceId deletado com sucesso', 'ServicesRemoteDatasource');
    } catch (e, stack) {
      AppLogger.error('Erro ao deletar serviço ID: $serviceId', e, stack, 'ServicesRemoteDatasource');
      rethrow;
    }
  }
}
