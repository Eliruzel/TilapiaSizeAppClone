import 'image_picker_stub.dart'
    if (dart.library.html) 'image_picker_web.dart'
    as implementation;

import 'image_selection.dart';

Future<PickedWebImage?> pickWebImage() => implementation.pickWebImage();
