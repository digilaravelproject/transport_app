import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/trip_controller.dart';
import '../domain/models/trip_model.dart';
import '../../../routes/route_helper.dart';
import '../../../core/widgets/app_image_preview.dart';
import '../../../core/constants/app_constants.dart';

class DutySheetListScreen extends StatefulWidget {
  const DutySheetListScreen({Key? key}) : super(key: key);

  @override
  State<DutySheetListScreen> createState() => _DutySheetListScreenState();
}

class _DutySheetListScreenState extends State<DutySheetListScreen> {
  final controller = Get.find<TripController>();
  late TripModel trip;

  @override
  void initState() {
    super.initState();
    trip = (Get.arguments is TripModel) ? Get.arguments : controller.selectedTrip.value!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDutySheets(trip.id.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Duty Sheets',
        subtitle: trip.tripNumber ?? 'TRP-000',
        trailing: IconButton(
          icon: const Icon(Iconsax.add_circle, color: AppColors.primaryColor),
          onPressed: () => Get.toNamed(RouteHelper.getDutySheetUploadRoute(), arguments: trip.id.toString()),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.dutySheets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.dutySheets.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchDutySheets(trip.id.toString()),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.dutySheets.length,
            itemBuilder: (context, index) {
              final sheet = controller.dutySheets[index];
              final note = sheet['notes']?.toString() ?? 'Signed duty sheet';
              final dateStr = sheet['created_at']?.toString() ?? '';
              
              String displayDate = 'N/A';
              if (dateStr.isNotEmpty) {
                try {
                  final date = DateTime.parse(dateStr);
                  displayDate = DateFormat('dd MMM, yyyy').format(date);
                } catch (_) {}
              }

              final String path = sheet['file_path']?.toString() ?? '';
              final String imageUrl = path.startsWith('http') ? path : "${AppConstants.imageBaseUrl}/$path";

              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.zero,
                onTap: () => AppImagePreview.show(
                  context, 
                  imageUrl: imageUrl, 
                  title: 'Duty Sheet - $displayDate',
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Iconsax.document_text, color: AppColors.primaryColor, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(note, style: AppTextStyle.subheading, fontSize: 15),
                            AppText(displayDate, style: AppTextStyle.caption),
                          ],
                        ),
                      ),
                      const Icon(Iconsax.eye, color: AppColors.primaryColor, size: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.document_copy, size: 64, color: AppColors.slate300),
            ),
            const SizedBox(height: 24),
            AppText('No Duty Sheets', style: AppTextStyle.subheading, fontSize: 18),
            const SizedBox(height: 8),
            AppText(
              'You haven\'t uploaded any duty sheets for this trip yet.',
              style: AppTextStyle.caption,
              align: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton.outline(
              text: 'Upload First Sheet',
              icon: const Icon(Iconsax.add, size: 20),
              onPressed: () => Get.toNamed(RouteHelper.getDutySheetUploadRoute(), arguments: trip.id.toString()),
            ),
          ],
        ),
      ),
    );
  }
}
