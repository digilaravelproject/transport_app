import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/network/response_model.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../domain/models/profile_model.dart';
import '../domain/services/profile_service.dart';

class ProfileController extends GetxController {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final GetCachedProfileUseCase _getCachedProfileUseCase;

  ProfileController({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required GetCachedProfileUseCase getCachedProfileUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _getCachedProfileUseCase = getCachedProfileUseCase;

  final isLoading = false.obs;
  Rx<ProfileModel?> profile = Rx<ProfileModel?>(null);
  Rx<File?> selectedImage = Rx<File?>(null);

  // Form controllers for edit profile
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final companyNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final gstinController = TextEditingController();
  final addressController = TextEditingController();
  var selectedCountryCode = '+91'.obs;


  @override
  void onInit() {
    super.onInit();
    loadCachedProfile();
    fetchProfile();
  }

  @override
  void onClose() {
    // Don't dispose controllers when using fenix: true
    super.onClose();
  }

  Future<void> loadCachedProfile() async {
    final cachedProfile = await _getCachedProfileUseCase.execute();
    if (cachedProfile != null) {
      profile.value = cachedProfile;
      _populateControllers(cachedProfile);
    }
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final response = await _getProfileUseCase.execute();

      if (response.isSuccess && response.body != null) {
        final data = response.body as Map<String, dynamic>;
        final profileData = data['data'] ?? data;
        profile.value = ProfileModel.fromJson(profileData);
        _populateControllers(profile.value!);
      } else {
        CustomSnackbar.showError(
          response.message ?? 'Failed to fetch profile',
        );
      }
    } catch (e) {
      print('❌ Error in fetchProfile: $e');
      CustomSnackbar.showError('Failed to load profile');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    try {
      isLoading.value = true;

      final response = await _updateProfileUseCase.execute(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        companyName: companyNameController.text.trim().isEmpty ? null : companyNameController.text.trim(),
        ownerName: ownerNameController.text.trim().isEmpty ? null : ownerNameController.text.trim(),
        gstin: gstinController.text.trim().isEmpty ? null : gstinController.text.trim(),
        address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
        logo: selectedImage.value,
      );

      if (response.isSuccess) {
        if (response.body != null) {
          final data = response.body as Map<String, dynamic>;
          final profileData = data['data'] ?? data;
          profile.value = ProfileModel.fromJson(profileData);
          _populateControllers(profile.value!);
        }
        
        // Clear selected image after successful update
        selectedImage.value = null;
        
        CustomSnackbar.showSuccess(
          response.message ?? 'Profile updated successfully',
        );
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back(); // Go back to profile screen
      } else {
        CustomSnackbar.showError(
          response.message ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      print('❌ Error in updateProfile: $e');
      CustomSnackbar.showError('Failed to update profile');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        CustomSnackbar.showSuccess('Image selected successfully');
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      CustomSnackbar.showError('Failed to pick image');
    }
  }

  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF2563EB)),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF2563EB)),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery);
              },
            ),
            if (selectedImage.value != null || profile.value?.logoUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Picture'),
                onTap: () {
                  Get.back();
                  selectedImage.value = null;
                  CustomSnackbar.showSuccess('Picture removed');
                },
              ),
          ],
        ),
      ),
    );
  }

  void _populateControllers(ProfileModel profile) {
    nameController.text = profile.name;
    emailController.text = profile.email;
    phoneController.text = profile.phone ?? '';
    companyNameController.text = profile.companyName ?? '';
    ownerNameController.text = profile.ownerName ?? '';
    gstinController.text = profile.gstin ?? '';
    addressController.text = profile.address ?? '';
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value != null && value.isNotEmpty && value.length != 10) {
      return 'Please enter a valid 10-digit mobile number';
    }
    return null;
  }
}

// Use Cases
class GetProfileUseCase {
  final ProfileService _profileService;

  GetProfileUseCase(this._profileService);

  Future<ResponseModel> execute() async {
    return await _profileService.getProfile();
  }
}

class UpdateProfileUseCase {
  final ProfileService _profileService;

  UpdateProfileUseCase(this._profileService);

  Future<ResponseModel> execute({
    required String name,
    required String email,
    String? phone,
    String? companyName,
    String? ownerName,
    String? gstin,
    String? address,
    File? logo,
  }) async {
    return await _profileService.updateProfile(
      name: name,
      email: email,
      phone: phone,
      companyName: companyName,
      ownerName: ownerName,
      gstin: gstin,
      address: address,
      logo: logo,
    );
  }
}

class GetCachedProfileUseCase {
  final ProfileService _profileService;

  GetCachedProfileUseCase(this._profileService);

  Future<ProfileModel?> execute() async {
    return await _profileService.getCachedProfile();
  }
}
