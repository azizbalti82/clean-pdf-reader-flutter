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
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: Obx(() {
        // Get list depending on section - moved outside widget building
        final List<String> pdfList = _getPdfList(pdfController);

        if (pdfList.isEmpty) {
          return const _EmptyStateWidget();
        }

        // Use separate Obx for grid/list toggle to minimize rebuilds
        return Obx(() => settingsProvider.isGrid.value
            ? _GridViewWidget(
            pdfList: pdfList,
            isRecent: type == "recent"
        )
            : _ListViewWidget(
            pdfList: pdfList,
            isRecent: type == "recent",
            context: context
        )
        );
      }),
    );
  }

  // Extract list logic to reduce rebuilds
  List<String> _getPdfList(PdfListsProvider pdfController) {
    switch (type) {
      case "pdf listing":
        return pdfController.homePDF;
      case "recent":
      // Cache the reversed list to avoid recreating on each build
        return pdfController.recentPDF.reversed.map((p) => p.path).toList();
      case "bookmark":
        return pdfController.bookmarkPDF;
      default:
        return [];
    }
  }
}
class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        width: MediaQuery.of(context).size.width * 0.8,
        child: const Center(
          child: Text(
            'No PDFs Available',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}

class _GridViewWidget extends StatelessWidget {
  const _GridViewWidget({
    required this.pdfList,
    required this.isRecent,
  });

  final List<String> pdfList;
  final bool isRecent;

  @override
  Widget build(BuildContext context) {
    return booksGridView(pdfList, isRecent: isRecent);
  }
}

class _ListViewWidget extends StatelessWidget {
  const _ListViewWidget({
    required this.pdfList,
    required this.isRecent,
    required this.context,
  });

  final List<String> pdfList;
  final bool isRecent;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return booksListView(pdfList, isRecent: isRecent, context: context);
  }
}