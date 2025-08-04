import 'dart:io';
import 'dart:typed_data';
import 'package:pdfx/pdfx.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<Uint8List?> getPdfThumbnail(String pdfFilePath) async {
  try {
    final file = File(pdfFilePath);
    if (!await file.exists()) return null;

    final document = await PdfDocument.openFile(pdfFilePath);
    final page = await document.getPage(1);

    final pageImage = await page.render(
      width: 600,
      height: 900,
      format: PdfPageImageFormat.png,
    );

    await page.close();
    await document.close();

    return pageImage?.bytes;
  } catch (e) {
    print('Error generating PDF thumbnail: $e');
    return null;
  }
}
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
    final thumbnailBytes = await getPdfThumbnail(pdfFilePath);

    if (thumbnailBytes != null) {
      // Cache the thumbnail
      await cacheFile.writeAsBytes(thumbnailBytes);
    }

    return thumbnailBytes;
  } catch (e) {
    print('Error with cached PDF thumbnail: $e');
    return await getPdfThumbnail(pdfFilePath);
  }
}