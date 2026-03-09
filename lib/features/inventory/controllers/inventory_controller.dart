import 'package:get/get.dart';
import '../domain/models/inventory_model.dart';

class InventoryController extends GetxController {
  final RxList<InventoryModel> _items = <InventoryModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;

  List<InventoryModel> get items => _items;

  List<InventoryModel> get filteredItems {
    if (searchQuery.value.isEmpty && selectedFilter.value == 'All') {
      return _items;
    }
    return _items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          item.sku.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesFilter = selectedFilter.value == 'All' || item.category == selectedFilter.value;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void updateSearch(String query) => searchQuery.value = query;
  void setFilter(String filter) => selectedFilter.value = filter;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    _items.assignAll([
      InventoryModel(
        id: 'INV001',
        name: 'Engine Oil (1L)',
        category: 'Oils & Fluids',
        currentStock: 45,
        reorderLevel: 10,
        unitPrice: 450.0,
        sku: 'OIL-1L-001',
        location: 'Main Warehouse - A1',
      ),
      InventoryModel(
        id: 'INV002',
        name: 'Brake Pads (Set)',
        category: 'Spare Parts',
        currentStock: 8,
        reorderLevel: 15,
        unitPrice: 1200.0,
        sku: 'BRK-PAD-002',
        location: 'Main Warehouse - B3',
      ),
      InventoryModel(
        id: 'INV003',
        name: 'Air Filter (Bus)',
        category: 'Spare Parts',
        currentStock: 12,
        reorderLevel: 5,
        unitPrice: 850.0,
        sku: 'AIR-FLT-003',
        location: 'Main Warehouse - C2',
      ),
      InventoryModel(
        id: 'INV004',
        name: 'Coolant (5L)',
        category: 'Oils & Fluids',
        currentStock: 2,
        reorderLevel: 10,
        unitPrice: 1500.0,
        sku: 'CLN-5L-004',
        location: 'Main Warehouse - A2',
      ),
    ]);
  }
}
