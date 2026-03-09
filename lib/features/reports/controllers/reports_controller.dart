import 'package:get/get.dart';
import '../domain/models/report_model.dart';

class ReportsController extends GetxController {
  final _recentReports = <ReportModel>[].obs;
  List<ReportModel> get recentReports => _recentReports;

  // Key KPI Metrics
  final totalTripsThisMonth = 145.obs;
  final totalRevenueThisMonth = 450000.0.obs;
  final activeVehiclesCount = 18.obs;
  final activeDriversCount = 22.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    _recentReports.assignAll([
      ReportModel(
        id: 'RPT001',
        reportName: 'Monthly Financial Summary - April 2024',
        type: 'Financial',
        generatedBy: 'Admin',
        generatedDate: DateTime.now().subtract(const Duration(days: 1)),
        format: 'PDF',
        status: 'Ready',
      ),
      ReportModel(
        id: 'RPT002',
        reportName: 'Vehicle Utilization Report - Q1',
        type: 'Operational',
        generatedBy: 'System Auto',
        generatedDate: DateTime.now().subtract(const Duration(days: 3)),
        format: 'Excel',
        status: 'Ready',
      ),
      ReportModel(
        id: 'RPT003',
        reportName: 'Driver Attendance & Shift Log',
        type: 'Performance',
        generatedBy: 'Manager',
        generatedDate: DateTime.now().subtract(const Duration(days: 5)),
        format: 'CSV',
        status: 'Ready',
      ),
    ]);
  }

  void generateNewReport(String name, String type, String format) {
    Get.snackbar('Generating Report', 'Your $type report "$name" is being generated.', snackPosition: SnackPosition.BOTTOM);
    Future.delayed(const Duration(seconds: 2), () {
       _recentReports.insert(0, ReportModel(
        id: 'RPT00${_recentReports.length + 1}',
        reportName: name,
        type: type,
        generatedBy: 'Current User',
        generatedDate: DateTime.now(),
        format: format,
        status: 'Ready',
      ));
      Get.snackbar('Report Ready', 'Your report is ready to download.', snackPosition: SnackPosition.BOTTOM);
    });
  }
}
