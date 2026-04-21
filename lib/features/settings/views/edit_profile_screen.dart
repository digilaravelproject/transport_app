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
import '../controllers/settings_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final SettingsController controller = Get.find<SettingsController>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _gstController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: controller.agencyName.value);
    _emailController = TextEditingController(text: controller.email.value);
    _phoneController = TextEditingController(text: controller.phone.value);
    _gstController = TextEditingController(text: controller.gstNumber.value);
    _addressController = TextEditingController(text: controller.address.value);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _gstController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Edit Profile',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
               child: Stack(
                 children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primaryLight,
                      child: const Icon(Iconsax.building, color: AppColors.primaryColor, size: 50),
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
               ),
            ),
            const SizedBox(height: 32),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('Vendor Details', style: AppTextStyle.subheading, color: AppColors.primaryColor),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Vendor Name',
                    hint: 'Enter vendor name',
                    controller: _nameController,
                    icon: Iconsax.building,
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Email Address',
                    hint: 'Enter email address',
                    controller: _emailController,
                    icon: Iconsax.sms,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Phone Number',
                    hint: 'Enter phone number',
                    controller: _phoneController,
                    icon: Iconsax.call,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'GST Number',
                    hint: 'Enter GST number',
                    controller: _gstController,
                    icon: Icons.assignment_outlined,
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Complete Address',
                    hint: 'Enter complete address',
                    controller: _addressController,
                    icon: Iconsax.location,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Save Changes',
              onPressed: () {
                controller.updateProfile(
                   _nameController.text,
                   _emailController.text,
                   _phoneController.text,
                   _gstController.text,
                   _addressController.text,
                );
                Get.back();
              },
            ),
             const SizedBox(height: 12),
            AppButton.outline(
              text: 'Cancel',
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}
