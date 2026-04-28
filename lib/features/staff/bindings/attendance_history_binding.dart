import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../controllers/attendance_history_controller.dart';
import '../domain/repositories/attendance_repository.dart';
import '../domain/services/attendance_service.dart';

class AttendanceHistoryBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<AttendanceRepository>(
      () => AttendanceRepositoryImpl(Get.find<ApiClient>()),
      fenix: true,
    );

    // Use Cases
    Get.lazyPut(
      () => GetAttendanceHistoryUseCase(Get.find<AttendanceRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => SearchAttendanceHistoryUseCase(Get.find<AttendanceRepository>()),
      fenix: true,
    );

    // Controller
    Get.lazyPut(
      () => AttendanceHistoryController(
        getAttendanceHistoryUseCase: Get.find<GetAttendanceHistoryUseCase>(),
        searchAttendanceHistoryUseCase: Get.find<SearchAttendanceHistoryUseCase>(),
      ),
      fenix: true,
    );
  }
}
