import 'dart:io';
import 'dart:typed_data';

import 'package:cached_memory_image/cached_memory_image.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:flutter/foundation.dart';
import 'package:shimmer/shimmer.dart';

/*
Future<Uint8List?> getPdfThumbnail(String pdfFilePath) async {
  try {
    final file = File(pdfFilePath);
    if (!await file.exists()) return null;

    final document = await PdfDocument.openFile(pdfFilePath);
    final page = await document.getPage(1);


    final pageImage = await page.render(
      width: 300,
      height: 450,
      format: PdfPageImageFormat.png,
      backgroundColor: "white"
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
 */

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

/*
/// PERSISTENT singleton cache that survives widget rebuilds
class PersistentThumbnailCache {
  static final PersistentThumbnailCache _instance =
  PersistentThumbnailCache._internal();
  factory PersistentThumbnailCache() => _instance;
  PersistentThumbnailCache._internal();

  // PERSISTENT memory cache - survives widget rebuilds
  final Map<String, Uint8List?> _memoryCache = {};
  final Map<String, Future<Uint8List?>> _pendingRequests = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  static const int _maxCacheSize = 100;
  static const Duration _cacheExpiry = Duration(hours: 6);

  /// Main method - checks memory first, then disk, then generates
  Future<Uint8List?> getThumbnail(String pdfPath) async {
    final cacheKey = _getCacheKey(pdfPath);

    // 1. Check memory cache FIRST - this persists across rebuilds
    if (_memoryCache.containsKey(cacheKey)) {
      final timestamp = _cacheTimestamps[cacheKey];
      if (timestamp != null &&
          DateTime.now().difference(timestamp) < _cacheExpiry) {
        print('✓ Memory cache hit for: ${path.basename(pdfPath)}');
        return _memoryCache[cacheKey];
      } else {
        // Expired - remove from cache
        _memoryCache.remove(cacheKey);
        _cacheTimestamps.remove(cacheKey);
      }
    }

    // 2. Check if request is already in progress
    if (_pendingRequests.containsKey(cacheKey)) {
      print('⏳ Waiting for pending request: ${path.basename(pdfPath)}');
      return await _pendingRequests[cacheKey]!;
    }

    // 3. Start new request
    final future = _loadThumbnail(pdfPath, cacheKey);
    _pendingRequests[cacheKey] = future;

    try {
      final result = await future;

      // Store in memory cache
      if (result != null) {
        _addToMemoryCache(cacheKey, result);
        print('✓ Cached in memory: ${path.basename(pdfPath)}');
      }

      return result;
    } finally {
      _pendingRequests.remove(cacheKey);
    }
  }

  /// Load from disk cache or generate new thumbnail
  Future<Uint8List?> _loadThumbnail(String pdfPath, String cacheKey) async {
    try {
      // Try disk cache first
      final diskBytes = await _loadFromDiskCache(pdfPath);
      if (diskBytes != null) {
        print('✓ Disk cache hit for: ${path.basename(pdfPath)}');
        return diskBytes;
      }

      // Generate new thumbnail
      print('⚙️ Generating thumbnail for: ${path.basename(pdfPath)}');
      final newBytes = await _generateThumbnail(pdfPath);

      if (newBytes != null) {
        // Save to disk cache (don't await - do in background)
        _saveToDiskCache(pdfPath, newBytes);
      }

      return newBytes;
    } catch (e) {
      print('Error loading thumbnail for $pdfPath: $e');
      return null;
    }
  }

  /// Load from disk cache
  Future<Uint8List?> _loadFromDiskCache(String pdfPath) async {
    try {
      final cacheFile = await _getCacheFile(pdfPath);
      if (await cacheFile.exists()) {
        return await cacheFile.readAsBytes();
      }
    } catch (e) {
      print('Error reading disk cache: $e');
    }
    return null;
  }

  /// Save to disk cache (background operation)
  void _saveToDiskCache(String pdfPath, Uint8List bytes) {
    _getCacheFile(pdfPath).then((cacheFile) async {
      try {
        await cacheFile.writeAsBytes(bytes);
      } catch (e) {
        print('Error saving to disk cache: $e');
      }
    });
  }

  /// Generate thumbnail - FIXED VERSION (no isolate for now)
  Future<Uint8List?> _generateThumbnail(String pdfPath) async {
    try {
      print('Starting thumbnail generation for: ${path.basename(pdfPath)}');

      if (!await File(pdfPath).exists()) {
        print('PDF file does not exist: $pdfPath');
        return null;
      }

      // Generate directly on main thread for debugging
      // TODO: Move to isolate once working
      final document = await PdfDocument.openFile(pdfPath);
      print('PDF document opened successfully');

      final page = await document.getPage(1);
      print('Got first page');

      final pageImage = await page.render(
        width: 200,
        height: 300,
        format: PdfPageImageFormat.png,
        backgroundColor: '#FFFFFF', // Try string format
      );
      print('Page rendered successfully');

      await page.close();
      await document.close();
      print('PDF resources closed');

      if (pageImage?.bytes != null) {
        print('Thumbnail generated successfully, size: ${pageImage!.bytes.length} bytes');
        return pageImage.bytes;
      } else {
        print('Page image is null');
        return null;
      }
    } catch (e, stackTrace) {
      print('Error generating thumbnail: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Add to memory cache with size management
  void _addToMemoryCache(String key, Uint8List bytes) {
    // Clean up if cache is full
    if (_memoryCache.length >= _maxCacheSize) {
      _evictOldestEntries();
    }

    _memoryCache[key] = bytes;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// Remove oldest entries when cache is full
  void _evictOldestEntries() {
    if (_cacheTimestamps.isEmpty) return;

    final entries = _cacheTimestamps.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    // Remove oldest 25% of entries
    final removeCount = (_maxCacheSize * 0.25).round();
    for (int i = 0; i < removeCount && i < entries.length; i++) {
      final key = entries[i].key;
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Get cache file path
  Future<File> _getCacheFile(String pdfPath) async {
    final cacheDir = await getTemporaryDirectory();
    final file = File(pdfPath);
    final stat = await file.stat();

    final fileName = path.basenameWithoutExtension(pdfPath);
    final uniqueId = '${fileName}_${stat.size}_${stat.modified.millisecondsSinceEpoch}';

    return File('${cacheDir.path}/thumb_$uniqueId.png');
  }

  /// Get cache key
  String _getCacheKey(String pdfPath) {
    return pdfPath; // Use full path as key
  }

  /// Clear all caches
  void clearAll() {
    _memoryCache.clear();
    _cacheTimestamps.clear();
    _pendingRequests.clear();
  }

  /// Clear memory cache only
  void clearMemory() {
    _memoryCache.clear();
    _cacheTimestamps.clear();
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'memory_cache_count': _memoryCache.length,
      'pending_requests': _pendingRequests.length,
      'cache_size_mb': _memoryCache.values
          .where((bytes) => bytes != null)
          .fold(0, (sum, bytes) => sum + bytes!.length) / (1024 * 1024),
    };
  }

  /// Preload thumbnails for better UX
  void preloadThumbnails(List<String> pdfPaths) {
    for (final pdfPath in pdfPaths) {
      // Only preload if not already cached or pending
      final cacheKey = _getCacheKey(pdfPath);
      if (!_memoryCache.containsKey(cacheKey) &&
          !_pendingRequests.containsKey(cacheKey)) {
        getThumbnail(pdfPath).then((_) {
          // Preloaded successfully
        }).catchError((e) {
          print('Preload failed for $pdfPath: $e');
        });
      }
    }
  }
}

 */

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