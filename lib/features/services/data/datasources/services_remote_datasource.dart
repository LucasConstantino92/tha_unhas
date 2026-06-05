import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/network/supabase/sb_tables.dart';
import '../models/service_model.dart';

abstract class ServicesRemoteDatasource {
  Future<List<ServiceModel>> getActiveServices();
  Future<void> addService(ServiceModel service);
  Future<void> updateService(ServiceModel service);
  Future<void> deleteService(String serviceId);
}

class ServicesRemoteDatasourceImpl implements ServicesRemoteDatasource {
  final SupabaseClient _supabaseClient;

  ServicesRemoteDatasourceImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<List<ServiceModel>> getActiveServices() async {
    try {
      AppLogger.info('Buscando lista de serviços ativos no Supabase', 'ServicesRemoteDatasource');
      final helper = SBTables.services.helper(_supabaseClient);
      final response = await helper.array(
        ServiceModel.fromJson,
        columns: '*',
      );
      final list = response.toList();
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
      AppLogger.info('Tentando cadastrar novo serviço no Supabase: ${service.name} (R\$ ${service.price})', 'ServicesRemoteDatasource');
      final helper = SBTables.services.helper(_supabaseClient);
      final data = service.toJson();
      if (service.id.isEmpty) {
        data.remove('id'); // Deixar o Supabase gerar o UUID
      }
      await helper.insert(data);
      AppLogger.success('Serviço cadastrado com sucesso: ${service.name}', 'ServicesRemoteDatasource');
    } catch (e, stack) {
      AppLogger.error('Erro ao cadastrar novo serviço: ${service.name}', e, stack, 'ServicesRemoteDatasource');
      rethrow;
    }
  }

  @override
  Future<void> updateService(ServiceModel service) async {
    try {
      AppLogger.info('Tentando atualizar serviço no Supabase: ${service.name} | ID: ${service.id}', 'ServicesRemoteDatasource');
      final helper = SBTables.services.helper(_supabaseClient);
      final data = service.toJson();
      data.remove('id'); // O ID vai na cláusula where, não nos dados a serem alterados
      
      await helper.update(
        data: data,
        where: {'id': service.id},
      );
      AppLogger.success('Serviço atualizado com sucesso: ${service.name} | ID: ${service.id}', 'ServicesRemoteDatasource');
    } catch (e, stack) {
      AppLogger.error('Erro ao atualizar serviço: ${service.name} | ID: ${service.id}', e, stack, 'ServicesRemoteDatasource');
      rethrow;
    }
  }

  @override
  Future<void> deleteService(String serviceId) async {
    try {
      AppLogger.info('Tentando deletar serviço ID: $serviceId no Supabase', 'ServicesRemoteDatasource');
      final helper = SBTables.services.helper(_supabaseClient);
      await helper.delete({'id': serviceId});
      AppLogger.success('Serviço ID: $serviceId deletado com sucesso', 'ServicesRemoteDatasource');
    } catch (e, stack) {
      AppLogger.error('Erro ao deletar serviço ID: $serviceId', e, stack, 'ServicesRemoteDatasource');
      rethrow;
    }
  }
}
