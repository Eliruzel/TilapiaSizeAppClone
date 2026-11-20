import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'image_selection.dart';

Future<PickedWebImage?> pickWebImage() async {
  final input = html.FileUploadInputElement()..accept = 'image/*';
  final selectedFile = Completer<html.File?>();
  input.onChange.listen((_) {
    if (!selectedFile.isCompleted) {
      selectedFile.complete(
        input.files?.isNotEmpty == true ? input.files!.first : null,
      );
    }
  });
  input.click();
  final file = await selectedFile.future;
  if (file == null) return null;

  final reader = html.FileReader()..readAsArrayBuffer(file);
  await reader.onLoadEnd.first;
  final result = reader.result;
  final bytes = switch (result) {
    ByteBuffer buffer => buffer.asUint8List(),
    Uint8List value => value,
    _ => null,
  };
  if (bytes == null) return null;
  return PickedWebImage(name: file.name, bytes: bytes);
}
