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

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({Key? key}) : super(key: key);

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _controller = Get.find<StaffController>();
  StaffRole _selectedRole = StaffRole.driver;
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
  final _shiftController = TextEditingController();
  final _licenseNoController = TextEditingController();
  final _licenseExpiryController = TextEditingController();
  final _badgeNoController = TextEditingController();
  final _badgeExpiryController = TextEditingController();

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
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
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
                    phoneCode: _controller.selectedCountryCode.value,
                    onPhoneCodeTap: () => PhoneHelper.showCountryPicker(
                      context: context,
                      selectedCode: _controller.selectedCountryCode,
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
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Joining Date',
                    hint: 'DD/MM/YYYY',
                    controller: _joiningDateController,
                    icon: Iconsax.calendar_1,
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Joining Date',
                    hint: 'DD/MM/YYYY',
                    controller: _joiningDateController,
                    icon: Iconsax.calendar_1,
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
            
            const SizedBox(height: 16),
            _buildSectionTitle('Documents Upload'),
            _buildStaffDocumentSection(
              'Aadhar Card',
              aadharFile,
              () => _pickDocument('aadhar'),
              noController: _aadharNoController,
              noLabel: 'Aadhar Number',
            ),
            if (_selectedRole == StaffRole.driver) ...[
              const SizedBox(height: 12),
              _buildStaffDocumentSection(
                'PAN Card',
                panFile,
                () => _pickDocument('pan'),
                noController: _panNoController,
                noLabel: 'PAN Number',
              ),
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
              const SizedBox(height: 12),
              _buildStaffDocumentSection(
                'Bank Passbook',
                passbookFile,
                () => _pickDocument('passbook'),
              ),
              const SizedBox(height: 12),
              _buildStaffDocumentSection(
                'Passport Size Photo',
                photoFile,
                () => _pickDocument('photo'),
              ),
            ] else ...[
              const SizedBox(height: 12),
              _buildStaffDocumentSection(
                'Profile Photo',
                photoFile,
                () => _pickDocument('photo'),
              ),
            ],
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

