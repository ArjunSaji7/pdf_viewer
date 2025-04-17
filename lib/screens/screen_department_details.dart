import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class ScreenDepartmentDetails extends StatefulWidget {
  final String fileName;
  final String department;


  const ScreenDepartmentDetails({super.key, required this.fileName, required this.department});

  @override
  State<ScreenDepartmentDetails> createState() => _ScreenDepartmentDetailsState();
}

class _ScreenDepartmentDetailsState extends State<ScreenDepartmentDetails> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  // Load PDF from Firebase Storage to temporary directory for viewing
  Future<void> _loadPdf() async {
    try {
      final ref = FirebaseStorage.instance.ref().child(widget.fileName);
      final bytes = await ref.getData();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.fileName.split('/').last}');
      await file.writeAsBytes(bytes!);

      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading PDF: $e");
      setState(() => isLoading = false);
    }
  }

  // Download PDF using FlutterDownloader
  void _registerDownloadCallback() {
    FlutterDownloader.registerCallback((id, status, progress) {
      if (status == DownloadTaskStatus.complete) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download completed: $id")),
        );
      } else if (status == DownloadTaskStatus.failed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: $id")),
        );
      } else if (status == DownloadTaskStatus.canceled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download canceled: $id")),
        );
      }
    });
  }

  Future<void> _downloadPdf() async {
    try {
      if (Platform.isAndroid && await Permission.notification.isDenied) {
        await Permission.notification.request();
      }

      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied")),
        );
        return;
      }

      final ref = FirebaseStorage.instance.ref().child(widget.fileName);
      final downloadUrl = await ref.getDownloadURL();

      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final originalName = widget.fileName.split('/').last;
      String fileName = originalName;
      String filePath = '${downloadsDir.path}/$fileName';

      int count = 1;
      while (await File(filePath).exists()) {
        final nameWithoutExt = originalName.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
        fileName = "$nameWithoutExt($count).pdf";
        filePath = "${downloadsDir.path}/$fileName";
        count++;
      }

      final taskId = await FlutterDownloader.enqueue(
        url: downloadUrl,
        savedDir: downloadsDir.path,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
        requiresStorageNotLow: true,
      );

      if (taskId == null) {
        throw Exception('Download task could not be created');
      }

    } catch (e) {
      debugPrint("Download error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: ${e.toString()}")),
      );
    }
  }

  // Share PDF file
  Future<void> _sharePdf() async {
    if (localPath != null) {
      await Share.shareXFiles(
        [XFile(localPath!)],
        text: 'Sharing PDF: ${widget.fileName}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(widget.department),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadPdf,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePdf,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : localPath != null
          ? PDFView(
        filePath: localPath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageSnap: true,
      )
          : const Center(child: Text('Failed to load PDF')),
    );
  }
}
