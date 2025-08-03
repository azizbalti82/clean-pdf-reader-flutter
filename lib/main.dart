import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'core/getx_scroll_manager.dart';
import 'core/services/settings_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/tts_service.dart';
import 'core/utils/constants.dart';
import 'core/utils/theme_data.dart';
import 'features/application/presentation/views/app_view.dart';
import 'features/application/presentation/views/widgets/system_wrapper_view.dart';

bool isGrid = true;
int gridCount = 3;
String sortType = 'name';
List<String> pdfFiles = [];

Future<void> loadSettings() async {
  isGrid = await SettingsService.getIsGrid();
  gridCount = await SettingsService.getGridCount();
  sortType = await SettingsService.getSortType();
}

void loadPDFs() async {
  try {
    pdfFiles.clear();
    pdfFiles = await loadAllPdfFiles();
    pdfFiles.forEach((file) {
      print(file);  // Print each PDF file path
    });
  } catch (e) {
    print("Error: $e");
  }
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Constants.packageInfo = await PackageInfo.fromPlatform();
  loadSettings();
  loadPDFs();
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
      theme: AppTheme.lightTheme,       // use the light theme
      darkTheme: AppTheme.darkTheme,    // use the dark theme
      themeMode: ThemeMode.system,

      home: const SystemUiStyleWrapper(
        child: AppView()
      ),
    );
  }
}