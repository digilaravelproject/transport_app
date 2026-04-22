import 'dart:io';
import '../../../../core/services/network/response_model.dart';
import '../models/profile_model.dart';

abstract class ProfileServiceInterface {
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
  Future<ProfileModel?> getCachedProfile();
  Future<void> saveProfile(ProfileModel profile);
  Future<void> clearProfile();
}
