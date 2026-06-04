import 'dart:typed_data';

Future<String> downloadRequestFile({required String filename, required String content}) async {
  throw UnsupportedError('Saving files is not supported on this platform.');
}

Future<String> downloadRequestBytes({required String filename, required Uint8List bytes}) async {
  throw UnsupportedError('Saving files is not supported on this platform.');
}
