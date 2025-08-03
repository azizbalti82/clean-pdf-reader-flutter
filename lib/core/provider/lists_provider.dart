import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart' as path;

class PDFController extends GetxController {
  // Observable lists for PDF data
  List<String> allPDF = []; // homePDF

  RxList<String> homePDF = <String>[].obs; // homePDF
  RxList<String> recentPDF = <String>[].obs; // recentPDF
  RxList<String> bookmarkPDF = <String>[].obs; // bookmarkPDF

  void initAllPDF(List<String> newPDFs, String sortType) {
    // Initialize the list
    allPDF = newPDFs;
    sort(sortType);
  }

  void sort(String sortType){
    _sortHelper(homePDF,sortType);
    _sortHelper(recentPDF,sortType);
    _sortHelper(bookmarkPDF,sortType);
  }
  void _sortHelper(List<String> list, String sortType){
    // Sort based on the specified sort type
    switch (sortType) {
      case 'name':
        list.sort((a, b) {
          String nameA = path.basenameWithoutExtension(a).toLowerCase();
          String nameB = path.basenameWithoutExtension(b).toLowerCase();
          return nameA.compareTo(nameB);
        });
        break;

      case 'date_new':
        list.sort((a, b) {
          File fileA = File(a);
          File fileB = File(b);
          DateTime dateA = fileA
              .statSync()
              .modified;
          DateTime dateB = fileB
              .statSync()
              .modified;
          return dateB.compareTo(dateA); // Newest first
        });
        break;

      case 'date_old':
        list.sort((a, b) {
          File fileA = File(a);
          File fileB = File(b);
          DateTime dateA = fileA
              .statSync()
              .modified;
          DateTime dateB = fileB
              .statSync()
              .modified;
          return dateA.compareTo(dateB); // Oldest first
        });
        break;

      default:
      // If sortType is not recognized, keep original order or sort by name as default
        list.sort((a, b) {
          String nameA = path.basenameWithoutExtension(a).toLowerCase();
          String nameB = path.basenameWithoutExtension(b).toLowerCase();
          return nameA.compareTo(nameB);
        });
    }
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
