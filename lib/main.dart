import 'package:flutter/material.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pdf_reader/features/pdf%20listing/models/pdf.dart';
import 'core/provider/lists_provider.dart';
import 'core/provider/settings_provider.dart';
import 'core/services/settings_service.dart';
import 'core/services/storage_service.dart';
import 'core/utils/constants.dart';
import 'core/utils/theme_data.dart';
import 'features/application/presentation/views/app_view.dart';
import 'features/application/presentation/views/widgets/system_wrapper_view.dart';
import 'features/pdf listing/services/pdf_service.dart';

Future<void> loadSettings() async {
  bool isGrid = await SettingsService.getIsGrid();
  int gridCount = await SettingsService.getGridCount();
  String sortType = await SettingsService.getSortType();

  bool isLTR = await SettingsService.getIsLTR();
  bool isYellow = await SettingsService.getIsYellow();
  bool isDark = await SettingsService.getIsDark();
  bool isVertical = await SettingsService.getIsVertical();
  bool isContinuous = await SettingsService.getIsContinuous();


  final SettingsProvider settingsProvider = Get.put(SettingsProvider());
  settingsProvider.initSettings(isGrid,sortType,gridCount,isLTR,isYellow,isDark,isVertical,isContinuous);
}

void loadPDFs() async {
  try {
    List<String> pdfFiles = await loadAllPdfFiles();
    //get all pdfs from hive:
    List<Pdf> hivePdfs = PdfService.getAllPdfs();
    List<String> bookmarksPdfs = pdfFiles.where((p)=> hivePdfs.where((m)=>m.isBookmark).map((m)=>m.path).contains(p)).toList();
    List<Pdf> recentPdfs = hivePdfs.where((m)=>m.isOpened && pdfFiles.contains(m.path)).toList();


    //init lists
    final PdfListsProvider pdfController = Get.put(PdfListsProvider());
    final SettingsProvider settingsProvider = Get.put(SettingsProvider());
    pdfController.initAllPDF(pdfFiles,settingsProvider.sortBy.value);
    pdfController.updateHomePDF(pdfFiles);
    pdfController.updateRecentPDF(recentPdfs);
    pdfController.updateBookmarkPDF(bookmarksPdfs);

    pdfController.sort(settingsProvider.sortBy.value);
  } catch (e) {
    print("Error: $e");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //hive
  await Hive.initFlutter();
  Hive.registerAdapter(PdfAdapter());
  await Hive.openBox<Pdf>('pdfBox');

  Constants.packageInfo = await PackageInfo.fromPlatform();
  Get.put(SettingsProvider());
  Get.put(PdfListsProvider());
  loadSettings();
  loadPDFs();
  await FullScreen.ensureInitialized();
  // Request permissions early (but don't block app startup)
  requestPermissions().catchError((e) {
    print("Permission error: $e");
  });
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
