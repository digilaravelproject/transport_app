class InventoryItemRequestModel {
  final String name;
  final String category;
  final String itemCode;
  final String unit;
  final double initialStock;
  final double reorderLevel;
  final double unitPrice;
  final String storageLocation;
  final String description;

  InventoryItemRequestModel({
    required this.name,
    required this.category,
    required this.itemCode,
    required this.unit,
    required this.initialStock,
    required this.reorderLevel,
    required this.unitPrice,
    required this.storageLocation,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'item_code': itemCode,
      'unit': unit,
      'initial_stock': initialStock,
      'reorder_level': reorderLevel,
      'unit_price': unitPrice,
      'storage_location': storageLocation,
      'description': description,
    };
  }
}
