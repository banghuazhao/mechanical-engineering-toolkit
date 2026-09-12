import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a feedback email with the app version, device and OS filled in.
///
/// Shared by the side menu and the Mac Help menu, so the two cannot drift
/// into collecting different details.
Future<void> sendFeedbackEmail() async {
  final deviceInfo = DeviceInfoPlugin();

  String device;
  String systemVersion;

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    device = androidInfo.model;
    systemVersion = androidInfo.version.sdkInt.toString();
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    device = iosInfo.model;
    systemVersion = iosInfo.systemVersion;
  } else if (Platform.isMacOS) {
    final macInfo = await deviceInfo.macOsInfo;
    // `model` is the marketing identifier (MacBookPro18,3); osRelease is the
    // macOS version string.
    device = macInfo.model;
    systemVersion = macInfo.osRelease;
  } else {
    device = '';
    systemVersion = '';
  }

  final packageInfo = await PackageInfo.fromPlatform();
  final appName = packageInfo.appName;
  final version = packageInfo.version;

  final uri = Uri(
    scheme: 'mailto',
    path: 'appsbayarea@gmail.com',
    query: 'subject=$appName Feedback&body=\n\n\nVersion=$version\n'
        'Device=$device\nSystem Version=$systemVersion',
  );

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $uri';
  }
}

/// Opens the app's store page, where a review can be left.
Future<void> openStoreListing() async {
  final inAppReview = InAppReview.instance;
  if (await inAppReview.isAvailable()) {
    await inAppReview.openStoreListing();
  }
}
