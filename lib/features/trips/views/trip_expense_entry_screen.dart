import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/trip_controller.dart';

class TripExpenseEntryScreen extends StatefulWidget {
  const TripExpenseEntryScreen({Key? key}) : super(key: key);

  @override
  State<TripExpenseEntryScreen> createState() => _TripExpenseEntryScreenState();
}

class _TripExpenseEntryScreenState extends State<TripExpenseEntryScreen> {
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  String selectedType = 'Fuel';

  final List<String> expenseTypes = ['Fuel', 'Driver Allowance', 'Toll', 'Parking', 'Other'];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(title: 'Add Expense'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('Expense Type', style: AppTextStyle.body, fontWeight: FontWeight.w600),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 24),
                  AppInputField(
                    label: 'Amount',
                    controller: amountController,
                    hint: '₹ 0.00',
                    keyboardType: TextInputType.number,
                    icon: Icons.currency_rupee_rounded,
                  ),
                  const SizedBox(height: 20),
                  AppInputField(
                    label: 'Notes',
                    controller: noteController,
                    hint: 'Enter expense details...',
                    icon: Icons.note_add_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  _buildUploadCard(),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Save Expense',
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_upload_outlined, color: AppColors.primaryColor, size: 32),
          const SizedBox(height: 8),
          AppText('Upload Receipt', style: AppTextStyle.body, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
          AppText('PNG, JPG, PDF (Max 5MB)', style: AppTextStyle.caption),
        ],
      ),
    );
  }
}
