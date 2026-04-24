import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:get/get.dart';

class RazorpayService extends GetxService {
  late Razorpay _razorpay;
  
  Function(PaymentSuccessResponse)? onSuccess;
  Function(PaymentFailureResponse)? onFailure;
  Function(ExternalWalletResponse)? onExternalWallet;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout({
    required String key,
    required int amount,
    required String orderId,
    required String name,
    required String description,
    required String email,
    required String contact,
    String? color,
  }) {
    var options = {
      'key': key,
      'amount': amount, // amount in the smallest currency unit
      'name': name,
      'order_id': orderId,
      'description': description,
      'timeout': 300, // in seconds
      'prefill': {
        'contact': contact,
        'email': email,
      },
      'theme': {
        'color': color ?? '#F97316', // Default primary color
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('❌ Error opening Razorpay: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    onSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    onFailure?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    onExternalWallet?.call(response);
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}
