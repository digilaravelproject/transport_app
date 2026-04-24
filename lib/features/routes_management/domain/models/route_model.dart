class RouteModel {
  final String id;
  final String routeName;
  final String origin;
  final String destination;
  final double distanceKm;
  final String estimatedTime;
  final List<String> viaStops;
  final bool isActive;
  final List<Map<String, dynamic>> schedules;
  final List<Map<String, dynamic>> points;

  RouteModel({
    required this.id,
    required this.routeName,
    required this.origin,
    required this.destination,
    required this.distanceKm,
    required this.estimatedTime,
    required this.viaStops,
    this.isActive = true,
    this.schedules = const [],
    this.points = const [],
  });
}
