import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';

import 'package:flutter_svg/svg.dart';
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

class _PdfPreviewViewState extends State<PdfPreviewView>
    with WidgetsBindingObserver {
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
  ScrollController? _scrollController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _enableFullscreen());
    _scrollController = ScrollController();
    pdfPath = widget.pdfPath;
    pdfController = Get.put(PdfListsProvider());
    settingsProvider = Get.put(SettingsProvider());
    WidgetsBinding.instance.addObserver(this);
    resetTimer();
    _initializePdf();
    try {
      currentPage = pdfController.recentPDF
          .firstWhere((p) => p.path == pdfPath)
          .currentPage;
    } catch (e) {
      currentPage = 1;
    }
    addToRecent();
  }

  @override
  void dispose() {
    super.dispose();
    _autoFullscreenTimer?.cancel();
    pdfxController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _scrollController?.dispose();
    _debounceTimer?.cancel();
    FullScreen.setFullScreen(false);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _enableFullscreen());

    return Obx(() {
      theme = settingsProvider.isDark.value
          ? AppTheme.darkTheme
          : Theme.of(context);
      return Theme(
        data: theme,
        child: Scaffold(
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

    if (pdfxController == null) {
      return const Center(child: Text('PDF controller not initialized'));
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
              :pdfViewer(),
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
    return Directionality(
      textDirection:
          !settingsProvider.isLTR.value && !settingsProvider.isVertical.value
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: PdfView(
          controller: pdfxController!,
          scrollDirection: settingsProvider.isVertical.value
              ? Axis.vertical
              : Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          pageSnapping: !settingsProvider.isContinuous.value,

          // Performance optimizations
          builders: PdfViewBuilders<DefaultBuilderOptions>(
            options: const DefaultBuilderOptions(
              loaderSwitchDuration: Duration(milliseconds: 300),
            ),
            documentLoaderBuilder: (context) {
              return Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Loading PDF...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            },

            pageLoaderBuilder: (context) {
              return Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: Theme.of(context).primaryColor.withOpacity(0.7),
                ),
              );
            },

            errorBuilder: (context, error) {
              return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading PDF',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),

          onDocumentLoaded: (document) {
            setState(() {
              pagesNumber = document.pagesCount;
            });

            // Optimized page jumping with better timing
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Timer(const Duration(milliseconds: 200), () {
                if (mounted && pdfxController != null) {
                  pdfxController!.jumpToPage(currentPage - 1);
                }
              });
            });
          },

          onPageChanged: (page) async {
            if (mounted) {
              setState(() {
                currentPage = page;
              });

              // Debounce recent updates to avoid excessive calls
              _debounceTimer?.cancel();
              _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                if (mounted) {
                  addToRecent(updateCurrentPage: true);
                }
              });
            }
          },
        ),
    );
  }

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
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text('Go'),
            ),
          ],
        ),
      );

      currentPage = int.parse(newValue.toString());
      pdfxController?.jumpToPage(currentPage);
    } catch (e) {
    }
  }

  Future<void> _initializePdf() async {
    try {
      final file = File(pdfPath);
      if (!await file.exists()) {
        setState(() {
          errorMessage = 'PDF file not found at: $pdfPath';
        });
        return;
      }
      pdfxController = PdfController(document: PdfDocument.openFile(pdfPath));
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading PDF: $e';
      });
    }
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
