import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../routes/route_helper.dart';

class IntroController extends GetxController {
  var currentPage = 0.obs;
  final pageController = PageController();

  final List<Map<String, String>> introData = [
    {
      'title': 'Streamline Your Fleet',
      'description': 'Efficiently manage leads, trips, and vehicles in one centralized dashboard built for growth.',
      'image': 'assets/images/intro_1_v2.png',
    },
    {
      'title': 'Real-time Trip Tracking',
      'description': 'Assign drivers, monitor routes, and handle expenses seamlessly with our intelligent tracking system.',
      'image': 'assets/images/intro_2_v2.png',
    },
    {
      'title': 'Power Your Profits',
      'description': 'Gain deep insights into your revenue, expenses, and financial health with automated reporting.',
      'image': 'assets/images/intro_3_v2.png',
    },
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < introData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } else {
      getStarted();
    }
  }

  void backPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  void getStarted() {
    Get.offAllNamed(RouteHelper.getSignupRoute());
  }
}
