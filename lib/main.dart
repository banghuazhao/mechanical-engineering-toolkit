import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mechanical_engineering_toolkit/home/tool_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/ads_manager.dart';
import 'package:mechanical_engineering_toolkit/util/in_app_reviewer_helper.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:provider/provider.dart';

import 'generated/l10n.dart';
import 'home/favorites.dart';
import 'home/history.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AdsManager.debugPrintID();

  InAppReviewHelper.checkAndAskForReview();

  await SharedPreferencesHelper.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Favorites()),
        ChangeNotifierProvider(create: (context) => NumberPrecisionHelper()),
        ChangeNotifierProvider(create: (context) => ToolHistory()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // 讲en设置为第一项,没有适配语言时,英语为首选项
        supportedLocales: S.delegate.supportedLocales,
        // 插件目前不完善手动处理简繁体
        localeResolutionCallback: (locale, supportLocales) {
          // 中文 简繁体处理
          if (locale?.languageCode == 'zh') {
            if (locale?.scriptCode == 'Hant') {
              return const Locale('zh', 'HK'); //繁体
            } else {
              return const Locale('zh', ''); //简体
            }
          }
          return const Locale('en', '');
        },
        title: 'ME Toolkit',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const ToolPage(),
      ),
    );
  }
}
