import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pdf_reader/features/pdf%20preview/presentation/views/widgets/pdf_options_bottom_sheet_view.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path/path.dart' as path_ob;

import 'package:get/get.dart';
import 'dart:async';
import 'dart:io';
import '../../../../core/provider/lists_provider.dart';
import '../../../../core/provider/settings_provider.dart';
import '../../../../core/utils/theme_data.dart';
import '../../../pdf listing/models/pdf.dart';
import '../../../pdf listing/presentation/views/widgets/pdf_options_bottom_sheet_view.dart';
import '../../../pdf listing/services/pdf_service.dart';


class PdfPreviewView extends StatefulWidget {
  const PdfPreviewView({super.key, required this.pdfPath});
  final String pdfPath;
  @override
  State<PdfPreviewView> createState() => _PdfPreviewViewState();
}

class _PdfPreviewViewState extends State<PdfPreviewView> with WidgetsBindingObserver {
  late PdfListsProvider pdfController;
  late SettingsProvider settingsProvider;

  late String pdfPath;
  Timer? _autoFullscreenTimer;
  PdfController? pdfxController;
  bool isLoading = true;
  String? errorMessage;
  int currentPage = 1;
  int pagesNumber = 1;
  Timer? _timer;
  bool isOptionsShown = true;
  late ThemeData theme;

  void startTimer() {
    _timer = Timer(Duration(seconds: 3), () {
      setState(() {
        isOptionsShown = !isOptionsShown;
      });
    });
  }
  void resetTimer() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();  // Cancel the existing timer
    }
    startTimer();  // Start a new timer
  }

  @override
  void initState() {
    super.initState();
    pdfPath = widget.pdfPath;
    pdfController = Get.put(PdfListsProvider());
    settingsProvider = Get.put(SettingsProvider());
    WidgetsBinding.instance.addObserver(this);
    resetTimer();
    _initializePdf();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enableFullscreen();
    });
    currentPage = pdfController.recentPDF
          .firstWhere((p) => p.path == pdfPath)
          .currentPage;
    addToRecent();
  }

  Future<void> _initializePdf() async {
    try {
      // Check if file exists
      final file = File(pdfPath);
      if (!await file.exists()) {
        setState(() {
          errorMessage = 'PDF file not found at: $pdfPath';
          isLoading = false;
        });
        return;
      }

      // Initialize PDF controller with file path
      pdfxController = PdfController(
        document: PdfDocument.openFile(pdfPath),
      );

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading PDF: $e';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _autoFullscreenTimer?.cancel();
    pdfxController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    // Reset to normal UI mode when leaving
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    /// update history when screen closed
  }

  void _enableFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _onScreenTap() {
    if (FullScreen.isFullScreen) {
      // Exit fullscreen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      // Start auto fullscreen timer (2 seconds)
      _autoFullscreenTimer?.cancel();
      _autoFullscreenTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          _enableFullscreen();
        }
      });
    } else {
      // If somehow not in fullscreen, enable it immediately
      _enableFullscreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Update theme reactively based on settings
      theme = settingsProvider.isDark.value ? AppTheme.darkTheme : AppTheme.lightTheme;

      return Theme(
          data: theme, child:
      Scaffold(
        body: GestureDetector(
          onTap: _onScreenTap,
          child: Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: MediaQuery
                .of(context)
                .size
                .height,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: _buildPdfContent(),
          ),
        ),
      ));
    });
  }

  Widget _buildPdfContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Error Loading PDF',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (pdfxController == null) {
      return const Center(
        child: Text('PDF controller not initialized'),
      );
    }

    return GestureDetector(
        onTap:(){
          setState(() {
            isOptionsShown = !isOptionsShown;
          });
          resetTimer();
        },
        child:Stack(
          children: [

        settingsProvider.isDark.value || settingsProvider.isYellow.value ?
        buildFilteredPDFViewer(settingsProvider.isDark.value ? "dark" : "yellow")
        : pdfViewer(),
            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              top: isOptionsShown ? 0 : -100,  // Adjust position based on state
              left: 10,
              right: 10,
              child: AnimatedOpacity(
                opacity: isOptionsShown ? 1.0 : 0.0,  // Fade in/out
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    width: double.infinity,  // Or any width constraint you'd like
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.4),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: theme.colorScheme.onBackground.withOpacity(0.8),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            path_ob.basenameWithoutExtension(pdfPath),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showCupertinoModalBottomSheet(
                              topRadius: Radius.circular(25),
                              context: context,
                              builder: (context) => PdfPreviewOptionsBottomSheetView(),
                            );
                          },
                          icon: SvgPicture.asset(
                            "assets/icons/parameter.svg",
                            width: 22,
                            color: theme.colorScheme.onBackground.withOpacity(0.8),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showCupertinoModalBottomSheet(
                              topRadius: Radius.circular(25),
                              context: context,
                              builder: (context) => PdfOptionsBottomSheetView(path: pdfPath, fromPreview: true),
                            );
                          },
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: theme.colorScheme.onBackground.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              bottom: isOptionsShown ? 0 : -100,  // Adjust position based on state
              left: 10,
              right: 10,
              child: AnimatedOpacity(
                opacity: isOptionsShown ? 1.0 : 0.0,  // Fade in/out
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: Align(
                  alignment: Alignment.center, // Ensures the child is centered in the parent
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    margin: EdgeInsets.symmetric(vertical: 40, horizontal: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.4),
                        width: 0.5,
                      ),
                    ),
                    child: Text("$currentPage / $pagesNumber"),
                  ),
                ),
              ),
            )
          ],
        )
    );
  }

  void addToRecent({updateCurrentPage=false}) async{
    //update recent in hive
    Pdf? pdf = PdfService.getPdf(pdfPath);

    if (pdf == null) {
      pdf = Pdf(path: pdfPath,
          lastOpenDate: DateTime.now(),
          isBookmark: false,
          isOpened:true,
          currentPage: 1);
    } else {
      pdf = pdf.copyWith(isOpened: true,lastOpenDate: DateTime.now(),currentPage: updateCurrentPage? currentPage : null);
    }

    bool result = await PdfService.savePdf(pdfPath, pdf);

    if (result) {
      // Update the UI
      pdfController.recentPDF.removeWhere((p)=>p.path==pdf?.path);
      pdfController.recentPDF.add(pdf);
    }
  }

  Widget buildFilteredPDFViewer(String type) {
    Widget pdfWidget = pdfViewer();

    // Apply color filter if selected
    ColorFilter? filter = (type=="dark")? ColorFilter.matrix([
      -1.0, 0.0, 0.0, 0.0, 255.0,
      0.0, -1.0, 0.0, 0.0, 255.0,
      0.0, 0.0, -1.0, 0.0, 255.0,
      0.0, 0.0, 0.0, 1.0, 0.0,
    ]) : ColorFilter.matrix([
      0.393, 0.769, 0.189, 0, 0,
      0.349, 0.686, 0.168, 0, 0,
      0.272, 0.534, 0.131, 0, 0,
      0, 0, 0, 1, 0,
    ]) ;

    pdfWidget = ColorFiltered(
        colorFilter: filter,
        child: pdfWidget,
    );

    // Add dimming effect for better reading (optional)
    if (type=="yellow") {
      pdfWidget = Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1), // Subtle dimming
        ),
        child: pdfWidget,
      );
    }

    return pdfWidget;
  }

  pdfViewer() {
    return Directionality(
      textDirection: (!settingsProvider.isLTR.value && !settingsProvider.isVertical.value)
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: PdfView(
        controller: pdfxController!,
        scrollDirection: settingsProvider.isVertical.value ? Axis.vertical : Axis.horizontal,

        // Change physics for continuous scrolling
        physics: const BouncingScrollPhysics(), // or AlwaysScrollableScrollPhysics()

        pageSnapping: !settingsProvider.isContinuous.value,

        onDocumentLoaded: (document) {
          print('PDF loaded: ${document.pagesCount} pages');
          setState(() {
            pagesNumber = document.pagesCount;
          });
          Timer(Duration(milliseconds: 300), () {
            pdfxController!.jumpToPage(currentPage - 1);
          });
        },

        onPageChanged: (page) async {
          print('Page changed: $page');
          setState(() {
            currentPage = page;
          });
          addToRecent(updateCurrentPage: true);
        },
      ),
    );
  }
}