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
import '../domain/models/staff_model.dart';
import '../../roles/controllers/role_controller.dart';
import '../../roles/domain/models/role_model.dart';
import '../../shifts/controllers/shift_controller.dart';
import '../../shifts/domain/models/shift_model.dart';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({Key? key}) : super(key: key);

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _controller = Get.find<StaffController>();
  final _roleController = Get.isRegistered<RoleController>() 
      ? Get.find<RoleController>() 
      : Get.put(RoleController());
  final _shiftController = Get.isRegistered<ShiftController>()
      ? Get.find<ShiftController>()
      : Get.put(ShiftController());
      
  final _formKey = GlobalKey<FormState>();
  RoleModel? _selectedRole;
  ShiftModel? _selectedShift;
  SalaryType _selectedSalaryType = SalaryType.monthly;

  PlatformFile? aadharFile;
  PlatformFile? panFile;
  PlatformFile? licenseFile;
  PlatformFile? badgeFile;
  PlatformFile? passbookFile;
  PlatformFile? photoFile;

  // Controllers for the fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _joiningDateController = TextEditingController();
  final _aadharNoController = TextEditingController();
  final _panNoController = TextEditingController();
  final _salaryController = TextEditingController();
  final _licenseNoController = TextEditingController();
  final _licenseExpiryController = TextEditingController();
  final _badgeNoController = TextEditingController();
  final _badgeExpiryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _roleController.fetchRoles();
    _shiftController.refreshShifts();
  }

  Future<void> _pickDocument(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf', 'doc', 'docx'],
    );
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
        title: 'Add Staff',
        subtitle: 'Register new employee',
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
                    validator: (v) => v!.isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  Obx(() => AppInputField(
                    label: 'Phone Number',
                    hint: 'Enter mobile number',
                    controller: _phoneController,
                    icon: Iconsax.call,
                    keyboardType: TextInputType.phone,
                    phoneCode: _controller.selectedCountryCode.value,
                    onPhoneCodeTap: () => PhoneHelper.showCountryPicker(
                      context: context,
                      selectedCode: _controller.selectedCountryCode,
                    ),
                    validator: (v) {
                      if (v!.isEmpty) return 'Phone number is required';
                      if (v.length < 10) return 'Invalid phone number';
                      return null;
                    },
                  )),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Email Address',
                    hint: 'name@agency.com',
                    controller: _emailController,
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v!.isEmpty) return 'Email is required';
                      if (!GetUtils.isEmail(v)) return 'Invalid email format';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Obx(() => _buildRoleDropdown()),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
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
                    validator: (v) => v!.isEmpty ? 'Address is required' : null,
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Joining Date',
                    hint: 'YYYY-MM-DD',
                    controller: _joiningDateController,
                    readOnly: true,
                    onTap: () => _selectDate(context, _joiningDateController),
                    icon: Iconsax.calendar_1,
                    validator: (v) => v!.isEmpty ? 'Joining date is required' : null,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
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
                    validator: (v) => v!.isEmpty ? 'Salary is required' : null,
                  ),
                  const SizedBox(height: 16),
                  Obx(() => _buildShiftDropdown()),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            _buildSectionTitle('Documents Upload'),
            _buildStaffDocumentSection(
              'Aadhar Card',
              aadharFile,
              () => _pickDocument('aadhar'),
              noController: _aadharNoController,
              noLabel: 'Aadhar Number',
            ),
            const SizedBox(height: 12),
            _buildStaffDocumentSection(
              'PAN Card',
              panFile,
              () => _pickDocument('pan'),
              noController: _panNoController,
              noLabel: 'PAN Number',
            ),
            if (_isDriver) ...[
              const SizedBox(height: 12),
              _buildStaffDocumentSection(
                'Driving License',
                licenseFile,
                () => _pickDocument('license'),
                expiryController: _licenseExpiryController,
                noController: _licenseNoController,
                noLabel: 'License Number',
              ),
              const SizedBox(height: 12),
              _buildStaffDocumentSection(
                'Badge Number',
                badgeFile,
                () => _pickDocument('badge'),
                expiryController: _badgeExpiryController,
                noController: _badgeNoController,
                noLabel: 'Badge Number',
              ),
            ],
            const SizedBox(height: 12),
            _buildStaffDocumentSection(
              'Bank Passbook',
              passbookFile,
              () => _pickDocument('passbook'),
            ),
            const SizedBox(height: 12),
            _buildStaffDocumentSection(
              'Profile Photo',
              photoFile,
              () => _pickDocument('photo'),
            ),
            const SizedBox(height: 32),
            Obx(() => AppButton(
              text: 'Save Staff',
              isLoading: _controller.isLoading.value,
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
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
                    'phone': '${_controller.selectedCountryCode.value}${_phoneController.text}',
                    'email': _emailController.text,
                    'staff_type': _selectedRole!.id,
                    'salary_type': _selectedSalaryType.name,
                    'basic_salary': _salaryController.text,
                    'work_shift': _selectedShift!.id,
                    'date_of_joining': _joiningDateController.text,
                    'address': _addressController.text,
                    'aadhar_number': _aadharNoController.text,
                    'aadhar_file': aadharFile?.path,
                    'pan_number': _panNoController.text,
                    'pan_file': panFile?.path,
                    'dl_number': _licenseNoController.text,
                    'dl_expiry': _licenseExpiryController.text,
                    'dl_file': licenseFile?.path,
                    'badge_number': _badgeNoController.text,
                    'badge_expiry': _badgeExpiryController.text,
                    'badge_file': badgeFile?.path,
                    'passbook_file': passbookFile?.path,
                    'photo_file': photoFile?.path,
                  };

                  final success = await _controller.addStaff(data);
                  if (success) {
                    Get.back();
                    Get.snackbar('Success', 'Staff added successfully', backgroundColor: AppColors.successColor, colorText: Colors.white);
                  }
                }
              },
            )),
            const SizedBox(height: 12),
            AppButton.outline(
              text: 'Cancel',
              onPressed: () => Get.back(),
            ),
            const SizedBox(height: 32),
          ],
        ),
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
          validator: (v) => v == null ? 'Role is required' : null,
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
          validator: (v) => v == null ? 'Shift is required' : null,
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

  Widget _buildStaffDocumentSection(
    String label,
    PlatformFile? file,
    VoidCallback onUpload, {
    TextEditingController? expiryController,
    TextEditingController? noController,
    String? noLabel,
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
            isUploaded: file != null,
            localPath: file?.path,
            fileName: file?.name,
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
