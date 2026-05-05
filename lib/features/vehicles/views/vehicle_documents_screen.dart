import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../routes/route_helper.dart';
import '../controllers/vehicle_controller.dart';
import '../domain/models/vehicle_model.dart';

class VehicleDocumentsScreen extends StatefulWidget {
  const VehicleDocumentsScreen({Key? key}) : super(key: key);

  @override
  State<VehicleDocumentsScreen> createState() => _VehicleDocumentsScreenState();
}

class _VehicleDocumentsScreenState extends State<VehicleDocumentsScreen> {
  final VehicleController controller = Get.find<VehicleController>();
  late VehicleModel vehicle;

  @override
  void initState() {
    super.initState();
    vehicle = Get.arguments ?? controller.vehicles.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchVehicleDocuments(vehicle.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Documents',
        subtitle: vehicle.vehicleNumber,
      ),
      floatingActionButton: FloatingActionButton(heroTag: null,
        onPressed: () => Get.toNamed(RouteHelper.getDocumentUploadRoute(), arguments: vehicle),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Iconsax.document_upload, color: AppColors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.documents.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.documents.isEmpty) {
          return const Center(child: AppText('No documents uploaded', style: AppTextStyle.body));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.documents.length,
          itemBuilder: (context, index) {
            final doc = controller.documents[index];
            return _buildDocumentCard(doc);
          },
        );
      }),
    );
  }

  Widget _buildDocumentCard(VehicleDocument doc) {
    final bool isExpired = doc.expiryDate != null && doc.expiryDate!.isBefore(DateTime.now());

    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isExpired ? AppColors.errorColor.withOpacity(0.1) : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.description_rounded, 
              color: isExpired ? AppColors.errorColor : AppColors.primaryColor
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(doc.type, style: AppTextStyle.body, fontWeight: FontWeight.w600),
                const SizedBox(height: 4),
                AppText('Number: ${doc.number}', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                if (doc.expiryDate != null) ...[
                  const SizedBox(height: 2),
                  AppText('Expires: ${doc.expiryDate!.day}/${doc.expiryDate!.month}/${doc.expiryDate!.year}', 
                    style: AppTextStyle.caption, 
                    color: isExpired ? AppColors.errorColor : AppColors.textColorSecondary
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Iconsax.document_download, color: AppColors.primaryColor, size: 20),
                onPressed: () {
                  if (doc.fileUrl.isNotEmpty) {
                    Get.snackbar('Download', 'Opening document...', snackPosition: SnackPosition.BOTTOM);
                    // You can use url_launcher here if needed
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.visibility_rounded, color: AppColors.textColorHint, size: 20),
                onPressed: () {
                   if (doc.fileUrl.isNotEmpty) {
                    Get.toNamed('/document-preview', arguments: doc);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
