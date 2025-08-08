import 'package:hive/hive.dart';

import '../models/pdf.dart';

class PdfService {
  static final Box<Pdf> _pdfBox = Hive.box<Pdf>('pdfBox');

  static Future<bool> savePdf(String key, Pdf pdf) async {
    try {
      await _pdfBox.put(key, pdf);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  static Future<bool> saveAll(List<Pdf> pdfs) async {
    try {
      for (Pdf pdf in pdfs) {
        await _pdfBox.put(pdf.path, pdf);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Pdf? getPdf(String key) {
    return _pdfBox.get(key);
  }

  static List<Pdf> getAllPdfs() {
    return _pdfBox.values.toList();
  }

  static Future<bool> update(String key, Pdf pdf) async {
    try {
      if (_pdfBox.containsKey(key)) {
        await _pdfBox.put(key, pdf);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> delete(String key) async {
    try {
      if (_pdfBox.containsKey(key)) {
        await _pdfBox.delete(key);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteAll() async {
    try {
      await _pdfBox.clear();
      return true;
    } catch (e) {
      return false;
    }
  }
}
