class VehicleModel {
  final int id;
  final String registrationNumber;
  final String type;
  final int seatingCapacity;
  final String make;
  final String model;
  final int modelYear;
  final String fuelType;
  final String currentKm;
  final bool isAvailable;
  final bool isActive;
  final int tripsCount;
  final String createdAt;
  final double perKmPrice;
  final double acPricePerKm;

  VehicleModel({
    required this.id,
    required this.registrationNumber,
    required this.type,
    required this.seatingCapacity,
    required this.make,
    required this.model,
    required this.modelYear,
    required this.fuelType,
    required this.currentKm,
    required this.isAvailable,
    required this.isActive,
    required this.tripsCount,
    required this.createdAt,
    this.perKmPrice = 0.0,
    this.acPricePerKm = 0.0,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? 0,
      registrationNumber: json['registration_number'] ?? '',
      type: json['type'] ?? '',
      seatingCapacity: json['seating_capacity'] ?? 0,
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      modelYear: json['model_year'] ?? 0,
      fuelType: json['fuel_type'] ?? '',
      currentKm: json['current_km']?.toString() ?? '0',
      isAvailable: json['is_available'] ?? false,
      isActive: json['is_active'] ?? true,
      tripsCount: json['trips_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
      perKmPrice: double.tryParse(json['per_km_price']?.toString() ?? '0') ?? 0.0,
      acPricePerKm: double.tryParse(json['ac_price_per_km']?.toString() ?? '0') ?? 0.0,
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
      'model_year': modelYear,
      'fuel_type': fuelType,
      'current_km': currentKm,
      'is_available': isAvailable,
      'is_active': isActive,
      'trips_count': tripsCount,
      'created_at': createdAt,
      'per_km_price': perKmPrice,
      'ac_price_per_km': acPricePerKm,
    };
  }

  String get displayName => make.isNotEmpty || model.isNotEmpty ? '$make $model'.trim() : '';
  String get capacityText => '$seatingCapacity Seater';
  String get fullDisplayText {
    List<String> parts = [registrationNumber];
    if (displayName.isNotEmpty) parts.add(displayName);
    parts.add(capacityText);
    if (acPricePerKm > 0) parts.add('AC');
    return parts.join(' • ');
  }
}