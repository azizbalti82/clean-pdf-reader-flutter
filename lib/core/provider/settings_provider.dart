import 'package:get/get.dart';

class SettingsProvider extends GetxController {
  RxBool isGrid = false.obs; // homePDF
  RxInt colCount = 0.obs; // bookmarkPDF
  RxString sortBy = ''.obs; // recentPDF
  RxString bgColor = 'follow'.obs; // recentPDF
  /// preview preferences
  RxBool isVertical = true.obs; //false means "horizontal"
  RxBool isContinuous = true.obs; //false means "jump"
  RxBool isDark = false.obs;
  RxBool isYellow = false.obs;
  RxBool isLTR = false.obs;
  RxInt renderingQuality = 2.obs;

  RxBool isStorageGranted = true.obs;



  void initSettings(bool isGrid,String sortBy,int colCount,bool isLTR,bool isYellow,bool isDark,bool isVertical,bool isContinuous,int renderingQuality,String bgColor) {
    this.colCount.value = colCount;
    this.isGrid.value = isGrid;
    this.sortBy.value = sortBy;
    this.isLTR.value = isLTR;
    this.isYellow.value = isYellow;
    this.isDark.value = isDark;
    this.isVertical.value = isVertical;
    this.isContinuous.value = isContinuous;
    this.renderingQuality.value = renderingQuality;
    this.bgColor.value = bgColor;
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
  /// preview preferences
  void updateIsVertical(bool result) {
    isVertical.value = result;
  }
  void updateIsContinuous(bool result) {
    isContinuous.value = result;
  }
  void updateIsDark(bool result) {
    isDark.value = result;
  }
  void updateIsYellow(bool result) {
    isYellow.value = result;
  }
  void updateIsLTR(bool result) {
    isLTR.value = result;
  }
  void updateRenderingQuality(int result) {
    renderingQuality.value = result;
  }
  void updateBgColor(String result) {
    bgColor.value = result;
  }
}
