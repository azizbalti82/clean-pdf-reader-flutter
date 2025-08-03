import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:path/path.dart' as path;
import 'package:pdf_reader/main.dart';

import '../../features/pdf preview/presentation/views/pdf_preview_view.dart';

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

Widget booksGridView(
  List<String> list, {
  String? icon,
  Function(String item)? onTap,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return GridView.builder(
        shrinkWrap: true,
        itemCount: list.length,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridCount,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio:
              0.6, // Adjust this to control the overall card height
        ),
        itemBuilder: (context, index) {
          final item = list[index];
          return pdfItem(
            filePath: item,
            context: context,
            onTap: () => onTap?.call(item),
          );
        },
      );
    },
  );
}

Widget booksListView(
  List<String> list, {
  String? icon,
  Function(String item)? onTap,
  required BuildContext context,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: list
        .map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: pdfItemInline(
              filePath: item,
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
  required BuildContext context,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: () async{
      await Get.to(PdfPreviewView(pdfPath: filePath,));
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
          // PDF preview area with fixed aspect ratio
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.background.withOpacity(0.9),
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: Icon(
                        Icons.picture_as_pdf,
                        size: 40,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // File info section with dynamic text sizing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 16),
            child: Text(
              path.basenameWithoutExtension(filePath),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget pdfItemInline({
  required String filePath,
  required BuildContext context,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: () async{
      await Get.to(PdfPreviewView(pdfPath: filePath,));
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
              child: Text(
                path.basenameWithoutExtension(filePath),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
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
