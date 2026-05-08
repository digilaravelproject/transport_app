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
import 'location_search_screen.dart';
import '../domain/models/route_model.dart';
import '../../../routes/route_helper.dart';

class CreateRouteScreen extends StatefulWidget {
  const CreateRouteScreen({Key? key}) : super(key: key);

  @override
  State<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends State<CreateRouteScreen> {
  final RouteController controller = Get.find<RouteController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  List<TextEditingController> _destinationControllers = [TextEditingController()];
  
  RouteModel? _editingRoute;

  @override
  void initState() {
    super.initState();
    _editingRoute = Get.arguments as RouteModel?;

    if (_editingRoute != null) {
      _nameController.text = _editingRoute!.routeName;
      controller.originController.text = _editingRoute!.origin;
      controller.distanceController.text = _editingRoute!.distanceKm.toString();
      controller.estimatedTimeController.text = _editingRoute!.estimatedTime;

      // Parse points
      if (_editingRoute!.points.isNotEmpty) {
        final startPoint = _editingRoute!.points.firstWhere((p) => p['type'] == 'start', orElse: () => _editingRoute!.points.first);
        _originPoint = Map<String, dynamic>.from(startPoint);

        final destPoints = _editingRoute!.points.where((p) => p['type'] != 'start').toList();
        if (destPoints.isNotEmpty) {
          _destinationControllers = destPoints.map((p) => TextEditingController(text: p['name'])).toList();
          _destinationPoints = List<Map<String, dynamic>?>.from(destPoints.map((p) => Map<String, dynamic>.from(p)));
          controller.destinationController.text = destPoints.last['name'] ?? '';
        }
      }

      // Parse schedules
      if (_editingRoute!.schedules.isNotEmpty) {
        _schedules.clear();
        for (var s in _editingRoute!.schedules) {
          _schedules.add({
            'departure': TextEditingController(text: s['departure_time'] ?? s['start_time']),
            'arrival': TextEditingController(text: s['arrival_time'] ?? s['end_time']),
            'days': List<String>.from(s['days'] is List ? s['days'] : [s['days']?.toString() ?? 'Daily']),
          });
        }
      }
    } else {
      // Initialize shared controllers for new route
      controller.originController.text = '';
      controller.destinationController.text = '';
      controller.distanceController.text = '';
      controller.estimatedTimeController.text = '';
    }
  }

  final List<Map<String, dynamic>> _schedules = [
    {
      'departure': TextEditingController(),
      'arrival': TextEditingController(),
      'days': <String>[],
    }
  ];

  Map<String, dynamic>? _originPoint;
  List<Map<String, dynamic>?> _destinationPoints = [null];

  final List<String> _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Daily'];

  @override
  void dispose() {
    _nameController.dispose();
    for (var c in _destinationControllers) {
      c.dispose();
    }
    for (var s in _schedules) {
      s['departure'].dispose();
      s['arrival'].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: _editingRoute != null ? 'Edit Route' : 'Create Route',
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            children: [
            // --- Route Information Section ---
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText('Route Information', 
                    fontSize: 18, 
                    fontWeight: FontWeight.w700, 
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(height: 12),
                  AppInputField(
                    label: 'Route Name',
                    hint: 'e.g. Pune to Mumbai Express',
                    icon: Iconsax.routing,
                    controller: _nameController,
                    isRequired: true,
                    validator: (val) => (val == null || val.isEmpty) ? 'Please enter a route name' : null,
                  ),
                  const SizedBox(height: 12),
                  
                  // Origin
                  AppInputField(
                    label: 'Origin (Start)',
                    hint: 'e.g. Swargate, Pune',
                    icon: Iconsax.location5,
                    controller: controller.originController,
                    readOnly: true,
                    isRequired: true,
                    validator: (val) => (val == null || val.isEmpty) ? 'Please select an origin' : null,
                    onTap: () async {
                      final result = await Get.to(() => const LocationSearchScreen(title: 'Search Origin'));
                      if (result != null) {
                        setState(() {
                          _originPoint = result;
                          controller.originController.text = result['name'];
                        });
                        controller.calculateRoute();
                      }
                    },
                  ),
                  const SizedBox(height: 12),

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
                            _destinationPoints.add(null);
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
                              readOnly: true,
                              isRequired: true,
                              validator: (val) => (val == null || val.isEmpty) ? 'Please select a destination' : null,
                              onTap: () async {
                                final result = await Get.to(() => LocationSearchScreen(title: 'Search Destination ${index + 1}'));
                                if (result != null) {
                                  setState(() {
                                    _destinationPoints[index] = result;
                                    _destinationControllers[index].text = result['name'];
                                    // If it's the last destination, set it as the primary destination for calculation
                                    if (index == _destinationControllers.length - 1) {
                                      controller.destinationController.text = result['name'];
                                    }
                                  });
                                  controller.calculateRoute();
                                }
                              },
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
                                    _destinationPoints.removeAt(index);
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
                          controller: controller.distanceController,
                          isRequired: true,
                          validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppInputField(
                          label: 'Estimated Time',
                          hint: 'e.g. 3h 30m',
                          icon: Iconsax.clock,
                          controller: controller.estimatedTimeController,
                          isRequired: true,
                          validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: AppInputField(
                                  label: 'Departure',
                                  hint: '08:00',
                                  icon: Iconsax.clock,
                                  controller: schedule['departure'],
                                  isRequired: true,
                                  validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
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
                                  isRequired: true,
                                  validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
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
                           const SizedBox(height: 12),
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
        onPressed: () async {
          if (!_formKey.currentState!.validate()) {
            return;
          }

          if (_originPoint == null || _destinationPoints.any((p) => p == null)) {
            Get.showSnackbar(GetSnackBar(
              message: 'Please select all locations from the search results',
              backgroundColor: AppColors.errorColor,
              duration: const Duration(seconds: 3),
            ));
            return;
          }

          // Check if at least one day is selected for each schedule
          for (int i = 0; i < _schedules.length; i++) {
            if ((_schedules[i]['days'] as List).isEmpty) {
               Get.showSnackbar(GetSnackBar(
                message: 'Please select frequency for Schedule ${i + 1}',
                backgroundColor: AppColors.errorColor,
                duration: const Duration(seconds: 3),
              ));
              return;
            }
          }

          final List<Map<String, dynamic>> points = [];
          
          // Add Start point
          points.add({
            "type": "start",
            "name": _originPoint!['name'],
            "lat": _originPoint!['lat'],
            "lng": _originPoint!['lng'],
            "order": 0
          });

          // Add intermediate stops and end point
          for (int i = 0; i < _destinationPoints.length; i++) {
            final isLast = i == _destinationPoints.length - 1;
            points.add({
              "type": isLast ? "end" : "stop",
              "name": _destinationPoints[i]!['name'],
              "lat": _destinationPoints[i]!['lat'],
              "lng": _destinationPoints[i]!['lng'],
              "order": i + 1
            });
          }

          final List<Map<String, dynamic>> schedules = _schedules.map((s) => {
            "departure_time": s['departure'].text,
            "arrival_time": s['arrival'].text,
            "days": s['days'],
          }).toList();

          final Map<String, dynamic> payload = {
            "name": _nameController.text,
            "distance": double.tryParse(controller.distanceController.text) ?? 0.0,
            "estimated_time": controller.estimatedTimeController.text,
            "points": points,
            "schedules": schedules,
          };

          final success = _editingRoute != null 
            ? await controller.updateRoute(_editingRoute!.id, payload)
            : await controller.createRoute(payload);

          if (success) {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
            Future.delayed(const Duration(milliseconds: 300), () {
              Get.showSnackbar(GetSnackBar(
                message: _editingRoute != null ? 'Route updated successfully' : 'Route created successfully',
                backgroundColor: AppColors.successColor,
                duration: const Duration(seconds: 3),
              ));
            });
          }
        },
      ),
    ),
  );
}
}
