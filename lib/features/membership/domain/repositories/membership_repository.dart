import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';

class MembershipRepository {
  final ApiClient _apiClient;

  MembershipRepository(this._apiClient);

  Future<ResponseModel> getPlans() async {
    try {
      final response = await _apiClient.get(
        AppConstants.plansListUrl,
        handleError: false,
        showToaster: false,
      );

      return response;
    } catch (e) {
      print('❌ Error in getPlans repository: $e');
      return ResponseModel(
        isSuccess: false,
        message: 'Failed to fetch plans',
        statusCode: 500,
      );
    }
  }

  Future<ResponseModel> createSubscription(int planId) async {
    try {
      final response = await _apiClient.post(
        AppConstants.createSubscriptionUrl,
        data: {'plan_id': planId},
        handleError: true,
        showToaster: false,
      );
      return response;
    } catch (e) {
      print('❌ Error in createSubscription: $e');
      return ResponseModel(isSuccess: false, message: e.toString());
    }
  }

  Future<ResponseModel> verifyPayment({
    required int subscriptionId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConstants.verifyPaymentUrl,
        data: {
          'subscription_id': subscriptionId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
        handleError: true,
        showToaster: false,
      );
      return response;
    } catch (e) {
      print('❌ Error in verifyPayment: $e');
      return ResponseModel(isSuccess: false, message: e.toString());
    }
  }

  Future<ResponseModel> getCurrentSubscription() async {
    try {
      final response = await _apiClient.get(
        AppConstants.currentSubscriptionUrl,
        handleError: true,
        showToaster: false,
      );
      return response;
    } catch (e) {
      print('❌ Error in getCurrentSubscription: $e');
      return ResponseModel(isSuccess: false, message: e.toString());
    }
  }

  Future<ResponseModel> getSubscriptionHistory() async {
    try {
      final response = await _apiClient.get(
        AppConstants.subscriptionsHistoryUrl,
        handleError: true,
        showToaster: false,
      );
      return response;
    } catch (e) {
      print('❌ Error in getSubscriptionHistory: $e');
      return ResponseModel(isSuccess: false, message: e.toString());
    }
  }
}
