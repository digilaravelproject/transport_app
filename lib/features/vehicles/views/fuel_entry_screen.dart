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
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../core/utils/custom_snackbar.dart';

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
  FilePickerResult? receiptFile;
  
  String? amountError;
  String? quantityError;

  @override
  void initState() {
    super.initState();
    vehicle = Get.arguments as VehicleModel;
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );
    if (result != null) {
      setState(() => receiptFile = result);
    }
  }

  Future<void> _saveFuelEntry() async {
    setState(() {
      amountError = null;
      quantityError = null;
    });

    bool hasError = false;

    // Validation
    if (_amountController.text.isEmpty) {
      setState(() => amountError = 'Please enter fuel amount');
      hasError = true;
    }
    if (_quantityController.text.isEmpty) {
      setState(() => quantityError = 'Please enter fuel quantity');
      hasError = true;
    }

    if (hasError) return;

    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() => amountError = 'Invalid amount');
      return;
    }

    final double? quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      setState(() => quantityError = 'Invalid quantity');
      return;
    }

    final double pricePerUnit = amount / quantity;

    final Map<String, String> body = {
      'activity_date': '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
      'amount': amount.toString(),
      'quantity': quantity.toString(),
      'price_per_unit': pricePerUnit.toStringAsFixed(2),
      'station_name': _stationController.text,
    };

    final success = await controller.addFuelEntryMultipart(vehicle.id, body, receiptFile);
    if (success) {
      Navigator.pop(context);
      CustomSnackbar.showSuccess('Fuel entry saved successfully');
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
                      _buildTextField('Fuel Amount (₹)', 'e.g. 5000', controller: _amountController, keyboardType: TextInputType.number, errorText: amountError),
                      const SizedBox(height: 16),
                      _buildTextField('Quantity (Ltrs)', 'e.g. 50.5', controller: _quantityController, keyboardType: TextInputType.number, errorText: quantityError),
                      const SizedBox(height: 16),
                      _buildTextField('Station Name', 'e.g. HP Petrol Pump', controller: _stationController),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // File Upload & Preview
                InkWell(
                  onTap: _pickFile,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: receiptFile != null 
                      ? Column(
                          children: [
                            _buildFilePreview(),
                            const SizedBox(height: 12),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Iconsax.edit, size: 16, color: AppColors.primaryColor),
                                SizedBox(width: 8),
                                AppText('Change Document', style: AppTextStyle.body, color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                              ],
                            ),
                          ],
                        )
                      : const Row(
                          children: [
                            Icon(Iconsax.document_upload, color: AppColors.primaryColor),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText('Upload Receipt (Optional)', style: AppTextStyle.body),
                                SizedBox(height: 2),
                                AppText(
                                  'Supports: JPG, PNG, PDF or DOC',
                                  fontSize: 11,
                                  color: AppColors.textColorSecondary,
                                ),
                              ],
                            ),
                          ],
                        ),
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

  Widget _buildFilePreview() {
    final file = receiptFile!.files.first;
    final isImage = ['jpg', 'jpeg', 'png'].contains(file.extension?.toLowerCase());

    if (isImage && file.path != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(File(file.path!), height: 150, width: double.infinity, fit: BoxFit.cover),
      );
    } else {
      return Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              file.extension?.toLowerCase() == 'pdf' ? Iconsax.document_text5 : Iconsax.document_code5,
              color: AppColors.primaryColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: AppText(
                file.name,
                style: AppTextStyle.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
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

  Widget _buildTextField(String label, String hint, {TextEditingController? controller, TextInputType? keyboardType, String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.body, fontSize: 13, fontWeight: FontWeight.w500),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: (_) {
            if (errorText != null) {
              setState(() {
                if (label.contains('Amount')) amountError = null;
                if (label.contains('Quantity')) quantityError = null;
              });
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textColorHint, fontSize: 14),
            filled: true,
            fillColor: AppColors.slate50,
            errorText: errorText,
            errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: errorText != null ? Colors.red : AppColors.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: errorText != null ? Colors.red : AppColors.slate200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: errorText != null ? Colors.red : AppColors.primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
