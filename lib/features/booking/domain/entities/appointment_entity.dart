class AppointmentEntity {
  final String id;
  final String userId;
  final String serviceId;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // 'pending', 'confirmed', 'cancelled', 'rejected'
  final double paidPrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? clientName;
  final String? clientPhone;
  final String? serviceName;
  final String? colorId;
  final String? colorHex;

  const AppointmentEntity({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.paidPrice,
    required this.createdAt,
    required this.updatedAt,
    this.clientName,
    this.clientPhone,
    this.serviceName,
    this.colorId,
    this.colorHex,
  });
}
