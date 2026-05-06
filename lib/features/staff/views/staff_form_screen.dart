import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
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
import '../../../core/utils/custom_snackbar.dart';
import '../domain/models/staff_model.dart';
import '../../roles/controllers/role_controller.dart';
import '../../roles/domain/models/role_model.dart';
import '../../shifts/controllers/shift_controller.dart';
import '../../shifts/domain/models/shift_model.dart';

class StaffFormScreen extends StatefulWidget {
  const StaffFormScreen({Key? key}) : super(key: key);

  @override
  State<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends State<StaffFormScreen> {
  final StaffModel? staff = Get.arguments is StaffModel ? Get.arguments : null;
  
  final _staffController = Get.find<StaffController>();
  final _roleController = Get.isRegistered<RoleController>() ? Get.find<RoleController>() : Get.put(RoleController());
  final _shiftController = Get.isRegistered<ShiftController>() ? Get.find<ShiftController>() : Get.put(ShiftController());

  String? _selectedRoleId;
  int? _selectedShiftId;
  SalaryType _selectedSalaryType = SalaryType.monthly;

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

  PlatformFile? aadharFile;
  PlatformFile? panFile;
  PlatformFile? licenseFile;
  PlatformFile? badgeFile;
  PlatformFile? passbookFile;
  PlatformFile? photoFile;

  bool get _isEdit => staff != null;
  bool get _isDriver {
    final role = _roleController.roles.firstWhereOrNull((r) => r.id == _selectedRoleId);
    return role?.roleName.toLowerCase() == 'driver';
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    if (_isEdit) {
      _nameController.text = staff!.name;
      _emailController.text = staff!.email;
      _addressController.text = staff!.address;
      _joiningDateController.text = staff!.joiningDate != null ? '${staff!.joiningDate!.year}-${staff!.joiningDate!.month.toString().padLeft(2, '0')}-${staff!.joiningDate!.day.toString().padLeft(2, '0')}' : '';
      _aadharNoController.text = staff!.aadharNumber ?? '';
      _panNoController.text = staff!.panNumber ?? '';
      _salaryController.text = staff!.salary.toString();
      _selectedSalaryType = staff!.salaryType;
      _licenseNoController.text = staff!.licenseNumber ?? '';
      _licenseExpiryController.text = staff!.licenseExpiry != null ? '${staff!.licenseExpiry!.year}-${staff!.licenseExpiry!.month.toString().padLeft(2, '0')}-${staff!.licenseExpiry!.day.toString().padLeft(2, '0')}' : '';
      _badgeNoController.text = staff!.badgeNumber ?? '';
      _badgeExpiryController.text = staff!.badgeExpiry != null ? '${staff!.badgeExpiry!.year}-${staff!.badgeExpiry!.month.toString().padLeft(2, '0')}-${staff!.badgeExpiry!.day.toString().padLeft(2, '0')}' : '';

      if (staff!.phone.startsWith('+91')) {
        _staffController.selectedCountryCode.value = '+91';
        _phoneController.text = staff!.phone.substring(3).trim();
      } else {
        _phoneController.text = staff!.phone;
      }
    }

    await _roleController.fetchRoles();
    if (_isEdit && staff!.roleId != null) {
      final matchedRole = _roleController.roles.firstWhereOrNull(
        (r) => r.id == staff!.roleId || r.roleName.toLowerCase() == staff!.roleId!.toLowerCase(),
      );
      _selectedRoleId = matchedRole?.id;
    } else if (!_isEdit && _roleController.roles.isNotEmpty) {
      // Default to Driver for new staff if available
      final driverRole = _roleController.roles.firstWhereOrNull((r) => r.roleName.toLowerCase() == 'driver')
          ?? _roleController.roles.first;
      _selectedRoleId = driverRole.id;
    }

    await _shiftController.refreshShifts();
    if (_isEdit) {
      if (staff!.shiftId != null) {
        final matchedShift = _shiftController.shifts.firstWhereOrNull((s) => s.id.toString() == staff!.shiftId);
        _selectedShiftId = matchedShift?.id;
      } else if (staff!.shiftName != null) {
        final matchedShift = _shiftController.shifts.firstWhereOrNull((s) => s.name.toLowerCase() == staff!.shiftName!.toLowerCase());
        _selectedShiftId = matchedShift?.id;
      }
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

  Future<void> _pickDocument(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        if (type == 'aadhar') aadharFile = result.files.first;
        if (type == 'pan') panFile = result.files.first;
        if (type == 'license') licenseFile = result.files.first;
        if (type == 'badge') badgeFile = result.files.first;
        if (type == 'passbook') passbookFile = result.files.first;
        if (type == 'photo') photoFile = result.files.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: _isEdit ? 'Edit Staff' : 'Add Staff',
        subtitle: _isEdit ? staff!.name : 'Register new employee',
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
                  _buildRoleDropdown(),
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
                  _buildShiftDropdown(),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Documents Upload'),
            _buildStaffDocumentSection(
              'Aadhar Card',
              aadharFile,
              () => _pickDocument('aadhar'),
              noController: _aadharNoController,
              noLabel: 'Aadhar Number',
              previewUrl: _isEdit ? staff!.photoUrl : null,
            ),
            const SizedBox(height: 12),
            _buildStaffDocumentSection(
              'PAN Card',
              panFile,
              () => _pickDocument('pan'),
              noController: _panNoController,
              noLabel: 'PAN Number',
              previewUrl: null,
              fileName: _isEdit && staff!.panNumber != null ? 'pan_${staff!.name.toLowerCase().replaceAll(' ', '_')}.pdf' : null,
            ),
            const SizedBox(height: 12),
            _buildStaffDocumentSection(
              'Driving License',
              licenseFile,
              () => _pickDocument('license'),
              expiryController: _licenseExpiryController,
              noController: _licenseNoController,
              noLabel: 'License Number',
              previewUrl: null,
              fileName: _isEdit && staff!.licenseNumber != null ? 'license_${staff!.name.toLowerCase().replaceAll(' ', '_')}.pdf' : null,
            ),
            const SizedBox(height: 12),
            _buildStaffDocumentSection(
              'Badge Number',
              badgeFile,
              () => _pickDocument('badge'),
              expiryController: _badgeExpiryController,
              noController: _badgeNoController,
              noLabel: 'Badge Number',
              previewUrl: null,
              fileName: _isEdit && staff!.badgeNumber != null ? 'badge_${staff!.name.toLowerCase().replaceAll(' ', '_')}.pdf' : null,
            ),
            const SizedBox(height: 12),
            _buildStaffDocumentSection(
              'Bank Passbook',
              passbookFile,
              () => _pickDocument('passbook'),
              previewUrl: _isEdit ? staff!.bankPassbookUrl : null,
            ),
            const SizedBox(height: 12),
            _buildStaffDocumentSection(
              'Profile Photo',
              photoFile,
              () => _pickDocument('photo'),
              previewUrl: _isEdit ? staff!.photoUrl : null,
            ),
            const SizedBox(height: 32),
            Obx(() => AppButton(
              text: _isEdit ? 'Update Staff' : 'Save Staff',
              isLoading: _staffController.isLoading.value,
              onPressed: () => _handleSubmit(),
            )),
            if (_isEdit) ...[
              const SizedBox(height: 12),
              AppButton.outline(
                text: 'Delete Staff',
                color: AppColors.errorColor,
                onPressed: () => _showDeleteConfirmation(),
              ),
            ] else ...[
              const SizedBox(height: 12),
              AppButton.outline(
                text: 'Cancel',
                onPressed: () => Get.back(),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (_selectedRoleId == null) {
      CustomSnackbar.showError('Please select a role');
      return;
    }
    if (_selectedShiftId == null) {
      CustomSnackbar.showError('Please select a work shift');
      return;
    }

    final Map<String, dynamic> data = {
      'name': _nameController.text,
      'phone': '${_staffController.selectedCountryCode.value}${_phoneController.text}',
      'email': _emailController.text,
      'staff_type': _selectedRoleId,
      'salary_type': _selectedSalaryType.name,
      'basic_salary': _salaryController.text,
      'work_shift': _selectedShiftId,
      'date_of_joining': _joiningDateController.text,
      'address': _addressController.text,
      'aadhar_number': _aadharNoController.text,
      'pan_number': _panNoController.text,
      'dl_number': _licenseNoController.text,
      'dl_expiry': _licenseExpiryController.text,
      'badge_number': _badgeNoController.text,
      'badge_expiry': _badgeExpiryController.text,
      'aadhar_file': aadharFile?.path,
      'pan_file': panFile?.path,
      'dl_file': licenseFile?.path,
      'badge_file': badgeFile?.path,
      'passbook_file': passbookFile?.path,
      'photo_file': photoFile?.path,
    };

    data.forEach((key, value) {
      print('$key : $value');
    });

    bool success;
    if (_isEdit) {
      success = await _staffController.updateStaff(staff!.id, data);
    } else {
      success = await _staffController.addStaff(data);
    }

    if (success) {
      Navigator.pop(context);
      CustomSnackbar.showSuccess(_isEdit ? 'Staff updated successfully' : 'Staff added successfully');
    }
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText('Select Role', style: AppTextStyle.label),
        const SizedBox(height: 8),
        Obx(() {
          // Deduplicate roles by ID to avoid Flutter dropdown assertion crash
          final uniqueRoles = <String, RoleModel>{};
          for (final role in _roleController.roles) {
            uniqueRoles[role.id] = role;
          }
          final roleList = uniqueRoles.values.toList();

          // Ensure selectedId exists in the current list
          final validId = roleList.any((r) => r.id == _selectedRoleId)
              ? _selectedRoleId
              : null;

          return DropdownButtonFormField<String>(
            value: validId,
            hint: const Text('Select Role'),
            items: roleList.map((role) {
              return DropdownMenuItem<String>(
                value: role.id,
                child: Text(role.roleName),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedRoleId = val),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.slate50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.slate200),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildShiftDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText('Work Shift', style: AppTextStyle.label),
        const SizedBox(height: 8),
        Obx(() {
          // Deduplicate shifts by ID
          final uniqueShifts = <int, ShiftModel>{};
          for (final shift in _shiftController.shifts) {
            if (shift.id != null) uniqueShifts[shift.id!] = shift;
          }
          final shiftList = uniqueShifts.values.toList();

          // Ensure selectedId exists in the current list
          final validId = shiftList.any((s) => s.id == _selectedShiftId)
              ? _selectedShiftId
              : null;

          return DropdownButtonFormField<int>(
            value: validId,
            hint: const Text('Select Work Shift'),
            items: shiftList.map((shift) {
              return DropdownMenuItem<int>(
                value: shift.id,
                child: Text(shift.name),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedShiftId = val),
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
          );
        }),
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
      firstDate: DateTime(1950),
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
    PlatformFile? file,
    VoidCallback onUpload, {
    TextEditingController? expiryController,
    TextEditingController? noController,
    String? noLabel,
    String? previewUrl,
    String? fileName,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
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
            fileName: file?.name ?? fileName,
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
