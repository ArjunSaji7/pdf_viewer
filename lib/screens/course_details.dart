import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class CourseDetails extends StatefulWidget {
  final String fileName;
  final String course;

  const CourseDetails({
    super.key,
    required this.fileName,
    required this.course,
  });

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
    FlutterDownloader.registerCallback(downloadCallback); // ✅ top-level callback
  }

  Future<void> _loadPdf() async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('course_pdf/${widget.fileName}');

      final bytes = await ref.getData();

      final dir = await getTemporaryDirectory();
      final sub = Directory('${dir.path}/course_pdf');
      if (!await sub.exists()) await sub.create();

      final file = File('${sub.path}/${widget.fileName}');
      await file.writeAsBytes(bytes!);

      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading PDF: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _downloadPdf() async {
    try {
      if (Platform.isAndroid && await Permission.notification.isDenied) {
        await Permission.notification.request();
      }

      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied")),
        );
        return;
      }

      final ref = FirebaseStorage.instance.ref().child('course_pdf/${widget.fileName}');
      final downloadUrl = await ref.getDownloadURL();

      final baseDir = await getExternalStorageDirectory();
      final downloadsDir = Directory('${baseDir!.path}/Downloads');
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

      await FlutterDownloader.enqueue(
        url: downloadUrl,
        savedDir: downloadsDir.path,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
        requiresStorageNotLow: true,
      );
    } catch (e) {
      debugPrint("Download error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: ${e.toString()}")),
      );
    }
  }

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
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          widget.course,
          style: const TextStyle(color: Color(0xFF2D388F), fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D388F)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadPdf,
            color: const Color(0xFF2D388F),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePdf,
            color: const Color(0xFF2D388F),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF135C56)))
          : localPath != null
          ? PDFView(
        filePath: localPath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageSnap: true,
        backgroundColor: Colors.black,
      )
          : const Center(
        child: Text(
          'Failed to load PDF',
          style: TextStyle(color: Color(0xFF135C56), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

//Top-level download callback function
@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final taskStatus = DownloadTaskStatus.values[status];
  debugPrint('Download task ($id) status: $taskStatus progress: $progress');
}
