import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  Future<ResponseModel> getNotifications({int page = 1, int perPage = 20, int? unreadOnly}) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'per_page': perPage,
    };
    
    if (unreadOnly != null) {
      queryParams['unread_only'] = unreadOnly;
    }

    final response = await _apiClient.get(
      '/api/v1/notifications',
      queryParameters: queryParams,
    );

    if (response.isSuccess && response.json != null) {
      final List<dynamic> data = response.json!['data'] ?? [];
      final List<NotificationModel> notifications = data.map((e) => NotificationModel.fromJson(e)).toList();
      final meta = NotificationMeta.fromJson(response.json!['meta'] ?? {});
      
      return ResponseModel(
        isSuccess: true,
        statusCode: response.statusCode ?? 200,
        message: response.message,
        body: {
          'notifications': notifications,
          'meta': meta,
        },
      );
    }
    
    return response;
  }

  // Future<ResponseModel> markAsRead(int id) async {
  //   return await _apiClient.patch('/api/v1/notifications/$id/mark-as-read');
  // }

  // Future<ResponseModel> markAllAsRead() async {
  //   return await _apiClient.post('/api/v1/notifications/mark-all-as-read', data: {});
  // }
}
