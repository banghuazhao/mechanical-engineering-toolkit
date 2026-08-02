import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mechanical_engineering_toolkit/home/tool_page.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/ads_manager.dart';
import 'package:mechanical_engineering_toolkit/util/in_app_reviewer_helper.dart';
import 'package:mechanical_engineering_toolkit/util/language.dart';
import 'package:mechanical_engineering_toolkit/util/material_library.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:provider/provider.dart';

import 'generated/l10n.dart';
import 'home/favorites.dart';
import 'home/history.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  InAppReviewHelper.checkAndAskForReview();

  await SharedPreferencesHelper.init();

  final removeAdsService = RemoveAdsService();
  await removeAdsService.init();
  AdsManager.setAdsRemoved(removeAdsService.isAdsRemoved);
  removeAdsService.addListener(
    () => AdsManager.setAdsRemoved(removeAdsService.isAdsRemoved),
  );

  AdsManager.debugPrintID();

  runApp(MyApp(removeAdsService: removeAdsService));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.removeAdsService});

  final RemoveAdsService removeAdsService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: removeAdsService),
        ChangeNotifierProvider(create: (context) => Favorites()),
        ChangeNotifierProvider(create: (context) => NumberPrecisionHelper()),
        ChangeNotifierProvider(create: (context) => UnitSystemPreference()),
        ChangeNotifierProvider(create: (context) => ToolHistory()),
        ChangeNotifierProvider(create: (context) => MaterialLibrary()),
        ChangeNotifierProvider(create: (context) => LanguagePreference()),
      ],
      child: Consumer<LanguagePreference>(
        builder: (context, languagePref, _) => MaterialApp(
          builder: (context, child) => NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification &&
                  notification.dragDetails != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
              return false;
            },
            child: child ?? const SizedBox.shrink(),
          ),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // 讲en设置为第一项,没有适配语言时,英语为首选项
          supportedLocales: S.delegate.supportedLocales,
          // null 时跟随系统语言,否则使用用户在侧边栏选择的语言
          locale: languagePref.locale,
          // 插件目前不完善手动处理简繁体
          localeResolutionCallback: (locale, supportLocales) {
            // 中文 简繁体处理
            if (locale?.languageCode == 'zh') {
              const traditionalRegions = {'HK', 'TW', 'MO'};
              if (locale?.scriptCode == 'Hant' ||
                  traditionalRegions.contains(locale?.countryCode)) {
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
      ),
    );
  }
}
