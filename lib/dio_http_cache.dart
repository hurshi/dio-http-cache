library dio_http_cache;

export 'src/builder_dio.dart';
export 'src/core/config.dart';
export 'src/core/obj.dart';
export 'src/manager_dio.dart';
export 'src/store/store_impl.dart';

export 'package:dio_http_cache/src/core/path/path_helper.dart' // Stub implementation
    if (dart.library.io) 'package:dio_http_cache/src/core/path/path_helper_io.dart' // dart:io implementation
    if (dart.library.html) 'package:dio_http_cache/src/core/path/path_helper_web.dart';// dart:html implementation
