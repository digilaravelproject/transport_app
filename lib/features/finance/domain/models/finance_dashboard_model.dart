class FinanceDashboardModel {
  final Period period;
  final double totalRevenue;
  final double totalExpenses;
  final double totalProfit;
  final double pendingAmount;
  final List<TripModel> completedTrips;
  final int completedCount;

  FinanceDashboardModel({
    required this.period,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.totalProfit,
    required this.pendingAmount,
    required this.completedTrips,
    required this.completedCount,
  });

  factory FinanceDashboardModel.fromJson(Map<String, dynamic> json) {
    return FinanceDashboardModel(
      period: Period.fromJson(json['period'] ?? {}),
      totalRevenue: double.tryParse(json['total_revenue']?.toString() ?? '0') ?? 0.0,
      totalExpenses: double.tryParse(json['total_expenses']?.toString() ?? '0') ?? 0.0,
      totalProfit: double.tryParse(json['total_profit']?.toString() ?? '0') ?? 0.0,
      pendingAmount: double.tryParse(json['pending_amount']?.toString() ?? '0') ?? 0.0,
      completedTrips: (json['completed_trips'] as List<dynamic>?)
              ?.map((e) => TripModel.fromJson(e))
              .toList() ??
          [],
      completedCount: json['completed_count'] ?? 0,
    );
  }
}

class Period {
  final String from;
  final String to;

  Period({required this.from, required this.to});

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }
}

class TripModel {
  final int id;
  final String tripNumber;
  final String tripDate;
  final String route;
  final String customer;
  final String? vehicle;
  final String? driver;
  final double revenue;
  final double tax;
  final double discount;
  final double paid;
  final double balance;
  final String paymentStatus;

  TripModel({
    required this.id,
    required this.tripNumber,
    required this.tripDate,
    required this.route,
    required this.customer,
    this.vehicle,
    this.driver,
    required this.revenue,
    required this.tax,
    required this.discount,
    required this.paid,
    required this.balance,
    required this.paymentStatus,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] ?? 0,
      tripNumber: json['trip_number'] ?? '',
      tripDate: json['trip_date'] ?? '',
      route: json['route'] ?? '',
      customer: json['customer'] ?? '',
      vehicle: json['vehicle'],
      driver: json['driver'],
      revenue: double.tryParse(json['revenue']?.toString() ?? '0') ?? 0.0,
      tax: double.tryParse(json['tax']?.toString() ?? '0') ?? 0.0,
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0,
      paid: double.tryParse(json['paid']?.toString() ?? '0') ?? 0.0,
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
      paymentStatus: json['payment_status'] ?? '',
    );
  }
}
