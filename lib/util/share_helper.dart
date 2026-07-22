import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareResult(String toolName, List<String> lines) async {
  final body = lines.where((l) => l.isNotEmpty).join('\n');
  await SharePlus.instance.share(
    ShareParams(text: '[$toolName]\n\n$body\n\n— ME Toolkit'),
  );
}

/// Captures the [RepaintBoundary] identified by [boundaryKey] as a PNG and
/// shares it as an image file. Pass the key of a `RepaintBoundary` wrapping
/// the result card(s) the user should see in the shared screenshot.
Future<void> shareResultImage(GlobalKey boundaryKey, String toolName) async {
  final boundary =
      boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) return;
  final image = await boundary.toImage(pixelRatio: 3);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) return;
  final bytes = byteData.buffer.asUint8List();
  final fileName = '${toolName.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')}.png';
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(bytes, mimeType: 'image/png', name: fileName)],
      text: '[$toolName] — ME Toolkit',
    ),
  );
}
