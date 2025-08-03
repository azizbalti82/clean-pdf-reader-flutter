import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:pdfx/pdfx.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:io';

import '../../../../core/provider/lists_provider.dart';
import '../../../../core/widgets/basics.dart';
import '../../../../core/widgets/cards_views.dart';
import '../../../application/presentation/views/widgets/system_wrapper_view.dart';

class PdfPreviewView extends StatefulWidget {
  const PdfPreviewView({super.key, required this.pdfPath});
  final String pdfPath;
  @override
  State<PdfPreviewView> createState() => _PdfPreviewViewState();
}

class _PdfPreviewViewState extends State<PdfPreviewView> with WidgetsBindingObserver {
  late PDFController pdfController;
  late String pdfPath;
  Timer? _autoFullscreenTimer;
  PdfController? pdfxController;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    pdfPath = widget.pdfPath;
    pdfController = Get.put(PDFController());
    WidgetsBinding.instance.addObserver(this);

    _initializePdf();

    // Instantly go fullscreen when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enableFullscreen();
    });
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
    _autoFullscreenTimer?.cancel();
    pdfxController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    // Reset to normal UI mode when leaving
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
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
    return Scaffold(
      body: GestureDetector(
        onTap: _onScreenTap,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          child: _buildPdfContent(),
        ),
      ),
    );
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
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
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

    return PdfView(
      controller: pdfxController!,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      onDocumentLoaded: (document) {
        print('PDF loaded: ${document.pagesCount} pages');
      },
      onPageChanged: (page) {
        print('Page changed: $page');
      },
    );
  }
}

// Alternative version with more aggressive auto-hide behavior
class PdfPreviewViewAggressive extends StatefulWidget {
  const PdfPreviewViewAggressive({super.key, required this.pdfPath});
  final String pdfPath;

  @override
  State<PdfPreviewViewAggressive> createState() => _PdfPreviewViewAggressiveState();
}

class _PdfPreviewViewAggressiveState extends State<PdfPreviewViewAggressive>
    with WidgetsBindingObserver {
  late PDFController pdfController;
  late String pdfPath;
  Timer? _hideTimer;
  Timer? _periodicTimer;
  PdfController? pdfxController;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    pdfPath = widget.pdfPath;
    pdfController = Get.put(PDFController());
    WidgetsBinding.instance.addObserver(this);

    _initializePdf();

    // Instantly go fullscreen when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enableFullscreen();
      _startPeriodicHiding();
    });
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
    _hideTimer?.cancel();
    _periodicTimer?.cancel();
    pdfxController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _enableFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _startPeriodicHiding() {
    _periodicTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        _enableFullscreen();
      }
    });
  }

  void _onUserInteraction() {
    // Reset the aggressive timer on user interaction
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _enableFullscreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:() async{
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        return true;
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: _onUserInteraction,
          onScaleUpdate: (_) => _onUserInteraction(),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: _buildPdfContent(),
          ),
        ),
      ),
    );
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
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
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

    return PdfView(
      controller: pdfxController!,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      onDocumentLoaded: (document) {
        print('PDF loaded: ${document.pagesCount} pages');
      },
      onPageChanged: (page) {
        print('Page changed: $page');
      },
    );
  }
}