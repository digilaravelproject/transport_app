import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_image_preview.dart';

class UploadBox extends StatelessWidget {
  final String label;
  final String? fileName;
  final String? previewUrl;
  final String? localPath;
  final VoidCallback onTap;
  final bool isUploaded;

  const UploadBox({
    super.key,
    required this.label,
    this.fileName,
    this.previewUrl,
    this.localPath,
    required this.onTap,
    this.isUploaded = false,
  });

  bool _isImage(String? path) {
    if (path == null) return false;
    final ext = path.toLowerCase();
    return ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.png') || ext.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    final bool isImageFile = _isImage(localPath ?? previewUrl);
    
    return InkWell(
      onTap: isUploaded && (previewUrl != null || localPath != null)
          ? () {
              if (isImageFile) {
                AppImagePreview.show(
                  context,
                  imageUrl: previewUrl,
                  imagePath: localPath,
                  title: label,
                );
              } else if (localPath != null) {
                OpenFilex.open(localPath!);
              }
            }
          : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: isUploaded ? AppColors.successColor.withValues(alpha: 0.05) : AppColors.slate50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUploaded ? AppColors.successColor : AppColors.slate200,
            width: 1.2,
            style: BorderStyle.solid,
          ),
        ),
        child: isUploaded && (previewUrl != null || localPath != null)
            ? Row(
                children: [
                   Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.slate200),
                      color: isImageFile ? null : AppColors.white,
                      image: isImageFile
                          ? DecorationImage(
                              image: localPath != null
                                  ? FileImage(File(localPath!)) as ImageProvider
                                  : NetworkImage(previewUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: Center(
                      child: isImageFile
                          ? Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Iconsax.eye, size: 12, color: Colors.white),
                            )
                          : const Icon(Iconsax.document_text1, size: 24, color: AppColors.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          label,
                          style: AppTextStyle.body,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColorPrimary,
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          fileName ?? (isImageFile ? 'Image Uploaded' : 'Document Uploaded'),
                          fontSize: 11,
                          color: AppColors.successColor,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onTap,
                    icon: const Icon(Iconsax.edit, size: 18, color: AppColors.primaryColor),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Iconsax.document_upload,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Upload $label',
                        style: AppTextStyle.body,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        'JPG, PNG, PDF or DOC',
                        fontSize: 10,
                        color: AppColors.textColorSecondary.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
