import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../domain/models/vehicle_model.dart';
import '../domain/models/service_record_model.dart';
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

class ServiceEntryScreen extends StatefulWidget {
  const ServiceEntryScreen({Key? key}) : super(key: key);

  @override
  State<ServiceEntryScreen> createState() => _ServiceEntryScreenState();
}
class _ServiceEntryScreenState extends State<ServiceEntryScreen> {
  final VehicleController controller = Get.find<VehicleController>();
  late VehicleModel vehicle;
  String? mode;
  ServiceRecord? sourceRecord;

  DateTime selectedDate = DateTime.now();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController totalBillController = TextEditingController();
  final TextEditingController paidAmountController = TextEditingController();
  final TextEditingController workshopController = TextEditingController();
  final TextEditingController kmController = TextEditingController();
  
  FilePickerResult? billFile;
  
  String? typeError;
  String? totalBillError;
  String? paidAmountError;
  String? workshopError;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;

    if (args is Map) {
      vehicle = args['vehicle'];
      mode = args['mode'];
      sourceRecord = args['record'];
    } else {
      vehicle = args;
    }
    
    // Pre-fill from existing record if available
    final record = sourceRecord;
    if (record != null) {
      workshopController.text = record.workshop;
      if (mode == 'payment') {
        typeController.text = 'Payment for ${record.type}';
      } else {
        typeController.text = record.type;
      }
    }

    // Set default values based on mode
    if (mode == 'payment') {
      if (typeController.text.isEmpty) typeController.text = 'Service Payment';
      totalBillController.text = '0';
    } else if (mode == 'bill') {
      paidAmountController.text = '0';
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );
    if (result != null) {
      setState(() => billFile = result);
    }
  }

  Future<void> _saveEntry() async {
    setState(() {
      typeError = null;
      totalBillError = null;
      paidAmountError = null;
      workshopError = null;
    });

    bool hasError = false;

    if (mode != 'payment' && typeController.text.isEmpty) {
      typeError = 'Please enter service type';
      hasError = true;
    }
    if (mode != 'payment' && totalBillController.text.isEmpty) {
      totalBillError = 'Please enter total bill';
      hasError = true;
    }
    if (mode != 'bill' && paidAmountController.text.isEmpty) {
      paidAmountError = 'Please enter amount paid';
      hasError = true;
    }
    if (mode != 'payment' && workshopController.text.isEmpty) {
      workshopError = 'Please enter workshop name';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    final Map<String, String> body = {
      'activity_date': '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
      'title': typeController.text,
      'amount': totalBillController.text,
      'amount_paid': paidAmountController.text,
      'workshop_name': workshopController.text,
      'km_reading': kmController.text,
    };

    final bool success = await controller.addServiceEntryMultipart(vehicle.id, body, billFile);
    
    if (success) {
      Get.back();
      Get.snackbar('Success', 'Service entry saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successColor.withOpacity(0.1),
        colorText: AppColors.successColor,
      );
    }
  }

  @override
  void dispose() {
    typeController.dispose();
    totalBillController.dispose();
    paidAmountController.dispose();
    workshopController.dispose();
    kmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Add Service Entry';
    if (mode == 'payment') title = 'Record Service Payment';
    if (mode == 'bill') title = 'Add Service Bill';

    return AppScaffold(
      appBar: AppHeader(title: title, subtitle: vehicle.vehicleNumber),
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
                      if (mode != 'payment') ...[
                        _buildTextField('Service Type', 'e.g. Engine Oil Change', typeController, errorText: typeError),
                        const SizedBox(height: 16),
                      ],
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (mode != 'payment')
                            Expanded(
                                child: _buildTextField('Total Bill (₹)', 'e.g. 12000', totalBillController,
                                    keyboardType: TextInputType.number, errorText: totalBillError)),
                          if (mode != 'payment' && mode != 'bill') const SizedBox(width: 12),
                          if (mode != 'bill')
                            Expanded(
                                child: _buildTextField('Amount Paid (₹)', 'e.g. 12000', paidAmountController,
                                    keyboardType: TextInputType.number, errorText: paidAmountError)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (mode != 'payment') ...[
                        _buildTextField('Workshop Name', 'e.g. Tata Authorized Center', workshopController, errorText: workshopError),
                        const SizedBox(height: 16),
                        _buildTextField('Kilometer Reading (Optional)', 'e.g. 45000', kmController, keyboardType: TextInputType.number),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // File Upload Section
                InkWell(
                  onTap: _pickFile,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: billFile != null ? AppColors.primaryColor : AppColors.slate200),
                    ),
                    child: billFile != null 
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
                                AppText('Upload Service Bill (Optional)', style: AppTextStyle.body),
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
                  text: mode == 'payment' ? 'Save Payment' : 'Save Entry',
                  onPressed: _saveEntry,
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
    final file = billFile!.files.first;
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

  Widget _buildTextField(String label, String hint, TextEditingController textController,
      {TextInputType? keyboardType}) {
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
