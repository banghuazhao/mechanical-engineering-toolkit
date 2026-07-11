import 'package:share_plus/share_plus.dart';

Future<void> shareResult(String toolName, List<String> lines) async {
  final body = lines.where((l) => l.isNotEmpty).join('\n');
  await SharePlus.instance.share(
    ShareParams(text: '[$toolName]\n\n$body\n\n— ME Toolkit'),
  );
}
