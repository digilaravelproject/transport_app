class RouteModel {
  final String id;
  final String routeName; // e.g., 'Pune to Mumbai (Express)'
  final String origin;
  final String destination;
  final double distanceKm;
  final String estimatedTime; // e.g., '3h 30m'
  final List<String> viaStops; // List of major stops
  final bool isActive;

  RouteModel({
    required this.id,
    required this.routeName,
    required this.origin,
    required this.destination,
    required this.distanceKm,
    required this.estimatedTime,
    required this.viaStops,
    this.isActive = true,
  });
}
