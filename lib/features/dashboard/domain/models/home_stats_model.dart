class HomeStatsModel {
  final int todayTrips;
  final double dailyRevenue;
  final int pendingLeads;
  final int activeVehicles;
  final List<RecentActivity> recentActivity;

  HomeStatsModel({
    required this.todayTrips,
    required this.dailyRevenue,
    required this.pendingLeads,
    required this.activeVehicles,
    required this.recentActivity,
  });

  factory HomeStatsModel.fromJson(Map<String, dynamic> json) {
    return HomeStatsModel(
      todayTrips: json['today_trips'] ?? 0,
      dailyRevenue: (json['daily_revenue'] ?? 0).toDouble(),
      pendingLeads: json['pending_leads'] ?? 0,
      activeVehicles: json['active_vehicles'] ?? 0,
      recentActivity: (json['recent_activity'] as List? ?? [])
          .map((e) => RecentActivity.fromJson(e))
          .toList(),
    );
  }
}

class RecentActivity {
  final int id;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final String createdAt;

  RecentActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.createdAt,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id'],
      type: json['type'] ?? 'general',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      data: json['data'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
