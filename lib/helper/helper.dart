import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:intl/intl.dart';
import 'package:jarvis/lang/lang.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

String randomId() {
  return const Uuid().v4();
}

// Convert base64 to image and store it in a temporary file
Future<String> writeImageFromBase64(String base64, String ext) async {
  final directory = await getApplicationDocumentsDirectory();
  // Ensure the directory exists
  await Directory('${directory.path}/cache').create(recursive: true);

  final file = File('${directory.path}/cache/temp_${randomId()}.$ext');
  await file.writeAsBytes(base64Decode(base64));
  return file.path.substring(directory.path.length + 1);
}

String filenameWithoutExt(String filePath) {
  int slashIndex = filePath.lastIndexOf('/');
  int dotIndex = filePath.lastIndexOf('.');
  if (dotIndex < 0 || dotIndex < slashIndex) {
    return filePath.substring(slashIndex + 1);
  } else {
    return filePath.substring(slashIndex + 1, dotIndex);
  }
}

Future<File> writeTempFile(String path, Uint8List bytes) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/$path');
  return await file.writeAsBytes(bytes);
}

Future<Uint8List> readTempFile(String path) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/$path');
  return await file.readAsBytes();
}


/// Convert time to human readable format
String humanTime(DateTime? ts, {bool withTime = false}) {
  if (ts == null || ts.millisecondsSinceEpoch == 0) {
    return '';
  }

  var now = DateTime.now();
  var diff = now.difference(ts);
  if (diff.inDays > 0) {
    if (withTime) {
      return DateFormat('yyyy/MM/dd HH:mm').format(ts.toLocal());
    }

    return DateFormat('yyyy/MM/dd').format(ts.toLocal());
  }

  if (diff.inHours > 0) {
    return '${diff.inHours} hours ago';
  }

  if (diff.inMinutes > 0) {
    return '${diff.inMinutes} minutes ago';
  }

  return 'Just now';
}

/// Parse error message
String resolveError(BuildContext context, Object error) {
  if (error is LanguageText) {
    return error.message.getString(context);
  }

  return error.toString();
}
