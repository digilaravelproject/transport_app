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
      appBar: AppHeader(title: title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              child: Column(
                children: [
                  _buildDateField(),
                  const SizedBox(height: 16),
                  if (mode != 'payment') ...[
                    _buildTextField('Service Type', 'e.g. Engine Oil Change', typeController),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      if (mode != 'payment')
                        Expanded(
                            child: _buildTextField('Total Bill (₹)', 'e.g. 12000', totalBillController,
                                keyboardType: TextInputType.number)),
                      if (mode != 'payment' && mode != 'bill') const SizedBox(width: 12),
                      if (mode != 'bill')
                        Expanded(
                            child: _buildTextField('Amount Paid (₹)', 'e.g. 12000', paidAmountController,
                                keyboardType: TextInputType.number)),
                    ],
                  ),
                  if (mode != 'payment') ...[
                    _buildTextField('Workshop Name', 'e.g. Tata Authorized Center', workshopController),
                    const SizedBox(height: 16),
                    _buildTextField('Kilometer Reading', 'e.g. 45000', kmController, keyboardType: TextInputType.number),
                  ],
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
                  AppText('Upload Service Bill', style: AppTextStyle.body),
                ],
              ),
            ),
            const SizedBox(height: 40),
            AppButton(
              text: mode == 'payment' ? 'Save Payment' : 'Save Entry',
              onPressed: () {
                bool isValid = true;
                if (mode == 'payment') {
                  isValid = paidAmountController.text.isNotEmpty;
                } else {
                  isValid = typeController.text.isNotEmpty && totalBillController.text.isNotEmpty;
                }

                if (isValid) {
                  if (mode == 'payment' && sourceRecord != null) {
                    controller.addPaymentToService(
                      sourceRecord!.id, 
                      double.tryParse(paidAmountController.text) ?? 0.0,
                      selectedDate,
                    );
                  } else {
                    final record = ServiceRecord(
                      id: DateTime.now().millisecondsSinceEpoch,
                      date: selectedDate,
                      type: typeController.text,
                      totalBill: double.tryParse(totalBillController.text) ?? 0.0,
                      paidAmount: double.tryParse(paidAmountController.text) ?? 0.0,
                      workshop: workshopController.text.isNotEmpty ? workshopController.text : 'Unknown Workshop',
                    );
                    controller.addServiceEntry(record);
                  }
                  Get.back();
                } else {
                  Get.snackbar('Error', 'Please fill in required fields',
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
