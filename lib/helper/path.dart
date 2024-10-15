import 'dart:io' show Directory, Platform;
import 'package:jarvis/helper/logger.dart';
import 'package:jarvis/helper/platform.dart';
import 'package:path_provider/path_provider.dart';

class PathHelper {
  late final String cachePath;
  late final String documentsPath;
  late final String supportPath;

  init() async {
    try {
      cachePath =
          (await getApplicationCacheDirectory()).path.replaceAll('\\', '/');
    } catch (e) {
      cachePath = '';
    }

    try {
      documentsPath =
          (await getApplicationDocumentsDirectory()).path.replaceAll('\\', '/');
    } catch (e) {
      documentsPath = '';
    }

    try {
      supportPath =
          (await getApplicationSupportDirectory()).path.replaceAll('\\', '/');
    } catch (e) {
      supportPath = '';
    }

    // Make sure the .jarvis directory exists
    try {
      Directory(getHomePath).create(recursive: true);

    } catch (e) {
      Logger.instance.e('创建 $getHomePath 目录失败: $e');
    }
  }

  String get getHomePath {
    if (PlatformTool.isMacOS() || PlatformTool.isLinux()) {
      return '${Platform.environment['HOME'] ?? ''}/.jarvis'
          .replaceAll('\\', '/');
    } else if (PlatformTool.isWindows()) {
      return '${Platform.environment['UserProfile'] ?? ''}/.jarvis'
          .replaceAll('\\', '/');
    } else if (PlatformTool.isAndroid() || PlatformTool.isIOS()) {
      return '$documentsPath/.jarvis'.replaceAll('\\', '/');
    }

    return '.jarvis';
  }

  String get getLogfilePath {
    return '$getHomePath/jarvis.log';
  }

  String get getCachePath {
    return getHomePath;
  }

  /// Singleton
  static final PathHelper _instance = PathHelper._internal();
  PathHelper._internal();

  factory PathHelper() {
    return _instance;
  }

  Map<String, String> toMap() {
    return {
      'cachePath': cachePath,
      'cachePathReal': getCachePath,
      'documentsPath': documentsPath,
      'supportPath': supportPath,
      'homePath': getHomePath,
      'logfilePath': getLogfilePath,
    };
  }
}
