import 'package:get/get.dart';
import '../domain/models/shift_model.dart';

class ShiftController extends GetxController {
  final RxList<ShiftModel> _shifts = <ShiftModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;

  List<ShiftModel> get shifts => _shifts;

  List<ShiftModel> get filteredShifts {
    if (searchQuery.value.isEmpty && selectedFilter.value == 'All') {
      return _shifts;
    }
    return _shifts.where((shift) {
      final matchesSearch = shift.shiftName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (shift.notes?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false);
      
      final matchesFilter = selectedFilter.value == 'All' || shift.type == selectedFilter.value;
      
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
    _shifts.assignAll([
      ShiftModel(
        id: 'SHF001',
        shiftName: 'Morning Shift A',
        startTime: '06:00 AM',
        endTime: '02:00 PM',
        type: 'Regular',
        assignedDrivers: ['Ravi Kumar', 'Amit Singh'],
        date: DateTime.now(),
        notes: 'Tech park route drivers',
      ),
      ShiftModel(
        id: 'SHF002',
        shiftName: 'Evening Shift B',
        startTime: '02:00 PM',
        endTime: '10:00 PM',
        type: 'Regular',
        assignedDrivers: ['John Doe'],
        date: DateTime.now(),
        notes: 'School drop-off',
      ),
      ShiftModel(
        id: 'SHF003',
        shiftName: 'Night Extra',
        startTime: '10:00 PM',
        endTime: '06:00 AM',
        type: 'Overtime',
        assignedDrivers: [],
        date: DateTime.now().add(const Duration(days: 1)),
        notes: 'Airport transfers',
      ),
    ]);
  }
}
