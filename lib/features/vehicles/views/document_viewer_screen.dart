import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';

import '../domain/models/vehicle_model.dart';

class DocumentViewerScreen extends StatefulWidget {
  const DocumentViewerScreen({Key? key}) : super(key: key);

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  VehicleDocument? document;
  late String fileUrl;
  late String fileName;
  bool isImage = false;
  bool isDownloading = false;
  double downloadProgress = 0;

  @override
  void initState() {
    super.initState();
    final dynamic args = Get.arguments;
    if (args is VehicleDocument) {
      document = args;
      fileUrl = document!.fileUrl;
    } else if (args is String) {
      fileUrl = args;
    } else {
      fileUrl = '';
    }

    if (fileUrl.isNotEmpty) {
      fileName = fileUrl.split('/').last;
      final ext = fileName.split('.').last.toLowerCase();
      isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
    } else {
      fileName = 'Unknown File';
    }
  }

  Future<void> _downloadAndOpenFile() async {
    setState(() {
      isDownloading = true;
      downloadProgress = 0;
    });

    try {
      final dio = Dio();
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/$fileName';

      await dio.download(
        fileUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              downloadProgress = received / total;
            });
          }
        },
      );

      await OpenFilex.open(savePath);
    } catch (e) {
      Get.snackbar('Error', 'Failed to download or open file: $e', 
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: document?.type ?? 'View Document',
        subtitle: document?.number,
        trailing: IconButton(
          icon: isDownloading 
            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(value: downloadProgress, strokeWidth: 2, color: AppColors.primaryColor))
            : const Icon(Iconsax.document_download, color: AppColors.primaryColor),
          onPressed: isDownloading ? null : _downloadAndOpenFile,
        ),
      ),
      body: Center(
        child: isImage 
          ? InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: fileUrl,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.contain,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.insert_drive_file_outlined, size: 80, color: AppColors.textColorHint),
                const SizedBox(height: 20),
                AppText(fileName, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                const SizedBox(height: 10),
                const AppText('This file type cannot be previewed in-app.', style: AppTextStyle.caption),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _downloadAndOpenFile,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const AppText('Open File', color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
