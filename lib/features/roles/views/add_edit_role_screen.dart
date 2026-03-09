import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/role_controller.dart';
import '../domain/models/role_model.dart';

class AddEditRoleScreen extends StatefulWidget {
  final RoleModel? role; // null = Add mode
  const AddEditRoleScreen({Key? key, this.role}) : super(key: key);

  @override
  State<AddEditRoleScreen> createState() => _AddEditRoleScreenState();
}

class _AddEditRoleScreenState extends State<AddEditRoleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  bool _isActive = true;

  final List<String> _allPermissions = ['Trips', 'Vehicles', 'Staff', 'Leads', 'Corporate', 'Finance', 'Inventory', 'Shifts', 'Routes', 'Reports', 'Templates', 'Roles', 'Settings'];
  List<String> _selectedPermissions = [];

  bool get isEdit => widget.role != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.role?.roleName ?? '');
    _descCtrl = TextEditingController(text: widget.role?.description ?? '');
    _selectedPermissions = List.from(widget.role?.permissions ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _togglePermission(String p) {
    setState(() {
      if (_selectedPermissions.contains(p)) {
        _selectedPermissions.remove(p);
      } else {
        _selectedPermissions.add(p);
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPermissions.isEmpty) {
      Get.snackbar('Validation', 'Please select at least one permission', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.warningColor, colorText: AppColors.white);
      return;
    }
    final controller = Get.find<RoleController>();
    if (isEdit) {
      controller.updateRole(RoleModel(
        id: widget.role!.id,
        roleName: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        assignedUsersCount: widget.role!.assignedUsersCount,
        permissions: _selectedPermissions,
      ));
      Get.back();
      Get.snackbar('Updated', 'Role updated successfully', snackPosition: SnackPosition.BOTTOM);
    } else {
      controller.addRole(RoleModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roleName: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        assignedUsersCount: 0,
        permissions: _selectedPermissions,
      ));
      Get.back();
      Get.snackbar('Created', 'Role created successfully', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useScaffold: false,
      appBar: AppHeader(title: isEdit ? 'Edit Role' : 'New Role'),
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
                    const AppText('Role Name *', style: AppTextStyle.label),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        hintText: 'e.g. Dispatcher',
                        prefixIcon: const Icon(Iconsax.shield_tick, color: AppColors.primaryColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryColor, width: 2)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Role name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    const AppText('Description', style: AppTextStyle.label),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'What can this role do?',
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppText('Permissions *', style: AppTextStyle.subheading, fontSize: 16),
                        TextButton(
                          onPressed: () => setState(() {
                            if (_selectedPermissions.length == _allPermissions.length) {
                              _selectedPermissions.clear();
                            } else {
                              _selectedPermissions = List.from(_allPermissions);
                            }
                          }),
                          child: Text(_selectedPermissions.length == _allPermissions.length ? 'Deselect All' : 'Select All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allPermissions.map((p) {
                        final selected = _selectedPermissions.contains(p);
                        return GestureDetector(
                          onTap: () => _togglePermission(p),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primaryColor : AppColors.primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: selected ? AppColors.primaryColor : AppColors.borderColor),
                            ),
                            child: AppText(p, style: AppTextStyle.caption, color: selected ? AppColors.white : AppColors.textColorSecondary, fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: SwitchListTile(
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  title: const AppText('Active', style: AppTextStyle.body, fontWeight: FontWeight.w600),
                  subtitle: AppText(_isActive ? 'This role is enabled' : 'This role is disabled', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                  activeColor: AppColors.successColor,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: isEdit ? 'Update Role' : 'Create Role',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
