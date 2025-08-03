import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path/path.dart' as path;
import 'package:pdf_reader/main.dart';


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

Widget roomAppBar(
  BuildContext context, {
  required String text,
  required VoidCallback settingsClick,
  required VoidCallback reportClick,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      IconButton(
        onPressed: () => Navigator.pop(context),
        icon: SvgPicture.asset(
          "assets/icons/close.svg",
          width: 21,
          color: colorScheme.onSurface,
        ),
      ),
      Expanded(
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
      IconButton(
        onPressed: reportClick,
        icon: SvgPicture.asset(
          "assets/icons/flag.svg",
          width: 22,
          color: colorScheme.onSurface,
        ),
      ),
      IconButton(
        onPressed: settingsClick,
        icon: SvgPicture.asset(
          "assets/icons/settings.svg",
          width: 23,
          color: colorScheme.onSurface,
        ),
      ),
    ],
  );
}

Widget booksGridView(List<String> list, {String? icon, Function(String item)? onTap}) {
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
          childAspectRatio: 0.6, // Adjust this to control the overall card height
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

Widget pdfItem({
  required String filePath,
  required BuildContext context,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
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
      child:
      ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  Container(
                    color: Theme.of(context).colorScheme.background.withOpacity(0.9),
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: Icon(
                        Icons.picture_as_pdf,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
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