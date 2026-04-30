class InventoryModel {
  final int id;
  final String name;
  final String category;
  final double currentStock;
  final double reorderLevel;
  final double unitPrice;
  final String sku;
  final String location;
  final String unit;
  final String description;
  final bool isLowStockStatus;

  InventoryModel({
    required this.id,
    required this.name,
    required this.category,
    required this.currentStock,
    required this.reorderLevel,
    required this.unitPrice,
    required this.sku,
    required this.location,
    required this.unit,
    required this.description,
    this.isLowStockStatus = false,
  });

  bool get isLowStock => isLowStockStatus || currentStock <= reorderLevel;

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Uncategorized',
      currentStock: double.tryParse(json['quantity_in_stock']?.toString() ?? '0') ?? 0.0,
      reorderLevel: double.tryParse(json['reorder_level']?.toString() ?? '0') ?? 0.0,
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0.0,
      sku: json['item_code']?.toString() ?? '',
      location: json['storage_location']?.toString() ?? '',
      unit: json['unit']?.toString() ?? 'unit',
      description: json['description']?.toString() ?? '',
      isLowStockStatus: json['is_low_stock'] == true || json['is_low_stock'] == 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
