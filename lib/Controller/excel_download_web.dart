// Deprecated: Excel downloads are now handled in Excel_controller.dart with web package
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<void> downloadExcelBytes(Uint8List bytes, String fileName) async {
  try {
    web.Blob blob = web.Blob(
      [bytes] as dynamic,
      web.BlobPropertyBag(
        type:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      ),
    );

    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = fileName;

    web.document.body!.append(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(url);
  } catch (e) {
    print('Error downloading: $e');
  }
}
