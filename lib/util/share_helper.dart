import 'package:share_plus/share_plus.dart';

void shareResult(String toolName, List<String> lines) {
  final body = lines.where((l) => l.isNotEmpty).join('\n');
  Share.share('[$toolName]\n\n$body\n\n— ME Toolkit');
}
