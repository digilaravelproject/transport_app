import 'package:get/get.dart';
import '../domain/models/notification_model.dart';
import '../domain/repositories/notification_repository.dart';
import '../../../../core/services/network/api_client.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository = NotificationRepository(ApiClient());

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final int perPage = 20;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      notifications.clear();
    }

    if (currentPage.value == 1) {
      isLoading.value = true;
    } else {
      isMoreLoading.value = true;
    }

    try {
      final response = await _repository.getNotifications(
        page: currentPage.value,
        perPage: perPage,
      );

      if (response.isSuccess && response.body != null) {
        final List<NotificationModel> newNotifications = response.body['notifications'];
        final NotificationMeta meta = response.body['meta'];
        
        if (currentPage.value == 1) {
          notifications.assignAll(newNotifications);
        } else {
          notifications.addAll(newNotifications);
        }
        
        totalItems.value = meta.total;
        currentPage.value++;
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  // Future<void> markAsRead(int id) async {
  //   final index = notifications.indexWhere((n) => n.id == id);
  //   if (index != -1 && !notifications[index].isRead) {
  //     final response = await _repository.markAsRead(id);
  //     if (response.isSuccess) {
  //       // Update local state instead of re-fetching
  //       final updatedNotification = NotificationModel(
  //         id: notifications[index].id,
  //         tenantId: notifications[index].tenantId,
  //         userId: notifications[index].userId,
  //         type: notifications[index].type,
  //         title: notifications[index].title,
  //         message: notifications[index].message,
  //         data: notifications[index].data,
  //         isRead: true,
  //         priority: notifications[index].priority,
  //         createdAt: notifications[index].createdAt,
  //         updatedAt: notifications[index].updatedAt,
  //       );
  //       notifications[index] = updatedNotification;
  //     }
  //   }
  // }
  //
  // Future<void> markAllAsRead() async {
  //   final response = await _repository.markAllAsRead();
  //   if (response.isSuccess) {
  //     fetchNotifications(isRefresh: true);
  //   }
  // }

  bool get hasMore => notifications.length < totalItems.value;
}
