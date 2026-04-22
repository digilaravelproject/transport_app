import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/services/network/multipart.dart';
import 'profile_repository_interface.dart';

class ProfileRepository implements ProfileRepositoryInterface {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  @override
  Future<ResponseModel> getProfile() async {
    try {
      final response = await _apiClient.get(
        AppConstants.profileUrl,
        handleError: false,
        showToaster: false,
      );

      return response;
    } catch (e) {
      print('❌ Error in getProfile repository: $e');
      return ResponseModel(
        isSuccess: false,
        message: 'Failed to fetch profile',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ResponseModel> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? companyName,
    String? ownerName,
    String? gstin,
    String? address,
    File? logo,
  }) async {
    try {
      // Prepare form data
      Map<String, String> formData = {};
      
      if (phone != null && phone.isNotEmpty) formData['phone'] = phone;
      if (companyName != null && companyName.isNotEmpty) formData['vendor_name'] = companyName;
      if (ownerName != null && ownerName.isNotEmpty) formData['owner_name'] = ownerName;
      if (gstin != null && gstin.isNotEmpty) formData['gstin'] = gstin;
      if (address != null && address.isNotEmpty) formData['address'] = address;

      // Prepare multipart file if logo is provided
      List<MultipartBody> multipartFiles = [];
      if (logo != null) {
        // Convert File to XFile
        final xFile = XFile(logo.path);
        multipartFiles.add(MultipartBody('logo', xFile));
      }

      final response = await _apiClient.postMultipartData(
        AppConstants.updateProfileUrl,
        formData,
        multipartFiles,
        [], // No other documents
        handleError: false,
        showToaster: false,
      );

      return response;
    } catch (e) {
      print('❌ Error in updateProfile repository: $e');
      return ResponseModel(
        isSuccess: false,
        message: 'Failed to update profile',
        statusCode: 500,
      );
    }
  }
}
