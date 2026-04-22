import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../widgets/app_text.dart';

class PhoneHelper {
  static final List<String> countryCodes = [
    '+91', '+1', '+44', '+971', '+61', '+65', '+64', '+81'
  ];

  static void showCountryPicker({
    required BuildContext context,
    required RxString selectedCode,
    void Function(String)? onSelected,
  }) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText('Select Country Code', style: AppTextStyle.subheading),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: countryCodes.length,
                itemBuilder: (context, index) {
                  return Obx(() => ListTile(
                    title: AppText(countryCodes[index], fontWeight: FontWeight.w600),
                    trailing: selectedCode.value == countryCodes[index] 
                        ? const Icon(Icons.check_circle, color: AppColors.primaryColor) 
                        : null,
                    onTap: () {
                      selectedCode.value = countryCodes[index];
                      if (onSelected != null) onSelected(countryCodes[index]);
                      Get.back();
                    },
                  ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
