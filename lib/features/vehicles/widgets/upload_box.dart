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
  final String? remoteUrl;
  final String? localPath;
  final VoidCallback onTap;
  final bool isUploaded;

  const UploadBox({
    super.key,
    required this.label,
    this.fileName,
    this.previewUrl,
    this.remoteUrl,
    this.localPath,
    required this.onTap,
    this.isUploaded = false,
  });

  bool _isImage(String? path) {
    if (path == null) return false;
    final p = path.toLowerCase();
    // Common extensions
    if (p.endsWith('.jpg') || p.endsWith('.jpeg') || p.endsWith('.png') || p.endsWith('.webp') || p.endsWith('.gif') || p.endsWith('.bmp')) {
      return true;
    }
    // Check if it's a common image URI pattern or has image in the path
    if (p.contains('image') || p.contains('photo') || p.contains('graph')) {
       // Avoid matching .pdf even if it has 'image' in name
       if (p.endsWith('.pdf')) return false;
       return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final String? effectiveUrl = remoteUrl ?? previewUrl;
    final String? pathToCheck = localPath ?? effectiveUrl;
    final bool isImageFile = _isImage(pathToCheck);
    
    debugPrint('[UploadBox] label: $label, path: $pathToCheck, isImage: $isImageFile');
    
    return InkWell(
      onTap: isUploaded && (effectiveUrl != null || localPath != null)
          ? () {
              if (isImageFile) {
                AppImagePreview.show(
                  context,
                  imageUrl: effectiveUrl,
                  imagePath: localPath,
                  title: label,
                );
              } else {
                if (localPath != null) {
                  OpenFilex.open(localPath!);
                } else if (effectiveUrl != null) {
                  OpenFilex.open(effectiveUrl);
                }
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
        child: isUploaded && (effectiveUrl != null || localPath != null)
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
                                  : NetworkImage(effectiveUrl!),
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
                        'Supports: JPG, PNG, PDF or DOC',
                        fontSize: 11,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
