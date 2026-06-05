class WorkScheduleEntity {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final bool isBlocked;
  final String? note;
  final DateTime createdAt;

  const WorkScheduleEntity({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.isBlocked = false,
    this.note,
    required this.createdAt,
  });
}
