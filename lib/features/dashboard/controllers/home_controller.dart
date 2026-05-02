import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../domain/models/home_stats_model.dart';
import '../domain/repositories/home_repository.dart';

class HomeController extends GetxController {
  final HomeRepository _repository = HomeRepository(ApiClient());

  final Rxn<HomeStatsModel> stats = Rxn<HomeStatsModel>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeStats();
  }

  Future<void> fetchHomeStats() async {
    isLoading.value = true;
    try {
      final response = await _repository.getHomeStats();
      if (response.isSuccess && response.body != null) {
        stats.value = response.body as HomeStatsModel;
      }
    } catch (e) {
      print('Error fetching home stats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await fetchHomeStats();
  }
}
