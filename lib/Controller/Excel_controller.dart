import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';

class ExcelService {
  static Future<List<List<Data?>>> pickAndReadExcel() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true, // Required for Web & Desktop memory access
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        final bytes = file.bytes;

        if (bytes != null) {
          var excel = Excel.decodeBytes(bytes);
          for (var table in excel.tables.keys) {
            return excel.tables[table]?.rows ?? [];
          }
        }
      }
    } catch (e) {
      debugPrint('Error reading excel: $e');
    }
    return [];
  }
}
