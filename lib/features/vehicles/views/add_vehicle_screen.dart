import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../widgets/upload_box.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({Key? key}) : super(key: key);

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final List<String> vehicleTypes = ['AC Sleeper', 'Non-AC Sleeper', 'AC Seater', 'Non-AC Seater', 'Luxury Volvo'];
  String? selectedType;
  
  PlatformFile? rcFile;
  PlatformFile? insuranceFile;
  PlatformFile? permitFile;

  // Document Detail Controllers
  final _rcNoController = TextEditingController();
  final _rcExpiryController = TextEditingController();
  final _insNoController = TextEditingController();
  final _insExpiryController = TextEditingController();
  final _permitNoController = TextEditingController();
  final _permitExpiryController = TextEditingController();

  Future<void> _pickDocument(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf', 'doc', 'docx'],
    );
    if (result != null) {
      setState(() {
        if (type == 'RC') rcFile = result.files.first;
        if (type == 'Insurance') insuranceFile = result.files.first;
        if (type == 'Permit') permitFile = result.files.first;
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
    _rcNoController.dispose();
    _rcExpiryController.dispose();
    _insNoController.dispose();
    _insExpiryController.dispose();
    _permitNoController.dispose();
    _permitExpiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(title: 'Add New Vehicle'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Vehicle Information'),
            AppCard(
              child: Column(
                children: [
                  _buildTextField('Vehicle Number', 'e.g. DL 01 AB 1234'),
                  const SizedBox(height: 16),
                  _buildDropdown('Vehicle Type', vehicleTypes),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Seating Capacity', 'e.g. 36', keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField('Model Year', 'e.g. 2022', keyboardType: TextInputType.number)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Pricing Information'),
            AppCard(
              child: Column(
                children: [
                  _buildTextField('Per KM Price', 'e.g. 18.00', keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildTextField('AC Price per KM (Extra)', 'e.g. 2.00', keyboardType: TextInputType.number),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Required Documents'),
            _buildDocumentSection(
              'Registration Certificate (RC)',
              rcFile,
              _rcNoController,
              _rcExpiryController,
              () => _pickDocument('RC'),
              'RC Number',
            ),
            _buildDocumentSection(
              'Insurance Policy',
              insuranceFile,
              _insNoController,
              _insExpiryController,
              () => _pickDocument('Insurance'),
              'Policy Number',
            ),
            _buildDocumentSection(
              'Permit Details',
              permitFile,
              _permitNoController,
              _permitExpiryController,
              () => _pickDocument('Permit'),
              'Permit Number',
            ),
            const SizedBox(height: 40),
            AppButton(
              text: 'Save Vehicle',
              onPressed: () => Get.back(),
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

  Widget _buildDocumentSection(
    String label,
    PlatformFile? file,
    TextEditingController noController,
    TextEditingController expiryController,
    VoidCallback onUpload,
    String noLabel,
  ) {
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
            isUploaded: file != null,
            localPath: file?.path,
            fileName: file?.name,
            onTap: onUpload,
          ),
          const SizedBox(height: 16),
          AppInputField(
            label: noLabel,
            hint: 'Enter Number',
            controller: noController,
            icon: Iconsax.hashtag,
          ),
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

  Widget _buildTextField(String label, String hint, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.body, fontSize: 13, fontWeight: FontWeight.w500),
        const SizedBox(height: 8),
        TextField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textColorHint, fontSize: 14),
            filled: true,
            fillColor: AppColors.slate50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.slate200),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.body, fontSize: 13, fontWeight: FontWeight.w500),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.slate50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.slate200),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          hint: AppText('Select $label', style: AppTextStyle.body, color: AppColors.textColorHint),
          items: items.map((e) => DropdownMenuItem(value: e, child: AppText(e, style: AppTextStyle.body))).toList(),
          onChanged: (val) {},
        ),
      ],
    );
  }
}
