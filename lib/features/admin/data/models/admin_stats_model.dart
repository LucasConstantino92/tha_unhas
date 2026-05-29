import '../../domain/entities/admin_stats_entity.dart';

class AdminStatsModel extends AdminStatsEntity {
  const AdminStatsModel({
    required super.monthlyRevenue,
    required super.yearlyRevenue,
    required super.totalBookingsCount,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      monthlyRevenue: (json['monthly_revenue'] as num).toDouble(),
      yearlyRevenue: (json['yearly_revenue'] as num).toDouble(),
      totalBookingsCount: json['total_bookings_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthly_revenue': monthlyRevenue,
      'yearly_revenue': yearlyRevenue,
      'total_bookings_count': totalBookingsCount,
    };
  }
}
