import 'dart:typed_data';

class PickedWebImage {
  const PickedWebImage({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}
