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
import '../../../core/utils/phone_helper.dart';
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
  late SalaryType _selectedSalaryType;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _joiningDateController = TextEditingController();
  final TextEditingController _aadharNoController = TextEditingController();
  final TextEditingController _panNoController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _shiftController = TextEditingController();
  final TextEditingController _licenseNoController = TextEditingController();
  final TextEditingController _licenseExpiryController = TextEditingController();
  final TextEditingController _badgeNoController = TextEditingController();
  final TextEditingController _badgeExpiryController = TextEditingController();
  final _staffController = Get.find<StaffController>();

  @override
  void initState() {
    super.initState();
    _selectedRole = staff.role;
    _selectedSalaryType = staff.salaryType;
    _nameController.text = staff.name;
    _emailController.text = staff.email;
    _addressController.text = staff.address;
    _joiningDateController.text = staff.joiningDate != null ? '${staff.joiningDate!.day}/${staff.joiningDate!.month}/${staff.joiningDate!.year}' : '';
    _aadharNoController.text = staff.aadharNumber ?? '';
    _panNoController.text = staff.panNumber ?? '';
    _salaryController.text = staff.salary.toString();
    _shiftController.text = staff.shift ?? '';
    _licenseNoController.text = staff.licenseNumber ?? '';
    _licenseExpiryController.text = staff.licenseExpiry != null ? '${staff.licenseExpiry!.day}/${staff.licenseExpiry!.month}/${staff.licenseExpiry!.year}' : '';
    _badgeNoController.text = staff.badgeNumber ?? '';
    _badgeExpiryController.text = staff.badgeExpiry != null ? '${staff.badgeExpiry!.day}/${staff.badgeExpiry!.month}/${staff.badgeExpiry!.year}' : '';

    // Parse phone number
    if (staff.phone.contains(' ')) {
      final parts = staff.phone.split(' ');
      _staffController.selectedCountryCode.value = parts[0];
      _phoneController.text = parts.sublist(1).join(' ');
    } else if (staff.phone.startsWith('+')) {
      if (staff.phone.startsWith('+91')) {
        _staffController.selectedCountryCode.value = '+91';
        _phoneController.text = staff.phone.substring(3).trim();
      } else {
        _phoneController.text = staff.phone;
      }
    } else {
      _phoneController.text = staff.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _joiningDateController.dispose();
    _aadharNoController.dispose();
    _panNoController.dispose();
    _salaryController.dispose();
    _shiftController.dispose();
    _licenseNoController.dispose();
    _licenseExpiryController.dispose();
    _badgeNoController.dispose();
    _badgeExpiryController.dispose();
    super.dispose();
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
                    controller: _nameController,
                    icon: Iconsax.user,
                  ),
                  const SizedBox(height: 16),
                  Obx(() => AppInputField(
                    label: 'Phone Number',
                    hint: 'Enter mobile number',
                    controller: _phoneController,
                    icon: Iconsax.call,
                    keyboardType: TextInputType.phone,
                    phoneCode: _staffController.selectedCountryCode.value,
                    onPhoneCodeTap: () => PhoneHelper.showCountryPicker(
                      context: context,
                      selectedCode: _staffController.selectedCountryCode,
                    ),
                  )),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Email Address',
                    hint: 'name@agency.com',
                    controller: _emailController,
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
                    controller: _addressController,
                    icon: Iconsax.location,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Joining Date',
                    hint: 'DD/MM/YYYY',
                    controller: _joiningDateController,
                    icon: Iconsax.calendar_1,
                    onTap: () => _selectDate(context, _joiningDateController),
                    readOnly: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Work Details'),
            AppCard(
              child: Column(
                children: [
                  _buildSalaryTypeToggle(),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: _selectedSalaryType == SalaryType.monthly ? 'Monthly Salary' : 'Daily Rate',
                    hint: _selectedSalaryType == SalaryType.monthly ? '₹ 0.00' : '₹ 0.00 / day',
                    controller: _salaryController,
                    icon: Iconsax.card,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Work Shift',
                    hint: 'e.g. Day Shift, 9am - 6pm',
                    controller: _shiftController,
                    icon: Iconsax.clock,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Documents Upload'),
            _buildStaffDocumentSection(
              'Aadhar Card',
              null,
              () {},
              noController: _aadharNoController,
              noLabel: 'Aadhar Number',
              previewUrl: 'https://images.unsplash.com/photo-1579389083395-4507e9f4a171?q=80&w=200',
              fileName: 'aadhar_${staff.name.toLowerCase().replaceAll(' ', '_')}.pdf',
            ),
            if (_selectedRole == StaffRole.driver) ...[
              const SizedBox(height: 12),
              _buildStaffDocumentSection(
                'PAN Card',
                null,
                () {},
                noController: _panNoController,
                noLabel: 'PAN Number',
                previewUrl: staff.panNumber != null ? 'https://images.unsplash.com/photo-1589156229687-496a31ad1d1f?q=80&w=200' : null,
                fileName: staff.panNumber != null ? 'pan_${staff.name.toLowerCase().replaceAll(' ', '_')}.pdf' : null,
              ),
              const SizedBox(height: 12),
              _buildStaffDocumentSection(
                'Driving License',
                null,
                () {},
                noController: _licenseNoController,
                noLabel: 'License Number',
                expiryController: _licenseExpiryController,
                previewUrl: staff.licenseNumber != null ? 'https://images.unsplash.com/photo-1590218126027-3934f8285517?q=80&w=200' : null,
                fileName: staff.licenseNumber != null ? 'license_${staff.name.toLowerCase().replaceAll(' ', '_')}.pdf' : null,
              ),
              const SizedBox(height: 12),
              _buildStaffDocumentSection(
                'Badge Number',
                null,
                () {},
                noController: _badgeNoController,
                noLabel: 'Badge Number',
                expiryController: _badgeExpiryController,
                previewUrl: staff.badgeNumber != null ? 'https://images.unsplash.com/photo-1594819047050-99defca82545?q=80&w=200' : null,
                fileName: staff.badgeNumber != null ? 'badge_${staff.name.toLowerCase().replaceAll(' ', '_')}.pdf' : null,
              ),
              const SizedBox(height: 12),
              _buildStaffDocumentSection(
                'Bank Passbook',
                null,
                () {},
                previewUrl: staff.bankPassbookUrl ?? 'https://images.unsplash.com/photo-1501167786227-4cba60f6d58f?q=80&w=200',
              ),
              const SizedBox(height: 12),
              _buildStaffDocumentSection(
                'Passport Size Photo',
                null,
                () {},
                previewUrl: staff.photoUrl ?? 'https://images.unsplash.com/photo-1633332755192-727a05c4013d?q=80&w=200',
              ),
            ] else ...[
              const SizedBox(height: 12),
              _buildStaffDocumentSection(
                'Profile Photo',
                null,
                () {},
                previewUrl: staff.photoUrl ?? 'https://images.unsplash.com/photo-1633332755192-727a05c4013d?q=80&w=200',
              ),
            ],
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

  Widget _buildSalaryTypeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText('Salary Type', style: AppTextStyle.label),
        const SizedBox(height: 8),
        Container(
          height: 45,
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate200),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSalaryType = SalaryType.monthly),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _selectedSalaryType == SalaryType.monthly ? AppColors.primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppText(
                      'Monthly', 
                      style: AppTextStyle.body, 
                      color: _selectedSalaryType == SalaryType.monthly ? Colors.white : AppColors.textColorSecondary,
                      fontWeight: _selectedSalaryType == SalaryType.monthly ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSalaryType = SalaryType.daily),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _selectedSalaryType == SalaryType.daily ? AppColors.primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppText(
                      'Daily', 
                      style: AppTextStyle.body, 
                      color: _selectedSalaryType == SalaryType.daily ? Colors.white : AppColors.textColorSecondary,
                      fontWeight: _selectedSalaryType == SalaryType.daily ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Widget _buildStaffDocumentSection(
    String label,
    dynamic file, // Can be PlatformFile or null
    VoidCallback onUpload, {
    TextEditingController? expiryController,
    TextEditingController? noController,
    String? noLabel,
    String? previewUrl,
    String? fileName,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.document_text, size: 18, color: AppColors.primaryColor),
              ),
              const SizedBox(width: 12),
              AppText(label, style: AppTextStyle.subheading, fontSize: 14, color: AppColors.textColorPrimary, fontWeight: FontWeight.w600),
            ],
          ),
          const SizedBox(height: 16),
          UploadBox(
            label: 'Photo Copy',
            isUploaded: file != null || previewUrl != null,
            previewUrl: previewUrl,
            fileName: fileName,
            onTap: onUpload,
          ),
          if (noController != null) ...[
            const SizedBox(height: 16),
            AppInputField(
              label: noLabel ?? 'Document Number',
              hint: 'Enter Number',
              controller: noController,
              icon: Iconsax.hashtag,
            ),
          ],
          if (expiryController != null) ...[
            const SizedBox(height: 16),
            AppInputField(
              label: 'Expiry Date',
              hint: 'DD/MM/YYYY',
              controller: expiryController,
              readOnly: true,
              icon: Iconsax.calendar_1,
              onTap: () => _selectDate(context, expiryController),
            ),
          ],
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
