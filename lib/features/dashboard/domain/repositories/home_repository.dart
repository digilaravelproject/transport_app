import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../models/home_stats_model.dart';

class HomeRepository {
  final ApiClient _apiClient;

  HomeRepository(this._apiClient);

  Future<ResponseModel> getHomeStats() async {
    final response = await _apiClient.get('/api/v1/home/stats');
    
    if (response.isSuccess && response.json != null) {
      try {
        final stats = HomeStatsModel.fromJson(response.json!['data']);
        return ResponseModel(
          isSuccess: true,
          statusCode: response.statusCode ?? 200,
          message: response.message,
          body: stats,
        );
      } catch (e) {
        return ResponseModel(
          isSuccess: false,
          statusCode: 500,
          message: 'Error parsing home stats: $e',
        );
      }
    }
    return response;
  }
}
