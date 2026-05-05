import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../controllers/template_view_controller.dart';

/*
class TemplateViewScreen extends GetView<TemplateViewController> {
  const TemplateViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: Obx(() => AppHeader(
        title: controller.title.value,
        subtitle: 'Template Preview',
        showBackButton: true,
        trailing: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => controller.refreshWebView(),
        ),
      )),
      body: Obx(() {
        print("template url : ${controller.url.value}");
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Loading template...',
                  style: TextStyle(
                    color: AppColors.textColorPrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'URL: ${controller.url.value}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textColorSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }

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
                  const SizedBox(height: 8),
                  Text(
                    'URL: ${controller.url.value}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textColorSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => controller.retryLoad(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () {
                          // Copy URL to clipboard
                          // You can implement clipboard functionality here
                          CustomSnackbar.showSuccess('URL copied to clipboard');
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryColor),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Copy URL',
                          style: TextStyle(color: AppColors.primaryColor),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () async {
                          // Open URL in external browser
                          try {
                            final Uri uri = Uri.parse(controller.url.value);
                            // You can use url_launcher here if needed
                            CustomSnackbar.showSuccess('Opening in browser...');
                          } catch (e) {
                            CustomSnackbar.showError('Failed to open URL');
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.secondaryColor),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Open in Browser',
                          style: TextStyle(color: AppColors.secondaryColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            WebViewWidget(
              controller: controller.webViewController,
            ),
            if (controller.isPageLoading.value && controller.isLoading.value)
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
                      const Text(
                        'Loading content...',
                        style: TextStyle(
                          color: AppColors.textColorPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (controller.isPageLoading.value && !controller.isLoading.value)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  minHeight: 3,
                ),
              ),
          ],
        );
      }),
    );
  }
}*/



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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 60, color: AppColors.errorColor),
                const SizedBox(height: 10),
                Text(controller.errorMessage.value),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: controller.retryLoad,
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        /// WEBVIEW ALWAYS BUILD (IMPORTANT FIX)
        return Stack(
          children: [
            WebViewWidget(
              controller: controller.webViewController,
            ),

            /// FULL SCREEN LOADER (first load only)
            if (controller.isLoading.value)
              Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),

            /// TOP PROGRESS BAR (page loading)
            if (controller.isPageLoading.value &&
                !controller.isLoading.value)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(minHeight: 3),
              ),
          ],
        );
      }),
    );
  }
}
