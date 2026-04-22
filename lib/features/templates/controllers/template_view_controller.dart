import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/custom_snackbar.dart';

class TemplateViewController extends GetxController {
  late WebViewController webViewController;
  
  final RxString title = 'Template'.obs;
  final RxString url = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool isPageLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFromArguments();
    if (!hasError.value) {
      _initializeWebView();
    }
  }

  void _initializeFromArguments() {
    final arguments = Get.arguments;
    if (arguments != null) {
      if (arguments is Map<String, dynamic>) {
        title.value = arguments['title'] ?? 'Template';
        url.value = arguments['url'] ?? '';
      } else if (arguments is String) {
        // If only URL is passed
        url.value = arguments;
        title.value = 'Template';
      }
    }

    // Validate URL
    if (url.value.isEmpty) {
      hasError.value = true;
      errorMessage.value = 'No URL provided';
      isLoading.value = false;
      return;
    }

    // Add https:// if not present
    if (!url.value.startsWith('http://') && !url.value.startsWith('https://')) {
      url.value = 'https://${url.value}';
    }
  }

  void _initializeWebView() {
    if (hasError.value) return;

    try {
      webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // Update loading progress if needed
            },
            onPageStarted: (String url) {
              isPageLoading.value = true;
              hasError.value = false;
            },
            onPageFinished: (String url) {
              isPageLoading.value = false;
              isLoading.value = false;
            },
            onWebResourceError: (WebResourceError error) {
              hasError.value = true;
              errorMessage.value = error.description;
              isLoading.value = false;
              isPageLoading.value = false;
              CustomSnackbar.showError('Failed to load template: ${error.description}');
            },
            onNavigationRequest: (NavigationRequest request) {
              // Allow all navigation requests
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(url.value));
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to initialize WebView: $e';
      isLoading.value = false;
      CustomSnackbar.showError('Failed to load template');
    }
  }

  void refreshWebView() {
    if (hasError.value) {
      retryLoad();
      return;
    }

    try {
      isPageLoading.value = true;
      webViewController.reload();
      CustomSnackbar.showSuccess('Refreshing template...');
    } catch (e) {
      CustomSnackbar.showError('Failed to refresh');
    }
  }

  void retryLoad() {
    hasError.value = false;
    isLoading.value = true;
    errorMessage.value = '';
    _initializeWebView();
  }

  Future<bool> canGoBack() async {
    try {
      return await webViewController.canGoBack();
    } catch (e) {
      return false;
    }
  }

  void goBack() {
    try {
      webViewController.goBack();
    } catch (e) {
      CustomSnackbar.showError('Cannot go back');
    }
  }

  Future<bool> canGoForward() async {
    try {
      return await webViewController.canGoForward();
    } catch (e) {
      return false;
    }
  }

  void goForward() {
    try {
      webViewController.goForward();
    } catch (e) {
      CustomSnackbar.showError('Cannot go forward');
    }
  }
}