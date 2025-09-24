import 'dart:io';
import 'dart:typed_data';

import 'package:cached_memory_image/cached_memory_image.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:flutter/foundation.dart';
import 'package:shimmer/shimmer.dart';

navigate(BuildContext c,Widget screen,{bool? isReplace}){
  if(isReplace!=null && isReplace){
    Navigator.pushReplacement(
        c,
        MaterialPageRoute(builder: (context) => screen)
    );
  }else{
    Navigator.push(
        c,
        MaterialPageRoute(builder: (context) => screen)
    );
  }
}
//extract image from pdf
Future<Uint8List?> _getPdfThumbnail(String pdfFilePath) async {
  try {
    final file = File(pdfFilePath);
    if (!await file.exists()) return null;

    final document = await PdfDocument.openFile(pdfFilePath);
    final page = await document.getPage(1);

    final pageImage = await page.render(
      width: 300,
      height: 450,
      format: PdfPageImageFormat.png,
      backgroundColor: "#FFFFFFFF", // white in ARGB
    );

    await page.close();
    await document.close();

    return pageImage?.bytes;
  } catch (e) {
    print('Error generating PDF thumbnail: $e');
    return null;
  }
}
//get image from storage if its cached, other wise extract it with the function above and cache it
Future<Uint8List?> getPdfThumbnailCached(String pdfFilePath) async {
  try {
    // Create cache file path
    final cacheDir = await getTemporaryDirectory();
    final fileName = path.basenameWithoutExtension(pdfFilePath);
    final cacheFile = File('${cacheDir.path}/thumb_$fileName.png');

    // Return cached thumbnail if exists
    if (await cacheFile.exists()) {
      return await cacheFile.readAsBytes();
    }

    // Generate new thumbnail
    final thumbnailBytes = await _getPdfThumbnail(pdfFilePath);

    if (thumbnailBytes != null) {
      // Cache the thumbnail
      await cacheFile.writeAsBytes(thumbnailBytes);
    }

    return thumbnailBytes;
  } catch (e) {
    print('Error with cached PDF thumbnail: $e');
    return await _getPdfThumbnail(pdfFilePath);
  }
}
//return an image widget with cached image in memory
Widget getPdfThumbnailCachedExist(String imagePath, Future<Uint8List?>? imageFuture) {
  return FutureBuilder<Uint8List?>(
    future: imageFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // If the data is loading, show the shimmer animation
        return Shimmer.fromColors(
          baseColor: Theme.of(context).cardColor,
          highlightColor: Theme.of(context).colorScheme.surface.withOpacity(0.15),
          enabled: snapshot.connectionState == ConnectionState.waiting,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Theme.of(context).colorScheme.background,
          ),
        );
      } else if (snapshot.hasError || snapshot.data == null) {
        return const Icon(Icons.picture_as_pdf, size: 50, color: Colors.grey);
      } else {
        return CachedMemoryImage(
          uniqueKey: imagePath,
          bytes: snapshot.data!,
          fit:BoxFit.fill
        );
      }
    },
  );
}