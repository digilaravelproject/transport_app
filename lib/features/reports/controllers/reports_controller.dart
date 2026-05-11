import 'package:get/get.dart';
import '../domain/models/report_model.dart';

import '../../../core/services/network/api_client.dart';
import '../../../core/utils/custom_snackbar.dart';

class ReportsController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final _recentReports = <ReportModel>[].obs;
  List<ReportModel> get recentReports => _recentReports;
  
  final isLoading = false.obs;
  final isReportsLoading = false.obs;
  final selectedMonth = ''.obs;

  // Key KPI Metrics
  final totalTripsThisMonth = 0.obs;
  final totalRevenueThisMonth = 0.0.obs;
  final activeVehiclesCount = 0.obs;
  final activeDriversCount = 0.obs;

  // Pagination for View All
  final allReports = <ReportModel>[].obs;
  final currentPage = 1.obs;
  final hasMoreData = true.obs;
  final isMoreLoading = false.obs;

  // Monthly Report Section
  final monthlyReport = Rxn<ReportModel>();
  final isMonthlyLoading = false.obs;
  final selectedReportType = 'trip'.obs;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    selectedMonth.value = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    fetchReportsStats();
  }

  Future<void> fetchReportsStats() async {
    isReportsLoading.value = true;
    try {
      final response = await _apiClient.get('/api/v1/dashboard/reports/stats', queryParameters: {
        'month': selectedMonth.value,
      });
      
      if (response.isSuccess && response.body != null) {
        final data = response.body;
        totalTripsThisMonth.value = data['total_trips'] ?? 0;
        totalRevenueThisMonth.value = (data['trip_revenue'] ?? 0).toDouble();
        activeVehiclesCount.value = data['active_vehicles'] ?? 0;
        activeDriversCount.value = data['active_drivers'] ?? 0;
        
        if (data['recent_reports'] != null) {
          final List<dynamic> reportsData = data['recent_reports'];
          _recentReports.assignAll(reportsData.map((json) => ReportModel.fromJson(json)).toList());
        }
      }
    } catch (e) {
      print('Error fetching report stats: $e');
    } finally {
      isReportsLoading.value = false;
    }
  }

  Future<void> fetchAllReports({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      allReports.clear();
    }

    if (!hasMoreData.value || isMoreLoading.value) return;

    isMoreLoading.value = true;
    try {
      final response = await _apiClient.get('/api/v1/dashboard/reports', queryParameters: {
        'page': currentPage.value,
        'per_page': 15,
      });

      if (response.isSuccess && response.body != null) {
        final List<dynamic> data = response.body is Map ? (response.body['data'] ?? []) : response.body;
        final List<ReportModel> fetchedReports = data.map((json) => ReportModel.fromJson(json)).toList();

        if (fetchedReports.isEmpty) {
          hasMoreData.value = false;
        } else {
          allReports.addAll(fetchedReports);
          currentPage.value++;
        }
      }
    } catch (e) {
      print('Error fetching all reports: $e');
    } finally {
      isMoreLoading.value = false;
    }
  }

  void updateSelectedMonth(String month) {
    selectedMonth.value = month;
    fetchReportsStats();
    fetchMonthlyReport();
  }

  Future<void> fetchMonthlyReport() async {
    isMonthlyLoading.value = true;
    try {
      final response = await _apiClient.get('/api/v1/dashboard/reports/monthly', queryParameters: {
        'type': selectedReportType.value.toLowerCase(),
        'month': selectedMonth.value,
      });

      if (response.isSuccess && response.body != null) {
        monthlyReport.value = ReportModel.fromJson(response.body);
      } else {
        monthlyReport.value = null;
      }
    } catch (e) {
      print('Error fetching monthly report: $e');
      monthlyReport.value = null;
    } finally {
      isMonthlyLoading.value = false;
    }
  }

  void updateReportType(String type) {
    selectedReportType.value = type;
    fetchMonthlyReport();
  }

  Future<bool> generateReport(Map<String, dynamic> payload) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.post('/api/v1/dashboard/reports/generate', data: payload);
      if (response.isSuccess) {
        CustomSnackbar.showSuccess(response.message);
        fetchReportsStats(); // Refresh dashboard data
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to generate report');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void generateNewReport(String name, String type, String format) {
    // Old mock method - keeping it for compatibility if any other place uses it
    generateReport({
      "name": name,
      "type": type,
      "format": format.toLowerCase(),
      "from": DateTime.now().subtract(const Duration(days: 30)).toIso8601String().split('T')[0],
      "to": DateTime.now().toIso8601String().split('T')[0],
    });
  }
}
