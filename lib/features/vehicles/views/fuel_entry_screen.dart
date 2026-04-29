import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../domain/models/vehicle_model.dart';
import '../controllers/vehicle_controller.dart';

class FuelEntryScreen extends StatefulWidget {
  const FuelEntryScreen({Key? key}) : super(key: key);

  @override
  State<FuelEntryScreen> createState() => _FuelEntryScreenState();
}

class _FuelEntryScreenState extends State<FuelEntryScreen> {
  final VehicleController controller = Get.find<VehicleController>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _stationController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  late VehicleModel vehicle;

  @override
  void initState() {
    super.initState();
    vehicle = Get.arguments as VehicleModel;
  }

  Future<void> _saveFuelEntry() async {
    if (_amountController.text.isEmpty || _quantityController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill required fields', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final double amount = double.tryParse(_amountController.text) ?? 0;
    final double quantity = double.tryParse(_quantityController.text) ?? 0;
    final double pricePerUnit = quantity > 0 ? amount / quantity : 0;

    final data = {
      'activity_date': '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
      'amount': amount,
      'quantity': quantity,
      'price_per_unit': pricePerUnit.toStringAsFixed(2),
      'station_name': _stationController.text,
    };

    final success = await controller.addFuelEntry(vehicle.id, data);
    if (success) {
      Get.back();
      Get.snackbar('Success', 'Fuel entry saved successfully', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successColor.withOpacity(0.1),
        colorText: AppColors.successColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(title: 'Add Fuel Entry', subtitle: vehicle.vehicleNumber),
      body: Obx(() => Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                AppCard(
                  child: Column(
                    children: [
                      _buildDateField(),
                      const SizedBox(height: 16),
                      _buildTextField('Fuel Amount (₹)', 'e.g. 5000', controller: _amountController, keyboardType: TextInputType.number),
                      const SizedBox(height: 16),
                      _buildTextField('Quantity (Ltrs)', 'e.g. 50.5', controller: _quantityController, keyboardType: TextInputType.number),
                      const SizedBox(height: 16),
                      _buildTextField('Station Name', 'e.g. HP Petrol Pump', controller: _stationController),
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
                      const SizedBox(width: 12),
                      AppText('Upload Receipt Photo', style: AppTextStyle.body),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                AppButton(
                  text: 'Save Fuel Entry',
                  onPressed: _saveFuelEntry,
                ),
              ],
            ),
          ),
          if (controller.isLoading.value)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      )),
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

  Widget _buildTextField(String label, String hint, {TextEditingController? controller, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.body, fontSize: 13, fontWeight: FontWeight.w500),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
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
}
