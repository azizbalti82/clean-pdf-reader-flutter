import 'dart:async';
import 'dart:io';
import 'dart:typed_data'; // For Uint8List

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path/path.dart' as path_ob;
import 'package:pdf_reader/core/widgets/toasts.dart';
import 'package:pdf_reader/features/pdf%20preview/presentation/views/widgets/pdf_options_bottom_sheet_view.dart';

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

class _PdfPreviewViewState extends State<PdfPreviewView>
    with WidgetsBindingObserver {
  late PdfListsProvider pdfController;
  late SettingsProvider settingsProvider;

  late String pdfPath;
  Timer? _autoFullscreenTimer;
  bool isLoading = true;
  String? errorMessage;
  int currentPage = 1;
  int pagesNumber = 1;
  Timer? _timer;
  bool isOptionsShown = true;
  late ThemeData theme;
  ScrollController? _scrollController;
  Timer? _debounceTimer;


  @override
  void initState() {
    super.initState();
    pdfPath = widget.pdfPath;
    _scrollController = ScrollController();
    pdfController = Get.put(PdfListsProvider());
    settingsProvider = Get.put(SettingsProvider());

    WidgetsBinding.instance.addObserver(this);
    resetTimer();
    try {
      currentPage = pdfController.recentPDF
          .firstWhere((p) => p.path == pdfPath)
          .currentPage;
    } catch (e) {
      currentPage = 1;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _enableFullscreen());
    addToRecent();
  }

  @override
  void dispose() {
    super.dispose();
    FullScreen.setFullScreen(false);
    _autoFullscreenTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _scrollController?.dispose();
    _debounceTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _enableFullscreen());
    return Obx(() {
      theme = settingsProvider.isDark.value || settingsProvider.isYellow.value
          ? AppTheme.darkTheme
          : AppTheme.lightTheme;
      return Theme(
        data: theme,
        child: Scaffold(
          backgroundColor: theme.brightness==Brightness.light? Color(0xFFF4F8FA) : theme.colorScheme.background.withOpacity(0.6),
          body: GestureDetector(
            onTap: _onScreenTap,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: _buildPdfContent(),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPdfContent() {
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text('Error Loading PDF', style: theme.textTheme.headlineSmall),
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

    return GestureDetector(
      onTap: () {
        setState(() {
          isOptionsShown = !isOptionsShown;
        });
        resetTimer();
      },
      child: Stack(
        children: [
          settingsProvider.isDark.value || settingsProvider.isYellow.value
              ? buildFilteredPDFViewer(
                  settingsProvider.isDark.value ? "dark" : "yellow",
                )
              :SizedBox(
            width: double.infinity,
            child: SizedBox.expand( // This makes the child take all available space
              child: pdfViewer(), // Your PDF viewer widget
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            top: isOptionsShown ? 0 : -100,
            left: 10,
            right: 10,
            child: AnimatedOpacity(
              opacity: isOptionsShown ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  width: double.infinity,
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
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.8,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          path_ob.basenameWithoutExtension(pdfPath),
                          style: const TextStyle(
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
                            topRadius: const Radius.circular(25),
                            context: context,
                            builder: (context) =>
                                PdfPreviewOptionsBottomSheetView(),
                          );
                        },
                        icon: SvgPicture.asset(
                          "assets/icons/parameter.svg",
                          width: 22,
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.8,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showCupertinoModalBottomSheet(
                            topRadius: const Radius.circular(25),
                            context: context,
                            builder: (context) => PdfOptionsBottomSheetView(
                              path: pdfPath,
                              fromPreview: true,
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            bottom: isOptionsShown ? 0 : -100,
            left: 10,
            right: 10,
            child: AnimatedOpacity(
              opacity: isOptionsShown ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: (){
                    goToPage(pagesNumber);
                  },
                  child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 10,
                  ),
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
              )),
            ),
          ),
        ],
      ),
    );
  }

  void addToRecent({updateCurrentPage = false}) async {
    Pdf? pdf = PdfService.getPdf(pdfPath);
    if (pdf == null) {
      pdf = Pdf(
        path: pdfPath,
        lastOpenDate: DateTime.now(),
        isBookmark: false,
        isOpened: true,
        currentPage: 1,
      );
    } else {
      pdf = pdf.copyWith(
        isOpened: true,
        lastOpenDate: DateTime.now(),
        currentPage: updateCurrentPage ? currentPage : null,
      );
    }

    bool result = await PdfService.savePdf(pdfPath, pdf);

    if (result) {
      pdfController.recentPDF.removeWhere((p) => p.path == pdf?.path);
      pdfController.recentPDF.add(pdf);
    }
  }

  Widget buildFilteredPDFViewer(String type) {
    Widget pdfWidget = pdfViewer();
    ColorFilter? filter = type == "dark"
        ? ColorFilter.matrix([
            -1.0,
            0.0,
            0.0,
            0.0,
            255.0,
            0.0,
            -1.0,
            0.0,
            0.0,
            255.0,
            0.0,
            0.0,
            -1.0,
            0.0,
            255.0,
            0.0,
            0.0,
            0.0,
            1.0,
            0.0,
          ])
        : ColorFilter.matrix([
            0.393,
            0.769,
            0.189,
            0,
            0,
            0.349,
            0.686,
            0.168,
            0,
            0,
            0.272,
            0.534,
            0.131,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
          ]);
    pdfWidget = ColorFiltered(colorFilter: filter, child: pdfWidget);

    if (type == "yellow") {
      pdfWidget = Container(
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.1)),
        child: pdfWidget,
      );
    }

    return pdfWidget;
  }

  Widget pdfViewer() {
    return Stack(
      children: [
        Directionality(
          textDirection: !settingsProvider.isLTR.value && !settingsProvider.isVertical.value
              ? TextDirection.rtl
              : TextDirection.ltr,
          child:PDFView(
              filePath: pdfPath,
              defaultPage: currentPage,
              enableSwipe: true,
              swipeHorizontal: !settingsProvider.isVertical.value,
              autoSpacing: false,
              pageFling: false,
              pageSnap: !settingsProvider.isContinuous.value,
              backgroundColor: Colors.white,
              onError: (error) {
                if (mounted) {
                  // Handle error - maybe show a retry button
                  print('PDF load failed: ${error.toString()}');
                }
              },
              onPageError: (page, error) {
                if (mounted) {
                  // Handle error - maybe show a retry button
                  print('page $page load failed: $error');
                }
              },
              onPageChanged: (page,total) {
                // Use more aggressive debouncing to reduce state updates
                _pageChangeDebouncer?.cancel();
                _pageChangeDebouncer = Timer(const Duration(milliseconds: 300), () {
                  if (mounted && currentPage != page!) {
                    setState(() {
                      currentPage = page;
                    });
                    addToRecent(updateCurrentPage: true);
                  }
                });
              },
              onViewCreated: (c) async{
                if (mounted) {
                  pagesNumber = (await c.getPageCount())!;
                  setState(() {
                  });

                  // Pre-cache adjacent pages for smoother scrolling
                  // _precacheAdjacentPages();
                }
              },
            ),
        ),

        GestureDetector(
          behavior: HitTestBehavior.translucent, //to listen for tap events on an empty container

          onTap: (){
            setState(() {
              isOptionsShown = !isOptionsShown;
            });
            resetTimer();
          },

          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
        )

      ],
    );
  }
  Timer? _pageChangeDebouncer;
  Timer? _precacheTimer;

  /// functions ----------------------------------------------------------------
  void goToPage(int pagesCount) async {
    try {
      final controller = TextEditingController(text: currentPage.toString());

      final newValue = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Go To Page'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number, // Numeric keyboard
            inputFormatters: [
              // Allow only numeric input
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: 'Enter page number',
              errorText: _isValidInput(controller.text, pagesCount) ? null : 'Invalid page number',
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel')
            ),
            TextButton(
              onPressed: () {
                final input = controller.text.trim();
                if (_isValidInput(input, pagesCount)) {
                  Navigator.pop(context, input);
                }else{
                  Toast.showError("Enter a number from 1 to $pagesCount", context);
                }
              },
              child: Text('Go'),
            ),
          ],
        ),
      );

      if (newValue != null && newValue.isNotEmpty) {
        currentPage = int.parse(newValue);
      }
    } catch (e) {
      // Handle error if necessary
      print('Error: $e');
    }
  }

// Helper method to check if input is valid
  bool _isValidInput(String input, int pagesCount) {
    final page = int.tryParse(input);
    return page != null && page >= 1 && page <= pagesCount;
  }


  void startTimer() {
    _timer = Timer(const Duration(seconds: 3), () {
      setState(() {
        isOptionsShown = !isOptionsShown;
      });
    });
  }

  void resetTimer() {
    _timer?.cancel();
    startTimer();
  }

  void _enableFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _onScreenTap() {
    if (FullScreen.isFullScreen) {
      _autoFullscreenTimer?.cancel();
      _autoFullscreenTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) _enableFullscreen();
      });
    } else {
      _enableFullscreen();
    }
  }
}

