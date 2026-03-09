import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class UploadBox extends StatelessWidget {
  final String label;
  final String? fileName;
  final VoidCallback onTap;
  final bool isUploaded;

  const UploadBox({
    super.key,
    required this.label,
    this.fileName,
    required this.onTap,
    this.isUploaded = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isUploaded ? AppColors.successColor.withOpacity(0.05) : AppColors.slate50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUploaded ? AppColors.successColor : AppColors.slate200,
            width: 1.5,
            style: isUploaded ? BorderStyle.solid : BorderStyle.none, // Can't easily do dashed without package
          ),
        ),
        child: Column(
          children: [
            Icon(
              isUploaded ? Iconsax.tick_circle : Icons.cloud_upload_outlined,
              color: isUploaded ? AppColors.successColor : AppColors.primaryColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            AppText(
              isUploaded ? (fileName ?? 'Uploaded') : 'Upload $label',
              style: AppTextStyle.body,
              fontSize: 13,
              fontWeight: isUploaded ? FontWeight.w600 : FontWeight.normal,
              color: isUploaded ? AppColors.successColor : AppColors.textColorPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
