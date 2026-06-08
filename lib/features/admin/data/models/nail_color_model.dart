import '../../domain/entities/nail_color_entity.dart';

class NailColorModel extends NailColorEntity {
  const NailColorModel({
    required super.id,
    super.name,
    required super.hexCode,
    super.imageUrl,
    required super.isAvailable,
    required super.createdAt,
  });

  factory NailColorModel.fromJson(Map<String, dynamic> json) {
    return NailColorModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      hexCode: json['hex_code'] as String,
      imageUrl: json['image_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'hex_code': hexCode,
      'image_url': imageUrl,
      'is_available': isAvailable,
      // 'created_at': createdAt.toUtc().toIso8601String(), // Optional: let DB generate
    };
  }
}
