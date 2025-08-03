import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

bool _isRequestingPermissions = false;

Future<List<String>> loadAllPdfFiles() async {
  await requestPermissions();
  List<String> pdfFiles = [];

  try {
    if (Platform.isAndroid) {
      await searchAndroidDirectories(pdfFiles);
    } else {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        await searchDirectoryForPdfs(Directory(directory.path), pdfFiles);
      }
    }
  } catch (e) {
    print("Error loading PDF files: $e");
  }

  // Remove duplicates by converting the list to a Set and back to a list
  pdfFiles = pdfFiles.toSet().toList();

  return pdfFiles;
}

Future<void> searchAndroidDirectories(List<String> pdfFiles) async {
  // Common Android directories where PDFs are typically stored
  final directories = <String>[
    "/storage/emulated/0/Download",
    "/storage/emulated/0/Downloads",
    "/storage/emulated/0/Documents",
    "/storage/emulated/0/DCIM",
    "/storage/emulated/0/Pictures",
    "/storage/emulated/0/Android/data",
  ];

  for (var dirPath in directories) {
    try {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        await searchDirectoryForPdfs(dir, pdfFiles);
      }
    } catch (e) {
      print("Error accessing directory $dirPath: $e");
      // Continue with next directory instead of stopping
      continue;
    }
  }
}

Future<void> searchDirectoryForPdfs(Directory directory, List<String> pdfFiles) async {
  try {
    await for (var entity in directory.list(recursive: true, followLinks: false)) {
      try {
        if (entity is File &&
            entity.path.toLowerCase().endsWith('.pdf') &&
            !pdfFiles.contains(entity.path)) {

          // Additional check to ensure file is accessible
          if (await entity.exists()) {
            pdfFiles.add(entity.path);
          }
        }
      } catch (e) {
        // Skip individual files that cause errors (permission issues, etc.)
        print("Error processing file ${entity.path}: $e");
        continue;
      }
    }
  } catch (e) {
    print("Error searching directory ${directory.path}: $e");
    // Don't rethrow - let the function continue with other directories
  }
}

// Alternative optimized version using Set for better duplicate handling
Future<List<String>> loadAllPdfFilesOptimized() async {
  await requestPermissions();
  Set<String> pdfFiles = <String>{}; // Use Set directly to avoid duplicates

  try {
    if (Platform.isAndroid) {
      await searchAndroidDirectoriesOptimized(pdfFiles);
    } else {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        await searchDirectoryForPdfsOptimized(Directory(directory.path), pdfFiles);
      }
    }
  } catch (e) {
    print("Error loading PDF files: $e");
  }

  return pdfFiles.toList();
}

Future<void> searchAndroidDirectoriesOptimized(Set<String> pdfFiles) async {
  final directories = <String>[
    "/storage/emulated/0/Download",
    "/storage/emulated/0/Downloads",
    "/storage/emulated/0/Documents",
    "/storage/emulated/0/DCIM",
    "/storage/emulated/0/Pictures",
  ];

  // Process directories in parallel for better performance
  await Future.wait(
    directories.map((dirPath) async {
      try {
        final dir = Directory(dirPath);
        if (await dir.exists()) {
          await searchDirectoryForPdfsOptimized(dir, pdfFiles);
        }
      } catch (e) {
        print("Error accessing directory $dirPath: $e");
      }
    }),
    eagerError: false, // Continue even if some directories fail
  );
}

Future<void> searchDirectoryForPdfsOptimized(Directory directory, Set<String> pdfFiles) async {
  try {
    await for (var entity in directory.list(recursive: true, followLinks: false)) {
      try {
        if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
          // Set automatically handles duplicates
          if (await entity.exists()) {
            pdfFiles.add(entity.path);
          }
        }
      } catch (e) {
        // Skip problematic files silently for better performance
        continue;
      }
    }
  } catch (e) {
    print("Error searching directory ${directory.path}: $e");
  }
}
Future<void> requestPermissions() async {
  // Prevent concurrent permission requests
  if (_isRequestingPermissions) return;

  _isRequestingPermissions = true;

  try {
    if (Platform.isAndroid) {

      // Check Android version and request appropriate permissions
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) { // Android 13+
        // For documents and PDFs, i need MANAGE_EXTERNAL_STORAGE
        if (await Permission.manageExternalStorage.isDenied) {
          await Permission.manageExternalStorage.request();
        }

      } else if (sdkInt >= 30) { // Android 11-12
        // Request MANAGE_EXTERNAL_STORAGE for full access
        var manageStorageStatus = await Permission.manageExternalStorage.request();
        if (!manageStorageStatus.isGranted) {
          // Fallback to regular storage permission
          await Permission.storage.request();
        }

      } else { // Android 10 and below
        // Request traditional storage permission
        await Permission.storage.request();
      }

    } else if (Platform.isIOS) {
      // iOS permissions
      await Permission.photos.request();
    }

  } catch (e) {
    print("Error requesting permissions: $e");
  } finally {
    _isRequestingPermissions = false;
  }
}
