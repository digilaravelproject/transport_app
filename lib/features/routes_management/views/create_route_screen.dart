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
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final List<TextEditingController> _destinationControllers = [TextEditingController()];
  
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  final List<Map<String, dynamic>> _schedules = [
    {
      'departure': TextEditingController(),
      'arrival': TextEditingController(),
      'days': <String>[],
    }
  ];

  final List<String> _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Daily'];

  @override
  void dispose() {
    _nameController.dispose();
    _originController.dispose();
    for (var c in _destinationControllers) {
      c.dispose();
    }
    _distanceController.dispose();
    _timeController.dispose();
    for (var s in _schedules) {
      s['departure'].dispose();
      s['arrival'].dispose();
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          children: [
            // --- Route Information Section ---
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText('Route Information', 
                    fontSize: 18, 
                    fontWeight: FontWeight.w700, 
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(height: 20),
                  AppInputField(
                    label: 'Route Name',
                    hint: 'e.g. Pune to Mumbai Express',
                    icon: Iconsax.routing,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 20),
                  
                  // Origin
                  AppInputField(
                    label: 'Origin (Start)',
                    hint: 'e.g. Swargate, Pune',
                    icon: Iconsax.location5,
                    controller: _originController,
                  ),
                  const SizedBox(height: 20),

                  // Destinations (Multiple)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText('Destinations', 
                        fontSize: 14, 
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColorPrimary,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _destinationControllers.add(TextEditingController());
                          });
                        },
                        child: const Row(
                          children: [
                            Icon(Iconsax.add, size: 18, color: AppColors.primaryColor),
                            SizedBox(width: 4),
                            AppText('Add Destination', 
                              fontSize: 13, 
                              color: AppColors.primaryColor, 
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_destinationControllers.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppInputField(
                              hint: index == 0 ? 'e.g. Dadar, Mumbai' : 'Enter destination...',
                              icon: Iconsax.location,
                              controller: _destinationControllers[index],
                            ),
                          ),
                          if (_destinationControllers.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: AppColors.errorColor, size: 22),
                                onPressed: () {
                                  setState(() {
                                    _destinationControllers[index].dispose();
                                    _destinationControllers.removeAt(index);
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppInputField(
                          label: 'Distance (km)',
                          hint: '0',
                          icon: Iconsax.map,
                          keyboardType: TextInputType.number,
                          controller: _distanceController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppInputField(
                          label: 'Estimated Time',
                          hint: 'e.g. 3h 30m',
                          icon: Iconsax.clock,
                          controller: _timeController,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // --- Schedules Section ---
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText('Schedules', 
                        fontSize: 18, 
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColorPrimary,
                      ),
                      TextButton.icon(
                        icon: const Icon(Iconsax.add, size: 20, color: AppColors.primaryColor),
                        label: const AppText('Add Schedule', 
                          fontSize: 14, 
                          color: AppColors.primaryColor, 
                          fontWeight: FontWeight.bold,
                        ),
                        onPressed: () {
                          setState(() {
                            _schedules.add({
                              'departure': TextEditingController(),
                              'arrival': TextEditingController(),
                              'days': <String>[],
                            });
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_schedules.length, (index) {
                    final schedule = _schedules[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              AppText('Schedule ${index + 1}', 
                                fontSize: 14, 
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColorPrimary,
                              ),
                              const Spacer(),
                              if (_schedules.length > 1)
                                IconButton(
                                  icon: const Icon(Iconsax.trash, color: AppColors.errorColor, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _schedules[index]['departure'].dispose();
                                      _schedules[index]['arrival'].dispose();
                                      _schedules.removeAt(index);
                                    });
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: AppInputField(
                                  label: 'Departure',
                                  hint: '08:00',
                                  icon: Iconsax.clock,
                                  controller: schedule['departure'],
                                  onTap: () async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (time != null) {
                                      schedule['departure'].text = time.format(context);
                                    }
                                  },
                                  readOnly: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppInputField(
                                  label: 'Arrival',
                                  hint: '11:30',
                                  icon: Iconsax.clock,
                                  controller: schedule['arrival'],
                                  onTap: () async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (time != null) {
                                      schedule['arrival'].text = time.format(context);
                                    }
                                  },
                                  readOnly: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const AppText('Frequency', 
                            fontSize: 13, 
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColorSecondary,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _allDays.map((day) {
                              final isSelected = (schedule['days'] as List<String>).contains(day);
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      (schedule['days'] as List<String>).remove(day);
                                    } else {
                                      if (day == 'Daily') {
                                        (schedule['days'] as List<String>).clear();
                                        (schedule['days'] as List<String>).add('Daily');
                                      } else {
                                        (schedule['days'] as List<String>).remove('Daily');
                                        (schedule['days'] as List<String>).add(day);
                                      }
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primaryColor : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primaryColor : AppColors.slate200,
                                    ),
                                    boxShadow: isSelected ? [
                                      BoxShadow(
                                        color: AppColors.primaryColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      )
                                    ] : null,
                                  ),
                                  child: AppText(day, 
                                    fontSize: 12, 
                                    color: isSelected ? Colors.white : AppColors.textColorSecondary,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: AppButton(
          text: 'Save Route',
          onPressed: () {
            Get.snackbar(
              'Success', 
              'New route "${_nameController.text}" created successfully.', 
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.successColor,
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
            );
            Get.back();
          },
        ),
      ),
    );
  }
}
