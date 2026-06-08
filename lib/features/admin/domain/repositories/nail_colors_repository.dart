import 'dart:io';
import '../../domain/entities/nail_color_entity.dart';

abstract class NailColorsRepository {
  Future<List<NailColorEntity>> getNailColors();
  Future<NailColorEntity> addNailColor(NailColorEntity color, {File? imageFile});
  Future<void> updateNailColor(NailColorEntity color);
}
