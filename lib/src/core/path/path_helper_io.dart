import 'package:path_provider/path_provider.dart';

class PathHelper {
  static Future<String> getCurrentPath() async {
    return (await getTemporaryDirectory()).path;
  }
}
