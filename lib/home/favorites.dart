import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';

/// The [Favorites] class holds a list of favorite items saved by the user.
class Favorites extends ChangeNotifier {
  final String KEY = "TOOL_FAVORITE";

  List<int> get items {
    List<String> temp =
        SharedPreferencesHelper.localStorage.getStringList(KEY) ?? [];
    return temp.map((e) => int.parse(e)).toList();
  }

  add(int itemNo) {
    List<String> temp =
        SharedPreferencesHelper.localStorage.getStringList(KEY) ?? [];
    temp.add(itemNo.toString());
    SharedPreferencesHelper.localStorage.setStringList(KEY, temp);
    notifyListeners();
  }

  remove(int itemNo) async {
    List<String> temp =
        SharedPreferencesHelper.localStorage.getStringList(KEY) ?? [];
    temp.removeWhere((element) => element == itemNo.toString());
    SharedPreferencesHelper.localStorage.setStringList(KEY, temp);
    notifyListeners();
  }
}
