import 'dart:async';
import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:code_scanner/CardView.dart';
import 'package:code_scanner/ScanModel.dart';
import 'package:code_scanner/Search.dart';
import 'package:csv/csv.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

class Scanner extends StatefulWidget {
  Scanner(this.bloc, this.optionsPage);

  final bloc;
  final optionsPage;

  @override
  ScannerState createState() => ScannerState(bloc, this.optionsPage);
}

class ScannerState extends State<Scanner> {
  String barcode;
  String received;
  int currentTime;
  bool selected = false;
  Widget optionsPage;
  BannerAd _bannerAd;
  bool _adLoad = false;
  double _inset;
  Map shareOptions;
  final bloc;

  ScannerState(this.bloc, this.optionsPage);

  @override
  void initState() {
    super.initState();

    FirebaseAdMob.instance
        .initialize(appId: "ca-app-pub-4568632381691454~6824366172");
    _bannerAd = createBannerAd()
      ..load()
      ..show();

    shareOptions = {
      "Share Selection as Text": _shareText,
      "Share All Scans as Text": _shareAllText,
      "Share Selection as CSV": _shareCSV,
      "Share All Scans as CSV": _shareAllCSV,
    };
  }

  @override
  void dispose() {
    selected = true;
    _checkAll();
    _bannerAd?.dispose();
    super.dispose();
  }

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>[
      'qr',
      'barcode',
      'scanner',
      'inventory',
      'warehouse',
      'organize',
    ],
    childDirected: true,
    nonPersonalizedAds: true,
  );

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: "ca-app-pub-4568632381691454/8349254735",
      size: AdSize.smartBanner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.loaded) {
          setState(() => _adLoad = true);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double adHeight = deviceHeight > 720 ? 90 : deviceHeight > 400 ? 50 : 32;
    _inset = adHeight;

    return Container(
        padding: _adLoad
            ? EdgeInsets.only(bottom: _inset)
            : EdgeInsets.only(bottom: 0.0),
        child: Scaffold(
            appBar: AppBar(title: Text("Scanner"), actions: <Widget>[
              // action button
              PopupMenuButton(
                icon: Icon(Icons.share),
                onSelected: (result) {
                  shareOptions[result]();
                },
                itemBuilder: (BuildContext context) {
                  return shareOptions.keys.toList().map((key) {
                    return PopupMenuItem(
                      value: key,
                      child: Text(key),
                    );
                  }).toList();
                },
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(
                      context: context, delegate: ScanSearchDelegate(bloc));
                },
              ),
            ]),
            drawer: Drawer(child: optionsPage),
            floatingActionButton: FloatingActionButton.extended(
              elevation: 4.0,
              icon: const Icon(Icons.add),
              label: const Text('Scan'),
              onPressed: scan,
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomAppBar(
              child: new Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.delete_forever),
                    onPressed: _deleteItems,
                  ),
                  IconButton(
                    icon: selected
                        ? Icon(Icons.check_box)
                        : Icon(Icons.check_box_outline_blank),
                    onPressed: _checkAll,
                  ),
                ],
              ),
            ),
            body: Center(
              child: FutureBuilder<List<Scan>>(
                future: bloc.getScans(),
                builder:
                    (BuildContext context, AsyncSnapshot<List<Scan>> snap) {
                  if (snap.hasData) {
                    int listLen = snap.data.length;
                    return ListView.builder(
                      itemCount: listLen,
                      itemBuilder: (BuildContext context, int index) {
                        Scan item = snap.data[listLen - index - 1];
                        DateTime itemDate =
                            DateTime.fromMillisecondsSinceEpoch(item.datetime);
                        String formattedDate =
                            DateFormat('kk:mm:ss EEE d MMM').format(itemDate);
                        return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CardView(item, bloc)),
                              );
                            },
                            child: Card(
                              child: Dismissible(
                                key: UniqueKey(),
                                background: Container(color: Colors.red),
                                onDismissed: (direction) {
                                  bloc.delete(item.id);
                                },
                                child: ListTile(
                                  title: Text(item.name.length > 0
                                      ? item.name
                                      : item.code),
                                  subtitle: Text(formattedDate),
                                  trailing: Checkbox(
                                    value: item.checked,
                                    onChanged: ((_) =>
                                        setState(() => bloc.check(item))),
                                  ),
                                ),
                              ),
                            ));
                      },
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            )));
  }

  Future _checkAll() async {
    List unchecked = await bloc.getCheckedIds(selected);
    bloc.checkIds(unchecked);
    setState(() => selected = !selected);
  }

  void _deleteItems() async {
    List checked = await bloc.getCheckedIds(true);
    for (var i = 0; i < checked.length; i++) {
      bloc.delete(checked[i]);
    }
    setState(() => selected = false);
  }

  void _refresh() {
    setState(() {
      currentTime = DateTime.now().millisecondsSinceEpoch;
    });
  }

  void _addItem() {
    currentTime = DateTime.now().millisecondsSinceEpoch;
    bloc.add(new Scan(
        id: 0, code: barcode, name: "", datetime: currentTime, checked: false));
    _refresh();
  }

  _shareText() async {
    List checked = await bloc.getCheckedCodes();
    String joined = checked.join("\n");
    Share.share(joined);
  }

  _shareAllText() async {
    await _checkAll();
    _shareText();
  }

  _shareCSV() async {
    List scans = await bloc.getCheckedScans();
    List<List<dynamic>> scansList = [
      ["Code", "Name", "Scan Time"]
    ];
    for (var scan in scans) {
      scansList.add(scan.toList());
    }

    final res = const ListToCsvConverter().convert(scansList);
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    final tempCSV = File('$path/history.csv');
    tempCSV.writeAsStringSync(res);

    await Share.shareFile(tempCSV);

    selected = true;
    _checkAll();
  }

  _shareAllCSV() async {
    await _checkAll();
    _shareCSV();
  }

  Future scan() async {
    try {
      String bar = await BarcodeScanner.scan();

      if (bar.contains("MAILTO")) {
        bar = bar.replaceFirst("MAILTO", "mailto");
      }

      setState(() => barcode = bar);
      _addItem();
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() =>
          barcode = 'null (User returned using "back"-button before scanning)');
    } catch (e) {
      setState(() => barcode = 'Unknown error: $e');
    }
  }
}
