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
import '../../../core/utils/app_validators.dart';

class StaffFormScreen extends StatefulWidget {
  const StaffFormScreen({Key? key}) : super(key: key);

  @override
  State<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends State<StaffFormScreen> {
  StaffModel? staff = Get.arguments is StaffModel ? Get.arguments : null;
  
  final _staffController = Get.find<StaffController>();
  final _roleController = Get.isRegistered<RoleController>() ? Get.find<RoleController>() : Get.put(RoleController());
  final _shiftController = Get.isRegistered<ShiftController>() ? Get.find<ShiftController>() : Get.put(ShiftController());

  final _formKey = GlobalKey<FormState>();

  String? _selectedRoleId;
  int? _selectedShiftId;
  SalaryType _selectedSalaryType = SalaryType.monthly;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _joiningDateController = TextEditingController();
  
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _emergencyContactNameController = TextEditingController();
  final RxString _emergencyCountryCode = '+91'.obs;

  final TextEditingController _aadharNoController = TextEditingController();
  final TextEditingController _panNoController = TextEditingController();
  final TextEditingController _licenseNoController = TextEditingController();
  final TextEditingController _licenseTypeController = TextEditingController();
  final TextEditingController _licenseExpiryController = TextEditingController();
  final TextEditingController _badgeNoController = TextEditingController();
  final TextEditingController _badgeExpiryController = TextEditingController();
  
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _bankIfscController = TextEditingController();
  
  final TextEditingController _salaryController = TextEditingController(text: '0');
  final TextEditingController _daController = TextEditingController(text: '0');
  final TextEditingController _hraController = TextEditingController(text: '0');
  final TextEditingController _otherAllowanceController = TextEditingController(text: '0');
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _assignedVehicleController = TextEditingController();

  PlatformFile? aadharFile;
  PlatformFile? panFile;
  PlatformFile? licenseFile;
  PlatformFile? badgeFile;
  PlatformFile? passbookFile;
  PlatformFile? photoFile;

  // Document Error States
  String? aadharFileError;
  String? panFileError;
  String? licenseFileError;
  String? badgeFileError;
  String? passbookFileError;
  String? photoFileError;

  bool get _isEdit => staff != null;
  bool get _isDriver {
    if (_selectedRoleId == null) return false;
    final role = _roleController.roles.firstWhereOrNull((r) => r.id.toString() == _selectedRoleId.toString());
    return role?.roleName.toLowerCase() == 'driver';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  void _initData() async {
    if (_isEdit) {
      // Fetch latest staff details to ensure all documents are loaded
      final detailedStaff = await _staffController.getStaffDetails(staff!.id);
      if (detailedStaff != null && mounted) {
        setState(() {
          staff = detailedStaff;
        });
      }

      if (!mounted) return;

      _nameController.text = staff!.name;
      _emailController.text = staff!.email;
      _addressController.text = staff!.address;
      _dobController.text = staff!.dob != null ? '${staff!.dob!.year}-${staff!.dob!.month.toString().padLeft(2, '0')}-${staff!.dob!.day.toString().padLeft(2, '0')}' : '';
      _joiningDateController.text = staff!.joiningDate != null ? '${staff!.joiningDate!.year}-${staff!.joiningDate!.month.toString().padLeft(2, '0')}-${staff!.joiningDate!.day.toString().padLeft(2, '0')}' : '';
      _aadharNoController.text = staff!.aadharNumber ?? '';
      _panNoController.text = staff!.panNumber ?? '';
      
      _salaryController.text = staff!.salary == staff!.salary.toInt() ? staff!.salary.toInt().toString() : staff!.salary.toString();
      _selectedSalaryType = staff!.salaryType;
      
      _licenseNoController.text = staff!.licenseNumber ?? '';
      _licenseExpiryController.text = staff!.licenseExpiry != null ? '${staff!.licenseExpiry!.year}-${staff!.licenseExpiry!.month.toString().padLeft(2, '0')}-${staff!.licenseExpiry!.day.toString().padLeft(2, '0')}' : '';
      _badgeNoController.text = staff!.badgeNumber ?? '';
      _badgeExpiryController.text = staff!.badgeExpiry != null ? '${staff!.badgeExpiry!.year}-${staff!.badgeExpiry!.month.toString().padLeft(2, '0')}-${staff!.badgeExpiry!.day.toString().padLeft(2, '0')}' : '';
      
      _bankNameController.text = staff!.bankName ?? '';
      _bankAccountController.text = staff!.bankAccount ?? '';
      _bankIfscController.text = staff!.bankIfsc ?? '';
      _emergencyContactNameController.text = staff!.emergencyContactName ?? '';
      _notesController.text = staff!.notes ?? '';
      _assignedVehicleController.text = staff!.assignedVehicleNumber ?? '';
      _otherAllowanceController.text = staff!.otherAllowance?.toString() ?? '0';
      
      // Split emergency contact if it starts with +
      String emergency = staff!.emergencyContact ?? '';
      if (emergency.startsWith('+')) {
        if (emergency.startsWith('+91')) {
          _emergencyCountryCode.value = '+91';
          _emergencyContactController.text = emergency.substring(3).trim();
        } else {
          _emergencyContactController.text = emergency;
        }
      } else {
        _emergencyContactController.text = emergency;
      }

      _daController.text = staff!.daPerDay != null 
          ? (staff!.daPerDay == staff!.daPerDay!.toInt() ? staff!.daPerDay!.toInt().toString() : staff!.daPerDay!.toString()) 
          : '0';
      _hraController.text = staff!.hra != null 
          ? (staff!.hra == staff!.hra!.toInt() ? staff!.hra!.toInt().toString() : staff!.hra!.toString()) 
          : '0';
      _licenseTypeController.text = staff!.licenseType ?? '';

      if (staff!.phone.startsWith('+91')) {
        _staffController.selectedCountryCode.value = '+91';
        _phoneController.text = staff!.phone.substring(3).trim();
      } else {
        _phoneController.text = staff!.phone;
      }
    }

    await _roleController.fetchRoles();
    if (!mounted) return;
    if (_isEdit && staff!.roleId != null) {
      final matchedRole = _roleController.roles.firstWhereOrNull(
        (r) => r.id.toString() == staff!.roleId.toString() || r.roleName.toLowerCase() == staff!.roleId!.toString().toLowerCase(),
      );
      _selectedRoleId = matchedRole?.id;
    } else if (!_isEdit && _roleController.roles.isNotEmpty) {
      final driverRole = _roleController.roles.firstWhereOrNull((r) => r.roleName.toLowerCase() == 'driver')
          ?? _roleController.roles.first;
      _selectedRoleId = driverRole.id;
    }

    await _shiftController.refreshShifts();
    if (!mounted) return;
    if (_isEdit) {
      if (staff!.shiftId != null) {
        final matchedShift = _shiftController.shifts.firstWhereOrNull((s) => s.id.toString() == staff!.shiftId.toString());
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
    _dobController.dispose();
    _joiningDateController.dispose();
    _emergencyContactController.dispose();
    _emergencyContactNameController.dispose();
    _aadharNoController.dispose();
    _panNoController.dispose();
    _salaryController.dispose();
    _daController.dispose();
    _hraController.dispose();
    _bankNameController.dispose();
    _bankAccountController.dispose();
    _bankIfscController.dispose();
    _licenseNoController.dispose();
    _licenseExpiryController.dispose();
    _licenseTypeController.dispose();
    _badgeNoController.dispose();
    _badgeExpiryController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        if (type == 'aadhar') {
          aadharFile = result.files.first;
          aadharFileError = null;
        }
        if (type == 'pan') {
          panFile = result.files.first;
          panFileError = null;
        }
        if (type == 'license') {
          licenseFile = result.files.first;
          licenseFileError = null;
        }
        if (type == 'badge') {
          badgeFile = result.files.first;
          badgeFileError = null;
        }
        if (type == 'passbook') {
          passbookFile = result.files.first;
          passbookFileError = null;
        }
        if (type == 'photo') {
          photoFile = result.files.first;
          photoFileError = null;
        }
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
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Basic Information'),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppInputField(
                      label: 'Full Name',
                      hint: 'Enter full name',
                      controller: _nameController,
                      icon: Iconsax.user,
                      validator: (v) => AppValidators.validateEmpty(v, fieldName: 'Full Name'),
                    ),
                    const SizedBox(height: 12),
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
                      validator: (v) => AppValidators.validateMobile(v),
                    )),
                    const SizedBox(height: 12),
                    AppInputField(
                      label: 'Email Address',
                      hint: 'name@agency.com',
                      controller: _emailController,
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => AppValidators.validateEmail(v),
                    ),
                    const SizedBox(height: 12),
                    _buildRoleDropdown(),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              _buildSectionTitle('Personal Details'),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppInputField(
                      label: 'Date of Birth',
                      hint: 'YYYY-MM-DD',
                      controller: _dobController,
                      icon: Iconsax.calendar_1,
                      onTap: () => _selectDate(context, _dobController),
                      readOnly: true,
                      validator: (v) => AppValidators.validateEmpty(v, fieldName: 'DOB'),
                    ),
                    const SizedBox(height: 12),
                    AppInputField(
                      label: 'Joining Date',
                      hint: 'YYYY-MM-DD',
                      controller: _joiningDateController,
                      icon: Iconsax.calendar_tick,
                      onTap: () => _selectDate(context, _joiningDateController),
                      readOnly: true,
                      validator: (v) => AppValidators.validateEmpty(v, fieldName: 'Joining Date'),
                    ),
                    const SizedBox(height: 12),
                    AppInputField(
                      label: 'Permanent Address',
                      hint: 'Full address',
                      controller: _addressController,
                      icon: Iconsax.location,
                      maxLines: 2,
                      validator: (v) => AppValidators.validateEmpty(v, fieldName: 'Address'),
                    ),
                    const SizedBox(height: 12),
                    AppInputField(
                      label: 'Emergency Contact Name',
                      hint: 'Name',
                      controller: _emergencyContactNameController,
                      icon: Iconsax.user_tag,
                    ),
                    const SizedBox(height: 12),
                    Obx(() => AppInputField(
                      label: 'Emergency Contact',
                      hint: 'Phone No.',
                      controller: _emergencyContactController,
                      icon: Iconsax.call_calling,
                      keyboardType: TextInputType.phone,
                      phoneCode: _emergencyCountryCode.value,
                      onPhoneCodeTap: () => PhoneHelper.showCountryPicker(
                        context: context,
                        selectedCode: _emergencyCountryCode,
                      ),
                    )),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              _buildSectionTitle('Salary & Bank Details'),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSalaryTypeToggle(),
                    const SizedBox(height: 12),
                    AppInputField(
                      label: _selectedSalaryType == SalaryType.monthly ? 'Monthly Salary' : 'Daily Rate',
                      hint: '₹ 0.00',
                      controller: _salaryController,
                      icon: Iconsax.card,
                      keyboardType: TextInputType.number,
                      validator: (v) => AppValidators.validateEmpty(v, fieldName: 'Salary'),
                    ),
                    if (_selectedSalaryType == SalaryType.daily) ...[
                      const SizedBox(height: 12),
                      AppInputField(
                        label: 'DA Per Day',
                        hint: '₹ 0.00',
                        controller: _daController,
                        icon: Iconsax.wallet_2,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    if (_selectedSalaryType == SalaryType.monthly) ...[
                      const SizedBox(height: 12),
                      AppInputField(
                        label: 'HRA',
                        hint: '₹ 0.00',
                        controller: _hraController,
                        icon: Iconsax.house_2,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: 12),
                    AppInputField(
                      label: 'Bank Name',
                      hint: 'e.g. SBI, HDFC',
                      controller: _bankNameController,
                      icon: Iconsax.bank,
                    ),
                    const SizedBox(height: 12),
                    AppInputField(
                      label: 'Account Number',
                      hint: 'Enter account no.',
                      controller: _bankAccountController,
                      icon: Iconsax.hashtag,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    AppInputField(
                      label: 'IFSC Code',
                      hint: 'Enter IFSC',
                      controller: _bankIfscController,
                      icon: Iconsax.code,
                    ),
                    const SizedBox(height: 12),
                    const AppText('Bank Passbook', style: AppTextStyle.label),
                    const SizedBox(height: 8),
                    UploadBox(
                      label: 'Passbook Copy',
                      isUploaded: passbookFile != null || (_isEdit && staff!.bankPassbookUrl != null),
                      remoteUrl: _isEdit ? staff!.bankPassbookUrl : null,
                      localPath: passbookFile?.path,
                      fileName: passbookFile?.name,
                      onTap: () => _pickDocument('passbook'),
                    ),
                    if (passbookFileError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 4),
                        child: AppText(passbookFileError!, color: Colors.red, fontSize: 12),
                      ),
                    const SizedBox(height: 12),
                     _buildShiftDropdown(),
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
                keyboardType: TextInputType.number,
                remoteUrl: _isEdit ? staff!.aadharUrl : null,
                fileError: aadharFileError,
              ),
              const SizedBox(height: 8),
              _buildStaffDocumentSection(
                'PAN Card',
                panFile,
                () => _pickDocument('pan'),
                noController: _panNoController,
                noLabel: 'PAN Number',
                remoteUrl: _isEdit ? staff!.panUrl : null,
                fileName: _isEdit && staff!.panNumber != null ? 'pan_${staff!.name.toLowerCase().replaceAll(' ', '_')}.pdf' : null,
                fileError: panFileError,
              ),
              const SizedBox(height: 8),
              _buildStaffDocumentSection(
                'Driving License',
                licenseFile,
                () => _pickDocument('license'),
                expiryController: _licenseExpiryController,
                noController: _licenseNoController,
                noLabel: 'License Number',
                remoteUrl: _isEdit ? staff!.licenseUrl : null,
                fileName: _isEdit && staff!.licenseNumber != null ? 'license_${staff!.name.toLowerCase().replaceAll(' ', '_')}.pdf' : null,
                fileError: licenseFileError,
                extraField: AppInputField(
                  label: 'License Type',
                  hint: 'e.g. Heavy Vehicle, LMV',
                  controller: _licenseTypeController,
                  icon: Iconsax.truck_fast,
                ),
              ),
              const SizedBox(height: 8),
              _buildStaffDocumentSection(
                'Badge Number',
                badgeFile,
                () => _pickDocument('badge'),
                expiryController: _badgeExpiryController,
                noController: _badgeNoController,
                noLabel: 'Badge Number',
                remoteUrl: _isEdit ? staff!.badgeUrl : null,
                fileName: _isEdit && staff!.badgeNumber != null ? 'badge_${staff!.name.toLowerCase().replaceAll(' ', '_')}.pdf' : null,
                fileError: badgeFileError,
              ),
              const SizedBox(height: 8),
              _buildStaffDocumentSection(
                'Profile Photo',
                photoFile,
                () => _pickDocument('photo'),
                remoteUrl: _isEdit ? staff!.photoUrl : null,
                fileError: photoFileError,
              ),
              const SizedBox(height: 24),
              Obx(() => AppButton(
                text: _isEdit ? 'Update Staff' : 'Save Staff',
                isLoading: _staffController.isLoading.value,
                onPressed: () => _handleSubmit(),
              )),
              if (_isEdit) ...[
                const SizedBox(height: 8),
                AppButton.outline(
                  text: 'Delete Staff',
                  color: AppColors.errorColor,
                  onPressed: () => _showDeleteConfirmation(),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    setState(() {
      aadharFileError = null;
      panFileError = null;
      licenseFileError = null;
      badgeFileError = null;
      passbookFileError = null;
      photoFileError = null;
    });

    bool isValid = _formKey.currentState?.validate() ?? false;

    if (aadharFile == null && !_isEdit) {
      setState(() => aadharFileError = 'Aadhar Card document is required');
      isValid = false;
    }
    if (panFile == null && !_isEdit) {
      setState(() => panFileError = 'PAN Card document is required');
      isValid = false;
    }
    if (_isDriver && licenseFile == null && !_isEdit) {
      setState(() => licenseFileError = 'Driving License is required for drivers');
      isValid = false;
    }
    if (_isDriver && badgeFile == null && !_isEdit) {
      setState(() => badgeFileError = 'Badge document is required');
      isValid = false;
    }
    if (passbookFile == null && !_isEdit) {
      setState(() => passbookFileError = 'Bank Passbook is required');
      isValid = false;
    }
    if (photoFile == null && !_isEdit) {
      setState(() => photoFileError = 'Profile Photo is required');
      isValid = false;
    }

    if (!isValid) return;

    if (_selectedRoleId == null) return;
    if (_selectedShiftId == null) return;

    final Map<String, dynamic> data = {
      'name': _nameController.text.trim(),
      'phone': '${_staffController.selectedCountryCode.value}${_phoneController.text.trim()}',
      'email': _emailController.text.trim(),
      'staff_type': _selectedRoleId,
      'work_shift': _selectedShiftId,
      'date_of_birth': _dobController.text,
      'date_of_joining': _joiningDateController.text,
      'address': _addressController.text.trim(),
      'emergency_contact': '${_emergencyCountryCode.value}${_emergencyContactController.text.trim()}',
      'emergency_contact_name': _emergencyContactNameController.text.trim(),
      'license_number': _isDriver ? _licenseNoController.text.trim() : null,
      'license_expiry': _isDriver ? _licenseExpiryController.text : null,
      'license_type': _isDriver ? _licenseTypeController.text.trim() : null,
      'basic_salary': _salaryController.text.trim().isEmpty ? '0' : _salaryController.text.trim(),
      'da_per_day': _daController.text.trim().isEmpty ? '0' : _daController.text.trim(),
      'hra': _hraController.text.trim().isEmpty ? '0' : _hraController.text.trim(),
      'other_allowance': _otherAllowanceController.text.trim().isEmpty ? '0' : _otherAllowanceController.text.trim(),
      'bank_name': _bankNameController.text.trim(),
      'bank_account': _bankAccountController.text.trim(),
      'bank_ifsc': _bankIfscController.text.trim(),
      'aadhar_number': _aadharNoController.text.trim(),
      'pan_number': _panNoController.text.trim(),
      'badge_number': _badgeNoController.text.trim(),
      'badge_expiry': _badgeExpiryController.text,
      'assigned_vehicle': _assignedVehicleController.text.trim(),
      'notes': _notesController.text.trim(),
      'aadhar_file': aadharFile?.path,
      'pan_file': panFile?.path,
      'dl_file': licenseFile?.path,
      'badge_file': badgeFile?.path,
      'passbook_file': passbookFile?.path,
      'photo_file': photoFile?.path,
      'salary_type': _selectedSalaryType.name,
    };

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
        const SizedBox(height: 6),
        Obx(() {
          final uniqueRoles = <String, RoleModel>{};
          for (final role in _roleController.roles) {
            uniqueRoles[role.id] = role;
          }
          final roleList = uniqueRoles.values.toList();
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
            onChanged: (val) {
              setState(() {
                _selectedRoleId = val;
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.slate50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.slate200),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (v) => v == null ? 'Please select a role' : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
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
        const SizedBox(height: 6),
        Obx(() {
          final uniqueShifts = <int, ShiftModel>{};
          for (final shift in _shiftController.shifts) {
            if (shift.id != null) uniqueShifts[shift.id!] = shift;
          }
          final shiftList = uniqueShifts.values.toList();
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon: const Icon(Iconsax.clock, size: 20),
            ),
            validator: (v) => v == null ? 'Please select a shift' : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
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
        const SizedBox(height: 6),
        Container(
          height: 42,
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

  Future<void> _selectDate(BuildContext context, TextEditingController controller, {bool isExpiry = false}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isExpiry ? DateTime.now().add(const Duration(days: 30)) : DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: isExpiry ? DateTime.now() : DateTime(1950),
      lastDate: DateTime.now().add(const Duration(days: 365 * 15)),
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
        String? remoteUrl,
        String? fileName,
        TextInputType? keyboardType,
        String? fileError,
        Widget? extraField,
      }) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.document_text,
                  size: 16,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              AppText(
                label,
                style: AppTextStyle.subheading,
                fontSize: 13,
                color: AppColors.textColorPrimary,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          const SizedBox(height: 12),
          UploadBox(
            label: label,
            isUploaded: file != null ||
                (remoteUrl != null && remoteUrl.isNotEmpty),
            remoteUrl: file == null ? remoteUrl : null,
            localPath: file?.path,
            fileName: file?.name ?? fileName,
            onTap: onUpload,
          ),
          if (fileError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: AppText(fileError, color: Colors.red, fontSize: 12),
            ),
          if (noController != null) ...[
            const SizedBox(height: 12),
            AppInputField(
              label: noLabel ?? 'Document Number',
              hint: 'Enter Number',
              controller: noController,
              icon: Iconsax.hashtag,
              keyboardType: keyboardType ?? TextInputType.text,
              validator: (v) => AppValidators.validateEmpty(v, fieldName: noLabel ?? 'Number'),
            ),
          ],
          if (extraField != null) ...[
            const SizedBox(height: 12),
            extraField,
          ],
          if (expiryController != null) ...[
            const SizedBox(height: 12),
            AppInputField(
              label: 'Expiry Date',
              hint: 'YYYY-MM-DD',
              controller: expiryController,
              readOnly: true,
              icon: Iconsax.calendar_1,
              onTap: () => _selectDate(context, expiryController, isExpiry: true),
              keyboardType: TextInputType.none,
              validator: (v) => AppValidators.validateEmpty(v, fieldName: 'Expiry Date'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, bottom: 6),
      child: AppText(
        title,
        style: AppTextStyle.subheading,
        fontSize: 13,
        color: AppColors.primaryColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
