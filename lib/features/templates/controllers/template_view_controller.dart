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

    // Test URL accessibility
    _testUrlAccessibility();
  }

  void _testUrlAccessibility() async {
    try {
      print('Testing URL accessibility: ${url.value}');
      // You can add HTTP client test here if needed
      // For now, just proceed with WebView loading
    } catch (e) {
      print('URL accessibility test failed: $e');
    }
  }

  void _initializeWebView() {
    if (hasError.value) return;

    try {
      // Initialize WebViewController with proper configuration
      late final PlatformWebViewControllerCreationParams params;
      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
        );
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }

      webViewController = WebViewController.fromPlatformCreationParams(params);

      // Configure WebView settings
      webViewController
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..enableZoom(true);

      // Set Platform-specific User Agent
      if (webViewController.platform is AndroidWebViewController) {
        webViewController.setUserAgent('Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36');
      } else if (webViewController.platform is WebKitWebViewController) {
        webViewController.setUserAgent('Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 Safari/604.1');
      }

      // Enable DOM Storage for Android - CRITICAL for data rendering in many modern sites
      if (webViewController.platform is AndroidWebViewController) {
        // Use dynamic to bypass potential compilation issues with platform-specific methods
        try {
          (webViewController.platform as dynamic).setDomStorageEnabled(true);
        } catch (e) {
          print('Could not set DOM storage: $e');
        }
      }

      // Add timeout mechanism
      Timer? loadingTimeout;

      // Set navigation delegate with proper error handling
      webViewController.setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            print('WebView loading progress: $progress%');
            // If we reach 100% but page doesn't finish, handle it
            if (progress == 100) {
              Future.delayed(const Duration(seconds: 2), () {
                if (isPageLoading.value) {
                  print('Page reached 100% but onPageFinished not called, assuming loaded');
                  isPageLoading.value = false;
                  isLoading.value = false;
                  loadingTimeout?.cancel();
                }
              });
            }
          },
          onPageStarted: (String url) {
            print('WebView started loading: $url');
            isPageLoading.value = true;
            hasError.value = false;

            // Set timeout for loading
            loadingTimeout?.cancel();
            loadingTimeout = Timer(const Duration(seconds: 45), () {
              if (isPageLoading.value || isLoading.value) {
                print('WebView loading timeout');
                // Don't show error if we've already reached 100% progress
                if (isLoading.value) {
                  hasError.value = true;
                  errorMessage.value = 'Loading timeout - The page took too long to load\nURL: $url';
                  isLoading.value = false;
                }
                isPageLoading.value = false;
              }
            });
          },
          onPageFinished: (String url) {
            print('WebView finished loading: $url');
            isPageLoading.value = false;
            isLoading.value = false;
            loadingTimeout?.cancel();

            // Optional: Inject JS to ensure data is visible if needed
            // webViewController.runJavaScript('...');
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}, Code: ${error.errorCode}, Type: ${error.errorType}');
            // Only show error for critical failures
            if (error.isForMainFrame == true && (
                error.errorType == WebResourceErrorType.hostLookup ||
                    error.errorType == WebResourceErrorType.connect ||
                    error.errorType == WebResourceErrorType.timeout)) {
              hasError.value = true;
              errorMessage.value = 'Error ${error.errorCode}: ${error.description}\nURL: ${this.url.value}';
              isLoading.value = false;
              isPageLoading.value = false;
              loadingTimeout?.cancel();
              CustomSnackbar.showError('Failed to load template: ${error.description}');
            }
          },
          onHttpError: (HttpResponseError error) {
            print('WebView HTTP error: ${error.response?.statusCode}');
            // Some sites return 404/500 but still show content (error pages)
            // We only show error for critical issues if desired
          },
          onNavigationRequest: (NavigationRequest request) {
            print('WebView navigation request: ${request.url}');
            // Allow all navigation requests
            return NavigationDecision.navigate;
          },
        ),
      );

      print('Loading URL in WebView: ${url.value}');

      // Load the URL immediately
      if (!hasError.value) {
        try {
          webViewController.loadRequest(Uri.parse(url.value));
        } catch (e) {
          print('Error loading URL: $e');
          hasError.value = true;
          errorMessage.value = 'Failed to load URL: $e';
          isLoading.value = false;
        }
      }
    } catch (e) {
      print('WebView initialization error: $e');
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
    isPageLoading.value = false;
    errorMessage.value = '';

    // Try with a different URL format if the original fails
    String retryUrl = url.value;
    if (!retryUrl.contains('?')) {
      retryUrl += '?mobile=1&webview=1';
    } else {
      retryUrl += '&mobile=1&webview=1';
    }

    print('Retrying with URL: $retryUrl');

    try {
      // If webViewController hasn't been initialized yet (e.g. initial error),
      // we must initialize it first.
      try {
        // This check will throw LateInitializationError if not initialized
        webViewController.loadRequest(Uri.parse(retryUrl));
      } catch (e) {
        print('WebViewController not initialized, initializing now: $e');
        _initializeWebView();
      }
    } catch (e) {
      print('Retry failed: $e');
      _initializeWebView();
    }
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