class BookingEntity {
  final String id;
  final String userId;
  final DateTime dateTime;
  final String serviceName; // Ex: Manicure, Pedicure, etc.
  final String status;      // Ex: Confirmado, Pendente, Cancelado

  const BookingEntity({
    required this.id,
    required this.userId,
    required this.dateTime,
    required this.serviceName,
    required this.status,
  });
}
