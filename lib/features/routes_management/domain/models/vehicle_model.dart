class VehicleModel {
  final int id;
  final String registrationNumber;
  final String type;
  final int seatingCapacity;
  final String make;
  final String model;
  final String fuelType;
  final String currentKm;
  final bool isAvailable;
  final bool isActive;
  final int tripsCount;
  final String createdAt;

  VehicleModel({
    required this.id,
    required this.registrationNumber,
    required this.type,
    required this.seatingCapacity,
    required this.make,
    required this.model,
    required this.fuelType,
    required this.currentKm,
    required this.isAvailable,
    required this.isActive,
    required this.tripsCount,
    required this.createdAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? 0,
      registrationNumber: json['registration_number'] ?? '',
      type: json['type'] ?? '',
      seatingCapacity: json['seating_capacity'] ?? 0,
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      fuelType: json['fuel_type'] ?? '',
      currentKm: json['current_km']?.toString() ?? '0',
      isAvailable: json['is_available'] ?? false,
      isActive: json['is_active'] ?? true,
      tripsCount: json['trips_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registration_number': registrationNumber,
      'type': type,
      'seating_capacity': seatingCapacity,
      'make': make,
      'model': model,
      'fuel_type': fuelType,
      'current_km': currentKm,
      'is_available': isAvailable,
      'is_active': isActive,
      'trips_count': tripsCount,
      'created_at': createdAt,
    };
  }

  String get displayName => '$make $model';
  String get capacityText => '$seatingCapacity Seater';
  String get fullDisplayText => '$registrationNumber • $displayName • $capacityText';
}