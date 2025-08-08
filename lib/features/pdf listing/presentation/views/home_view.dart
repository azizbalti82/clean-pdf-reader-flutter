import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/provider/lists_provider.dart';
import '../../../../core/provider/settings_provider.dart';
import '../../../../core/widgets/basics.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key, required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final PdfListsProvider pdfController = Get.find<PdfListsProvider>();
    final SettingsProvider settingsProvider = Get.find<SettingsProvider>();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: Obx(() {
        //get list depending on section
        List<String> pdfList = [];
        if (type == "pdf listing") {
          pdfList = pdfController.homePDF;
        } else if (type == "recent") {
          pdfList = pdfController.recentPDF.reversed.map((p)=>p.path).toList();
        } else if (type == "bookmark") {
          pdfList = pdfController.bookmarkPDF;
        }

        return (pdfList.isEmpty)
            ? Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: Text(
                'No PDFs Available',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        )
            : settingsProvider.isGrid.value
            ? booksGridView(pdfList, isRecent: type == "recent")
            : booksListView(pdfList, isRecent: type == "recent", context: context);
      }),
    );
  }
}