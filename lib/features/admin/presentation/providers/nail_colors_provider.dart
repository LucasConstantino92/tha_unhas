import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/nail_color_entity.dart';
import '../../domain/repositories/nail_colors_repository.dart';
import '../../data/datasources/nail_colors_remote_datasource.dart';
import '../../data/repositories/nail_colors_repository_impl.dart';

final nailColorsDatasourceProvider = Provider<NailColorsRemoteDatasource>((ref) {
  return NailColorsRemoteDatasourceImpl(supabaseClient: Supabase.instance.client);
});

final nailColorsRepositoryProvider = Provider<NailColorsRepository>((ref) {
  final datasource = ref.watch(nailColorsDatasourceProvider);
  return NailColorsRepositoryImpl(remoteDatasource: datasource);
});

final nailColorsListProvider = AsyncNotifierProvider<NailColorsListNotifier, List<NailColorEntity>>(() {
  return NailColorsListNotifier();
});

class NailColorsListNotifier extends AsyncNotifier<List<NailColorEntity>> {
  @override
  Future<List<NailColorEntity>> build() async {
    final repository = ref.watch(nailColorsRepositoryProvider);
    return repository.getNailColors();
  }

  Future<void> addNailColor(String hexCode, String? name, bool isAvailable, {File? imageFile}) async {
    final repository = ref.watch(nailColorsRepositoryProvider);
    final entity = NailColorEntity(
      id: '',
      name: name,
      hexCode: hexCode,
      isAvailable: isAvailable,
      createdAt: DateTime.now(),
    );
    
    final newColor = await repository.addNailColor(entity, imageFile: imageFile);
    
    final currentList = state.valueOrNull ?? [];
    state = AsyncData([newColor, ...currentList]);
  }

  Future<void> updateNailColor(NailColorEntity color) async {
    final repository = ref.watch(nailColorsRepositoryProvider);
    await repository.updateNailColor(color);
    
    final currentList = state.valueOrNull ?? [];
    final index = currentList.indexWhere((c) => c.id == color.id);
    if (index != -1) {
      currentList[index] = color;
      state = AsyncData([...currentList]);
    }
  }
}
