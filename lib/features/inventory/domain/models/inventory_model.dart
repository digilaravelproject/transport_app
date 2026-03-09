class InventoryModel {
  final String id;
  final String name;
  final String category; // 'Spare Parts', 'Tools', 'Office Supplies', 'Oils & Fluids'
  final int currentStock;
  final int reorderLevel;
  final double unitPrice;
  final String sku;
  final String location;

  InventoryModel({
    required this.id,
    required this.name,
    required this.category,
    required this.currentStock,
    required this.reorderLevel,
    required this.unitPrice,
    required this.sku,
    required this.location,
  });

  bool get isLowStock => currentStock <= reorderLevel;
}
