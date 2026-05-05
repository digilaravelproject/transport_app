import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

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
    _initFromArgs();
  }

  void _initFromArgs() {
    final args = Get.arguments;

    if (args is Map<String, dynamic>) {
      title.value = args['title'] ?? 'Template';
      url.value = args['url'] ?? '';
    } else if (args is String) {
      url.value = args;
    }

    if (url.value.isEmpty) {
      hasError.value = true;
      errorMessage.value = "URL not provided";
      isLoading.value = false;
      return;
    }

    url.value = url.value.trim();

    if (!url.value.startsWith('http')) {
      url.value = 'https://${url.value}';
    }

    _initWebView();
  }

  void _initWebView() {
    try {
      late final PlatformWebViewControllerCreationParams params;

      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
        );
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }

      webViewController = WebViewController.fromPlatformCreationParams(params);

      // Set Platform-specific User Agent
      String userAgent = "";
      if (GetPlatform.isAndroid) {
        userAgent = 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36';
      } else if (GetPlatform.isIOS) {
        userAgent = 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 Safari/604.1';
      }

      webViewController
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setUserAgent(userAgent)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              print("WebView started loading: $url");
              isPageLoading.value = true;
              hasError.value = false;
            },
            onProgress: (progress) {
              if (progress == 100) {
                isLoading.value = false;
              }
            },
            onPageFinished: (url) {
              print("WebView finished loading: $url");
              isLoading.value = false;
              isPageLoading.value = false;
            },
            onWebResourceError: (error) {
              print("WebView Error: ${error.description}, Type: ${error.errorType}");
              
              // Only show error screen for critical main frame failures
              if (error.isForMainFrame == true) {
                 if (error.errorType == WebResourceErrorType.hostLookup ||
                    error.errorType == WebResourceErrorType.connect ||
                    error.errorType == WebResourceErrorType.timeout) {
                  hasError.value = true;
                  errorMessage.value = error.description;
                  isLoading.value = false;
                  isPageLoading.value = false;
                }
              }
            },
          ),
        );

      // Android fixes
      if (webViewController.platform is AndroidWebViewController) {
        // Use dynamic to bypass potential compilation issues with platform-specific methods
        final dynamic android = webViewController.platform;
        try {
          android.setMediaPlaybackRequiresUserGesture(false);
          android.setDomStorageEnabled(true);
        } catch (e) {
          print("Error setting Android-specific WebView settings: $e");
        }
      }

      // LOAD URL
      String finalUrl = url.value;
      
      // Handle PDF URLs for Android using Google Docs Viewer
      if (GetPlatform.isAndroid && (finalUrl.toLowerCase().contains('.pdf') || finalUrl.toLowerCase().contains('preview'))) {
        print("Detected potential PDF/Preview on Android, using Google Docs Viewer");
        finalUrl = 'https://docs.google.com/gview?embedded=true&url=$finalUrl';
      }

      print("Loading URL in WebView: $finalUrl");
      webViewController.loadRequest(Uri.parse(finalUrl));
      
    } catch (e) {
      print("WebView Init Exception: $e");
      hasError.value = true;
      errorMessage.value = e.toString();
      isLoading.value = false;
    }
  }

  void refreshWebView() {
    if (hasError.value) {
      retryLoad();
    } else {
      webViewController.reload();
    }
  }

  void retryLoad() {
    hasError.value = false;
    isLoading.value = true;
    isPageLoading.value = false;
    _initWebView();
  }
}
