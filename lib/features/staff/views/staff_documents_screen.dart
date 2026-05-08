import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../vehicles/widgets/upload_box.dart';
import '../../../core/widgets/app_image_preview.dart';
import '../controllers/staff_controller.dart';
import '../domain/models/staff_model.dart';

class StaffDocumentsScreen extends GetView<StaffController> {
  const StaffDocumentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StaffModel staff = Get.arguments ?? controller.staffList.first;

    // Fetch documents on build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchStaffDocuments(staff.id);
    });

    return AppScaffold(
      appBar: AppHeader(
        title: 'Staff Documents',
        subtitle: staff.name,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _showUploadModal(staff.id),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Iconsax.document_upload, color: AppColors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.staffDocuments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.staffDocuments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.document_text, size: 64, color: AppColors.textColorHint.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                const AppText('No documents found', style: AppTextStyle.body, color: AppColors.textColorHint),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchStaffDocuments(staff.id),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.staffDocuments.length,
            itemBuilder: (context, index) {
              final doc = controller.staffDocuments[index];
              return _DocumentCard(doc: doc, controller: controller);
            },
          ),
        );
      }),
    );
  }

  void _showUploadModal(int staffId) {
    Get.bottomSheet(
      _UploadDocumentModal(staffId: staffId, controller: controller),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }
}

class _UploadDocumentModal extends StatefulWidget {
  final int staffId;
  final StaffController controller;
  const _UploadDocumentModal({required this.staffId, required this.controller});

  @override
  State<_UploadDocumentModal> createState() => _UploadDocumentModalState();
}

class _UploadDocumentModalState extends State<_UploadDocumentModal> {
  final _formKey = GlobalKey<FormState>();
  final _docNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  
  String _selectedDocType = 'aadhar';
  PlatformFile? _selectedFile;

  final List<Map<String, String>> _docTypes = [
    {'value': 'aadhar', 'label': 'Aadhar Card'},
    {'value': 'pan', 'label': 'PAN Card'},
    {'value': 'license', 'label': 'Driving License'},
  //  {'value': 'badge', 'label': 'Badge'},
    {'value': 'bank_passbook', 'label': 'Bank Passbook'},
    {'value': 'photo', 'label': 'Photo'},
  ];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
    );
    if (picked != null) {
      setState(() {
        _expiryDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText('Upload Document', style: AppTextStyle.heading, fontSize: 20),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 24),
              
              const AppText('Document Type', style: AppTextStyle.label),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedDocType,
                items: _docTypes.map((type) {
                  return DropdownMenuItem(
                    value: type['value'],
                    child: AppText(type['label']!, style: AppTextStyle.body),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedDocType = val!),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.slate50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.slate200)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
              
              const SizedBox(height: 16),
              AppInputField(
                label: 'Document Number',
                hint: 'Enter document number',
                controller: _docNumberController,
                icon: Iconsax.hashtag,
                validator: (val) => (val == null || val.isEmpty) ? 'Please enter document number' : null,
              ),
              
              const SizedBox(height: 16),
              AppInputField(
                label: 'Expiry Date',
                hint: 'YYYY-MM-DD',
                controller: _expiryDateController,
                icon: Iconsax.calendar_1,
                readOnly: true,
                onTap: _selectDate,
                validator: (val) => (val == null || val.isEmpty) ? 'Please select expiry date' : null,
              ),
              
              const SizedBox(height: 24),
              UploadBox(
                label: 'Document File',
                fileName: _selectedFile?.name,
                localPath: _selectedFile?.path,
                isUploaded: _selectedFile != null,
                onTap: _pickFile,
              ),
              
              const SizedBox(height: 32),
              Obx(() => AppButton(
                text: 'Submit Document',
                isLoading: widget.controller.isLoading.value,
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  
                  if (_selectedFile == null) {
                    Get.snackbar('Error', 'Please select a file', backgroundColor: AppColors.errorColor, colorText: Colors.white);
                    return;
                  }
                  
                  final success = await widget.controller.uploadStaffDocument(
                    staffId: widget.staffId,
                    documentType: _selectedDocType,
                    documentNumber: _docNumberController.text,
                    expiryDate: _expiryDateController.text,
                    filePath: _selectedFile?.path,
                  );
                  
                  if (success) {
                    Get.back();
                  }
                },
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final StaffDocument doc;
  final StaffController controller;
  const _DocumentCard({required this.doc, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: doc.viewUrl != null 
          ? () => AppImagePreview.show(
              context, 
              imageUrl: doc.viewUrl, 
              title: doc.name,
              onDownload: doc.downloadUrl != null ? () => controller.downloadFile(doc.downloadUrl!) : null,
            )
          : null,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
              image: (doc.viewUrl != null && (doc.viewUrl!.toLowerCase().endsWith('.jpg') || doc.viewUrl!.toLowerCase().endsWith('.jpeg') || doc.viewUrl!.toLowerCase().endsWith('.png')))
                  ? DecorationImage(
                      image: NetworkImage(doc.viewUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (doc.viewUrl != null && (doc.viewUrl!.toLowerCase().endsWith('.jpg') || doc.viewUrl!.toLowerCase().endsWith('.jpeg') || doc.viewUrl!.toLowerCase().endsWith('.png')))
                ? null
                : const Icon(Icons.description_outlined, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(doc.name, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                const SizedBox(height: 4),
                if (doc.documentNumber != null && doc.documentNumber!.isNotEmpty)
                  AppText('Number: ${doc.documentNumber}', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                if (doc.expiryDate != null)
                  AppText('Expiry: ${doc.expiryDate!.day}/${doc.expiryDate!.month}/${doc.expiryDate!.year}', style: AppTextStyle.caption, color: AppColors.errorColor),
                if (doc.createdAt != null)
                  AppText('Uploaded: ${doc.createdAt}', style: AppTextStyle.caption, color: AppColors.textColorHint, fontSize: 10),
              ],
            ),
          ),
          Column(
            children: [
              if (doc.viewUrl != null)
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, color: AppColors.primaryColor),
                  onPressed: () => AppImagePreview.show(
                    context, 
                    imageUrl: doc.viewUrl, 
                    title: doc.name,
                    onDownload: doc.downloadUrl != null ? () => controller.downloadFile(doc.downloadUrl!) : null,
                  ),
                ),
              if (doc.downloadUrl != null)
                IconButton(
                  icon: const Icon(Iconsax.document_download, color: AppColors.primaryColor),
                  onPressed: () => controller.downloadFile(doc.downloadUrl!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
