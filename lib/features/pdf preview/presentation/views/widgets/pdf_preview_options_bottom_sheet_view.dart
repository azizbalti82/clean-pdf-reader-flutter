import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path_ob;
import 'package:share_plus/share_plus.dart';

import '../../../../../core/provider/settings_provider.dart';
import '../../../../../core/services/settings_service.dart';
import '../../../../../core/widgets/basics.dart';
import '../../../../../main.dart';


class PdfPreviewOptionsBottomSheetView extends StatelessWidget {
  PdfPreviewOptionsBottomSheetView({super.key});

  final SettingsProvider settingsProvider = Get.put(SettingsProvider());

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical:12,horizontal: 30 ),
        child: Obx(() {
          statusBarPreviewSetup();
          return Column(
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
            //pdf theme
            Text("Pdf Filter",style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                selectableItem("Light",!settingsProvider.isDark.value && !settingsProvider.isYellow.value,context,(){
                  SettingsService.saveIsDark(false);
                  settingsProvider.updateIsDark(false);
                  SettingsService.saveIsYellow(false);
                  settingsProvider.updateIsYellow(false);
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
            //pdf theme
            Text("Background",style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                selectableItem("Follow Pdf Filter",settingsProvider.bgColor.value=="follow",context,(){
                  SettingsService.saveBgColor("follow");
                  settingsProvider.updateBgColor("follow");
                }),
                SizedBox(width: 12,),
                selectableItem("Light",settingsProvider.bgColor.value=="light",context,(){
                  SettingsService.saveBgColor("light");
                  settingsProvider.updateBgColor("light");
                }),
                SizedBox(width: 12,),
                selectableItem("Dark",settingsProvider.bgColor.value=="dark",context,(){
                  SettingsService.saveBgColor("dark");
                  settingsProvider.updateBgColor("dark");
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
          child: Text(name,style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isSelected ? accent:Theme.of(context).colorScheme.onBackground),
          )),
    );
  }
}
