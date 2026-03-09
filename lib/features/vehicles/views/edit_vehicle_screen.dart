import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../widgets/upload_box.dart';
import '../domain/models/vehicle_model.dart';

class EditVehicleScreen extends StatefulWidget {
  const EditVehicleScreen({Key? key}) : super(key: key);

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  late VehicleModel vehicle;
  final List<String> vehicleTypes = ['AC Sleeper', 'Non-AC Sleeper', 'AC Seater', 'Non-AC Seater', 'Luxury Volvo'];

  @override
  void initState() {
    super.initState();
    vehicle = Get.arguments ?? VehicleModel(
      vehicleNumber: '', type: '', capacity: 0, model: '', year: '', status: VehicleStatus.active
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(title: 'Edit Vehicle'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Vehicle Information'),
            AppCard(
              child: Column(
                children: [
                  _buildTextField('Vehicle Number', vehicle.vehicleNumber),
                  const SizedBox(height: 16),
                  _buildDropdown('Vehicle Type', vehicleTypes, vehicle.type),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Seating Capacity', vehicle.capacity.toString(), keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField('Model Year', vehicle.year, keyboardType: TextInputType.number)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Maintenance Info'),
            AppCard(
              child: _buildDropdown('Vehicle Status', ['Active', 'Maintenance', 'Inactive'], vehicle.status.name.capitalizeFirst!),
            ),
            const SizedBox(height: 40),
            AppButton(
              text: 'Update Vehicle',
              onPressed: () => Get.back(),
            ),
            const SizedBox(height: 12),
            AppButton.outline(
              text: 'Delete Vehicle',
              color: AppColors.errorColor,
              onPressed: () => _showDeleteConfirmation(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const AppText('Delete Vehicle', style: AppTextStyle.heading, fontSize: 18),
        content: AppText('Are you sure you want to remove ${vehicle.vehicleNumber} from your fleet?', style: AppTextStyle.body),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const AppText('Cancel', style: AppTextStyle.body)),
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            }, 
            child: const AppText('Delete', style: AppTextStyle.body, color: AppColors.errorColor)
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

  Widget _buildTextField(String label, String initialVal, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.body, fontSize: 13, fontWeight: FontWeight.w500),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialVal,
          keyboardType: keyboardType,
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
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String initialVal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.body, fontSize: 13, fontWeight: FontWeight.w500),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: items.contains(initialVal) ? initialVal : null,
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
          items: items.map((e) => DropdownMenuItem(value: e, child: AppText(e, style: AppTextStyle.body))).toList(),
          onChanged: (val) {},
        ),
      ],
    );
  }
}
