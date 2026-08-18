// Deprecated: Excel downloads are now handled in Excel_controller.dart with web package
export 'excel_download_stub.dart'
    if (dart.library.html) 'excel_download_web.dart';
