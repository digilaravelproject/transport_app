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
import '../../membership/controllers/membership_controller.dart';
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
  final controller = Get.find<RoleController>();

  static const List<String> _potentialPermissions = ['Trips', 'Vehicles', 'Staff', 'Leads', 'Corporate', 'Finance', 'Inventory', 'Shifts', 'Routes', 'Reports', 'Templates', 'Roles', 'Settings'];
  List<String> _allPermissions = [];
  List<String> _selectedPermissions = [];

  bool get isEdit => widget.role != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.role?.roleName ?? '');
    _descCtrl = TextEditingController(text: widget.role?.description ?? '');
    
    // Filter permissions based on Membership
    // Filter permissions based on Membership
    if (Get.isRegistered<MembershipController>()) {
      final membership = Get.find<MembershipController>();
      final sub = membership.activeSubscription.value;
      if (sub != null && sub.plan['module_access'] != null) {
        final allowedModules = (sub.plan['module_access'] as String).split(',').map((e) => e.trim()).toList();
        _allPermissions = _potentialPermissions.where((p) => allowedModules.contains(p)).toList();
      } else {
        // If no sub yet, keep it empty so it shows loading
        _allPermissions = [];
      }
    }
    
    _selectedPermissions = List.from(widget.role?.permissions ?? []);
    _isActive = widget.role?.isActive ?? true;

    // Ensure selected permissions only contain allowed ones
    _selectedPermissions.removeWhere((p) => !_allPermissions.contains(p));

    if (isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchFreshData());
    }
  }

  Future<void> _fetchFreshData() async {
    // 1. Fetch Membership/Subscription details first to know allowed modules
    final membership = Get.put(MembershipController());
    await membership.fetchCurrentSubscription();

    // 2. Fetch Role details
    await controller.fetchRoleDetails(widget.role!.id);
    
    final role = controller.selectedRole.value;
    if (role != null) {
      setState(() {
        // Update available permissions based on fresh membership data
        final sub = membership.activeSubscription.value;
        if (sub != null && sub.plan['module_access'] != null) {
          final allowedModules = (sub.plan['module_access'] as String).split(',').map((e) => e.trim()).toList();
          _allPermissions = _potentialPermissions
              .where((p) => allowedModules.contains(p)).toList();
        }

        _nameCtrl.text = role.roleName;
        _descCtrl.text = role.description;
        _isActive = role.isActive;
        _selectedPermissions = List.from(role.permissions);
        
        // Ensure selected permissions only contain currently allowed ones
        _selectedPermissions.removeWhere((p) => !_allPermissions.contains(p));
      });
    }
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPermissions.isEmpty) {
      Get.rawSnackbar(
        title: 'Validation',
        message: 'Please select at least one module',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warningColor,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    
    final controller = Get.find<RoleController>();
    
    bool success;
    if (isEdit) {
      success = await controller.updateRole(RoleModel(
        id: widget.role!.id,
        roleName: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        assignedUsersCount: widget.role!.assignedUsersCount,
        permissions: _selectedPermissions,
        level: widget.role!.level,
      ));
    } else {
      success = await controller.addRole(RoleModel(
        id: '', 
        roleName: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        assignedUsersCount: 0,
        permissions: _selectedPermissions,
      ));
    }

    if (success) {
      Get.back();
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.rawSnackbar(
          title: 'Success',
          message: isEdit ? 'Role updated' : 'Role created',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successColor,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RoleController>();

    return Stack(
      children: [
        AppScaffold(
          useScaffold: false,
          appBar: AppHeader(title: isEdit ? 'Edit Role' : 'New Role'),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(16),
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
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Role name is required';
                            if (v.trim().length < 3) return 'Role name must be at least 3 characters';
                            return null;
                          },
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
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Description is required';
                            if (v.trim().length < 5) return 'Description must be at least 5 characters';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const AppText('Module *', style: AppTextStyle.subheading, fontSize: 16),
                            TextButton(
                              onPressed: () {
                                final membership = Get.put(MembershipController());
                                List<String> displayPermissions = List.from(_allPermissions);
                                final sub = membership.activeSubscription.value;
                                if (sub != null && sub.plan['module_access'] != null) {
                                  final allowedModules = (sub.plan['module_access'] as String).split(',').map((e) => e.trim().toLowerCase()).toList();
                                  displayPermissions = displayPermissions.where((p) => allowedModules.contains(p.toLowerCase())).toList();
                                }
                                
                                setState(() {
                                  if (_selectedPermissions.length == displayPermissions.length) {
                                    _selectedPermissions.clear();
                                  } else {
                                    _selectedPermissions = List.from(displayPermissions);
                                  }
                                });
                              },
                              child: Obx(() {
                                final membership = Get.put(MembershipController());
                                List<String> displayPermissions = List.from(_allPermissions);
                                final sub = membership.activeSubscription.value;
                                if (sub != null && sub.plan['module_access'] != null) {
                                  final allowedModules = (sub.plan['module_access'] as String).split(',').map((e) => e.trim().toLowerCase()).toList();
                                  displayPermissions = displayPermissions.where((p) => allowedModules.contains(p.toLowerCase())).toList();
                                }
                                return Text(_selectedPermissions.length == displayPermissions.length ? 'Deselect All' : 'Select All');
                              }),
                            ),
                          ],
                        ),
                        if (_selectedPermissions.isEmpty) ...[
                          const SizedBox(height: 4),
                          const AppText('Please select at least one module', style: AppTextStyle.caption, color: AppColors.errorColor),
                        ],
                        const SizedBox(height: 12),
                        Obx(() {
                          final membership = Get.put(MembershipController());
                          
                          // Show loading if membership data is still fetching
                          if (membership.isLoading.value || _allPermissions.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          }

                          List<String> displayPermissions = List.from(_allPermissions);
                          
                          final sub = membership.activeSubscription.value;
                          if (sub != null && sub.plan['module_access'] != null) {
                            final allowedModules = (sub.plan['module_access'] as String).split(',').map((e) => e.trim().toLowerCase()).toList();
                            displayPermissions = displayPermissions.where((p) => allowedModules.contains(p.toLowerCase())).toList();
                          }

                          if (displayPermissions.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: AppText('No modules available for your current plan.', style: AppTextStyle.caption, color: AppColors.errorColor),
                            );
                          }

                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: displayPermissions.map((p) {
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
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText('Active', style: AppTextStyle.body, fontWeight: FontWeight.w600),
                            AppText(_isActive ? 'This role is enabled' : 'This role is disabled', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                          ],
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: _isActive,
                            onChanged: (v) => setState(() => _isActive = v),
                            activeColor: AppColors.primaryColor,
                            activeTrackColor: AppColors.primaryColor.withOpacity(0.3),
                          ),
                        ),
                      ],
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
        ),
        
        Obx(() => controller.isLoading.value 
          ? Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ) 
          : const SizedBox()
        ),
      ],
    );
  }
}
