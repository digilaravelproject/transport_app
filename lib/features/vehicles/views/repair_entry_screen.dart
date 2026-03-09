import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/vehicle_controller.dart';
import '../domain/models/vehicle_model.dart';

class RepairEntryScreen extends StatefulWidget {
  const RepairEntryScreen({Key? key}) : super(key: key);

  @override
  State<RepairEntryScreen> createState() => _RepairEntryScreenState();
}

class _RepairEntryScreenState extends State<RepairEntryScreen> {
  final VehicleController controller = Get.find<VehicleController>();
  DateTime selectedDate = DateTime.now();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController garageController = TextEditingController();

  @override
  void dispose() {
    typeController.dispose();
    costController.dispose();
    garageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(title: 'Add Repair Entry'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              child: Column(
                children: [
                  _buildDateField(),
                  const SizedBox(height: 16),
                  _buildTextField('Repair Type / Part', 'e.g. Brake Pad Replacement', typeController),
                  const SizedBox(height: 16),
                  _buildTextField('Repair Cost (₹)', 'e.g. 4500', costController, keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildTextField('Garage Name', 'e.g. City Motors', garageController),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slate200),
              ),
              child: const Row(
                children: [
                  Icon(Iconsax.camera, color: AppColors.primaryColor),
                  SizedBox(width: 12),
                  AppText('Upload Receipt Photo', style: AppTextStyle.body),
                ],
              ),
            ),
            const SizedBox(height: 40),
            AppButton(
              text: 'Save Repair Entry',
              onPressed: () {
                if (typeController.text.isNotEmpty && costController.text.isNotEmpty) {
                  final record = ServiceRecord(
                    date: selectedDate,
                    type: typeController.text,
                    cost: double.tryParse(costController.text) ?? 0.0,
                    workshop: garageController.text.isNotEmpty ? garageController.text : 'Unknown Workshop',
                  );
                  controller.addRepairEntry(record);
                  Get.back();
                } else {
                  Get.snackbar('Error', 'Please fill in all required fields', 
                    snackPosition: SnackPosition.BOTTOM, 
                    backgroundColor: AppColors.errorColor, 
                    colorText: Colors.white);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (date != null) setState(() => selectedDate = date);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText('Date', style: AppTextStyle.body, fontSize: 13, fontWeight: FontWeight.w500),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}', style: AppTextStyle.body),
                const Icon(Iconsax.calendar_1, size: 18, color: AppColors.primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController textController, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.body, fontSize: 13, fontWeight: FontWeight.w500),
        const SizedBox(height: 8),
        TextField(
          controller: textController,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textColorHint, fontSize: 14),
            filled: true,
            fillColor: AppColors.slate50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.slate200),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
