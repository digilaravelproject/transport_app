import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../controllers/trip_controller.dart';
import '../../../core/widgets/app_input_field.dart';
import 'package:path/path.dart';

class DutySheetUploadScreen extends StatefulWidget {
  const DutySheetUploadScreen({Key? key}) : super(key: key);

  @override
  State<DutySheetUploadScreen> createState() => _DutySheetUploadScreenState();
}

class _DutySheetUploadScreenState extends State<DutySheetUploadScreen> {
  XFile? selectedFile;
  final controller = Get.find<TripController>();
  final notesController = TextEditingController();
  late String tripId;

  @override
  void initState() {
    super.initState();
    tripId = Get.arguments?.toString() ?? "";
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() => selectedFile = image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(title: 'Upload Duty Sheet'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Iconsax.document, size: 64, color: AppColors.primaryColor),
                  const SizedBox(height: 16),
                  const AppText(
                    'Upload Driver Duty Sheet',
                    style: AppTextStyle.subheading,
                    fontSize: 18,
                  ),
                  const SizedBox(height: 8),
                  const AppText(
                    'Please scan or take a photo of the signed duty sheet for record validation.',
                    style: AppTextStyle.caption,
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (selectedFile == null)
                    Row(
                      children: [
                        Expanded(
                          child: _buildUploadOption(Iconsax.camera, 'Camera', () => _pickImage(ImageSource.camera)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildUploadOption(Icons.photo_library_rounded, 'Gallery', () => _pickImage(ImageSource.gallery)),
                        ),
                      ],
                    )
                  else
                    _buildPreview(),
                  const SizedBox(height: 24),
                  AppInputField(
                    label: 'Notes',
                    controller: notesController,
                    hint: 'Enter any notes (optional)',
                    icon: Iconsax.note_2,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Obx(() => AppButton(
              text: 'Submit Duty Sheet',
              isLoading: controller.isLoading.value,
              onPressed: selectedFile != null ? () async {
                final success = await controller.uploadDutySheet(tripId, selectedFile!, notesController.text);
                if (success) {
                  Get.back(closeOverlays: true);
                  Get.snackbar(
                    'Success', 
                    'Duty sheet uploaded successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.withOpacity(0.1),
                    colorText: Colors.green,
                  );
                }
              } : null,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.slate200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryColor),
            const SizedBox(height: 8),
            AppText(label, style: AppTextStyle.body, fontSize: 13),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.successColor.withOpacity(0.5)),
                image: DecorationImage(
                  image: FileImage(File(selectedFile!.path)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => setState(() => selectedFile = null),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppColors.errorColor, shape: BoxShape.circle),
                  child: const Icon(Iconsax.close_circle, color: AppColors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppText(basename(selectedFile!.path), style: AppTextStyle.body, fontWeight: FontWeight.w600),
      ],
    );
  }
}
