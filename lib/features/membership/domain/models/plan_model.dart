class PlanResponseModel {
  final bool success;
  final String message;
  final int? trailDays;
  final List<PlanModel> data;

  PlanResponseModel({
    required this.success,
    required this.message,
    this.trailDays,
    required this.data,
  });

  factory PlanResponseModel.fromJson(Map<String, dynamic> json) {
    return PlanResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      trailDays: json['trail_days'],
      data: (json['data'] as List?)
              ?.map((e) => PlanModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PlanModel {
  final int id;
  final String name;
  final String description;
  final int price;
  final String duration;
  final int billingCycleDays;
  final int maxVehicles;
  final int maxTripsPerMonth;
  final int maxStaff;
  final String moduleAccess;
  final List<String> features;
  final String status;
  final int sortOrder;
  final bool hasUnlimitedVehicles;
  final bool hasUnlimitedTrips;
  final bool hasUnlimitedStaff;

  PlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.billingCycleDays,
    required this.maxVehicles,
    required this.maxTripsPerMonth,
    required this.maxStaff,
    required this.moduleAccess,
    required this.features,
    required this.status,
    required this.sortOrder,
    required this.hasUnlimitedVehicles,
    required this.hasUnlimitedTrips,
    required this.hasUnlimitedStaff,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      duration: json['duration'] ?? '',
      billingCycleDays: json['billing_cycle_days'] ?? 0,
      maxVehicles: json['max_vehicles'] ?? 0,
      maxTripsPerMonth: json['max_trips_per_month'] ?? 0,
      maxStaff: json['max_staff'] ?? 0,
      moduleAccess: json['module_access'] ?? '',
      features: List<String>.from(json['features'] ?? []),
      status: json['status'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
      hasUnlimitedVehicles: json['has_unlimited_vehicles'] ?? false,
      hasUnlimitedTrips: json['has_unlimited_trips'] ?? false,
      hasUnlimitedStaff: json['has_unlimited_staff'] ?? false,
    );
  }
}
