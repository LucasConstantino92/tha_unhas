class AdminStatsEntity {
  final double monthlyRevenue;
  final double yearlyRevenue;
  final int totalBookingsCount;

  const AdminStatsEntity({
    required this.monthlyRevenue,
    required this.yearlyRevenue,
    required this.totalBookingsCount,
  });
}
