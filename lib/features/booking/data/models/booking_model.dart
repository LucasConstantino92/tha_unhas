import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.userId,
    required super.dateTime,
    required super.serviceName,
    required super.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      dateTime: DateTime.parse(json['date_time'] as String),
      serviceName: json['service_name'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date_time': dateTime.toIso8601String(),
      'service_name': serviceName,
      'status': status,
    };
  }
}
