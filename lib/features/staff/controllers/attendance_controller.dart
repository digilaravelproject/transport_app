import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../domain/models/attendance_model.dart';
import '../domain/services/attendance_service.dart';

class AttendanceController extends GetxController {
  final GetAttendanceUseCase _getAttendanceUseCase;
  final SaveAttendanceUseCase _saveAttendanceUseCase;

  AttendanceController({
    required GetAttendanceUseCase getAttendanceUseCase,
    required SaveAttendanceUseCase saveAttendanceUseCase,
  })  : _getAttendanceUseCase = getAttendanceUseCase,
        _saveAttendanceUseCase = saveAttendanceUseCase;

  // Observable state
  final RxList<AttendanceModel> attendanceList = <AttendanceModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxMap<int, String> dailyAttendance = <int, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadAttendance();
  }

  // Load attendance for selected date
  Future<void> loadAttendance() async {
    try {
      isLoading.value = true;
      
      final dateString = _formatDateForApi(selectedDate.value);
      print('Loading attendance for date: $dateString');

      final response = await _getAttendanceUseCase.call(date: dateString);

      if (response.isSuccess && response.body != null) {
        final List<AttendanceModel> records = response.body as List<AttendanceModel>;
        attendanceList.assignAll(records);
        
        // Update daily attendance map
        _updateDailyAttendanceMap(records);
        
        print('Successfully loaded ${records.length} attendance records');
      } else {
        attendanceList.clear();
        dailyAttendance.clear();
        print('Failed to load attendance: ${response.message}');
      }
    } catch (e) {
      print('Error loading attendance: $e');
      attendanceList.clear();
      dailyAttendance.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Update daily attendance map from API response
  void _updateDailyAttendanceMap(List<AttendanceModel> records) {
    final Map<int, String> map = {};
    
    for (var record in records) {
      if (record.attendance != null) {
        // Map API status to UI status
        String status = _mapApiStatusToUiStatus(record.attendance!.status);
        map[record.id] = status;
      } else {
        map[record.id] = '';
      }
    }
    
    dailyAttendance.assignAll(map);
  }

  // Map API status to UI status
  String _mapApiStatusToUiStatus(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'present':
        return 'Present';
      case 'absent':
        return 'Absent';
      case 'half':
    //  case 'halfday':
    //  case 'half day':
        return 'Half Day';
      default:
        return '';
    }
  }

  // Map UI status to API status
  String _mapUiStatusToApiStatus(String uiStatus) {
    switch (uiStatus) {
      case 'Present':
        return 'present';
      case 'Absent':
        return 'absent';
      case 'Half Day':
        return 'half';
      default:
        return '';
    }
  }

  // Change selected date
  void changeDate(DateTime date) {
    selectedDate.value = date;
    loadAttendance();
  }

  // Update attendance status for a staff member
  void updateAttendance(int staffId, String status) {
    dailyAttendance[staffId] = status;
  }

  // Check if selected date is today
  bool isToday() {
    final now = DateTime.now();
    return selectedDate.value.year == now.year &&
           selectedDate.value.month == now.month &&
           selectedDate.value.day == now.day;
  }

  // Save attendance
  Future<void> saveAttendance() async {
    try {
      isLoading.value = true;

      // Prepare attendance data with records array
      final List<Map<String, dynamic>> records = [];
      final now = DateTime.now();
      final currentTime = _formatTimeForApi(now);

      dailyAttendance.forEach((staffId, status) {
        if (status.isNotEmpty) {
          final record = {
            'staff_id': staffId,
            'status': _mapUiStatusToApiStatus(status),
          };

          // Add in_time and out_time with current time for present and half day
          if (status == 'Present' || status == 'Half Day') {
            record['in_time'] = currentTime;
            record['out_time'] = currentTime;
          }

          records.add(record);
        }
      });

      if (records.isEmpty) {
        CustomSnackbar.showError('Please mark attendance for at least one staff member');
        return;
      }

      final attendanceData = {
        'records': records,
      };

      final dateString = _formatDateForApi(selectedDate.value);
      print('Saving attendance for date: $dateString');
      print('Attendance records: $records');

      final response = await _saveAttendanceUseCase.call(
        date: dateString,
        attendanceData: attendanceData,
      );

      if (response.isSuccess) {
        CustomSnackbar.showSuccess(
          response.message ?? 'Attendance saved successfully',
        );
        
        // Refresh the attendance list
        await loadAttendance();
        
        // Navigate back after showing success message
        Future.delayed(const Duration(milliseconds: 500), () {
         // Get.back();
        });
      } else {
        CustomSnackbar.showError(
          response.message ?? 'Failed to save attendance',
        );
      }
    } catch (e) {
      print('Error saving attendance: $e');
      CustomSnackbar.showError('Error saving attendance: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh attendance
  Future<void> refreshAttendance() async {
    await loadAttendance();
  }

  // Format date for API (YYYY-MM-DD)
  String _formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Format time for API (HH:mm)
  String _formatTimeForApi(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  // Format date for display
  String _getFormattedDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }
}
