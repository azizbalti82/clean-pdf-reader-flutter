import 'package:hive/hive.dart';

part 'pdf.g.dart';  // Generated file for the TypeAdapter

@HiveType(typeId: 0,adapterName: 'PdfAdapter') // Use a unique typeId for this model
class Pdf {
  @HiveField(0)
  final String path;

  @HiveField(1)
  final DateTime lastOpenDate;

  @HiveField(2)
  final bool isBookmark;

  @HiveField(3)
  final int currentPage;

  @HiveField(4)
  final bool isOpened;

  Pdf({
    required this.path,
    required this.lastOpenDate,
    required this.isBookmark,
    required this.currentPage,
    required this.isOpened,
  });

  // 'copyWith' function to create a copy with modified values
  Pdf copyWith({
    String? path,
    DateTime? lastOpenDate,
    bool? isBookmark,
    int? currentPage,
    bool? isOpened,
  }) {
    return Pdf(
      path: path ?? this.path,  // If path is not passed, keep the original
      lastOpenDate: lastOpenDate ?? this.lastOpenDate,
      isBookmark: isBookmark ?? this.isBookmark,
      currentPage: currentPage ?? this.currentPage,
      isOpened: isOpened ?? this.isOpened,

    );
  }
}