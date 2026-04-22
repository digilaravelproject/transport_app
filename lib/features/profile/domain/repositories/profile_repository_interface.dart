import 'dart:io';
import '../../../../core/services/network/response_model.dart';

abstract class ProfileRepositoryInterface {
  Future<ResponseModel> getProfile();
  Future<ResponseModel> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? companyName,
    String? ownerName,
    String? gstin,
    String? address,
    File? logo,
  });
}
