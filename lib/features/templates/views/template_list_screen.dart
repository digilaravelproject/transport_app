import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/app_filter_chip.dart';
import '../controllers/template_controller.dart';
import '../domain/models/template_model.dart';
import '../../../routes/route_helper.dart';

class TemplateListScreen extends GetView<TemplateController> {
  const TemplateListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<TemplateController>()) {
      Get.put(TemplateController());
    }

    return AppScaffold(
      useScaffold: false,
      appBar: const AppHeader(
        title: 'Templates',
        subtitle: 'Manage your documents',
      ),
      // floatingActionButton: FloatingActionButton(heroTag: null,
      //   onPressed: () => Get.toNamed(RouteHelper.getAddTemplateRoute()),
      //   backgroundColor: AppColors.primaryColor,
      //   child: const Icon(Iconsax.add, color: AppColors.white),
      // ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppSearchBar(
              hint: 'Search templates...',
              onChanged: (val) => controller.onSearchChanged(val),
            ),
          ),
          
          const SizedBox(height: 12),
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: controller.filterTypes.map((filter) {
                final isSelected = controller.selectedFilter.value == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AppFilterChip(
                    label: filter,
                    isSelected: isSelected,
                    onTap: () => controller.setFilter(filter),
                  ),
                );
              }).toList(),
            ),
          )),
          
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }
              
              if (controller.filteredTemplates.isEmpty) {
                return const Center(child: AppText('No templates found', style: AppTextStyle.body));
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                itemCount: controller.filteredTemplates.length,
                itemBuilder: (context, index) {
                  final template = controller.filteredTemplates[index];
                  return _TemplateCard(template: template);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final TemplateModel template;
  const _TemplateCard({required this.template});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () {
        if (template.url != null && template.url!.isNotEmpty) {
          Get.toNamed(
            RouteHelper.getTemplateViewRoute(),
            arguments: {
              'title': template.name,
              'url': template.url!,
            },
          );
        } else {
          Get.toNamed(RouteHelper.getTemplateDetailsRoute(), arguments: template);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Iconsax.document_copy, color: AppColors.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  AppText(template.type, style: AppTextStyle.caption, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                ],
              ),
              if (template.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const AppText('DEFAULT', style: AppTextStyle.caption, color: AppColors.successColor, fontSize: 10),
                ),
            ],
          ),
          const SizedBox(height: 12),
          AppText(template.name, style: AppTextStyle.subheading, fontSize: 16),
          const SizedBox(height: 4),
          AppText(template.description, style: AppTextStyle.body, color: AppColors.textColorSecondary),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'Updated ${template.lastUpdated.day}/${template.lastUpdated.month}/${template.lastUpdated.year}', 
                style: AppTextStyle.caption, 
                color: AppColors.textColorHint
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Iconsax.eye, size: 20, color: AppColors.textColorSecondary),
                    onPressed: () {
                      if (template.url != null && template.url!.isNotEmpty) {
                        Get.toNamed(
                          RouteHelper.getTemplateViewRoute(),
                          arguments: {
                            'title': template.name,
                            'url': template.url!,
                          },
                        );
                      } else {
                        Get.toNamed(RouteHelper.getTemplateDetailsRoute(), arguments: template);
                      }
                    },
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  // IconButton(
                  //   icon: const Icon(Iconsax.edit, size: 20, color: AppColors.primaryColor),
                  //   onPressed: () => Get.toNamed(RouteHelper.getEditTemplateRoute(), arguments: template),
                  //   constraints: const BoxConstraints(),
                  //   padding: EdgeInsets.zero,
                  // ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
