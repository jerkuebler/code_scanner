import 'package:flutter/material.dart';

const double _kItemHeight = 48.0;
const EdgeInsetsDirectional _kItemPadding =
    EdgeInsetsDirectional.only(start: 56.0);

class _OptionsItem extends StatelessWidget {
  const _OptionsItem({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double textScaleFactor = MediaQuery.textScaleFactorOf(context);

    return MergeSemantics(
      child: Container(
        constraints: BoxConstraints(minHeight: _kItemHeight * textScaleFactor),
        padding: _kItemPadding,
        alignment: AlignmentDirectional.centerStart,
        child: DefaultTextStyle(
          style: DefaultTextStyle.of(context).style,
          maxLines: 2,
          overflow: TextOverflow.fade,
          child: IconTheme(
            data: Theme.of(context).primaryIconTheme,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _BooleanItem extends StatelessWidget {
  const _BooleanItem(this.title, this.value, this.onChanged, {this.switchKey});

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  // [switchKey] is used for accessing the switch from driver tests.
  final Key switchKey;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return _OptionsItem(
      child: Row(
        children: <Widget>[
          Expanded(
              child: DefaultTextStyle(
            style: theme.textTheme.body1,
            child: Semantics(
              child: Text(title),
              header: true,
            ),
          )),
          Switch(
            key: switchKey,
            value: value,
            onChanged: onChanged,
            activeColor: theme.accentColor,
            activeTrackColor: theme.bottomAppBarColor,
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return _OptionsItem(
      child: DefaultTextStyle(
        style: theme.textTheme.body1.copyWith(
          color: theme.accentColor,
        ),
        child: Semantics(
          child: Text(text),
          header: true,
        ),
      ),
    );
  }
}

class _ThemeItem extends StatelessWidget {
  const _ThemeItem(this.options, this.onOptionsChanged);

  final Options options;
  final ValueChanged<Options> onOptionsChanged;

  @override
  Widget build(BuildContext context) {
    bool currentDark = options.theme == ThemeData.dark();
    Options optionsUpdate = options.copyWith(
      theme: currentDark ? ThemeData.light() : ThemeData.dark(),
    );
    return _BooleanItem(
      'Dark Theme',
      currentDark,
      (bool value) {
        onOptionsChanged(optionsUpdate);
      },
      switchKey: const Key('dark_theme'),
    );
  }
}

class TextScaleValue {
  const TextScaleValue(this.scale, this.label);

  final double scale;
  final String label;

  @override
  bool operator ==(dynamic other) {
    if (runtimeType != other.runtimeType) return false;
    final TextScaleValue typedOther = other;
    return scale == typedOther.scale && label == typedOther.label;
  }

  @override
  int get hashCode => hashValues(scale, label);

  @override
  String toString() {
    return '$runtimeType($label)';
  }
}

const List<TextScaleValue> kAllTextScaleValues = <TextScaleValue>[
  TextScaleValue(null, 'System Default'),
  TextScaleValue(0.8, 'Small'),
  TextScaleValue(1.0, 'Normal'),
  TextScaleValue(1.3, 'Large'),
  TextScaleValue(2.0, 'Huge'),
];

class _TextScaleFactorItem extends StatelessWidget {
  const _TextScaleFactorItem(this.options, this.onOptionsChanged);

  final Options options;
  final ValueChanged<Options> onOptionsChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return _OptionsItem(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Text size', style: theme.textTheme.body1),
                Text(
                  '${options.textScaleFactor.label}',
                  style: theme.textTheme.body1,
                ),
              ],
            ),
          ),
          PopupMenuButton<TextScaleValue>(
            padding: const EdgeInsetsDirectional.only(end: 16.0),
            icon: Icon(Icons.arrow_drop_down, color: theme.accentColor),
            itemBuilder: (BuildContext context) {
              return kAllTextScaleValues.map<PopupMenuItem<TextScaleValue>>(
                  (TextScaleValue scaleValue) {
                return PopupMenuItem<TextScaleValue>(
                  value: scaleValue,
                  child: Text(scaleValue.label),
                );
              }).toList();
            },
            onSelected: (TextScaleValue scaleValue) {
              onOptionsChanged(
                options.copyWith(textScaleFactor: scaleValue),
              );
            },
          ),
        ],
      ),
    );
  }
}

class Options {
  Options({
    this.theme,
    this.textScaleFactor,
  });

  final ThemeData theme;
  final TextScaleValue textScaleFactor;

  Options copyWith({
    ThemeData theme,
    TextScaleValue textScaleFactor,
  }) {
    return Options(
      theme: theme ?? this.theme,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (runtimeType != other.runtimeType) return false;
    final Options typedOther = other;
    return theme == typedOther.theme &&
        textScaleFactor == typedOther.textScaleFactor;
  }

  @override
  int get hashCode => hashValues(
        theme,
        textScaleFactor,
      );

  @override
  String toString() {
    return '$runtimeType($theme)';
  }
}

class OptionsPage extends StatelessWidget {
  const OptionsPage({
    Key key,
    this.options,
    this.onOptionsChanged,
  }) : super(key: key);

  final Options options;
  final ValueChanged<Options> onOptionsChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DefaultTextStyle(
      style: theme.primaryTextTheme.subhead,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 124.0),
        children: <Widget>[
          DrawerHeader(
            child: Text('Options'),
            decoration: BoxDecoration(color: theme.primaryColor),
          ),
          const _Heading('Display'),
          _ThemeItem(options, onOptionsChanged),
          _TextScaleFactorItem(options, onOptionsChanged),
          const Divider(),
        ],
      ),
    );
  }
}
