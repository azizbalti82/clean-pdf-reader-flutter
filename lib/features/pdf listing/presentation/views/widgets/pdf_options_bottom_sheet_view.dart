import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path_ob;
import 'package:pdf_reader/features/pdf%20listing/models/pdf.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/provider/lists_provider.dart';
import '../../../../../core/widgets/toasts.dart';
import '../../../../../main.dart';
import '../../../services/pdf_service.dart';


class PdfOptionsBottomSheetView extends StatelessWidget {
  PdfOptionsBottomSheetView({super.key, required this.path, required this.fromPreview});
  final String path;
  final bool fromPreview;
  final PdfListsProvider pdfListsProvider = Get.put(PdfListsProvider());


  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 4),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(width: 15),
                Icon(
                      Icons.picture_as_pdf,
                      size: 40,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.6),
                ),
                SizedBox(width: 15),
                buildPdfInfoColumn(path),

                Obx(() {
                  return IconButton(
                    icon: FaIcon(
                      (pdfListsProvider.bookmarkPDF.contains(path))
                          ? FontAwesomeIcons.solidBookmark
                          : FontAwesomeIcons.bookmark,
                      size: 25,
                    ),
                    onPressed: () async {
                      Pdf? pdf = PdfService.getPdf(path);

                      if (pdf == null) {
                        pdf = Pdf(path: path, lastOpenDate: DateTime.now(),isOpened:false, isBookmark: true, currentPage: 1);
                      } else {
                        pdf = pdf.copyWith(isBookmark: !pdf.isBookmark);
                      }

                      bool result = await PdfService.savePdf(path, pdf);

                      if (result) {
                        // Update the UI
                        if (pdf.isBookmark) {
                          if (!pdfListsProvider.bookmarkPDF.contains(path)) {
                            pdfListsProvider.bookmarkPDF.add(path);
                          }
                        } else {
                          pdfListsProvider.bookmarkPDF.remove(path);
                        }
                      }
                    },
                  );
                })

              ],
            ),
            SizedBox(height: 30),

            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.all(0),
                child: Container(
                  width: double.infinity,
                  height: 1,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.075),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            buildClickableRow(
              icon: FontAwesomeIcons.shareFromSquare,
              text: "Share",
              iconColor:Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.7) ,
              onTap: () async{
                await sharePdfFile(
                path,
                subject: "Share PDF",
                text: path_ob.basenameWithoutExtension(path),
                );
              },
            ),
            SizedBox(height: 10),
            if(!fromPreview)
            buildClickableRow(
              icon: FontAwesomeIcons.edit,
              text: "Rename",
              iconColor:Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.7) ,
              onTap: () async{
                bool result = await renameFile(path,context);
                if(result){
                  Toast.showSuccess("PDF renamed successfully!", context);
                }else{
                  Toast.showError("Error while renaming PDF", context);
                }
              },
            ),
            SizedBox(height: 10),
            buildClickableRow(
              icon: FontAwesomeIcons.trashCan,
              text: "Delete",
              textColor: Theme.of(
                context,
              ).colorScheme.error.withOpacity(0.7) ,
              iconColor:Theme.of(
                context,
              ).colorScheme.error.withOpacity(0.7) ,
              spacing: 32,
              onTap: () async{
                bool result = await deleteFile(path,context);
                if(result){
                  Toast.showSuccess("PDF deleted successfully!", context);
                }else{
                  Toast.showError("Error while deleting PDF", context);
                }
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<bool> sharePdfFile(
      String filePath, {
        String? subject,
        String? text,
      }) async
  {
    try {
      // Check if file exists
      final file = File(filePath);
      if (!await file.exists()) {
        print('Error: PDF file not found at path: $filePath');
        return false;
      }

      final xFile = XFile(filePath);

      // Share the file
      final result = await Share.shareXFiles(
        [xFile],
        subject: subject ?? 'Sharing PDF Document',
        text: text ?? 'Please find the attached PDF document.',
      );

      if (result.status == ShareResultStatus.success) {
        print('PDF shared successfully');
        return true;
      } else {
        print('Sharing failed or was dismissed');
        return false;
      }
    } catch (e) {
      print('Error sharing PDF: $e');
      return false;
    }
  }
  Future<bool> deleteFile(
      String filePath,
      BuildContext context,
      ) async
  {
    try {
      final file = File(filePath);

      // Check if file exists
      if (!await file.exists()) {
        print('Warning: File does not exist at path: $filePath');
        return false;
      }

      // Get file info for confirmation dialog
      final fileName = path_ob.basename(filePath);

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete File'),
          content: Text('Are you sure you want to delete this file?\nThis action cannot be undone.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel')),
            TextButton(
              onPressed: () async{
                Navigator.of(context).pop(true);
                Navigator.of(context).pop(true);
                if(fromPreview){
                  Navigator.of(context).pop(true);
                }
                //update list with provider
                loadPDFs();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        ),
      );


      // If user cancelled or dialog was dismissed
      if (confirmed != true) {
        print('Deletion cancelled by user');
        return false;
      }

      // Delete the file
      await file.delete();

      // Verify deletion
      final deletionSuccessful = !await file.exists();

      if (deletionSuccessful) {
        print('File deleted successfully: $fileName');
      } else {
        print('Error: File still exists after deletion attempt');
      }

      return deletionSuccessful;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }
  Future<bool> renameFile(String filePath, BuildContext context) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final currentName = path_ob.basenameWithoutExtension(filePath);
      final extension = path_ob.extension(filePath);
      final directory = path_ob.dirname(filePath);

      final controller = TextEditingController(text: currentName);

      final newName = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Rename'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(suffixText: extension),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text('Rename'),
            ),
          ],
        ),
      );

      if (newName == null || newName.isEmpty || newName == currentName) return false;

      final newPath = path_ob.join(directory, '$newName$extension');
      if (await File(newPath).exists()) return false;

      await file.rename(newPath);
      Navigator.pop(context, true);
      loadPDFs();
      return true;

    } catch (e) {
      return false;
    }
  }

  Widget buildClickableRow({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    double iconSize = 20.0,
    double fontSize = 18.0,
    Color? iconColor,
    Color? textColor,
    double spacing = 30.0,
    double leftPadding = 20.0,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            SizedBox(width: leftPadding),
            FaIcon(icon, size: iconSize, color: iconColor),
            SizedBox(width: spacing),
            Text(
              text,
              style: TextStyle(fontSize: fontSize, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
  Widget buildPdfInfoColumn(String filePath) {
    return FutureBuilder<Map<String, String>>(
      future: _getPdfInfo(filePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(path_ob.basenameWithoutExtension(filePath)),
              SizedBox(height: 4),
              Text(
                "Loading...",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          );
        }

        final info = snapshot.data ?? {};

        return Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              path_ob.basenameWithoutExtension(filePath),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text(
              "${info['date'] ?? 'Unknown'} | Size: ${info['size'] ?? 'Unknown'}",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ));
      },
    );
  }
  Future<Map<String, String>> _getPdfInfo(String filePath) async {
    try {
      final file = File(filePath);
      final stat = await file.stat();

      // Format the date
      final dateFormat = DateFormat('MMM dd, yyyy');
      final formattedDate = dateFormat.format(stat.modified);

      // Format the file size
      final sizeInBytes = stat.size;
      final formattedSize = _formatFileSize(sizeInBytes);

      return {
        'date': formattedDate,
        'size': formattedSize,
      };
    } catch (e) {
      return {
        'date': 'Unknown',
        'size': 'Unknown',
      };
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

}
