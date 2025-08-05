import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf_reader/features/pdf%20listing/models/pdf.dart';

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
  late PdfListsProvider pdfController;
  late SettingsProvider settingsProvider;

  @override
  void initState() {
    super.initState();
    pdfController = Get.put(PdfListsProvider());
    settingsProvider = Get.put(SettingsProvider());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: Obx(() {
        //get list depending on section
        List<String> pdfList = [];
        if (widget.type == "pdf listing") {
          pdfList = pdfController.homePDF;
        } else if (widget.type == "recent") {
          for(Pdf p in pdfController.recentPDF){
            print(p.path);
          }
          pdfList = pdfController.recentPDF.reversed.map((p)=>p.path).toList();
        } else if (widget.type == "bookmark") {
          pdfList = pdfController.bookmarkPDF;
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
            ? booksGridView(pdfList,isRecent:widget.type == "recent")
            : booksListView(pdfList,isRecent:widget.type == "recent", context: context);
      }),
    );
  }
}
