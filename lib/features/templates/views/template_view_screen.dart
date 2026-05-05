import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../controllers/template_view_controller.dart';

class TemplateViewScreen extends GetView<TemplateViewController> {
  const TemplateViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: Obx(
        () => AppHeader(
          title: controller.title.value,
          subtitle: 'Template Preview',
          showBackButton: true,
          trailing: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshWebView,
          ),
        ),
      ),
      body: Obx(() {
        /// ERROR UI
        if (controller.hasError.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.errorColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load template',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textColorPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: controller.retryLoad,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Retry",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        /// WEBVIEW
        return Stack(
          children: [
            WebViewWidget(
              controller: controller.webViewController,
            ),

            /// FULL SCREEN LOADER (initial load)
            if (controller.isLoading.value)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading ${controller.title.value}...',
                        style: const TextStyle(
                          color: AppColors.textColorPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            /// TOP PROGRESS BAR (navigation/page loading)
            if (controller.isPageLoading.value && !controller.isLoading.value)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                ),
              ),
          ],
        );
      }),
    );
  }
}
