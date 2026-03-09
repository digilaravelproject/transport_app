import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';

class PdfViewerScreen extends StatelessWidget {
  const PdfViewerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Quotation PDF',
        onBack: () => Navigator.of(context).pop(),
        trailing: Row(
          children: [
            IconButton(icon: const Icon(Iconsax.document_download), onPressed: () {}),
            IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        color: AppColors.slate200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf_rounded, size: 80, color: AppColors.textColorHint),
            const SizedBox(height: 20),
            const AppText('PDF Viewer Interface', style: AppTextStyle.subheading),
            const SizedBox(height: 8),
            AppText('QTN-DOCUMENT-${DateTime.now().millisecond}.pdf', style: AppTextStyle.caption),
            const SizedBox(height: 40),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: List.generate(10, (index) => Container(
                  height: 10,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
