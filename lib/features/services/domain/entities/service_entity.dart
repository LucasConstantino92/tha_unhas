class ServiceEntity {
  final String id;
  final String name;
  final double price;
  final int durationMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMinutes,
    required this.createdAt,
    required this.updatedAt,
  });
}
