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
import 'package:pdf_reader/core/utils/tools.dart';
import 'package:pdf_reader/core/widgets/toasts.dart';
import 'package:pdf_reader/features/pdf%20preview/presentation/views/widgets/pdf_options_bottom_sheet_view.dart';

import '../../../../core/provider/lists_provider.dart';
import '../../../../core/provider/settings_provider.dart';
import '../../../../core/utils/theme_data.dart';
import '../../../../core/widgets/basics.dart';
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
  final Completer<PDFViewController> pdfCtrl = Completer<PDFViewController>();
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
  late bool isVertical;
  late String bgColor;

  @override
  void initState() {
    super.initState();
    pdfPath = widget.pdfPath;
    _scrollController = ScrollController();
    pdfController = Get.put(PdfListsProvider());
    settingsProvider = Get.put(SettingsProvider());
    isVertical = settingsProvider.isVertical.value;
    bgColor = settingsProvider.bgColor.value;


    WidgetsBinding.instance.addObserver(this);
    resetTimer();
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
    FullScreen.setFullScreen(false);
    _autoFullscreenTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _scrollController?.dispose();
    _debounceTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isVertical != settingsProvider.isVertical.value || bgColor != settingsProvider.bgColor.value) {
        isVertical = settingsProvider.isVertical.value;
        bgColor = settingsProvider.bgColor.value;

        // Schedule screen replacement after this frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PdfPreviewView(pdfPath: pdfPath,),
            ),
          );
        });
      }

      statusBarPreviewSetup();
      theme = settingsProvider.isDark.value
          ? AppTheme.darkTheme
          : AppTheme.lightTheme;
      return Theme(
        data: theme,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: theme.brightness == Brightness.light
                ? Color(0xFFF4F8FA)
                : theme.colorScheme.background.withOpacity(0.6),
            body: GestureDetector(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: _buildPdfContent(),
              ),
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

    return Stack(
      children: [
        settingsProvider.isDark.value || settingsProvider.isYellow.value
            ? buildFilteredPDFViewer(
                settingsProvider.isDark.value ? "dark" : "yellow",
              )
            : SizedBox(
                width: double.infinity,
                child: SizedBox.expand(
                  child: pdfViewer(),
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
                        color: theme.colorScheme.onBackground.withOpacity(0.8),
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
                          builder: (context) {
                            FullScreen.setFullScreen(true);
                            return PdfPreviewOptionsBottomSheetView();
                          },
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
                          topRadius: const Radius.circular(25),
                          context: context,
                          builder: (context) {
                            FullScreen.setFullScreen(true);
                            return PdfOptionsBottomSheetView(
                              path: pdfPath,
                              fromPreview: true,
                            );
                          },
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
        FutureBuilder(
          future: pdfCtrl.future,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FutureBuilder<int?>(
                future: snapshot.data?.getPageCount(),
                builder: (context, countSnapshot) {
                  if (countSnapshot.hasData) {
                    int count = countSnapshot.data ?? 1;

                    return AnimatedPositioned(
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
                            onTap: () {
                              goToPage();
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
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.4,
                                  ),
                                  width: 0.5,
                                ),
                              ),
                              child: Text("${currentPage+1} / $count"),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox(); // loading or empty
                  }
                },
              );
            } else {
              return const SizedBox(); // still waiting pdfCtrl.future
            }
          },
        ),
      ],
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
          textDirection:
              settingsProvider.isLTR.value && !settingsProvider.isVertical.value
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: PDFView(
            filePath: pdfPath,
            defaultPage: currentPage,
            enableSwipe: true,
            swipeHorizontal:!settingsProvider.isVertical.value,
            autoSpacing: !settingsProvider.isContinuous.value,
            fitPolicy: settingsProvider.isVertical.value
                ? FitPolicy.WIDTH
                : FitPolicy.HEIGHT,
            pageFling: false,
            pageSnap: !settingsProvider.isContinuous.value,
            backgroundColor: getSpaceColor(isReal: false),
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
            onPageChanged: (page, total) {
              setState(() {
                currentPage = page ?? 1;
              });
              addToRecent(updateCurrentPage: true);
            },
            onViewCreated: (PDFViewController pdfViewController) async {
              //pdfCtrl.complete(pdfViewController);
              if (!pdfCtrl.isCompleted) {
                pdfCtrl.complete(pdfViewController);
              }
            },
          ),
        ),

        GestureDetector(
          behavior: HitTestBehavior
              .translucent, //to listen for tap events on an empty container

          onTap: () {
            setState(() {
              isOptionsShown = !isOptionsShown;
              FullScreen.setFullScreen(!isOptionsShown);
            });
            resetTimer();
          },

          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
        ),
      ],
    );
  }

  /// functions ----------------------------------------------------------------
  void goToPage() async {
    try {
      final controller = TextEditingController(text: (currentPage+1).toString());
      var _controller = await pdfCtrl.future;
      int count = await _controller.getPageCount() ?? 1;
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
              errorText: _isValidInput(controller.text, count)
                  ? null
                  : 'Invalid page number',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final input = controller.text.trim();
                if (_isValidInput(input, count)) {
                  Navigator.pop(context, input);
                  _controller.setPage(int.parse(input)-1);
                  setState(() {});
                } else {
                  Toast.showError("Enter a number from 1 to $count", context);
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
        isOptionsShown = false;
      });
      FullScreen.setFullScreen(true);
    });
  }

  void resetTimer() {
    _timer?.cancel();
    startTimer();
  }
}
