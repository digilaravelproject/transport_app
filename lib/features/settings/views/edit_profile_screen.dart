import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/phone_helper.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../core/constants/app_text_constants.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({Key? key}) : super(key: key);

  ProfileController get controller => Get.find<ProfileController>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: AppTextConstants.editProfile.tr,
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
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: selectedImage != null
                                ? ClipOval(
                                    child: Image.file(
                                      selectedImage,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : (logoUrl != null && logoUrl.isNotEmpty)
                                    ? CachedNetworkImage(
                                        imageUrl: logoUrl,
                                        imageBuilder: (context, imageProvider) => Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        placeholder: (context, url) => const Center(
                                          child: SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => const Center(
                                          child: Icon(
                                            Iconsax.building,
                                            color: AppColors.primaryColor,
                                            size: 50,
                                          ),
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(
                                          Iconsax.building,
                                          color: AppColors.primaryColor,
                                          size: 50,
                                        ),
                                      ),
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
                      AppText(AppTextConstants.personalDetails.tr, style: AppTextStyle.subheading, color: AppColors.primaryColor),
                      const SizedBox(height: 16),
                      // AppInputField(
                      //   label: 'Full Name',
                      //   hint: 'Enter your full name',
                      //   controller: controller.nameController,
                      //   icon: Iconsax.user,
                      //   validator: controller.validateName,
                      // ),
                      AppInputField(
                        label: AppTextConstants.ownerName.tr,
                        hint: AppTextConstants.enterOwnerName.tr,
                        controller: controller.ownerNameController,
                        icon: Iconsax.user_octagon,
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
                            label: AppTextConstants.emailAddress.tr,
                            hint: AppTextConstants.enterYourEmail.tr,
                            controller: controller.emailController,
                            icon: Iconsax.sms,
                            keyboardType: TextInputType.emailAddress,
                            enabled: false,
                            validator: controller.validateEmail,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // AppInputField(
                      //   label: 'Phone Number',
                      //   hint: 'Enter phone number',
                      //   controller: controller.phoneController,
                      //   icon: Iconsax.call,
                      //   keyboardType: TextInputType.phone,
                      //   validator: controller.validatePhone,
                      //   phoneCode: controller.selectedCountryCode.value,
                      //   onPhoneCodeTap: () => PhoneHelper.showCountryPicker(
                      //     context: context,
                      //     selectedCode: controller.selectedCountryCode,
                      //   ),
                      // ),

                      Obx(() => AppInputField(
                        label: AppTextConstants.mobileNumber.tr,
                        controller: controller.phoneController,
                        hint: AppTextConstants.enterMobileNumber.tr,
                        icon: Iconsax.call,
                        keyboardType: TextInputType.phone,
                        phoneCode: controller.selectedCountryCode.value,
                        onPhoneCodeTap: () => PhoneHelper.showCountryPicker(
                          context: context,
                          selectedCode: controller.selectedCountryCode,
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(AppTextConstants.businessDetails.tr, style: AppTextStyle.subheading, color: AppColors.primaryColor),
                      const SizedBox(height: 16),
                      AppInputField(
                        label: AppTextConstants.companyName.tr,
                        hint: AppTextConstants.enterCompanyName.tr,
                        controller: controller.companyNameController,
                        icon: Iconsax.building,
                      ),
                     // const SizedBox(height: 16),
                     /* AppInputField(
                        label: 'Owner Name',
                        hint: 'Enter owner name',
                        controller: controller.ownerNameController,
                        icon: Iconsax.user_octagon,
                      ),*/
                      const SizedBox(height: 16),
                      AppInputField(
                        label: 'GST Number',
                        hint: 'Enter GST number',
                        controller: controller.gstinController,
                        icon: Icons.assignment_outlined,
                      ),
                      const SizedBox(height: 16),
                      AppInputField(
                        label: AppTextConstants.completeAddress.tr,
                        hint: AppTextConstants.enterCompleteAddress.tr,
                        controller: controller.addressController,
                        icon: Iconsax.location,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                AppButton(
                  text: isLoading ? '${AppTextConstants.sending.tr}...' : AppTextConstants.saveChanges.tr,
                  onPressed: isLoading
                      ? null
                      : () {
                    if (_formKey.currentState!.validate()) {
                      controller.updateProfile();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}