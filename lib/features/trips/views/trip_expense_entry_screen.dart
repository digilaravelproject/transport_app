import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/widgets/app_text.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../controllers/trip_controller.dart';
import 'package:intl/intl.dart';

class TripExpenseEntryScreen extends StatefulWidget {
  const TripExpenseEntryScreen({Key? key}) : super(key: key);

  @override
  State<TripExpenseEntryScreen> createState() => _TripExpenseEntryScreenState();
}

class _TripExpenseEntryScreenState extends State<TripExpenseEntryScreen> {
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String selectedType = 'Fuel';
  XFile? selectedReceipt;
  final controller = Get.find<TripController>();
  late String tripId;

  @override
  void initState() {
    super.initState();
    tripId = Get.arguments.toString();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => selectedReceipt = image);
    }
  }

  final List<String> expenseTypes = ['Fuel', 'Driver Allowance', 'Toll', 'Parking', 'Other'];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(title: 'Add Expense'),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('Expense Type', style: AppTextStyle.body, fontWeight: FontWeight.w600),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: expenseTypes.map((type) {
                      final isSelected = selectedType == type;
                      return ChoiceChip(
                        label: AppText(
                          type,
                          fontSize: 12,
                          color: isSelected ? AppColors.white : AppColors.textColorPrimary,
                        ),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => selectedType = type);
                        },
                        selectedColor: AppColors.primaryColor,
                        backgroundColor: AppColors.slate50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.primaryColor : AppColors.slate200,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Amount',
                    controller: amountController,
                    hint: '₹ 0.00',
                    keyboardType: TextInputType.number,
                    icon: Icons.currency_rupee_rounded,
                    validator: (v) => AppValidators.validateEmpty(v, fieldName: 'Amount'),
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Notes',
                    controller: noteController,
                    hint: 'Enter expense details...',
                    icon: Icons.note_add_rounded,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildUploadCard(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => AppButton(
              text: 'Save Expense',
              isLoading: controller.isLoading.value,
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;

                final body = {
                  'category': selectedType,
                  'amount': amountController.text,
                  'description': noteController.text,
                  'entry_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                };

                final success = await controller.addTripExpense(tripId, body, selectedReceipt);
                if (success) {
                  Get.back(closeOverlays: true);
                  Get.snackbar(
                    'Success', 
                    'Expense added successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.withOpacity(0.1),
                    colorText: Colors.green,
                  );
                }
              },
            )),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildUploadCard() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryLight, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            if (selectedReceipt != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(selectedReceipt!.path),
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
            ],
            const Icon(Icons.cloud_upload_outlined, color: AppColors.primaryColor, size: 32),
            const SizedBox(height: 8),
            AppText(
              selectedReceipt != null ? 'Change Receipt' : 'Upload Receipt', 
              style: AppTextStyle.body, 
              fontWeight: FontWeight.w600, 
              color: AppColors.primaryColor
            ),
            AppText('PNG, JPG, PDF (Max 5MB)', style: AppTextStyle.caption),
          ],
        ),
      ),
    );
}
}
