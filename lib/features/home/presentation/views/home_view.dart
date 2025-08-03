import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/provider/lists_provider.dart';
import '../../../../core/provider/settings_provider.dart';
import '../../../../core/widgets/basics.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.type});
  final String type;
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late PDFController pdfController;
  late SettingsProvider settingsProvider;

  @override
  void initState() {
    super.initState();
    pdfController = Get.put(PDFController());
    settingsProvider = Get.put(SettingsProvider());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: Obx(() {
        //get list depending on section
        List<String> pdfList = [];
        if (widget.type == "home") {
          pdfList = pdfController.homePDF.value;
        } else if (widget.type == "recent") {
          pdfList = pdfController.recentPDF.value;
        } else if (widget.type == "bookmark") {
          pdfList = pdfController.bookmarkPDF.value;
        }
        return (pdfList.isEmpty)
            ? Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
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
            ? booksGridView(pdfList)
            : booksListView(pdfList, context: context);
      }),
    );
  }
}
