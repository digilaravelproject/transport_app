import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../domain/models/staff_model.dart';

class StaffController extends GetxController {
  final staffList = <StaffModel>[].obs;
  final filteredStaff = <StaffModel>[].obs;
  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs;

  final attendanceRecords = <AttendanceRecord>[].obs;
  final salaryHistory = <SalaryRecord>[].obs;
  final advanceHistory = <AdvancePayment>[].obs;
  final staffDocuments = <StaffDocument>[].obs;
  final selectedCountryCode = '+91'.obs;
  final isLoading = false.obs;
  
  final ApiClient _apiClient = Get.find<ApiClient>();
  
  // Salary Filtering
  final selectedSalaryMonth = 'All'.obs;
  final selectedSalaryYear = '2024'.obs;
  
  // Attendance State
  final selectedDate = DateTime.now().obs;
  final dailyAttendance = <int, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStaff();
    _loadMockRecords();
    _loadAttendanceForDate(selectedDate.value);
    
    debounce(searchQuery, (_) => _filterStaff(), time: const Duration(milliseconds: 300));
    ever(selectedFilter, (_) => _filterStaff());
  }

  void _loadMockStaff() {
    staffList.value = [
      StaffModel(
        id: 1,
        name: 'Rahul Verma',
        phone: '+91 9876543210',
        email: 'rahul@agency.com',
        address: 'Sector 15, Gurgaon',
        role: StaffRole.driver,
        roleName: 'Driver',
        licenseNumber: 'DL-123456789',
        licenseExpiry: DateTime.now().add(const Duration(days: 400)),
        assignedVehicleNumber: 'DL 01 AB 1234',
        status: StaffStatus.active,
        joiningDate: DateTime(2023, 1, 15),
        aadharNumber: '1234 5678 9012',
        salary: 25000,
        shift: 'Day Shift',
        totalTrips: 45,
        dutyHours: 320,
        salaryBalance: 15000,
        advanceTaken: 2000,
      ),
      StaffModel(
        id: 2,
        name: 'Amit Kumar',
        phone: '+91 9876543211',
        email: 'amit@agency.com',
        address: 'MG Road, Delhi',
        role: StaffRole.driver,
        roleName: 'Driver',
        licenseNumber: 'DL-987654321',
        licenseExpiry: DateTime.now().add(const Duration(days: 150)),
        assignedVehicleNumber: 'RJ 14 PC 5588',
        status: StaffStatus.active,
        joiningDate: DateTime(2023, 6, 1),
        aadharNumber: '9876 5432 1098',
        salary: 22000,
        shift: 'Night Shift',
        totalTrips: 38,
        dutyHours: 280,
        salaryBalance: 12000,
        advanceTaken: 0,
      ),
      StaffModel(
        id: 3,
        name: 'Suresh Mehra',
        phone: '+91 9876543212',
        email: 'suresh@agency.com',
        address: 'Noida City Center',
        role: StaffRole.manager,
        roleName: 'Manager',
        status: StaffStatus.active,
        joiningDate: DateTime(2022, 10, 10),
        aadharNumber: '5566 7788 9900',
        salary: 50000,
        shift: 'General',
        salaryBalance: 45000,
        advanceTaken: 5000,
      ),
    ];
    filteredStaff.assignAll(staffList);
  }

  void _loadMockRecords() {
    final now = DateTime.now();
    attendanceRecords.value = [
      AttendanceRecord(date: now, checkIn: now.subtract(const Duration(hours: 4)), staffName: 'Rahul Verma', totalHours: 4.0, status: 'Present'),
      AttendanceRecord(date: now, checkIn: now.subtract(const Duration(hours: 5)), staffName: 'Amit Kumar', totalHours: 5.0, status: 'Present'),
      
      AttendanceRecord(date: now.subtract(const Duration(days: 1)), checkIn: DateTime(now.year, now.month, now.day - 1, 9, 0), checkOut: DateTime(now.year, now.month, now.day - 1, 18, 0), staffName: 'Rahul Verma', totalHours: 9.0, status: 'Present'),
      AttendanceRecord(date: now.subtract(const Duration(days: 1)), checkIn: DateTime(now.year, now.month, now.day - 1, 9, 30), checkOut: DateTime(now.year, now.month, now.day - 1, 14, 0), staffName: 'Amit Kumar', totalHours: 4.5, status: 'Half Day'),
      AttendanceRecord(date: now.subtract(const Duration(days: 1)), staffName: 'Suresh Mehra', totalHours: 0.0, status: 'Absent'),

      AttendanceRecord(date: now.subtract(const Duration(days: 2)), checkIn: DateTime(now.year, now.month, now.day - 2, 8, 45), checkOut: DateTime(now.year, now.month, now.day - 2, 17, 30), staffName: 'Rahul Verma', totalHours: 8.75, status: 'Present'),
      AttendanceRecord(date: now.subtract(const Duration(days: 2)), checkIn: DateTime(now.year, now.month, now.day - 2, 9, 0), checkOut: DateTime(now.year, now.month, now.day - 2, 18, 0), staffName: 'Suresh Mehra', totalHours: 9.0, status: 'Present'),
      
      AttendanceRecord(date: now.subtract(const Duration(days: 3)), checkIn: DateTime(now.year, now.month, now.day - 3, 9, 15), checkOut: DateTime(now.year, now.month, now.day - 3, 18, 15), staffName: 'Rahul Verma', totalHours: 9.0, status: 'Present'),
      AttendanceRecord(date: now.subtract(const Duration(days: 3)), checkIn: DateTime(now.year, now.month, now.day - 3, 9, 0), checkOut: DateTime(now.year, now.month, now.day - 3, 18, 0), staffName: 'Amit Kumar', totalHours: 9.0, status: 'Present'),
      
      AttendanceRecord(date: now.subtract(const Duration(days: 4)), checkIn: DateTime(now.year, now.month, now.day - 4, 10, 0), checkOut: DateTime(now.year, now.month, now.day - 4, 15, 0), staffName: 'Rahul Verma', totalHours: 5.0, status: 'Half Day'),
      AttendanceRecord(date: now.subtract(const Duration(days: 4)), staffName: 'Amit Kumar', totalHours: 0.0, status: 'Absent'),
      
      AttendanceRecord(date: now.subtract(const Duration(days: 5)), checkIn: DateTime(now.year, now.month, now.day - 5, 9, 0), checkOut: DateTime(now.year, now.month, now.day - 5, 18, 0), staffName: 'Rahul Verma', totalHours: 9.0, status: 'Present'),
      AttendanceRecord(date: now.subtract(const Duration(days: 5)), checkIn: DateTime(now.year, now.month, now.day - 5, 9, 0), checkOut: DateTime(now.year, now.month, now.day - 5, 18, 0), staffName: 'Amit Kumar', totalHours: 9.0, status: 'Present'),
    ];

    staffDocuments.value = [
      StaffDocument(name: 'Driving License', uploadDate: DateTime.now().subtract(const Duration(days: 200)), expiryDate: DateTime.now().add(const Duration(days: 400)), fileUrl: 'license.pdf'),
      StaffDocument(name: 'Aadhar Card', uploadDate: DateTime.now().subtract(const Duration(days: 300)), expiryDate: DateTime.now().add(const Duration(days: 365*10)), fileUrl: 'aadhar.pdf'),
    ];
  }

  void _filterStaff() {
    List<StaffModel> list = List.from(staffList);
    if (selectedFilter.value == 'Driver') {
      list = list.where((s) => s.roleName?.toLowerCase() == 'driver').toList();
    } else if (selectedFilter.value == 'Manager') {
      list = list.where((s) => s.roleName?.toLowerCase() == 'manager').toList();
    } else if (selectedFilter.value == 'Helper') {
      list = list.where((s) => s.roleName?.toLowerCase() == 'helper').toList();
    }
    if (searchQuery.value.isNotEmpty) {
      list = list.where((s) =>
          s.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (s.roleName ?? '').toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }
    filteredStaff.assignAll(list);
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  // Attendance Methods
  void changeDate(DateTime date) {
    selectedDate.value = date;
    _loadAttendanceForDate(date);
  }

  void _loadAttendanceForDate(DateTime date) {
    final map = <int, String>{};
    final now = DateTime.now();
    bool isTodayDate = date.year == now.year && date.month == now.month && date.day == now.day;

    for (var staff in staffList) {
      if (isTodayDate) {
        map[staff.id] = '';
      } else {
        if (staff.id % 2 == 0) {
          map[staff.id] = 'Present';
        } else {
          map[staff.id] = (date.day % 7 == 0) ? 'Absent' : 'Present';
        }
      }
    }
    dailyAttendance.assignAll(map);
  }

  void updateAttendance(int staffId, String status) {
    dailyAttendance[staffId] = status;
  }

  bool isToday() {
    final now = DateTime.now();
    return selectedDate.value.year == now.year &&
           selectedDate.value.month == now.month &&
           selectedDate.value.day == now.day;
  }

  Future<void> fetchStaff() async {
    isLoading.value = true;
    Map<String, dynamic> queryParams = {};
    if (searchQuery.value.isNotEmpty) {
      queryParams['search'] = searchQuery.value;
    }
    
    // Activity filter
    if (selectedFilter.value == 'Active') {
      queryParams['is_active'] = 1;
    } else if (selectedFilter.value == 'Inactive') {
      queryParams['is_active'] = 0;
    }

    final response = await _apiClient.get(AppConstants.getStaffUrl, queryParameters: queryParams);
    if (response.isSuccess && response.json != null) {
      final List<dynamic> data = response.json?['data'] ?? [];
      staffList.value = data.map((json) => StaffModel.fromJson(json)).toList();
      _filterStaff();
    } else {
      // Fallback to mock data for now if API fails or is empty
      if (staffList.isEmpty) _loadMockStaff();
    }
    isLoading.value = false;
  }

  Future<bool> addStaff(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final formData = dio.FormData.fromMap({
        'name': data['name'],
        'phone': data['phone'],
        'email': data['email'],
        'staff_type': data['staff_type'],
        'salary_type': data['salary_type'],
        'basic_salary': data['basic_salary'],
        'work_shift': data['work_shift'], // Kept as work_shift as per curl, but if 500 persists, try work_shift_id
        'date_of_joining': data['date_of_joining'],
        'address': data['address'],
        'aadhar_number': data['aadhar_number'],
        'pan_number': data['pan_number'],
        'dl_number': data['dl_number'],
        'dl_expiry': data['dl_expiry'],
        'badge_number': data['badge_number'],
        'badge_expiry': data['badge_expiry'],
      });

      // Add files
      if (data['aadhar_file'] != null && data['aadhar_file'].isNotEmpty) {
        formData.files.add(MapEntry('aadhar_file', await dio.MultipartFile.fromFile(data['aadhar_file'])));
      }
      if (data['pan_file'] != null && data['pan_file'].isNotEmpty) {
        formData.files.add(MapEntry('pan_file', await dio.MultipartFile.fromFile(data['pan_file'])));
      }
      if (data['dl_file'] != null && data['dl_file'].isNotEmpty) {
        formData.files.add(MapEntry('dl_file', await dio.MultipartFile.fromFile(data['dl_file'])));
      }
      if (data['badge_file'] != null && data['badge_file'].isNotEmpty) {
        formData.files.add(MapEntry('badge_file', await dio.MultipartFile.fromFile(data['badge_file'])));
      }
      if (data['passbook_file'] != null && data['passbook_file'].isNotEmpty) {
        formData.files.add(MapEntry('passbook_file', await dio.MultipartFile.fromFile(data['passbook_file'])));
      }
      if (data['photo_file'] != null && data['photo_file'].isNotEmpty) {
        formData.files.add(MapEntry('photo_file', await dio.MultipartFile.fromFile(data['photo_file'])));
      }

      final response = await _apiClient.post(AppConstants.createStaffUrl, data: formData);

      if (response.isSuccess) {
        fetchStaff();
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to add staff: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateStaff(dynamic id, Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final formData = dio.FormData.fromMap({
        '_method': 'PUT',
        'name': data['name'],
        'phone': data['phone'],
        'email': data['email'],
        'staff_type': data['staff_type'],
        'salary_type': data['salary_type'],
        'basic_salary': data['basic_salary'],
        'work_shift': data['work_shift'],
        'date_of_joining': data['date_of_joining'],
        'address': data['address'],
        'aadhar_number': data['aadhar_number'],
        'pan_number': data['pan_number'],
        'dl_number': data['dl_number'],
        'dl_expiry': data['dl_expiry'],
        'badge_number': data['badge_number'],
        'badge_expiry': data['badge_expiry'],
      });

      // Add files if new paths are provided
      if (data['aadhar_file'] != null && data['aadhar_file'].isNotEmpty && !data['aadhar_file'].startsWith('http')) {
        formData.files.add(MapEntry('aadhar_file', await dio.MultipartFile.fromFile(data['aadhar_file'])));
      }
      if (data['pan_file'] != null && data['pan_file'].isNotEmpty && !data['pan_file'].startsWith('http')) {
        formData.files.add(MapEntry('pan_file', await dio.MultipartFile.fromFile(data['pan_file'])));
      }
      if (data['dl_file'] != null && data['dl_file'].isNotEmpty && !data['dl_file'].startsWith('http')) {
        formData.files.add(MapEntry('dl_file', await dio.MultipartFile.fromFile(data['dl_file'])));
      }
      if (data['badge_file'] != null && data['badge_file'].isNotEmpty && !data['badge_file'].startsWith('http')) {
        formData.files.add(MapEntry('badge_file', await dio.MultipartFile.fromFile(data['badge_file'])));
      }
      if (data['passbook_file'] != null && data['passbook_file'].isNotEmpty && !data['passbook_file'].startsWith('http')) {
        formData.files.add(MapEntry('passbook_file', await dio.MultipartFile.fromFile(data['passbook_file'])));
      }
      if (data['photo_file'] != null && data['photo_file'].isNotEmpty && !data['photo_file'].startsWith('http')) {
        formData.files.add(MapEntry('photo_file', await dio.MultipartFile.fromFile(data['photo_file'])));
      }

      final response = await _apiClient.post(AppConstants.updateStaffUrl(id), data: formData);

      if (response.isSuccess) {
        fetchStaff();
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to update staff: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
