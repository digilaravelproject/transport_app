import 'dart:io';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage/shared_prefs.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../auth/domain/models/user_model.dart';
import '../models/profile_model.dart';
import '../repositories/profile_repository.dart';
import 'profile_service_interface.dart';

class ProfileService implements ProfileServiceInterface {
  final ProfileRepository _profileRepository;

  ProfileService(this._profileRepository);

  @override
  Future<ResponseModel> getProfile() async {
    final response = await _profileRepository.getProfile();

    // Auto-save profile if success
    if (response.isSuccess && response.body != null) {
      try {
        final data = response.body as Map<String, dynamic>;
        final profileData = data['data'] ?? data;
        final profile = ProfileModel.fromJson(profileData);
        await saveProfile(profile);
        
        // Also update UserModel in SharedPreferences
        await _updateUserModel(profile);
      } catch (e) {
        print('Error saving profile data: $e');
      }
    }

    return response;
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
    final response = await _profileRepository.updateProfile(
      name: name,
      email: email,
      phone: phone,
      companyName: companyName,
      ownerName: ownerName,
      gstin: gstin,
      address: address,
      logo: logo,
    );

    // Auto-save updated profile if success
    if (response.isSuccess && response.body != null) {
      try {
        final data = response.body as Map<String, dynamic>;
        final profileData = data['data'] ?? data;
        final profile = ProfileModel.fromJson(profileData);
        await saveProfile(profile);
        
        // Also update UserModel in SharedPreferences
        await _updateUserModel(profile);
      } catch (e) {
        print('Error saving updated profile data: $e');
      }
    }

    return response;
  }

  Future<void> _updateUserModel(ProfileModel profile) async {
    try {
      // Create/update UserModel from ProfileModel
      final user = UserModel(
        id: profile.id,
        name: profile.name,
        email: profile.email,
        phone: profile.phone,
        role: profile.role,
        tenantId: profile.tenantId,
        companyName: profile.companyName,
        ownerName: profile.ownerName,
        gstin: profile.gstin,
        address: profile.address,
        logoUrl: profile.logoUrl,
      );
      
      // Save to SharedPreferences
      await SharedPrefs.setString(AppConstants.userData, user.toJsonString());
    } catch (e) {
      print('Error updating UserModel: $e');
    }
  }

  @override
  Future<void> saveProfile(ProfileModel profile) async {
    await SharedPrefs.setString(AppConstants.profileData, profile.toJsonString());
  }

  @override
  Future<ProfileModel?> getCachedProfile() async {
    final profileJsonString = SharedPrefs.getString(AppConstants.profileData);
    if (profileJsonString == null || profileJsonString.isEmpty) {
      return null;
    }
    try {
      return ProfileModel.fromJsonString(profileJsonString);
    } catch (e) {
      print('Error parsing cached profile: $e');
      return null;
    }
  }

  @override
  Future<void> clearProfile() async {
    await SharedPrefs.remove(AppConstants.profileData);
  }
}
