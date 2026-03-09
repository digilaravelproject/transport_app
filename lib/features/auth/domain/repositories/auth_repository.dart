import 'dart:async';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import 'auth_repository_interface.dart';

class AuthRepository implements AuthRepositoryInterface {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  @override
  Future<ResponseModel> signup(String name, String mobile) async {
    final response = await _apiClient.post(
      AppConstants.userSignupUrl,
      data: {
        'name': name,
        'mobile': mobile,
      },
    );

    return response;
  }

  @override
  Future<ResponseModel> login(String mobile) async {
    final response = await _apiClient.post(
      AppConstants.userLoginUrl,
      data: {
        'mobile': mobile,
      },
    );

    return response;
  }

  @override
  Future<ResponseModel> verifyOtp(String mobile, String otp) async {
    final response = await _apiClient.post(
      AppConstants.otpVerifyUrl,
      data: {
        'mobile': mobile,
        'otp': otp,
      },
    );

    return response;
  }
}