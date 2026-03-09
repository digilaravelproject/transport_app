import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';

class ServiceEntryScreen extends StatefulWidget {
  const ServiceEntryScreen({Key? key}) : super(key: key);

  @override
  State<ServiceEntryScreen> createState() => _ServiceEntryScreenState();
}

class _ServiceEntryScreenState extends State<ServiceEntryScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(title: 'Add Service Entry'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              child: Column(
                children: [
                  _buildDateField(),
                  const SizedBox(height: 16),
                  _buildTextField('Service Type', 'e.g. Engine Oil Change'),
                  const SizedBox(height: 16),
                  _buildTextField('Service Cost (₹)', 'e.g. 12000', keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildTextField('Workshop Name', 'e.g. Tata Authorized Center'),
                  const SizedBox(height: 16),
                  _buildTextField('Kilometer Reading', 'e.g. 45000', keyboardType: TextInputType.number),
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
                  AppText('Upload Service Bill', style: AppTextStyle.body),
                ],
              ),
            ),
            const SizedBox(height: 40),
            AppButton(
              text: 'Save Service Entry',
              onPressed: () => Get.back(),
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

  Widget _buildTextField(String label, String hint, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.body, fontSize: 13, fontWeight: FontWeight.w500),
        const SizedBox(height: 8),
        TextField(
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
