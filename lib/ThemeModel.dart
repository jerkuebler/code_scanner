import 'package:code_scanner/Options.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModel extends Model {
  SharedPreferences prefs;

  Options options =
      Options(theme: ThemeData.dark(), textScaleFactor: kAllTextScaleValues[0]);

  void loadTheme() async {
    prefs = await SharedPreferences.getInstance();
    int textScaleIndex = prefs.getInt("textscale") ?? 0;

    options = Options(
      theme: getTheme(prefs.getString("theme") ?? "dark"),
      textScaleFactor: kAllTextScaleValues[textScaleIndex],
    );

    notifyListeners();
  }

  ThemeData getTheme(String theme) {
    if (theme == "light") {
      return ThemeData.light();
    }
    return ThemeData.dark();
  }

  void handleOptionsChanged(Options newOptions) async {
    options = newOptions;
    prefs.setString(
        "theme", newOptions.theme == ThemeData.dark() ? "dark" : "light");
    prefs.setInt(
        "textscale", kAllTextScaleValues.indexOf(newOptions.textScaleFactor));

    notifyListeners();
  }
}
