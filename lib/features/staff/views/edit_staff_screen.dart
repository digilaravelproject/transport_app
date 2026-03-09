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

class EditStaffScreen extends StatefulWidget {
  const EditStaffScreen({Key? key}) : super(key: key);

  @override
  State<EditStaffScreen> createState() => _EditStaffScreenState();
}

class _EditStaffScreenState extends State<EditStaffScreen> {
  final StaffModel staff = Get.arguments ?? Get.find<StaffController>().staffList.first;
  late StaffRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = staff.role;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Edit Staff',
        subtitle: staff.name,
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
                  AppInputField(
                    label: 'Full Name',
                    hint: 'Enter full name',
                    controller: TextEditingController(text: staff.name),
                    icon: Iconsax.user,
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Phone Number',
                    hint: 'Enter mobile number',
                    controller: TextEditingController(text: staff.phone),
                    icon: Iconsax.call,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Email Address',
                    hint: 'name@agency.com',
                    controller: TextEditingController(text: staff.email),
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
                  AppInputField(
                    label: 'Permanent Address',
                    hint: 'Full address',
                    controller: TextEditingController(text: staff.address),
                    icon: Iconsax.location,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Joining Date',
                    hint: 'DD/MM/YYYY',
                    controller: TextEditingController(text: staff.joiningDate != null ? '${staff.joiningDate!.day}/${staff.joiningDate!.month}/${staff.joiningDate!.year}' : ''),
                    icon: Iconsax.calendar_1,
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Aadhar Number',
                    hint: 'XXXX XXXX XXXX',
                    controller: TextEditingController(text: staff.aadharNumber ?? ''),
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
                   AppInputField(
                    label: 'Monthly Salary',
                    hint: '₹ 0.00',
                    controller: TextEditingController(text: staff.salary.toString()),
                    icon: Iconsax.card,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Work Shift',
                    hint: 'e.g. Day Shift, 9am - 6pm',
                    controller: TextEditingController(text: staff.shift ?? ''),
                    icon: Iconsax.clock,
                  ),
                  if (_selectedRole == StaffRole.driver) ...[
                    const SizedBox(height: 16),
                    AppInputField(
                      label: 'Driving License Number',
                      hint: 'Enter DL Number',
                      controller: TextEditingController(text: staff.licenseNumber ?? ''),
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
                    isUploaded: true,
                    fileName: 'aadhar_${staff.name.toLowerCase().replaceAll(' ', '_')}.pdf',
                    onTap: () {},
                  ),
                  if (_selectedRole == StaffRole.driver) ...[
                    const SizedBox(height: 12),
                    UploadBox(
                      label: 'Driving License Copy',
                      isUploaded: staff.licenseNumber != null,
                      fileName: staff.licenseNumber != null ? 'license_${staff.name.toLowerCase().replaceAll(' ', '_')}.pdf' : null,
                      onTap: () {},
                    ),
                  ],
                  const SizedBox(height: 12),
                  UploadBox(
                    label: 'Profile Photo',
                    isUploaded: staff.photoUrl != null,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Update Staff',
              onPressed: () => Get.back(),
            ),
            const SizedBox(height: 12),
            AppButton.outline(
              text: 'Delete Staff',
              color: AppColors.errorColor,
              onPressed: () => _showDeleteConfirmation(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const AppText('Delete Staff', style: AppTextStyle.heading, fontSize: 18),
        content: const AppText('Are you sure you want to remove this staff member? This action cannot be undone.', style: AppTextStyle.body),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const AppText('Cancel', style: AppTextStyle.body, color: AppColors.textColorHint)),
          TextButton(onPressed: () => Get.back(), child: const AppText('Delete', style: AppTextStyle.body, color: AppColors.errorColor, fontWeight: FontWeight.bold)),
        ],
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
