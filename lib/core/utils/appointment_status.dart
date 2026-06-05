enum AppointmentStatus {
  pending('pending', 'Pendente'),
  confirmed('confirmed', 'Confirmado'),
  inProgress('in_progress', 'Em Andamento'),
  completed('completed', 'Concluído'),
  noShow('no_show', 'Não Compareceu'),
  cancelled('cancelled', 'Cancelado');

  final String value;
  final String label;

  const AppointmentStatus(this.value, this.label);

  static AppointmentStatus fromValue(String? value) {
    return AppointmentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AppointmentStatus.pending,
    );
  }
}
