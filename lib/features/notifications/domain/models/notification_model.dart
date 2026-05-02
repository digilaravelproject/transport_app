class NotificationModel {
  final int id;
  final int? tenantId;
  final int? userId;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final String priority;
  final String createdAt;
  final String updatedAt;

  NotificationModel({
    required this.id,
    this.tenantId,
    this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      tenantId: json['tenant_id'],
      userId: json['user_id'],
      type: json['type'] ?? 'general',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      data: json['data'],
      isRead: json['is_read'] ?? false,
      priority: json['priority'] ?? 'low',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class NotificationMeta {
  final int total;
  final int currentPage;

  NotificationMeta({
    required this.total,
    required this.currentPage,
  });

  factory NotificationMeta.fromJson(Map<String, dynamic> json) {
    return NotificationMeta(
      total: json['total'] ?? 0,
      currentPage: json['current_page'] ?? 1,
    );
  }
}
