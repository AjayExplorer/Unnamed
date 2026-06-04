import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<String> downloadRequestFile({required String filename, required String content}) async {
  Directory? directory;
  
  if (Platform.isAndroid || Platform.isIOS) {
    directory = await getApplicationDocumentsDirectory();
  } else {
    directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
  }
  
  final file = File('${directory.path}/$filename');
  await file.writeAsString(content);
  
  if (Platform.isMacOS) {
    try {
      await Process.run('open', [file.path]);
    } catch (_) {}
  }
  
  return file.path;
}

Future<String> downloadRequestBytes({required String filename, required Uint8List bytes}) async {
  Directory? directory;
  
  if (Platform.isAndroid || Platform.isIOS) {
    directory = await getApplicationDocumentsDirectory();
  } else {
    directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
  }
  
  final file = File('${directory.path}/$filename');
  await file.writeAsBytes(bytes);
  
  if (Platform.isMacOS) {
    try {
      await Process.run('open', [file.path]);
    } catch (_) {}
  }
  
  return file.path;
}
