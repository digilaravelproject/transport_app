import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/template_controller.dart';
import '../domain/models/template_model.dart';
import 'add_edit_template_screen.dart';

class TemplateDetailsScreen extends StatelessWidget {
  const TemplateDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TemplateModel template = Get.arguments as TemplateModel;
    final controller = Get.find<TemplateController>();

    void deleteTemplate() {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Template'),
          content: Text('Are you sure you want to delete "${template.name}"? This cannot be undone.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                controller.deleteTemplate(template.id);
                Navigator.of(context).pop(); // Close dialog
                Get.back(); // Go back to list
                Get.snackbar('Deleted', 'Template deleted successfully', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.errorColor, colorText: AppColors.white);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }

    return AppScaffold(
      useScaffold: false,
      appBar: AppHeader(
        title: 'Template Details',
        trailing: Row(
          children: [
            IconButton(
              icon: const Icon(Iconsax.edit),
              onPressed: () => Get.to(() => AddEditTemplateScreen(template: template)),
            ),
            IconButton(
              icon: const Icon(Iconsax.trash, color: AppColors.errorColor),
              onPressed: deleteTemplate,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Card
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Iconsax.document_copy, color: AppColors.primaryColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(template.name, style: AppTextStyle.heading, fontSize: 20),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                  child: AppText(template.type, style: AppTextStyle.caption, color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                                if (template.isDefault) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: AppColors.successColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                    child: const AppText('DEFAULT', style: AppTextStyle.caption, color: AppColors.successColor, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (template.description.isNotEmpty) ...[
                    const Divider(height: 24),
                    const AppText('Description', style: AppTextStyle.label, color: AppColors.textColorHint),
                    const SizedBox(height: 6),
                    AppText(template.description, style: AppTextStyle.body, color: AppColors.textColorSecondary),
                  ],
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Iconsax.calendar_1, size: 14, color: AppColors.textColorHint),
                      const SizedBox(width: 6),
                      AppText(
                        'Last updated: ${template.lastUpdated.day}/${template.lastUpdated.month}/${template.lastUpdated.year}',
                        style: AppTextStyle.caption,
                        color: AppColors.textColorHint,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Actions Card
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText('Actions', style: AppTextStyle.subheading, fontSize: 16),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Edit Template',
                          onPressed: () => Get.to(() => AddEditTemplateScreen(template: template)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton.outline(
                          text: 'Delete',
                          color: AppColors.errorColor,
                          onPressed: deleteTemplate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Preview Template',
                    color: AppColors.infoColor,
                    onPressed: () => Get.snackbar('Preview', 'Template preview coming soon', snackPosition: SnackPosition.BOTTOM),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
