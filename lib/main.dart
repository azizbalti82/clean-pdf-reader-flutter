import 'package:flutter/material.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'core/getx_scroll_manager.dart';
import 'core/provider/lists_provider.dart';
import 'core/services/settings_service.dart';
import 'core/services/storage_service.dart';
import 'core/utils/constants.dart';
import 'core/utils/theme_data.dart';
import 'features/application/presentation/views/app_view.dart';
import 'features/application/presentation/views/widgets/system_wrapper_view.dart';

bool isGrid = true;
int gridCount = 3;
String sortType = 'name';

Future<void> loadSettings() async {
  isGrid = await SettingsService.getIsGrid();
  gridCount = await SettingsService.getGridCount();
  sortType = await SettingsService.getSortType();
}

void loadPDFs() async {
  try {
    List<String> pdfFiles = await loadAllPdfFiles();
    pdfFiles.forEach((file) {
      print(file); // Print each PDF file path
    });

    //init lists
    final PDFController pdfController = Get.put(PDFController());
    pdfController.initAllPDF(pdfFiles);
    pdfController.updateHomePDF(pdfFiles);
    pdfController.updateRecentPDF([]);
    pdfController.updateBookmarkPDF([]);
  } catch (e) {
    print("Error: $e");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Constants.packageInfo = await PackageInfo.fromPlatform();
  Get.put(PDFController());
  loadSettings();
  loadPDFs();
  await FullScreen.ensureInitialized();
  // Request permissions early (but don't block app startup)
  requestPermissions().catchError((e) {
    print("Permission error: $e");
  });
  Get.put(ScrollManager());
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: Constants.appName,
      theme: AppTheme.lightTheme,
      // use the light theme
      darkTheme: AppTheme.darkTheme,
      // use the dark theme
      themeMode: ThemeMode.system,

      home: const SystemUiStyleWrapper(child: AppView()),
    );
  }
}
