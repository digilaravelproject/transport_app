import 'package:get/get.dart';
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

  @override
  void onInit() {
    super.onInit();
    _loadMockStaff();
    _loadMockRecords();
    
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
    attendanceRecords.value = [
      AttendanceRecord(date: DateTime.now(), checkIn: DateTime.now().subtract(const Duration(hours: 4)), staffName: 'Rahul Verma', totalHours: 4.0),
      AttendanceRecord(date: DateTime.now(), checkIn: DateTime.now().subtract(const Duration(hours: 5)), staffName: 'Amit Kumar', totalHours: 5.0),
    ];

    salaryHistory.value = [
      SalaryRecord(month: 'February 2024', totalSalary: 25000, paidAmount: 25000, pendingAmount: 0),
      SalaryRecord(month: 'January 2024', totalSalary: 25000, paidAmount: 20000, pendingAmount: 5000),
    ];

    advanceHistory.value = [
      AdvancePayment(amount: 2000, reason: 'Personal Emergency', date: DateTime.now().subtract(const Duration(days: 5)), staffName: 'Rahul Verma'),
      AdvancePayment(amount: 5000, reason: 'Home Repair', date: DateTime.now().subtract(const Duration(days: 15)), staffName: 'Suresh Mehra'),
    ];

    staffDocuments.value = [
      StaffDocument(name: 'Driving License', uploadDate: DateTime.now().subtract(const Duration(days: 200)), expiryDate: DateTime.now().add(const Duration(days: 400)), fileUrl: 'license.pdf'),
      StaffDocument(name: 'Aadhar Card', uploadDate: DateTime.now().subtract(const Duration(days: 300)), expiryDate: DateTime.now().add(const Duration(days: 365*10)), fileUrl: 'aadhar.pdf'),
    ];
  }

  void _filterStaff() {
    List<StaffModel> list = List.from(staffList);
    if (selectedFilter.value == 'Driver') {
      list = list.where((s) => s.role == StaffRole.driver).toList();
    } else if (selectedFilter.value == 'Manager') {
      list = list.where((s) => s.role == StaffRole.manager).toList();
    } else if (selectedFilter.value == 'Helper') {
      list = list.where((s) => s.role == StaffRole.helper).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      list = list.where((s) =>
          s.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          s.role.name.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }
    filteredStaff.assignAll(list);
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }
}
