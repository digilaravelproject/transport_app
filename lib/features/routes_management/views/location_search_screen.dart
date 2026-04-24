import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../controllers/route_controller.dart';

class LocationSearchScreen extends StatefulWidget {
  final String title;
  const LocationSearchScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final controller = Get.find<RouteController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useScaffold: true,
      appBar: AppBar(
        title: AppText(widget.title, style: AppTextStyle.subheading, fontSize: 18),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppSearchBar(
              hint: 'Search location...',
              onChanged: (val) => controller.searchLocations(val),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isSearchingLocation.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.predictions.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.location, size: 48, color: AppColors.textColorHint),
                      SizedBox(height: 16),
                      AppText('Search for a location', color: AppColors.textColorHint),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.predictions.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1, 
                  thickness: 0.5, 
                  color: AppColors.slate200.withOpacity(0.5),
                ),
                itemBuilder: (context, index) {
                  final prediction = controller.predictions[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Iconsax.location, size: 18, color: AppColors.textColorSecondary),
                    ),
                    title: AppText(
                      prediction['description'], 
                      fontSize: 13, 
                      fontWeight: FontWeight.w500,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
                      );
                      
                      final details = await controller.getPlaceDetails(prediction['place_id']);
                      
                      if (!mounted) return;
                      Navigator.of(context).pop(); // close dialog

                      if (details != null) {
                        Navigator.of(context).pop({
                          'name': prediction['description'],
                          'lat': details['lat'],
                          'lng': details['lng'],
                        });
                      } else {
                        Get.snackbar(
                          'Error', 
                          'Could not get location details', 
                          backgroundColor: AppColors.errorColor, 
                          colorText: Colors.white,
                        );
                      }
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
