import 'dart:io';

import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/provider/settings_provider.dart';
import '../../../../../core/services/settings_service.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/widgets/form.dart';
import 'package:path/path.dart' as path_ob;

import '../../../../../core/widgets/toasts.dart';
import '../../../../../main.dart';


class PdfPreviewOptionsBottomSheetView extends StatelessWidget {
  PdfPreviewOptionsBottomSheetView({super.key});

  final SettingsProvider settingsProvider = Get.put(SettingsProvider());

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical:12,horizontal: 30 ),
        child: Obx(() { return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Text("Scroll Direction",style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 selectableItem("vertical",settingsProvider.isVertical.value,context,(){
                   SettingsService.saveIsVertical(true);
                   settingsProvider.updateIsVertical(true);
                 }),
                SizedBox(width: 12,),
                selectableItem("Horizontal",!settingsProvider.isVertical.value,context,(){
                  SettingsService.saveIsVertical(false);
                  settingsProvider.updateIsVertical(false);
                }),
              ],
            ),
            if(!settingsProvider.isVertical.value)
              const SizedBox(height: 20),
            if(!settingsProvider.isVertical.value)
              Text("Reading Direction",style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16)),
            if(!settingsProvider.isVertical.value)
              const SizedBox(height: 20),
            if(!settingsProvider.isVertical.value)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                selectableItem("LTR",settingsProvider.isLTR.value,context,(){
                  SettingsService.saveIsLTR(true);
                  settingsProvider.updateIsLTR(true);
                }),
                SizedBox(width: 12,),
                selectableItem("RTL",!settingsProvider.isLTR.value,context,(){
                  SettingsService.saveIsLTR(false);
                  settingsProvider.updateIsLTR(false);
                }),
              ],
            ),
            const SizedBox(height: 20),
            Text("Page Transition",style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                selectableItem("Continuous",settingsProvider.isContinuous.value,context,(){
                  SettingsService.saveIsContinuous(true);
                  settingsProvider.updateIsContinuous(true);
                }),
                SizedBox(width: 12,),
                selectableItem("Jump",!settingsProvider.isContinuous.value,context,(){
                  SettingsService.saveIsContinuous(false);
                  settingsProvider.updateIsContinuous(false);
                }),
              ],
            ),
            const SizedBox(height: 20),
            Text("Theme",style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                selectableItem("Default",!settingsProvider.isDark.value && !settingsProvider.isYellow.value,context,(){
                  SettingsService.saveIsDark(false);
                  settingsProvider.updateIsDark(false);
                }),
                SizedBox(width: 12,),
                selectableItem("Dark",settingsProvider.isDark.value,context,(){
                  SettingsService.saveIsDark(true);
                  SettingsService.saveIsYellow(false);
                  settingsProvider.updateIsDark(true);
                  settingsProvider.updateIsYellow(false);

                }),
                SizedBox(width: 12,),
                selectableItem("Yellow",settingsProvider.isYellow.value,context,(){
                  SettingsService.saveIsYellow(true);
                  settingsProvider.updateIsYellow(true);
                  SettingsService.saveIsDark(false);
                  settingsProvider.updateIsDark(false);
                }),
              ],
            ),
            const SizedBox(height: 20),
          ],
        );}),
      ),
    );
  }


  Widget selectableItem(String name,bool isSelected,BuildContext context,Function() f){
    Color accent = Theme.of(context).colorScheme.primary;
    Color card = Theme.of(context).cardColor;
    return GestureDetector(
      onTap: f,
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15,vertical: 7),
          decoration: BoxDecoration(
              color: isSelected ? accent.withOpacity(0.2) : card,
              borderRadius: BorderRadius.circular(20),
              border: isSelected ? Border.all(color: accent.withOpacity(0.8)):null
          ),
          child: Text(name,style: Theme.of(context).textTheme.titleMedium?.copyWith(color: isSelected ? accent:Theme.of(context).colorScheme.onBackground),
          )),
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
}
