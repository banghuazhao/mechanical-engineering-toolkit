import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:open_store/open_store.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreAppPage extends StatelessWidget {
  const MoreAppPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<MoreAppItem> _items = [];

    var finance_go =
        MoreAppItem(Image.asset("images/app_icons/finance_go.png"), S.of(context).FinanceGo, () {
      OpenStore.instance
          .open(appStoreId: "1519476344", androidAppBundleId: "com.appsbay.financego");
    });

    var Relaxing_Up =
        MoreAppItem(Image.asset("images/app_icons/relaxing_up.png"), S.of(context).Relaxing_Up, () {
      OpenStore.instance
          .open(appStoreId: "1618712178", androidAppBundleId: "com.appsbay.relaxing_up");
    });

    var Yes_Habit =
        MoreAppItem(Image.asset("images/app_icons/yes_habit.png"), S.of(context).Yes_Habit, () {
      OpenStore.instance.open(appStoreId: "1637643734", androidAppBundleId: "");
    });

    var Mint_Translate = MoreAppItem(
        Image.asset("images/app_icons/mint_translate.png"), S.of(context).Mint_Translate, () {
      OpenStore.instance
          .open(appStoreId: "1638456603", androidAppBundleId: "com.appsbay.mint_translate");
    });

    var Metronome_Go = MoreAppItem(
        Image.asset("images/app_icons/metronome_go.png"), S.of(context).Metronome_Go, () {
      OpenStore.instance
          .open(appStoreId: "1635462172", androidAppBundleId: "com.appsbay.metronome_go");
    });

    var Simple_Calculator = MoreAppItem(
        Image.asset("images/app_icons/simple_calculator.png"), S.of(context).Simple_Calculator, () {
      OpenStore.instance
          .open(appStoreId: "1610829871", androidAppBundleId: "com.appsbay.simple_calculator");
    });

    var Onlynote =
        MoreAppItem(Image.asset("images/app_icons/onlynote.png"), S.of(context).Onlynote, () {
      OpenStore.instance.open(appStoreId: "1616516732", androidAppBundleId: "com.appsbay.onlynote");
    });

    var World_Weather_Live = MoreAppItem(
        Image.asset("images/app_icons/world_weather_live.png"), S.of(context).World_Weather_Live,
        () {
      OpenStore.instance
          .open(appStoreId: "1612773646", androidAppBundleId: "com.appsbay.world_weather_live");
    });

    var Shows = MoreAppItem(Image.asset("images/app_icons/shows.png"), S.of(context).Shows, () {
      OpenStore.instance.open(appStoreId: "1624910011", androidAppBundleId: "com.appsbay.shows");
    });

    var Simple_English_Dictionary = MoreAppItem(
        Image.asset("images/app_icons/simple_english_dictionary.png"),
        S.of(context).Simple_English_Dictionary, () {
      OpenStore.instance.open(
          appStoreId: "1611258200", androidAppBundleId: "com.appsbay.simple_english_dictionary");
    });

    var Sudoku_Lover = MoreAppItem(
        Image.asset("images/app_icons/sudoku_lover.png"), S.of(context).Sudoku_Lover, () {
      OpenStore.instance
          .open(appStoreId: "1620749798", androidAppBundleId: "com.appsbay.sudoku_lovers");
    });

    var Express_Scan = MoreAppItem(
        Image.asset("images/app_icons/express_scan.png"), S.of(context).Express_Scan, () {
      OpenStore.instance
          .open(appStoreId: "1625121991", androidAppBundleId: "com.appsbay.express_scan");
    });

    var money_tracker = MoreAppItem(
        Image.asset("images/app_icons/money_tracker.png"), S.of(context).MoneyTracker, () {
      OpenStore.instance.open(appStoreId: "1534244892");
    });

    var novels_hub =
        MoreAppItem(Image.asset("images/app_icons/novels_hub.png"), S.of(context).NovelsHub, () {
      OpenStore.instance
          .open(appStoreId: "1528820845", androidAppBundleId: "com.appsbay.novelshub");
    });

    var nasa_lover =
        MoreAppItem(Image.asset("images/app_icons/nasa_lover.png"), S.of(context).NASALover, () {
      OpenStore.instance
          .open(appStoreId: "1595232677", androidAppBundleId: "com.AppsBay.nasa_lover");
    });

    var SwiftComp =
        MoreAppItem(Image.asset("images/app_icons/swiftcomp.png"), S.of(context).SwiftComp, () {
      OpenStore.instance
          .open(appStoreId: "1297825946", androidAppBundleId: "com.banghuazhao.swiftcomp");
    });

    if (Platform.isIOS) {
      _items = [
        SwiftComp,
        Relaxing_Up,
        Yes_Habit,
        Mint_Translate,
        Metronome_Go,
        World_Weather_Live,
        Shows,
        Simple_English_Dictionary,
        Sudoku_Lover,
        Express_Scan,
        Simple_Calculator,
        Onlynote,
        money_tracker,
        finance_go,
        novels_hub,
        nasa_lover,
        MoreAppItem(Image.asset("images/app_icons/appstore.png"), S.of(context).MoreApps, () {
          launch("https://apps.apple.com/us/developer/%E7%92%90%E7%92%98-%E6%9D%A8/id1599035519");
        })
      ];
    } else {
      _items = [
        SwiftComp,
        Relaxing_Up,
        Mint_Translate,
        Metronome_Go,
        World_Weather_Live,
        Shows,
        finance_go,
        Simple_English_Dictionary,
        Sudoku_Lover,
        Express_Scan,
        Simple_Calculator,
        Onlynote,
        novels_hub,
        nasa_lover,
        MoreAppItem(Image.asset("images/app_icons/googleplay.png"), S.of(context).MoreApps, () {
          launch("https://play.google.com/store/apps/developer?id=Lulin+Yang");
        })
      ];
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).MoreApps),
        ),
        body: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) {
            return MoreAppsRow.factory(_items[index]);
          },
        ));
  }
}

class MoreAppItem {
  Image appIcon;
  String title;
  void Function() onTap;

  MoreAppItem(this.appIcon, this.title, this.onTap);
}

class MoreAppsRow extends StatelessWidget {
  late Image appIcon;
  late IconData trailingIcon;
  late String title;
  late void Function() onTap;

  MoreAppsRow(
      {Key? key,
      this.trailingIcon = Icons.chevron_right_rounded,
      required this.appIcon,
      required this.title,
      required this.onTap})
      : super(key: key);

  MoreAppsRow.factory(MoreAppItem moreAppItem) {
    appIcon = moreAppItem.appIcon;
    trailingIcon = Icons.chevron_right_rounded;
    title = moreAppItem.title;
    onTap = moreAppItem.onTap;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: const BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onTap: onTap,
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 40,
              width: 40,
              child: appIcon,
            ),
          ),
          trailing: Icon(trailingIcon),
          title: Text(
            title,
          ),
        ),
      ),
    );
  }
}
