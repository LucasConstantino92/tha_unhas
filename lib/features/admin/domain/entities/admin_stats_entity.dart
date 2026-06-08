class AdminStatsEntity {
  final double monthlyRevenue;
  final double potentialMonthlyRevenue;
  final double yearlyRevenue;
  final int totalBookingsCount;

  const AdminStatsEntity({
    required this.monthlyRevenue,
    required this.potentialMonthlyRevenue,
    required this.yearlyRevenue,
    required this.totalBookingsCount,
  });
}
