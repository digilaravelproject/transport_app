import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/app_text.dart';

/*class AssignDriverToContractScreen extends StatefulWidget {
  const AssignDriverToContractScreen({Key? key}) : super(key: key);

  @override
  State<AssignDriverToContractScreen> createState() => _AssignDriverScreenState();
}

class _AssignDriverScreenState extends State<AssignDriverToContractScreen> {
  final TextEditingController searchController = TextEditingController();

  final RxList<int> selectedDrivers = <int>[].obs;

  final List<Map<String, dynamic>> allDrivers = [
    {
      "id": 1,
      "name": "Ravi Kumar",
      "type": "Truck Driver",
      "registration_number": "UP32 AB 1234",
    },
    {
      "id": 2,
      "name": "Amit Singh",
      "type": "Mini Truck Driver",
      "registration_number": "UP32 XY 5678",
    },
    {
      "id": 3,
      "name": "Suresh Yadav",
      "type": "Heavy Driver",
      "registration_number": "UP32 MN 9999",
    },
    {
      "id": 4,
      "name": "Vikash Sharma",
      "type": "Bus Driver",
      "registration_number": "UP32 ZZ 1111",
    },
  ];

  final RxString searchText = ''.obs;

  List<Map<String, dynamic>> get filteredDrivers {
    if (searchText.value.isEmpty) return allDrivers;

    return allDrivers
        .where((d) =>
    d['name']
        .toString()
        .toLowerCase()
        .contains(searchText.value.toLowerCase()) ||
        d['registration_number']
            .toString()
            .toLowerCase()
            .contains(searchText.value.toLowerCase()))
        .toList();
  }

  void toggleSelect(int id) {
    if (selectedDrivers.contains(id)) {
      selectedDrivers.remove(id);
    } else {
      selectedDrivers.add(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Assign Driver',
        subtitle: 'Select drivers to assign',
      ),

      floatingActionButton: Obx(() {
        return selectedDrivers.isNotEmpty
            ? FloatingActionButton.extended(
          onPressed: () {
            Get.back();
          },
          backgroundColor: AppColors.primaryColor,
          icon: const Icon(Iconsax.tick_circle, color: Colors.white),
          label: AppText(
            'Assign ${selectedDrivers.length} Drivers',
            style: AppTextStyle.body,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )
            : const SizedBox.shrink();
      }),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: AppSearchBar(
              hint: 'Search Driver...',
              onChanged: (v) => searchText.value = v,
            ),
          ),

          Expanded(
            child: Obx(() {
              final list = filteredDrivers;

              if (list.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.user, size: 60, color: Colors.grey),
                      SizedBox(height: 10),
                      AppText('No drivers found'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final driver = list[index];
                  final int id = driver['id'];
                  final bool isSelected = selectedDrivers.contains(id);

                  return GestureDetector(
                    onTap: () => toggleSelect(id),

                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),

                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                          ),
                        ],
                      ),

                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          child: const Icon(
                            Icons.person,
                            color: AppColors.primaryColor,
                          ),
                        ),

                        title: AppText(
                          driver['name'],
                          style: AppTextStyle.body,
                          fontWeight: FontWeight.bold,
                        ),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            AppText(driver['type'],
                                style: AppTextStyle.caption),
                            AppText(driver['registration_number'],
                                style: AppTextStyle.caption),
                          ],
                        ),

                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                            color: AppColors.primaryColor)
                            : const Icon(Icons.radio_button_unchecked),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}*/




class AssignDriverToContractScreen extends StatefulWidget {
  const AssignDriverToContractScreen({Key? key}) : super(key: key);

  @override
  State<AssignDriverToContractScreen> createState() =>
      _AssignDriverToContractScreenState();
}

class _AssignDriverToContractScreenState
    extends State<AssignDriverToContractScreen> {
  final RxList<int> selectedDrivers = <int>[].obs;
  final RxString searchText = ''.obs;

  final List<Map<String, dynamic>> allDrivers = [
    {
      "id": 1,
      "name": "Ravi Kumar",
      "type": "Truck Driver",
      "registration_number": "UP32 AB 1234"
    },
    {
      "id": 2,
      "name": "Amit Singh",
      "type": "Mini Truck Driver",
      "registration_number": "UP32 XY 5678"
    },
    {
      "id": 3,
      "name": "Suresh Yadav",
      "type": "Heavy Driver",
      "registration_number": "UP32 MN 9999"
    },
    {
      "id": 4,
      "name": "Vikash Sharma",
      "type": "Bus Driver",
      "registration_number": "UP32 ZZ 1111"
    },
  ];

  // 🔥 FIXED SELECTION LOGIC
  void toggleSelect(int id) {
    if (selectedDrivers.contains(id)) {
      selectedDrivers.remove(id);
    } else {
      selectedDrivers.add(id);
    }

    selectedDrivers.refresh(); // IMPORTANT FIX
  }

  List<Map<String, dynamic>> get filteredDrivers {
    if (searchText.value.isEmpty) return allDrivers;

    return allDrivers.where((d) {
      final name = d['name'].toString().toLowerCase();
      final reg = d['registration_number'].toString().toLowerCase();
      final search = searchText.value.toLowerCase();

      return name.contains(search) || reg.contains(search);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Assign Driver',
        subtitle: 'Select drivers to assign',
      ),

      floatingActionButton: Obx(() {
        return selectedDrivers.isNotEmpty
            ? FloatingActionButton.extended(
          onPressed: () => Get.back(),
          backgroundColor: AppColors.primaryColor,
          icon: const Icon(Iconsax.tick_circle, color: Colors.white),
          label: AppText(
            'Assign ${selectedDrivers.length} Drivers',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )
            : const SizedBox.shrink();
      }),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: AppSearchBar(
              hint: 'Search Driver...',
              onChanged: (v) => searchText.value = v,
            ),
          ),

          Expanded(
            child: Obx(() {
              final list = filteredDrivers;

              if (list.isEmpty) {
                return const Center(
                  child: AppText('No drivers found'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final driver = list[index];
                  final int id = int.tryParse(driver['id'].toString()) ?? 0;

                  return Obx(() {
                    final bool isSelected = selectedDrivers.contains(id);

                    return GestureDetector(
                      onTap: () => toggleSelect(id),

                      child: AnimatedContainer(
                        key: ValueKey("driver_$id"),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,

                        margin: const EdgeInsets.only(bottom: 12),

                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryLight : Colors.white,
                          borderRadius: BorderRadius.circular(16),

                          // 🔥 SELECTED BORDER
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryColor
                                : AppColors.borderColor,
                            width: isSelected ? 1.0 : 1,
                          ),

                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.25),
                              blurRadius: 15,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ]
                              : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),

                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : AppColors.primaryLight,
                            ),
                            child: Icon(
                              Icons.person,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primaryColor,
                            ),
                          ),

                          title: AppText(
                            driver['name'].toString(),
                            fontWeight: FontWeight.bold,
                            style: AppTextStyle.body,
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              AppText(driver['type'].toString(), style: AppTextStyle.caption),
                              AppText(
                                driver['registration_number'].toString(),
                                color: AppColors.textColorSecondary,
                                style: AppTextStyle.caption,
                              ),
                            ],
                          ),
                          // trailing: Icon(
                          //   isSelected ? Iconsax.tick_circle5 : Iconsax.add_circle,
                          //   color: isSelected ? AppColors.primaryColor : Colors.grey.shade400,
                          // ),
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}