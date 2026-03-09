import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input_field.dart';
import '../controllers/route_controller.dart';

class CreateRouteScreen extends StatefulWidget {
  const CreateRouteScreen({Key? key}) : super(key: key);

  @override
  State<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends State<CreateRouteScreen> {
  final RouteController controller = Get.find<RouteController>();
  final List<TextEditingController> _stopControllers = [TextEditingController()];

  @override
  void dispose() {
    for (var c in _stopControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Create Route',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('Route Information', style: AppTextStyle.subheading, color: AppColors.primaryColor),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Route Name',
                    hint: 'e.g. Pune to Mumbai Express',
                    icon: Icons.route_outlined,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Origin (Start)',
                    hint: 'e.g. Swargate, Pune',
                    icon: Icons.place_rounded,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Destination (End)',
                    hint: 'e.g. Dadar, Mumbai',
                    icon: Icons.place_outlined,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: const AppInputField(
                          label: 'Distance (km)',
                          hint: '0',
                          icon: Iconsax.map,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: const AppInputField(
                          label: 'Estimated Time',
                          hint: 'e.g. 3h 30m',
                          icon: Icons.access_time_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
             const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText('Via Stops (Optional)', style: AppTextStyle.subheading),
                      TextButton.icon(
                        icon: const Icon(Iconsax.add, size: 20, color: AppColors.primaryColor),
                        label: const AppText('Add Stop', style: AppTextStyle.caption, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                        onPressed: () {
                          setState(() {
                            _stopControllers.add(TextEditingController());
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_stopControllers.length, (index) {
                     return Padding(
                       padding: const EdgeInsets.only(bottom: 12),
                       child: Row(
                         children: [
                           Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.slate50,
                                shape: BoxShape.circle,
                              ),
                              child: AppText('${index + 1}', style: AppTextStyle.caption, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppInputField(
                                hint: 'Stop name...',
                                controller: _stopControllers[index],
                              ),
                            ),
                            if (_stopControllers.length > 1)
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: AppColors.errorColor),
                                onPressed: () {
                                  setState(() {
                                    _stopControllers[index].dispose();
                                    _stopControllers.removeAt(index);
                                  });
                                },
                              )
                         ],
                       ),
                     );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Save Route',
              onPressed: () {
                Get.snackbar('Success', 'New route created.', snackPosition: SnackPosition.BOTTOM);
                Get.back();
              },
            ),
            const SizedBox(height: 12),
            AppButton.outline(
              text: 'Cancel',
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}
