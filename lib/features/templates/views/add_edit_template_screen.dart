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

class AddEditTemplateScreen extends StatefulWidget {
  final TemplateModel? template; // null = Add mode
  const AddEditTemplateScreen({Key? key, this.template}) : super(key: key);

  @override
  State<AddEditTemplateScreen> createState() => _AddEditTemplateScreenState();
}

class _AddEditTemplateScreenState extends State<AddEditTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  String _selectedType = 'Invoice';
  bool _isDefault = false;
  bool _isActive = true;

  final List<String> _types = ['Invoice', 'Quotation', 'Duty Slip', 'Receipt', 'Contract'];

  bool get isEdit => widget.template != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.template?.name ?? '');
    _descCtrl = TextEditingController(text: widget.template?.description ?? '');
    _selectedType = widget.template?.type ?? 'Invoice';
    _isDefault = widget.template?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final controller = Get.find<TemplateController>();
    if (isEdit) {
      controller.updateTemplate(TemplateModel(
        id: widget.template!.id,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        type: _selectedType,
        lastUpdated: DateTime.now(),
        isDefault: _isDefault,
      ));
      Get.back();
      Get.snackbar('Updated', 'Template updated successfully', snackPosition: SnackPosition.BOTTOM);
    } else {
      controller.addTemplate(TemplateModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        type: _selectedType,
        lastUpdated: DateTime.now(),
        isDefault: _isDefault,
      ));
      Get.back();
      Get.snackbar('Created', 'Template created successfully', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useScaffold: false,
      appBar: AppHeader(title: isEdit ? 'Edit Template' : 'New Template'),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('Template Name *', style: AppTextStyle.label),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        hintText: 'e.g. Standard Invoice',
                        prefixIcon: const Icon(Iconsax.document_copy, color: AppColors.primaryColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryColor, width: 2)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    const AppText('Type *', style: AppTextStyle.label),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Iconsax.category, color: AppColors.primaryColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryColor, width: 2)),
                      ),
                      items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setState(() => _selectedType = v!),
                    ),
                    const SizedBox(height: 16),
                    const AppText('Description', style: AppTextStyle.label),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Describe this template...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryColor, width: 2)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _isDefault,
                      onChanged: (v) => setState(() => _isDefault = v),
                      title: const AppText('Set as Default', style: AppTextStyle.body, fontWeight: FontWeight.w600),
                      subtitle: const AppText('Auto-select this when generating documents', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                      activeColor: AppColors.primaryColor,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      title: const AppText('Active', style: AppTextStyle.body, fontWeight: FontWeight.w600),
                      subtitle: AppText(_isActive ? 'Visible in document generation' : 'Hidden from document generation', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                      activeColor: AppColors.successColor,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: isEdit ? 'Update Template' : 'Create Template',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
