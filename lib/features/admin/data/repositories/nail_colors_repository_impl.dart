import 'dart:io';
import '../../domain/entities/nail_color_entity.dart';
import '../../domain/repositories/nail_colors_repository.dart';
import '../datasources/nail_colors_remote_datasource.dart';
import '../models/nail_color_model.dart';

class NailColorsRepositoryImpl implements NailColorsRepository {
  final NailColorsRemoteDatasource remoteDatasource;

  NailColorsRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<NailColorEntity>> getNailColors() {
    return remoteDatasource.getNailColors();
  }

  @override
  Future<NailColorEntity> addNailColor(NailColorEntity entity, {File? imageFile}) {
    final model = NailColorModel(
      id: entity.id,
      name: entity.name,
      hexCode: entity.hexCode,
      imageUrl: entity.imageUrl,
      isAvailable: entity.isAvailable,
      createdAt: entity.createdAt,
    );
    return remoteDatasource.addNailColor(model, imageFile: imageFile);
  }

  @override
  Future<void> updateNailColor(NailColorEntity entity) {
    final model = NailColorModel(
      id: entity.id,
      name: entity.name,
      hexCode: entity.hexCode,
      imageUrl: entity.imageUrl,
      isAvailable: entity.isAvailable,
      createdAt: entity.createdAt,
    );
    return remoteDatasource.updateNailColor(model);
  }
}
