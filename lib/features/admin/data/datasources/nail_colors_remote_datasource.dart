import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/nail_color_model.dart';

abstract class NailColorsRemoteDatasource {
  Future<List<NailColorModel>> getNailColors();
  Future<NailColorModel> addNailColor(NailColorModel model, {File? imageFile});
  Future<void> updateNailColor(NailColorModel model);
}

class NailColorsRemoteDatasourceImpl implements NailColorsRemoteDatasource {
  final SupabaseClient _supabaseClient;

  NailColorsRemoteDatasourceImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<List<NailColorModel>> getNailColors() async {
    try {
      AppLogger.info('Buscando cores de esmalte do Supabase', 'NailColorsRemoteDatasource');
      final response = await _supabaseClient
          .from('nail_colors')
          .select()
          .order('created_at', ascending: false);
      
      final list = (response as List<dynamic>)
          .map((json) => NailColorModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return list;
    } catch (e, stack) {
      AppLogger.error('Erro ao buscar cores de esmalte', e, stack, 'NailColorsRemoteDatasource');
      rethrow;
    }
  }

  @override
  Future<NailColorModel> addNailColor(NailColorModel model, {File? imageFile}) async {
    try {
      AppLogger.info('Adicionando cor de esmalte no Supabase', 'NailColorsRemoteDatasource');
      
      String? imageUrl = model.imageUrl;
      
      if (imageFile != null) {
        // Upload image to Supabase Storage if needed
        // For simplicity, we assume the bucket 'nail_colors' exists and is public
        // If it doesn't exist, this might fail, but let's try
        try {
          final fileName = 'nail_${DateTime.now().millisecondsSinceEpoch}.jpg';
          await _supabaseClient.storage.from('nail_colors').upload(fileName, imageFile);
          imageUrl = _supabaseClient.storage.from('nail_colors').getPublicUrl(fileName);
        } catch (e) {
          AppLogger.error('Erro ao fazer upload da imagem, salvando sem URL', e, null, 'NailColorsRemoteDatasource');
        }
      }

      final dataToInsert = {
        'name': model.name,
        'hex_code': model.hexCode,
        'image_url': imageUrl,
        'is_available': model.isAvailable,
      };

      final response = await _supabaseClient
          .from('nail_colors')
          .insert(dataToInsert)
          .select()
          .single();

      return NailColorModel.fromJson(response);
    } catch (e, stack) {
      AppLogger.error('Erro ao adicionar cor de esmalte', e, stack, 'NailColorsRemoteDatasource');
      rethrow;
    }
  }

  @override
  Future<void> updateNailColor(NailColorModel model) async {
    try {
      AppLogger.info('Atualizando cor de esmalte ID: ${model.id}', 'NailColorsRemoteDatasource');
      await _supabaseClient
          .from('nail_colors')
          .update(model.toJson())
          .eq('id', model.id);
    } catch (e, stack) {
      AppLogger.error('Erro ao atualizar cor de esmalte ID: ${model.id}', e, stack, 'NailColorsRemoteDatasource');
      rethrow;
    }
  }
}
