import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/utils/custom_snackbar.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({Key? key}) : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late final WebViewController controller;
  bool isLoading = true;
  String? url;

  Future<void> _downloadAndOpenPdf() async {
    if (url == null || url!.isEmpty) return;
    
    try {
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      // Ensure we have a .pdf extension
      String fileName = url!.split('/').last;
      if (!fileName.toLowerCase().endsWith('.pdf')) {
        fileName = "$fileName.pdf";
      }
      final savePath = "${tempDir.path}/$fileName";
      
      CustomSnackbar.showInfo('Downloading quotation...');
      
      await dio.download(url!, savePath);
      
      await OpenFilex.open(savePath);
    } catch (e) {
      CustomSnackbar.showError('Error downloading quotation: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    url = Get.arguments as String?;
    
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {},
        ),
      );
      
    if (url != null && url!.isNotEmpty) {
      // For PDFs, we might need to use Google Docs Viewer if the direct link doesn't work well on mobile
      final String webUrl = url!.toLowerCase().endsWith('.pdf') 
          ? 'https://docs.google.com/gview?embedded=true&url=$url' 
          : url!;
      controller.loadRequest(Uri.parse(webUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: Colors.black,
      appBar: AppHeader(
        title: 'Quotation Viewer',
        onBack: () => Get.back(),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        trailing: IconButton(
          icon: const Icon(Iconsax.document_download, color: Colors.white),
          onPressed: _downloadAndOpenPdf,
        ),
      ),
      body: Stack(
        children: [
          if (url == null || url!.isEmpty)
            const Center(child: AppText('No URL provided', style: AppTextStyle.body))
          else
            WebViewWidget(controller: controller),
          
          if (isLoading && url != null && url!.isNotEmpty)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
