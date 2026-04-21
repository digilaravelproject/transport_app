import '../../../../core/services/network/response_model.dart';

abstract class AuthRepositoryInterface {
  Future<ResponseModel> sendOtp(String email);
  Future<ResponseModel> signup(String name, String mobile);
  Future<ResponseModel> login(String mobile);
  Future<ResponseModel> verifyOtp(String mobile, String otp);
}