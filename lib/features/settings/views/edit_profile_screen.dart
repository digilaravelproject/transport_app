import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../profile/controllers/profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({Key? key}) : super(key: key);

  ProfileController get controller => Get.find<ProfileController>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Edit Profile',
      ),
      body: Obx(() {
        final isLoading = controller.isLoading.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () => controller.showImagePickerOptions(),
                    child: Obx(() {
                      final selectedImage = controller.selectedImage.value;
                      final logoUrl = controller.profile.value?.logoUrl;

                      return Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primaryLight,
                            backgroundImage: selectedImage != null
                                ? FileImage(selectedImage)
                                : (logoUrl != null && logoUrl.isNotEmpty
                                    ? NetworkImage(logoUrl)
                                    : null) as ImageProvider?,
                            child: (selectedImage == null && (logoUrl == null || logoUrl.isEmpty))
                                ? const Icon(Iconsax.building, color: AppColors.primaryColor, size: 50)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Iconsax.camera, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 32),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText('Personal Details', style: AppTextStyle.subheading, color: AppColors.primaryColor),
                      const SizedBox(height: 16),
                      AppInputField(
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        controller: controller.nameController,
                        icon: Iconsax.user,
                        validator: controller.validateName,
                      ),
                      const SizedBox(height: 16),
                      // AppInputField(
                      //   label: 'Email Address',
                      //   hint: 'Enter email address',
                      //   controller: controller.emailController,
                      //   icon: Iconsax.sms,
                      //   keyboardType: TextInputType.emailAddress,
                      //   enabled: false, // Email cannot be edited
                      //   validator: controller.validateEmail,
                      // ),
                      Opacity(
                        opacity: 0.6, // 👈 fade effect
                        child: IgnorePointer(
                          ignoring: true, // 👈 click disable
                          child: AppInputField(
                            label: 'Email Address',
                            hint: 'Enter email address',
                            controller: controller.emailController,
                            icon: Iconsax.sms,
                            keyboardType: TextInputType.emailAddress,
                            enabled: false,
                            validator: controller.validateEmail,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppInputField(
                        label: 'Phone Number',
                        hint: 'Enter phone number',
                        controller: controller.phoneController,
                        icon: Iconsax.call,
                        keyboardType: TextInputType.phone,
                        validator: controller.validatePhone,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText('Business Details', style: AppTextStyle.subheading, color: AppColors.primaryColor),
                      const SizedBox(height: 16),
                      AppInputField(
                        label: 'Company Name',
                        hint: 'Enter company name',
                        controller: controller.companyNameController,
                        icon: Iconsax.building,
                      ),
                      const SizedBox(height: 16),
                      AppInputField(
                        label: 'Owner Name',
                        hint: 'Enter owner name',
                        controller: controller.ownerNameController,
                        icon: Iconsax.user_octagon,
                      ),
                      const SizedBox(height: 16),
                      AppInputField(
                        label: 'GST Number',
                        hint: 'Enter GST number',
                        controller: controller.gstinController,
                        icon: Icons.assignment_outlined,
                      ),
                      const SizedBox(height: 16),
                      AppInputField(
                        label: 'Complete Address',
                        hint: 'Enter complete address',
                        controller: controller.addressController,
                        icon: Iconsax.location,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                AppButton(
                  text: isLoading ? 'Saving...' : 'Save Changes',
                  onPressed: isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            controller.updateProfile();
                          }
                        },
                ),
                const SizedBox(height: 12),
                AppButton.outline(
                  text: 'Cancel',
                  onPressed: isLoading ? null : () => Get.back(),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
