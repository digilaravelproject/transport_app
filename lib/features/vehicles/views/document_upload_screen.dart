import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input_field.dart';
import '../widgets/upload_box.dart';
import '../controllers/vehicle_controller.dart';
import '../domain/models/vehicle_model.dart';
import '../../../core/utils/custom_snackbar.dart';



class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({Key? key}) : super(key: key);

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final VehicleController controller = Get.find<VehicleController>();
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final notesController = TextEditingController(text: 'Registration certificate');
  final alertDaysController = TextEditingController(text: '30');
  DateTime issueDate = DateTime.now();
  DateTime expiryDate = DateTime.now().add(const Duration(days: 365));
  PlatformFile? pickedFile;
  dynamic vehicleId;

  final RxString nameError = ''.obs;
  final RxString numberError = ''.obs;
  final RxString fileError = ''.obs;
  final RxString alertDaysError = ''.obs;

  @override
  void initState() {
    super.initState();
    final dynamic args = Get.arguments;
    if (args is VehicleModel) {
      vehicleId = args.id;
    } else if (args is Map && args.containsKey('id')) {
      vehicleId = args['id'];
    } else {
      vehicleId = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(title: 'Upload Document'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              child: Column(
                children: [
                  Obx(() => AppInputField(
                    label: 'Document Name',
                    hint: 'e.g. RC, Insurance, Permit',
                    controller: nameController,
                    isRequired: true,
                    errorText: nameError.value.isEmpty ? null : nameError.value,
                    onChanged: (v) => nameError.value = '',
                  )),
                  const SizedBox(height: 16),
                  Obx(() => AppInputField(
                    label: 'Document Number',
                    hint: 'e.g. MH12AB1234',
                    controller: numberController,
                    isRequired: true,
                    errorText: numberError.value.isEmpty ? null : numberError.value,
                    onChanged: (v) => numberError.value = '',
                  )),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          'Issue Date',
                          issueDate,
                          (d) => setState(() => issueDate = d),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateField(
                          'Expiry Date',
                          expiryDate,
                          (d) => setState(() => expiryDate = d),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => AppInputField(
                          label: 'Alert Before (Days)',
                          hint: 'e.g. 30',
                          controller: alertDaysController,
                          keyboardType: TextInputType.number,
                          errorText: alertDaysError.value.isEmpty ? null : alertDaysError.value,
                          onChanged: (v) => alertDaysError.value = '',
                        )),
                      ),
                      const SizedBox(width: 12),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Notes',
                    hint: 'e.g. Registration certificate',
                    controller: notesController,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UploadBox(
                  label: 'Document File',
                  isUploaded: pickedFile != null,
                  fileName: pickedFile?.name,
                  localPath: pickedFile?.path,
                  onTap: _pickFile,
                ),
                if (fileError.value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: AppText(fileError.value, color: Colors.red, fontSize: 12),
                  ),
              ],
            )),
            const SizedBox(height: 40),
            Obx(() => AppButton(
              text: 'Save Document',
              isLoading: controller.isLoading.value,
              onPressed: _validateAndSave,
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
    );
    if (result != null) {
      setState(() {
        pickedFile = result.files.first;
        fileError.value = '';
      });
    }
  }

  Future<void> _validateAndSave() async {
    bool isValid = true;
    
    if (nameController.text.trim().isEmpty) {
      nameError.value = 'Please enter document name';
      isValid = false;
    }
    
    if (numberController.text.trim().isEmpty) {
      numberError.value = 'Please enter document number';
      isValid = false;
    }
    
    if (pickedFile == null) {
      fileError.value = 'Please upload a document file';
      isValid = false;
    }

    if (isValid) {
      final success = await controller.uploadDocument(
        vehicleId: vehicleId,
        documentType: nameController.text.trim(),
        documentNumber: numberController.text.trim(),
        issueDate: issueDate,
        expiryDate: expiryDate,
        file: pickedFile!,
        notes: notesController.text.trim(),
        alertBeforeDays: int.tryParse(alertDaysController.text.trim()) ?? 30,
      );

      if (success) {
        Navigator.pop(context, true);
        CustomSnackbar.showSuccess('Document uploaded successfully');
      } else {
        CustomSnackbar.showError('Failed to upload document');
      }
    }
  }

  Widget _buildDateField(String label, DateTime date, Function(DateTime) onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.body, fontSize: 13, fontWeight: FontWeight.w600),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2000),
              lastDate: DateTime.now().add(const Duration(days: 365*15)),
            );
            if (picked != null) onPick(picked);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AppText(
                    '${date.day}/${date.month}/${date.year}',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(Iconsax.calendar_1, size: 18, color: AppColors.primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
