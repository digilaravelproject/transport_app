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

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final SettingsController controller = Get.find<SettingsController>();
  
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Change Password',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('Update Security Credentials', style: AppTextStyle.subheading, color: AppColors.primaryColor),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Current Password',
                    hint: 'Enter your current password',
                    controller: _currentController,
                    icon: Iconsax.lock,
                    obscureText: _obscureCurrent,
                    suffixIcon: IconButton(
                       icon: Icon(_obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textColorSecondary),
                       onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'New Password',
                    hint: 'Enter your new password',
                    controller: _newController,
                    icon: Iconsax.lock,
                    obscureText: _obscureNew,
                     suffixIcon: IconButton(
                       icon: Icon(_obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textColorSecondary),
                       onPressed: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Confirm New Password',
                    hint: 'Confirm your new password',
                    controller: _confirmController,
                    icon: Iconsax.tick_circle,
                    obscureText: _obscureConfirm,
                     suffixIcon: IconButton(
                       icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textColorSecondary),
                       onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Change Password',
              onPressed: () {
                if (_newController.text.isNotEmpty && _newController.text == _confirmController.text) {
                   controller.changePassword(_currentController.text, _newController.text);
                   Get.back();
                } else if (_newController.text != _confirmController.text) {
                   Get.snackbar('Error', 'New passwords do not match', backgroundColor: AppColors.errorColor, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
                }
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
