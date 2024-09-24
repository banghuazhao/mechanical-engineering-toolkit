import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mechanical_engineering_toolkit/home/tool_page.dart';
import 'package:mechanical_engineering_toolkit/util/ads_manager.dart';
import 'package:mechanical_engineering_toolkit/util/in_app_reviewer_helper.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:provider/provider.dart';

import 'generated/l10n.dart';
import 'home/favorites.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppTrackingTransparency.requestTrackingAuthorization();

  MobileAds.instance.initialize();

  AdsManager.debugPrintID();

  InAppReviewHelper.checkAndAskForReview();

  await SharedPreferencesHelper.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Favorites()),
        ChangeNotifierProvider(create: (context) => NumberPrecisionHelper())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // 讲en设置为第一项,没有适配语言时,英语为首选项
        supportedLocales: S.delegate.supportedLocales,
        // 插件目前不完善手动处理简繁体
        localeResolutionCallback: (locale, supportLocales) {
          print(locale);
          // 中文 简繁体处理
          if (locale?.languageCode == 'zh') {
            if (locale?.scriptCode == 'Hant') {
              return const Locale('zh', 'HK'); //繁体
            } else {
              return const Locale('zh', ''); //简体
            }
          }
          return Locale('en', '');
        },
        title: 'ME Toolkit1',
        theme: ThemeData(
          appBarTheme: AppBarTheme(
              backgroundColor: Color(0xffA8866B),
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20)),
          colorScheme: const ColorScheme.light(
            primary: Color(0xffA8866B),
            secondary: Color(0xffA8866B),
            onSecondary: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xffF2F2F2),
          textTheme: const TextTheme(),
        ),
        home: const ToolPage(),
      ),
    );
  }
}
