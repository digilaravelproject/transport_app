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
import '../../roles/controllers/role_controller.dart';
import '../../roles/domain/models/role_model.dart';
import '../../shifts/controllers/shift_controller.dart';
import '../../shifts/domain/models/shift_model.dart';

class EditStaffScreen extends StatefulWidget {
  const EditStaffScreen({Key? key}) : super(key: key);

  @override
  State<EditStaffScreen> createState() => _EditStaffScreenState();
}

class _EditStaffScreenState extends State<EditStaffScreen> {
  final StaffModel staff = Get.arguments ?? Get.find<StaffController>().staffList.first;
  final _roleController = Get.isRegistered<RoleController>() 
      ? Get.find<RoleController>() 
      : Get.put(RoleController());
  final _shiftController = Get.isRegistered<ShiftController>()
      ? Get.find<ShiftController>()
      : Get.put(ShiftController());
      
  RoleModel? _selectedRole;
  ShiftModel? _selectedShift;
  late SalaryType _selectedSalaryType;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _joiningDateController = TextEditingController();
  final TextEditingController _aadharNoController = TextEditingController();
  final TextEditingController _panNoController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _licenseNoController = TextEditingController();
  final TextEditingController _licenseExpiryController = TextEditingController();
  final TextEditingController _badgeNoController = TextEditingController();
  final TextEditingController _badgeExpiryController = TextEditingController();
  final _staffController = Get.find<StaffController>();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    _selectedSalaryType = staff.salaryType;
    _nameController.text = staff.name;
    _emailController.text = staff.email;
    _addressController.text = staff.address;
    _joiningDateController.text = staff.joiningDate != null ? '${staff.joiningDate!.year}-${staff.joiningDate!.month.toString().padLeft(2, '0')}-${staff.joiningDate!.day.toString().padLeft(2, '0')}' : '';
    _aadharNoController.text = staff.aadharNumber ?? '';
    _panNoController.text = staff.panNumber ?? '';
    _salaryController.text = staff.salary.toString();
    _licenseNoController.text = staff.licenseNumber ?? '';
    _licenseExpiryController.text = staff.licenseExpiry != null ? '${staff.licenseExpiry!.year}-${staff.licenseExpiry!.month.toString().padLeft(2, '0')}-${staff.licenseExpiry!.day.toString().padLeft(2, '0')}' : '';
    _badgeNoController.text = staff.badgeNumber ?? '';
    _badgeExpiryController.text = staff.badgeExpiry != null ? '${staff.badgeExpiry!.year}-${staff.badgeExpiry!.month.toString().padLeft(2, '0')}-${staff.badgeExpiry!.day.toString().padLeft(2, '0')}' : '';

    // Parse phone number
    if (staff.phone.startsWith('+91')) {
      _staffController.selectedCountryCode.value = '+91';
      _phoneController.text = staff.phone.substring(3).trim();
    } else {
      _phoneController.text = staff.phone;
    }

    // Fetch roles and select the current one
    await _roleController.fetchRoles();
    if (staff.roleId != null) {
      _selectedRole = _roleController.roles.firstWhereOrNull((r) => r.id == staff.roleId || r.roleName.toLowerCase() == staff.roleId!.toLowerCase());
    }

    // Fetch shifts and select the current one
    await _shiftController.refreshShifts();
    if (staff.shiftId != null) {
      _selectedShift = _shiftController.shifts.firstWhereOrNull((s) => s.id.toString() == staff.shiftId);
    } else if (staff.shiftName != null) {
      _selectedShift = _shiftController.shifts.firstWhereOrNull((s) => s.name.toLowerCase() == staff.shiftName!.toLowerCase());
    }

    setState(() {});
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
    _licenseNoController.dispose();
    _licenseExpiryController.dispose();
    _badgeNoController.dispose();
    _badgeExpiryController.dispose();
    super.dispose();
  }

  bool get _isDriver => _selectedRole?.roleName.toLowerCase() == 'driver';

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
                  Obx(() => _buildRoleDropdown()),
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
                    hint: 'YYYY-MM-DD',
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
                  Obx(() => _buildShiftDropdown()),
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
              previewUrl: staff.photoUrl,
              fileName: 'aadhar_${staff.name.toLowerCase().replaceAll(' ', '_')}.pdf',
            ),
            const SizedBox(height: 12),
            _buildStaffDocumentSection(
              'PAN Card',
              null,
              () {},
              noController: _panNoController,
              noLabel: 'PAN Number',
              previewUrl: null,
              fileName: staff.panNumber != null ? 'pan_${staff.name.toLowerCase().replaceAll(' ', '_')}.pdf' : null,
            ),
            if (_isDriver) ...[
              const SizedBox(height: 12),
              _buildStaffDocumentSection(
                'Driving License',
                null,
                () {},
                noController: _licenseNoController,
                noLabel: 'License Number',
                expiryController: _licenseExpiryController,
                previewUrl: null,
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
                previewUrl: null,
                fileName: staff.badgeNumber != null ? 'badge_${staff.name.toLowerCase().replaceAll(' ', '_')}.pdf' : null,
              ),
            ],
            const SizedBox(height: 12),
            _buildStaffDocumentSection(
              'Bank Passbook',
              null,
              () {},
              previewUrl: staff.bankPassbookUrl,
            ),
            const SizedBox(height: 12),
            _buildStaffDocumentSection(
              'Profile Photo',
              null,
              () {},
              previewUrl: staff.photoUrl,
            ),
            const SizedBox(height: 32),
            Obx(() => AppButton(
              text: 'Update Staff',
              isLoading: _staffController.isLoading.value,
              onPressed: () async {
                if (_selectedRole == null) {
                  Get.snackbar('Error', 'Please select a role', backgroundColor: AppColors.errorColor, colorText: Colors.white);
                  return;
                }
                if (_selectedShift == null) {
                  Get.snackbar('Error', 'Please select a work shift', backgroundColor: AppColors.errorColor, colorText: Colors.white);
                  return;
                }
                final Map<String, dynamic> data = {
                  'name': _nameController.text,
                  'phone': '${_staffController.selectedCountryCode.value}${_phoneController.text}',
                  'email': _emailController.text,
                  'staff_type': _selectedRole!.id,
                  'salary_type': _selectedSalaryType.name,
                  'basic_salary': _salaryController.text,
                  'work_shift': _selectedShift!.id,
                  'date_of_joining': _joiningDateController.text,
                  'address': _addressController.text,
                  'aadhar_number': _aadharNoController.text,
                  'pan_number': _panNoController.text,
                  'dl_number': _licenseNoController.text,
                  'dl_expiry': _licenseExpiryController.text,
                  'badge_number': _badgeNoController.text,
                  'badge_expiry': _badgeExpiryController.text,
                };

                final success = await _staffController.updateStaff(staff.id, data);
                if (success) {
                  Get.back();
                  Get.snackbar('Success', 'Staff updated successfully', backgroundColor: AppColors.successColor, colorText: Colors.white);
                }
              },
            )),
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

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText('Select Role', style: AppTextStyle.label),
        const SizedBox(height: 8),
        DropdownButtonFormField<RoleModel>(
          value: _selectedRole,
          hint: const Text('Select Role'),
          items: _roleController.roles.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(role.roleName),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedRole = val),
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

  Widget _buildShiftDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText('Work Shift', style: AppTextStyle.label),
        const SizedBox(height: 8),
        DropdownButtonFormField<ShiftModel>(
          value: _selectedShift,
          hint: const Text('Select Work Shift'),
          items: _shiftController.shifts.map((shift) {
            return DropdownMenuItem(
              value: shift,
              child: Text(shift.name),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedShift = val),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.slate50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.slate200),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            prefixIcon: const Icon(Iconsax.clock, size: 20),
          ),
        ),
      ],
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
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
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
            isUploaded: file != null || (previewUrl != null && previewUrl.isNotEmpty),
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
              hint: 'YYYY-MM-DD',
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
