import '../../domain/entities/work_schedule_entity.dart';

class WorkScheduleModel extends WorkScheduleEntity {
  const WorkScheduleModel({
    required super.id,
    required super.startTime,
    required super.endTime,
    super.isBlocked = false,
    super.note,
    required super.createdAt,
  });

  factory WorkScheduleModel.fromJson(Map<String, dynamic> json) {
    return WorkScheduleModel(
      id: (json['id'] ?? '') as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      isBlocked: json['is_blocked'] as bool? ?? false,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
      'is_blocked': isBlocked,
      'note': note,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}
