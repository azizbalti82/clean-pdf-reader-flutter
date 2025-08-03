import 'package:get/get.dart';

class SettingsProvider extends GetxController {
  RxBool isGrid = false.obs; // homePDF
  RxInt colCount = 0.obs; // bookmarkPDF
  RxString sortBy = ''.obs; // recentPDF

  void initSettings(bool isGrid,String sortBy,int colCount) {
    this.colCount.value = colCount;
    this.isGrid.value = isGrid;
    this.sortBy.value = sortBy;
  }

  void updateIsGrid(bool isGrid) {
    this.isGrid.value = isGrid;
  }
  void updateSortBy(String sortBy) {
    this.sortBy.value = sortBy;
  }
  void updateColCount(int colCount) {
    this.colCount.value = colCount;
  }
}
