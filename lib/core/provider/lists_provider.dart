import 'package:get/get.dart';

class PDFController extends GetxController {
  // Observable lists for PDF data
  List<String> allPDF = []; // homePDF

  RxList<String> homePDF = <String>[].obs; // homePDF
  RxList<String> recentPDF = <String>[].obs; // recentPDF
  RxList<String> bookmarkPDF = <String>[].obs; // bookmarkPDF

  void initAllPDF(List<String> newPDFs) {
    allPDF = newPDFs;
  }

  // Method to update homePDF
  void updateHomePDF(List<String> newPDFs) {
    homePDF.value = newPDFs;
  }

  // Method to update recentPDF
  void updateRecentPDF(List<String> newPDFs) {
    recentPDF.value = newPDFs;
  }

  // Method to update bookmarkPDF
  void updateBookmarkPDF(List<String> newPDFs) {
    bookmarkPDF.value = newPDFs;
  }

  // Optionally, you can add methods for filtering or searching PDFs
  void filterHomePDF(String query) {
    if (query.isEmpty) {
      homePDF.value = allPDF;
    } else {
      homePDF.value = allPDF.where((pdf) => pdf.contains(query)).toList();
    }
  }
}
