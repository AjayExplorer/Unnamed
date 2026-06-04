// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

Future<String> downloadRequestFile({required String filename, required String content}) async {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes], 'text/plain');
  final url = html.Url.createObjectUrlFromBlob(blob);
  
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
    
  html.Url.revokeObjectUrl(url);
  return 'Downloads folder';
}

Future<String> downloadRequestBytes({required String filename, required Uint8List bytes, String mimeType = 'application/pdf'}) async {
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
    
  html.Url.revokeObjectUrl(url);
  return 'Downloads folder';
}
