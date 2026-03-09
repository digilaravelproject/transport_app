import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../vehicles/widgets/upload_box.dart';
import '../controllers/staff_controller.dart';
import '../domain/models/staff_model.dart';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({Key? key}) : super(key: key);

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _controller = Get.find<StaffController>();
  StaffRole _selectedRole = StaffRole.driver;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Add Staff',
        subtitle: 'Register new employee',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Basic Information'),
            AppCard(
              child: Column(
                children: [
                  const AppInputField(
                    label: 'Full Name',
                    hint: 'Enter full name',
                    icon: Iconsax.user,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Phone Number',
                    hint: 'Enter mobile number',
                    icon: Iconsax.call,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Email Address',
                    hint: 'name@agency.com',
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    'Select Role',
                    _selectedRole,
                    StaffRole.values,
                    (val) => setState(() => _selectedRole = val!),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Personal Details'),
            AppCard(
              child: Column(
                children: [
                  const AppInputField(
                    label: 'Permanent Address',
                    hint: 'Full address',
                    icon: Iconsax.location,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Joining Date',
                    hint: 'DD/MM/YYYY',
                    icon: Iconsax.calendar_1,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Aadhar Number',
                    hint: 'XXXX XXXX XXXX',
                    icon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Work Details'),
            AppCard(
              child: Column(
                children: [
                  const AppInputField(
                    label: 'Monthly Salary',
                    hint: '₹ 0.00',
                    icon: Iconsax.card,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Work Shift',
                    hint: 'e.g. Day Shift, 9am - 6pm',
                    icon: Iconsax.clock,
                  ),
                  if (_selectedRole == StaffRole.driver) ...[
                    const SizedBox(height: 16),
                    const AppInputField(
                      label: 'Driving License Number',
                      hint: 'Enter DL Number',
                      icon: Icons.card_membership_rounded,
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Documents Upload'),
            AppCard(
              child: Column(
                children: [
                  UploadBox(
                    label: 'Aadhar Card Copy',
                    onTap: () {},
                  ),
                  if (_selectedRole == StaffRole.driver) ...[
                    const SizedBox(height: 12),
                    UploadBox(
                      label: 'Driving License Copy',
                      onTap: () {},
                    ),
                  ],
                  const SizedBox(height: 12),
                  UploadBox(
                    label: 'Profile Photo',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Save Staff',
              onPressed: () => Get.back(),
            ),
            const SizedBox(height: 12),
            AppButton.outline(
              text: 'Cancel',
              onPressed: () => Get.back(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T extends Enum>(
    String label,
    T value,
    List<T> items,
    Function(T?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.label),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item.name.capitalizeFirst!),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.slate50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.slate200),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: AppText(
        title,
        style: AppTextStyle.subheading,
        fontSize: 14,
        color: AppColors.primaryColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
