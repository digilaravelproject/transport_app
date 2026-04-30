import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../domain/models/attendance_history_model.dart';
import '../domain/services/attendance_service.dart';

class AttendanceHistoryController extends GetxController {
  final GetAttendanceHistoryUseCase _getAttendanceHistoryUseCase;
  final SearchAttendanceHistoryUseCase _searchAttendanceHistoryUseCase;

  AttendanceHistoryController({
    required GetAttendanceHistoryUseCase getAttendanceHistoryUseCase,
    required SearchAttendanceHistoryUseCase searchAttendanceHistoryUseCase,
  })  : _getAttendanceHistoryUseCase = getAttendanceHistoryUseCase,
        _searchAttendanceHistoryUseCase = searchAttendanceHistoryUseCase;

  // Observable state
  final RxList<AttendanceHistoryModel> historyList = <AttendanceHistoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  
  // Date filter
  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();
  
  // Text controllers for date inputs
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadAttendanceHistory();
    
    // Debounce search to avoid too many API calls
    debounce(
      searchQuery,
      (_) => _performSearch(),
      time: const Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    startDateController.dispose();
    endDateController.dispose();
    super.onClose();
  }

  // Load attendance history
  Future<void> loadAttendanceHistory() async {
    try {
      isLoading.value = true;

      String? startDateString;
      String? endDateString;

      if (startDate.value != null) {
        startDateString = _formatDateForApi(startDate.value!);
      }
      if (endDate.value != null) {
        endDateString = _formatDateForApi(endDate.value!);
      }

      print('Loading attendance history');
      print('Start Date: $startDateString');
      print('End Date: $endDateString');

      final response = await _getAttendanceHistoryUseCase.call(
        startDate: startDateString,
        endDate: endDateString,
      );

      if (response.isSuccess && response.body != null) {
        final List<AttendanceHistoryModel> records =
            response.body as List<AttendanceHistoryModel>;
        historyList.assignAll(records);
       // Get.back();

        print('Successfully loaded ${records.length} attendance history records');
      } else {
        historyList.clear();
        print('Failed to load attendance history: ${response.message}');
      }
    } catch (e) {
      print('Error loading attendance history: $e');
      historyList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh attendance history
  Future<void> refreshAttendanceHistory() async {
    await loadAttendanceHistory();
  }

  // Update search query
  void updateSearch(String query) {
    searchQuery.value = query;
  }

  // Perform search via API
  Future<void> _performSearch() async {
    final query = searchQuery.value.trim();
    
    // If search is empty, load all data
    if (query.isEmpty) {
      await loadAttendanceHistory();
      return;
    }

    try {
      isSearching.value = true;

      print('Searching attendance for: $query');

      final response = await _searchAttendanceHistoryUseCase.call(query: query);

      if (response.isSuccess && response.body != null) {
        final List<AttendanceHistoryModel> records =
            response.body as List<AttendanceHistoryModel>;
        historyList.assignAll(records);

        print('Successfully loaded ${records.length} search results');
      } else {
        historyList.clear();
        print('Search failed: ${response.message}');
      }
    } catch (e) {
      print('Error searching attendance: $e');
      historyList.clear();
    } finally {
      isSearching.value = false;
    }
  }

  // Get filtered history list (no longer needed for local filtering)
  List<AttendanceHistoryModel> get filteredHistoryList {
    return historyList;
  }

  // Get all attendance records flattened with staff info
  List<AttendanceRecordWithStaff> get flattenedRecords {
    final List<AttendanceRecordWithStaff> records = [];

    for (var staff in filteredHistoryList) {
      for (var attendance in staff.attendance) {
        records.add(AttendanceRecordWithStaff(
          staffId: staff.id,
          staffName: staff.name,
          staffPhone: staff.phone,
          staffType: staff.staffType,
          date: attendance.date,
          status: attendance.status,
          inTime: attendance.inTime,
          outTime: attendance.outTime,
          totalHours: attendance.totalHours,
        ));
      }
    }

    // Sort by date descending (newest first)
    records.sort((a, b) => b.date.compareTo(a.date));

    return records;
  }

  // Show filter bottom sheet
  void showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter by Date Range',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Start Date
            TextField(
              controller: startDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Start Date',
                hintText: 'Select start date',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: startDate.value != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          startDate.value = null;
                          startDateController.clear();
                        },
                      )
                    : null,
              ),
              onTap: () => _selectStartDate(context),
            ),
            const SizedBox(height: 16),
            
            // End Date
            TextField(
              controller: endDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'End Date',
                hintText: 'Select end date',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: endDate.value != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          endDate.value = null;
                          endDateController.clear();
                        },
                      )
                    : null,
              ),
              onTap: () => _selectEndDate(context),
            ),
            const SizedBox(height: 24),
            
            // Filter Button
            ElevatedButton(
              onPressed: () {
                Get.back();
                loadAttendanceHistory();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply Filter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Clear Filter Button
            if (startDate.value != null || endDate.value != null)
              OutlinedButton(
                onPressed: () {
                  startDate.value = null;
                  endDate.value = null;
                  startDateController.clear();
                  endDateController.clear();
                  Get.back();
                  loadAttendanceHistory();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Clear Filter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Select start date
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      startDate.value = picked;
      startDateController.text = _formatDateForDisplay(picked);
    }
  }

  // Select end date
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? DateTime.now(),
      firstDate: startDate.value ?? DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      endDate.value = picked;
      endDateController.text = _formatDateForDisplay(picked);
    }
  }

  // Format date for API (YYYY-MM-DD)
  String _formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Format date for display
  String _formatDateForDisplay(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}

// Helper class to flatten attendance records with staff info
class AttendanceRecordWithStaff {
  final int staffId;
  final String staffName;
  final String staffPhone;
  final String staffType;
  final DateTime date;
  final String status;
  final String? inTime;
  final String? outTime;
  final String? totalHours;

  AttendanceRecordWithStaff({
    required this.staffId,
    required this.staffName,
    required this.staffPhone,
    required this.staffType,
    required this.date,
    required this.status,
    this.inTime,
    this.outTime,
    this.totalHours,
  });

  String get displayStatus {
    final first = status.isNotEmpty ? status[0].toUpperCase() : '';
    final rest = status.length > 1 ? status.substring(1).toLowerCase() : '';
    return '$first$rest';
  }

  String get displayTotalHours {
    if (totalHours == null) return '0h';
    final hours = double.tryParse(totalHours!) ?? 0.0;
    return '${hours.toStringAsFixed(1)}h';
  }
}
