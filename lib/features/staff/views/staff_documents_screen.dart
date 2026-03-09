import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/staff_controller.dart';
import '../domain/models/staff_model.dart';

class StaffDocumentsScreen extends GetView<StaffController> {
  const StaffDocumentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StaffModel staff = Get.arguments ?? controller.staffList.first;

    return AppScaffold(
      appBar: AppHeader(
        title: 'Staff Documents',
        subtitle: staff.name,
      ),
      floatingActionButton: FloatingActionButton(heroTag: null,
        onPressed: () => _showUploadModal(),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Iconsax.document_upload, color: AppColors.white),
      ),
      body: Obx(() {
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.staffDocuments.length,
          itemBuilder: (context, index) {
            final doc = controller.staffDocuments[index];
            return _DocumentCard(doc: doc);
          },
        );
      }),
    );
  }

  void _showUploadModal() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText('Upload Document', style: AppTextStyle.heading, fontSize: 20),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                labelText: 'Document Name',
                filled: true,
                fillColor: AppColors.slate50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Expiry Date',
                hintText: 'DD/MM/YYYY',
                filled: true,
                fillColor: AppColors.slate50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.slate200)),
                    child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Iconsax.image, color: AppColors.textColorHint), AppText('Add Image', style: AppTextStyle.caption)]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.slate200)),
                    child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.picture_as_pdf_outlined, color: AppColors.textColorHint), AppText('Add PDF', style: AppTextStyle.caption)]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Get.back(), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const AppText('Submit Document', style: AppTextStyle.body, color: Colors.white, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final StaffDocument doc;
  const _DocumentCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.warningColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.description_outlined, color: AppColors.warningColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(doc.name, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                const SizedBox(height: 4),
                AppText('Uploaded: ${doc.uploadDate.day}/${doc.uploadDate.month}/${doc.uploadDate.year}', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                AppText('Expiry: ${doc.expiryDate.day}/${doc.expiryDate.month}/${doc.expiryDate.year}', style: AppTextStyle.caption, color: AppColors.errorColor),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(icon: const Icon(Icons.visibility_outlined, color: AppColors.primaryColor), onPressed: () {}),
              IconButton(icon: const Icon(Iconsax.document_download, color: AppColors.textColorHint), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }
}
