import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../domain/models/vehicle_model.dart';
import '../controllers/vehicle_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../vehicles/widgets/upload_box.dart';
import '../../../core/widgets/app_image_preview.dart';
import 'package:file_picker/file_picker.dart';

class ServicePaymentHistoryScreen extends GetView<VehicleController> {
  const ServicePaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map args = Get.arguments;
    final ServiceRecord record = args['record'];
    final VehicleModel vehicle = args['vehicle'];
    final String type = args['type'] ?? 'Repair'; // 'Repair' or 'Service'

    return AppScaffold(
      appBar: const AppHeader(title: 'Payment History'),
      body: Obx(() {
        // Find the latest record state from the controller
        final currentRecord = (type == 'Repair' ? controller.repairHistory : controller.serviceHistory)
            .firstWhere((r) => r.id == record.id, orElse: () => record);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Record Summary Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(currentRecord.type, style: AppTextStyle.subheading, fontSize: 20),
                            const SizedBox(height: 4),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Iconsax.location, size: 14, color: AppColors.textColorHint),
                                  const SizedBox(width: 6),
                                  Expanded(child: AppText(currentRecord.workshop, style: AppTextStyle.caption, color: AppColors.textColorSecondary, overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: currentRecord.isFullPaid ? AppColors.successColor.withOpacity(0.1) : AppColors.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: AppText(
                            currentRecord.isFullPaid ? 'PAID' : 'PENDING',
                            style: AppTextStyle.caption,
                            fontWeight: FontWeight.bold,
                            color: currentRecord.isFullPaid ? AppColors.successColor : AppColors.errorColor,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32, thickness: 0.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryStat('Total bill', '₹${currentRecord.totalBill.toStringAsFixed(0)}', AppColors.textColorPrimary),
                        _buildSummaryStat('Amount Paid', '₹${currentRecord.paidAmount.toStringAsFixed(0)}', AppColors.successColor),
                        _buildSummaryStat('Due Amount', '₹${currentRecord.pendingAmount.toStringAsFixed(0)}', AppColors.errorColor),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              const AppText('Payment Logs', style: AppTextStyle.subheading),
              const SizedBox(height: 16),
              
              // Payment History List
              if (currentRecord.payments.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Iconsax.document_text, size: 48, color: AppColors.slate300),
                        const SizedBox(height: 12),
                        const AppText('No payment logs found', color: AppColors.textColorHint),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: currentRecord.payments.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final log = currentRecord.payments[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.successColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Iconsax.tick_circle, size: 16, color: AppColors.successColor),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText('Payment Received', style: AppTextStyle.body, fontWeight: FontWeight.bold),
                                  AppText('${log.date.day}/${log.date.month}/${log.date.year}', style: AppTextStyle.caption, color: AppColors.textColorHint),
                                ],
                              ),
                            ],
                          ),
                          AppText('₹${log.amount.toStringAsFixed(0)}', style: AppTextStyle.body, fontWeight: FontWeight.bold, color: AppColors.successColor),
                          if (log.receiptUrl != null) ...[
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () => AppImagePreview.show(
                                context,
                                imageUrl: log.receiptUrl,
                                title: 'Payment Receipt',
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Iconsax.receipt_2, size: 18, color: AppColors.primaryColor),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              
              const SizedBox(height: 40),
              
              if (currentRecord.pendingAmount > 0)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showPaymentBottomSheet(context, currentRecord, type),
                    icon: const Icon(Iconsax.add_square, size: 18),
                    label: const Text('GIVE AMOUNT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  void _showPaymentBottomSheet(BuildContext context, ServiceRecord record, String type) {
    final amountController = TextEditingController();
    DateTime payDate = DateTime.now();
    PlatformFile? pickedFile;

    AppBottomSheet.show(
      context: context,
      title: 'Record Payment',
      isScrollControlled: true,
      children: [
        StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText('Due Balance: ₹${record.pendingAmount.toStringAsFixed(0)}', 
                    style: AppTextStyle.body, color: AppColors.errorColor, fontWeight: FontWeight.bold),
                const SizedBox(height: 20),
                AppInputField(
                  hint: 'Enter Amount',
                  label: 'Payment Amount',
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  icon: Iconsax.money_send,
                ),
                const SizedBox(height: 16),
                AppInputField(
                  hint: 'Select Date',
                  label: 'Payment Date',
                  readOnly: true,
                  icon: Iconsax.calendar_1,
                  controller: TextEditingController(text: '${payDate.day}/${payDate.month}/${payDate.year}'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: payDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setModalState(() => payDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 16),
                UploadBox(
                  label: 'Payment Receipt',
                  isUploaded: pickedFile != null,
                  fileName: pickedFile?.name,
                  localPath: pickedFile?.path,
                  onTap: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
                    );
                    if (result != null) {
                      setModalState(() => pickedFile = result.files.first);
                    }
                  },
                ),
                const SizedBox(height: 32),
                AppButton(
                  text: 'Confirm Payment',
                  onPressed: () {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    if (amount <= 0) {
                      Get.snackbar('Error', 'Please enter a valid amount');
                      return;
                    }
                    if (amount > record.pendingAmount) {
                      Get.snackbar('Error', 'Amount exceeds the due balance');
                      return;
                    }

                    if (type == 'Repair') {
                      controller.addPaymentToRepair(record.id, amount, payDate, receiptUrl: pickedFile?.path);
                    } else {
                      controller.addPaymentToService(record.id, amount, payDate, receiptUrl: pickedFile?.path);
                    }
                    
                    Get.back(); // Close bottom sheet
                  },
                ),
                const SizedBox(height: 20), // Padding for bottom
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.caption, color: AppColors.textColorHint),
        const SizedBox(height: 4),
        AppText(value, style: AppTextStyle.body, fontWeight: FontWeight.bold, color: color),
      ],
    );
  }
}
