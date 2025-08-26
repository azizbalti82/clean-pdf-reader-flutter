import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path/path.dart' as path;
import 'package:shimmer/shimmer.dart';

import '../../features/pdf listing/models/pdf.dart';
import '../../features/pdf listing/presentation/views/widgets/pdf_options_bottom_sheet_view.dart';
import '../../features/pdf listing/services/pdf_service.dart';
import '../../features/pdf preview/presentation/views/pdf_preview_view.dart';
import '../provider/settings_provider.dart';
import '../utils/tools.dart';

Widget simpleAppBar(BuildContext context, {required String text}) {
  final colorScheme = Theme.of(context).colorScheme;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.07), // cardColor equivalent
          borderRadius: BorderRadius.circular(50),
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(
            "assets/icons/back.svg",
            width: 20,
            color: colorScheme.onSurface, // textColor equivalent
          ),
        ),
      ),
      Flexible(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
            ),
            softWrap: true,
          ),
        ),
      ),
      const SizedBox(width: 45),
    ],
  );
}

final SettingsProvider settingsProvider = Get.find<SettingsProvider>();

Widget booksGridView(
    List<String> list, {
      String? icon,
      required bool isRecent,
      Function(String item)? onTap,
    }) {
  return Obx(() {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: list.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: settingsProvider.colCount.value,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.6,
      ),
      itemBuilder: (context, index) {
        final item = list[index];
        return pdfItem(
          filePath: item,
          isRecent: isRecent,
          context: context,
          onTap: () => onTap?.call(item),
        );
      },
    );
  });
}


Widget booksListView(
  List<String> list, {
  String? icon,
  Function(String item)? onTap,
  required BuildContext context,
      required bool isRecent
})
{
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: list
        .map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: pdfItemInline(
              filePath: item,
              isRecent: isRecent,
              context: context,
              onTap: () => onTap?.call(item),
            ),
          ),
        )
        .toList(),
  );
}

Widget pdfItem({
  required String filePath,
  required bool isRecent,
  required BuildContext context,
  VoidCallback? onTap,
}) {
  return PdfItem(
    filePath: filePath,
    isRecent: isRecent,
    onTap: onTap,
  );
}

Widget pdfItemInline({
  required String filePath,
  required BuildContext context,
  required bool isRecent,
  VoidCallback? onTap,
})
{
  return GestureDetector(
    onTap: () async{
      navigate(context,PdfPreviewView(pdfPath: filePath));
      },
    onLongPress: (){
      showCupertinoModalBottomSheet(
        topRadius: Radius.circular(25),
        context: context,
        builder: (context) => PdfOptionsBottomSheetView(path:filePath,fromPreview: false,),
      );
    },
    child: Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // PDF icon area - fixed width
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background.withOpacity(0.6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.picture_as_pdf,
                size: 32,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
              ),
            ),
          ),

          // File info section - takes remaining space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    path.basenameWithoutExtension(filePath),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if(isRecent)
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 3,horizontal: 7),
                    margin: EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      getTimeSinceLastOpen(path:filePath),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              )
            ),
          ),

          // Optional trailing icon
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
        ],
      ),
    ),
  );
}

String getTimeSinceLastOpen({required String path}) {
  Pdf? pdf = PdfService.getPdf(path);

  if (pdf == null) {
    return 'No data';
  }

  DateTime now = DateTime.now();
  Duration difference = now.difference(pdf.lastOpenDate);

  if (difference.inSeconds < 10) {
    return 'now';
  } else if (difference.inSeconds < 60) {
    return '${difference.inSeconds} sec ago';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} min ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hr ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
  } else if (difference.inDays < 30) {
    int weeks = (difference.inDays / 7).floor();
    return '$weeks wk${weeks == 1 ? '' : 's'} ago';
  } else if (difference.inDays < 365) {
    int months = (difference.inDays / 30).floor();
    return '$months mo${months == 1 ? '' : 's'} ago';
  } else {
    int years = (difference.inDays / 365).floor();
    return '$years yr${years == 1 ? '' : 's'} ago';
  }
}



class PdfItem extends StatefulWidget {
  final String filePath;
  final bool isRecent;
  final VoidCallback? onTap;

  const PdfItem({
    Key? key,
    required this.filePath,
    required this.isRecent,
    this.onTap,
  }) : super(key: key);

  @override
  State<PdfItem> createState() => _PdfItemState();
}
class _PdfItemState extends State<PdfItem> with AutomaticKeepAliveClientMixin {
  Future<Uint8List?>? _thumbnailFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(covariant PdfItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filePath != widget.filePath) {
      _loadThumbnail();
    }
  }

  void _loadThumbnail() {
    _thumbnailFuture = getPdfThumbnailCached(widget.filePath);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
      onTap: () {
        navigate(context, PdfPreviewView(pdfPath: widget.filePath));
      },
      onLongPress: () {
        showCupertinoModalBottomSheet(
          topRadius: const Radius.circular(25),
          context: context,
          builder: (context) => PdfOptionsBottomSheetView(
            path: widget.filePath,
            fromPreview: false,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // PDF preview area with cached thumbnail
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Container(
                  color: Theme.of(context)
                      .colorScheme
                      .background
                      .withOpacity(0.9),
                  width: double.infinity,
                  height: double.infinity,
                  child: _thumbnailFuture != null
                      ? getPdfThumbnailCachedExist(
                      widget.filePath, _thumbnailFuture!)
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            // File info section
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    path.basenameWithoutExtension(widget.filePath),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if (widget.isRecent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 7),
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        getTimeSinceLastOpen(path: widget.filePath),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


statusBarPreviewSetup(){
  // set system bars style based on theme
  if (settingsProvider.isDark.value) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  } else if (settingsProvider.isYellow.value) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.yellow.shade50,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.yellow.shade50,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  } else {
    // Light mode
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
}