import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:vietmap_iee_map/vietmap_flutter_gl.dart';

/// Adds an asset image to the currently displayed style
Future<void> addImageFromAsset(
    VietmapController controller, String name, String assetName) async {
  final ByteData bytes = await rootBundle.load(assetName);
  final Uint8List list = bytes.buffer.asUint8List();
  return controller.addImage(name, list);
}
