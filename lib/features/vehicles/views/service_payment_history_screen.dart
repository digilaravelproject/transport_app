import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../domain/models/vehicle_model.dart';
import '../domain/models/service_record_model.dart';
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
import '../../../routes/route_helper.dart';
import '../../../core/widgets/app_empty_state.dart';

class ServicePaymentHistoryScreen extends StatefulWidget {
  const ServicePaymentHistoryScreen({super.key});

  @override
  State<ServicePaymentHistoryScreen> createState() => _ServicePaymentHistoryScreenState();
}

class _ServicePaymentHistoryScreenState extends State<ServicePaymentHistoryScreen> {
  final VehicleController controller = Get.find<VehicleController>();
  late ServiceRecord initialRecord;
  late VehicleModel vehicle;
  late String type;

  @override
  void initState() {
    super.initState();
    final Map args = Get.arguments;
    initialRecord = args['record'];
    vehicle = args['vehicle'];
    type = args['type'] ?? 'Repair';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (type == 'Repair') {
        controller.fetchRepairDetails(vehicle.id, initialRecord.id);
      } else {
        controller.fetchServiceDetails(vehicle.id, initialRecord.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(title: 'Payment History'),
      body: RefreshIndicator(
        onRefresh: () async {
          if (type == 'Repair') {
            await controller.fetchRepairDetails(vehicle.id, initialRecord.id);
          } else {
            await controller.fetchServiceDetails(vehicle.id, initialRecord.id);
          }
        },
        child: Obx(() {
          // Find the latest record state from the controller
          final currentRecord = (type == 'Repair' ? controller.repairHistory : controller.serviceHistory)
              .firstWhere((r) => r.id == initialRecord.id, orElse: () => initialRecord);

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
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
                    child: AppEmptyState(
                      title: 'No Payment Logs',
                      subtitle: 'No payment transactions have been recorded for this record yet.',
                      icon: Iconsax.document_text,
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
                          children: [
                            Expanded(
                              child: Row(
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
                            ),
                            if (log.receiptUrl != null && log.receiptUrl!.isNotEmpty && !log.receiptUrl!.contains('null')) ...[
                              InkWell(
                                onTap: () => Get.toNamed(
                                  RouteHelper.getDocumentPreviewRoute(),
                                  arguments: log.receiptUrl,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Iconsax.eye, size: 18, color: AppColors.primaryColor),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            AppText('₹${log.amount.toStringAsFixed(0)}', style: AppTextStyle.body, fontWeight: FontWeight.bold, color: AppColors.successColor),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: Obx(() {
        final currentRecord = (type == 'Repair' ? controller.repairHistory : controller.serviceHistory)
            .firstWhere((r) => r.id == initialRecord.id, orElse: () => initialRecord);
            
        if (currentRecord.pendingAmount <= 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: AppButton(
            text: 'GIVE AMOUNT',
            icon: const Icon(Iconsax.add_square, size: 20),
            onPressed: () => _showPaymentBottomSheet(context, currentRecord, vehicle, type),
          ),
        );
      }),
    );
  }

  void _showPaymentBottomSheet(BuildContext context, ServiceRecord record, VehicleModel vehicle, String type) {
    final amountController = TextEditingController();
    DateTime payDate = DateTime.now();
    PlatformFile? pickedFile;
    final RxString amountError = ''.obs;

    AppBottomSheet.show(
      context: context,
      title: 'Record Payment',
      isScrollControlled: true,
      children: [
        StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText('Due Balance: ₹${record.pendingAmount.toStringAsFixed(0)}', 
                        style: AppTextStyle.body, color: AppColors.errorColor, fontWeight: FontWeight.bold),
                    const SizedBox(height: 20),
                    Obx(() => AppInputField(
                      hint: 'Enter Amount',
                      label: 'Payment Amount',
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      icon: Iconsax.money_send,
                      errorText: amountError.value.isEmpty ? null : amountError.value,
                      onChanged: (val) {
                        final entered = double.tryParse(val) ?? 0;
                        if (entered > record.pendingAmount) {
                          amountError.value = 'Amount exceeds the due balance (max: ₹${record.pendingAmount.toStringAsFixed(0)})';
                        } else {
                          amountError.value = '';
                        }
                      },
                    )),
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
                    Obx(() => AppButton(
                      text: 'Confirm Payment',
                      isLoading: controller.isLoading.value,
                      onPressed: () async {
                        final amountText = amountController.text.trim();
                        if (amountText.isEmpty) {
                          amountError.value = 'Please enter payment amount';
                          return;
                        }

                        final amount = double.tryParse(amountText) ?? 0;
                        if (amount <= 0) {
                          amountError.value = 'Please enter a valid amount';
                          return;
                        }

                        if (amount > record.pendingAmount) {
                          amountError.value = 'Amount exceeds the due balance';
                          return;
                        }

                        bool success = false;
                        if (type == 'Repair') {
                          success = await controller.addPaymentToRepair(
                            vehicle.id, 
                            record.id, 
                            amount, 
                            payDate, 
                            receiptFile: pickedFile
                          );
                        } else {
                          success = await controller.addPaymentToService(
                            vehicle.id, 
                            record.id, 
                            amount, 
                            payDate, 
                            receiptFile: pickedFile
                          );
                        }
                        
                        if (success) {
                          if (context.mounted) Navigator.pop(context); // Close bottom sheet
                          Get.snackbar('Success', 'Payment recorded successfully',
                            backgroundColor: AppColors.successColor.withOpacity(0.1),
                            colorText: AppColors.successColor);
                        } else {
                          Get.snackbar('Error', 'Failed to record payment',
                            backgroundColor: AppColors.errorColor.withOpacity(0.1),
                            colorText: AppColors.errorColor);
                        }
                      },
                    )),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
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
