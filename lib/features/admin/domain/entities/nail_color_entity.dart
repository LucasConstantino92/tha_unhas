class NailColorEntity {
  final String id;
  final String? name;
  final String hexCode;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime createdAt;

  const NailColorEntity({
    required this.id,
    this.name,
    required this.hexCode,
    this.imageUrl,
    required this.isAvailable,
    required this.createdAt,
  });
}
