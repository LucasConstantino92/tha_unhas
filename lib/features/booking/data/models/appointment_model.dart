import '../../domain/entities/appointment_entity.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    required super.userId,
    required super.serviceId,
    required super.startTime,
    required super.endTime,
    required super.status,
    required super.paidPrice,
    required super.createdAt,
    required super.updatedAt,
    super.clientName,
    super.clientPhone,
    super.serviceName,
    super.colorId,
    super.colorHex,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final userProfiles = json['user_profiles'] as Map<String, dynamic>?;
    final services = json['services'] as Map<String, dynamic>?;
    final nailColors = json['nail_colors'] as Map<String, dynamic>?;

    return AppointmentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      serviceId: json['service_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: json['status'] as String,
      paidPrice: (json['paid_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      clientName: userProfiles != null ? (userProfiles['nome'] ?? userProfiles['name']) as String? : null,
      clientPhone: userProfiles != null ? userProfiles['phone'] as String? : null,
      serviceName: services != null ? services['name'] as String? : null,
      colorId: json['color_id'] as String?,
      colorHex: nailColors != null ? nailColors['hex_code'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'service_id': serviceId,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
      'status': status,
      'paid_price': paidPrice,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      if (colorId != null) 'color_id': colorId,
    };
  }
}
