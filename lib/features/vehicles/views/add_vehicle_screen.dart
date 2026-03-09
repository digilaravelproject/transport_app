import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
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
  
  bool rcUploaded = false;
  bool insuranceUploaded = false;
  bool permitUploaded = false;

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
            const SizedBox(height: 24),
            _buildSectionTitle('Driver Assignment'),
            AppCard(
              child: _buildDropdown('Assign Driver', ['Rajesh Kumar', 'Suresh Singh', 'Amit Sharma', 'None']),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Required Documents'),
            Column(
              children: [
                UploadBox(
                  label: 'Registration Certificate (RC)',
                  isUploaded: rcUploaded,
                  onTap: () => setState(() => rcUploaded = true),
                ),
                const SizedBox(height: 12),
                UploadBox(
                  label: 'Insurance Policy',
                  isUploaded: insuranceUploaded,
                  onTap: () => setState(() => insuranceUploaded = true),
                ),
                const SizedBox(height: 12),
                UploadBox(
                  label: 'Permit Details',
                  isUploaded: permitUploaded,
                  onTap: () => setState(() => permitUploaded = true),
                ),
              ],
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
