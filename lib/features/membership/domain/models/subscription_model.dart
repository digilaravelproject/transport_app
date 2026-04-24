class SubscriptionHistoryResponseModel {
  final bool success;
  final String message;
  final List<ActiveSubscriptionModel> data;

  SubscriptionHistoryResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SubscriptionHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistoryResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? List<ActiveSubscriptionModel>.from(json['data'].map((x) => ActiveSubscriptionModel.fromJson(x))) 
          : [],
    );
  }
}

class SubscriptionResponseModel {
  final bool success;
  final String message;
  final SubscriptionDataModel data;

  SubscriptionResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SubscriptionResponseModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: SubscriptionDataModel.fromJson(json['data'] ?? {}),
    );
  }
}

class SubscriptionDataModel {
  final SubscriptionModel subscription;
  final RazorpayOrderModel razorpayOrder;

  SubscriptionDataModel({
    required this.subscription,
    required this.razorpayOrder,
  });

  factory SubscriptionDataModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionDataModel(
      subscription: SubscriptionModel.fromJson(json['subscription'] ?? {}),
      razorpayOrder: RazorpayOrderModel.fromJson(json['razorpay_order'] ?? {}),
    );
  }
}

class CurrentSubscriptionResponseModel {
  final bool success;
  final String message;
  final ActiveSubscriptionModel? data;

  CurrentSubscriptionResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory CurrentSubscriptionResponseModel.fromJson(Map<String, dynamic> json) {
    return CurrentSubscriptionResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ActiveSubscriptionModel.fromJson(json['data']) : null,
    );
  }
}

class ActiveSubscriptionModel {
  final int id;
  final int userId;
  final String status;
  final String paymentStatus;
  final bool isActive;
  final String? startDate;
  final String? endDate;
  final int totalAmount;
  final dynamic plan; // Can use PlanModel if imported

  ActiveSubscriptionModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.paymentStatus,
    required this.isActive,
    this.startDate,
    this.endDate,
    required this.totalAmount,
    this.plan,
  });

  factory ActiveSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return ActiveSubscriptionModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      status: json['status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      isActive: json['is_active'] ?? false,
      startDate: json['start_date'],
      endDate: json['end_date'],
      totalAmount: json['total_amount'] ?? 0,
      plan: json['plan'],
    );
  }
}

class SubscriptionModel {
  final int id;
  final int userId;
  final String status;
  final String paymentStatus;
  final int totalAmount;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      status: json['status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      totalAmount: json['total_amount'] ?? 0,
    );
  }
}

class RazorpayOrderModel {
  final String id;
  final int amount;
  final String currency;
  final String status;
  final String razorpayKey;

  RazorpayOrderModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.razorpayKey,
  });

  factory RazorpayOrderModel.fromJson(Map<String, dynamic> json) {
    return RazorpayOrderModel(
      id: json['id'] ?? '',
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? 'INR',
      status: json['status'] ?? '',
      razorpayKey: json['razorpay_key'] ?? '',
    );
  }
}
