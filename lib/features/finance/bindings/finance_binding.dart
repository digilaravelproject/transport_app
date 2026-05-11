import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../controllers/finance_controller.dart';
import '../domain/repositories/finance_repository.dart';
import '../domain/services/finance_service.dart';
import '../domain/services/finance_service.dart' as finance_service;

class FinanceBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<FinanceRepository>(
      () => FinanceRepositoryImpl(Get.find<ApiClient>()),
      fenix: true,
    );

    // Use Case
    Get.lazyPut(
      () => GetFinanceDataUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetTransactionByIdUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => AddTransactionUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetFinanceDashboardUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );

    // Controller
    Get.lazyPut(
      () => FinanceController(
        getFinanceDataUseCase: Get.find<GetFinanceDataUseCase>(),
        getTransactionByIdUseCase: Get.find<GetTransactionByIdUseCase>(),
        addTransactionUseCase: Get.find<AddTransactionUseCase>(),
        getFinanceDashboardUseCase: Get.find<GetFinanceDashboardUseCase>(),
      ),
      fenix: true,
    );
  }
}