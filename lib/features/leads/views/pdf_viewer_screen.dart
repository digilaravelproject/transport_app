import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/services/storage/token_manger.dart';
import '../../../core/constants/app_constants.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({Key? key}) : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool isLoading = true;
  String? url;
  String title = 'Quotation Viewer';
  Map<String, String> headers = {};
  String? localPath;

  Future<void> _downloadAndOpenPdf() async {
    if (url == null || url!.isEmpty) return;
    
    try {
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      
      String fileName = url!.split('/').last;
      if (!fileName.contains('.')) {
        fileName = "$fileName.pdf";
      }
      
      final savePath = "${tempDir.path}/$fileName";
      
      CustomSnackbar.showInfo('Downloading document...');
      
      String token = await TokenManager.getToken();
      if (token.isEmpty) {
        token = AppConstants.apiToken;
      }
      final Map<String, dynamic> currentHeaders = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/pdf',
      };

      await dio.download(
        url!, 
        savePath,
        options: Options(headers: currentHeaders),
      );
      
      await OpenFilex.open(savePath);
    } catch (e) {
      CustomSnackbar.showError('Error downloading document: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    
    if (Get.arguments is Map) {
      final args = Get.arguments as Map;
      url = args['url'];
      title = args['title'] ?? 'Quotation Viewer';
    } else {
      url = Get.arguments as String?;
    }
    
    _initPdf();
  }

  Future<void> _initPdf() async {
    if (url == null || url!.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    try {
      String token = await TokenManager.getToken();
      if (token.isEmpty) {
        token = AppConstants.apiToken;
      }

      headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/pdf',
      };

      // Download to a temporary file for viewing
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      final String fileName = "view_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final String path = "${tempDir.path}/$fileName";

      await dio.download(
        url!,
        path,
        options: Options(headers: headers),
      );

      final file = File(path);
      final size = await file.length();
      debugPrint('Downloaded PDF size: $size bytes');

      if (size < 1000) {
        try {
          final content = await file.readAsString();
          debugPrint('Small file content snippet: ${content.substring(0, content.length > 200 ? 200 : content.length)}');
          if (content.contains('<!DOCTYPE html>') || content.contains('<html')) {
             throw 'The server returned an HTML page instead of a PDF. This might be an error message.';
          }
        } catch (e) {
          debugPrint('Could not read small file as string, probably a tiny binary PDF: $e');
        }
      }

      setState(() {
        localPath = path;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      CustomSnackbar.showError('Error loading PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: Colors.black,
      appBar: AppHeader(
        title: title,
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
            const Center(child: AppText('No URL provided', style: AppTextStyle.body, color: Colors.white))
          else if (isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryColor),
                  SizedBox(height: 16),
                  AppText('Loading document...', color: Colors.white),
                ],
              ),
            )
          else if (localPath != null)
            Container(
              color: Colors.black,
              child: SfPdfViewer.file(
                File(localPath!),
                onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                  CustomSnackbar.showError('Failed to render PDF: ${details.description}');
                },
              ),
            )
          else
            const Center(child: AppText('Failed to load document', color: Colors.white)),
        ],
      ),
    );
  }
}
