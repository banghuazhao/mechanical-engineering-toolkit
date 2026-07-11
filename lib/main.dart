import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mechanical_engineering_toolkit/home/tool_page.dart';
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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
        title: 'ME Toolkit',
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Color(0xffA8866B),
            secondary: Color(0xffA8866B),
            onSecondary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF1C1C1E),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xffA8866B),
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            elevation: 0,
            scrolledUnderElevation: 2,
          ),
          scaffoldBackgroundColor: const Color(0xffF5F4F2),
          cardTheme: CardThemeData(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            color: Colors.white,
            margin: EdgeInsets.zero,
            shadowColor: Colors.transparent,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF8F7F6),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDDDAD6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDDDAD6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xffA8866B), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE05252)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE05252), width: 2),
            ),
            labelStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14),
            floatingLabelStyle:
                const TextStyle(color: Color(0xffA8866B), fontSize: 13),
            errorStyle: const TextStyle(color: Color(0xFFE05252), fontSize: 12),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xffA8866B),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: StadiumBorder(),
          ),
          dividerTheme: const DividerThemeData(
            space: 1,
            thickness: 1,
            color: Color(0xFFF0EDE9),
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
            ),
            titleMedium: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3A3A3C),
            ),
            bodyLarge: TextStyle(
              fontSize: 15,
              color: Color(0xFF1C1C1E),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              color: Color(0xFF48484A),
            ),
          ),
          listTileTheme: const ListTileThemeData(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          ),
        ),
        home: const ToolPage(),
      ),
    );
  }
}
