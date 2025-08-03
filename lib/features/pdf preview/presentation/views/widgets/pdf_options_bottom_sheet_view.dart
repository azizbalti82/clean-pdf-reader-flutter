import 'dart:io';

import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../../../../core/utils/constants.dart';
import '../../../../../core/widgets/form.dart';
import 'package:path/path.dart' as path_ob;


class PdfOptionsBottomSheetView extends StatelessWidget {
  const PdfOptionsBottomSheetView({super.key, required this.path});
  final String path;

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
                IconButton(onPressed: (){
                  //add to bookmark
                }, icon: FaIcon(FontAwesomeIcons.bookmark, size: 25),),
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
              onTap: () {
                // Handle share action
                print("Share tapped");
              },
            ),
            SizedBox(height: 10),
            buildClickableRow(
              icon: FontAwesomeIcons.edit,
              text: "Rename",
              iconColor:Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.7) ,
              onTap: () {
                // Handle share action
                print("Share tapped");
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
              onTap: () {
                // Handle share action
                print("delete tapped");
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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
