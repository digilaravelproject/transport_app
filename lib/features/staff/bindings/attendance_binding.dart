import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../controllers/attendance_controller.dart';
import '../domain/repositories/attendance_repository.dart';
import '../domain/services/attendance_service.dart';

class AttendanceBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<AttendanceRepository>(
      () => AttendanceRepositoryImpl(Get.find<ApiClient>()),
      fenix: true,
    );

    // Use Cases
    Get.lazyPut(
      () => GetAttendanceUseCase(Get.find<AttendanceRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => SaveAttendanceUseCase(Get.find<AttendanceRepository>()),
      fenix: true,
    );

    // Controller
    Get.lazyPut(
      () => AttendanceController(
        getAttendanceUseCase: Get.find<GetAttendanceUseCase>(),
        saveAttendanceUseCase: Get.find<SaveAttendanceUseCase>(),
      ),
      fenix: true,
    );
  }
}
