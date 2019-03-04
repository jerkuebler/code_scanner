import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:code_scanner/BLOCS/DatabaseBloc.dart';
import 'package:code_scanner/Scanner.dart';
import 'package:code_scanner/ThemeModel.dart';
import 'package:code_scanner/Options.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  ThemeModel model = ThemeModel();
  final bloc = ScansBloc();

  @override
  void initState() {
    super.initState();
    model.loadTheme();
  }

  Widget _applyTextScaleFactor(Widget child) {
    return Builder(
      builder: (BuildContext context) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: model.options.textScaleFactor.scale,
          ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ThemeModel>(
        model: model,
        child: ScopedModelDescendant<ThemeModel>(
            builder: (context, child, model) => MaterialApp(
                  title: "Code Reader",
                  theme: model.options.theme,
                  home: Scanner(
                      bloc,
                      ScopedModelDescendant<ThemeModel>(
                          builder: (context, child, model) => OptionsPage(
                                options: model.options,
                                onOptionsChanged: model.handleOptionsChanged,
                              ))),
                  builder: (BuildContext context, Widget child) {
                    return Directionality(
                        textDirection: TextDirection.ltr,
                        child: _applyTextScaleFactor(child));
                  },
                )));
  }
}
