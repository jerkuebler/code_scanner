import 'package:code_scanner/BLOCS/DatabaseBloc.dart';
import 'package:code_scanner/ScanModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CardView extends StatefulWidget {
  CardView(this.scan, this.bloc);

  final Scan scan;
  final ScansBloc bloc;

  @override
  State<StatefulWidget> createState() => new CardViewState();
}

class CardViewState extends State<CardView> {
  Scan scanState;
  final textController = TextEditingController();
  ScansBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc;
    scanState = widget.scan;
    textController.text = scanState.name;
  }

  Future<bool> canLaunchCode() async {
    return await canLaunch(scanState.code);
  }

  @override
  Widget build(BuildContext context) {
    DateTime itemDate = DateTime.fromMillisecondsSinceEpoch(scanState.datetime);
    String formattedDate = DateFormat('kk:mm:ss EEE d MMM').format(itemDate);

    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Details')),
      body: Card(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: FutureBuilder(
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return snapshot.data != false
                    ? InkWell(
                        child: Text(scanState.code,
                            style: theme.textTheme.body1
                                .copyWith(color: theme.accentColor)),
                        onTap: (() => launch(scanState.code)),
                      )
                    : Text(scanState.code);
              },
              future: canLaunchCode(),
            ),
            subtitle: Text(formattedDate),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: "Scan Description",
            ),
            controller: textController,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                    onPressed: () {
                      scanState.name = textController.text;
                      bloc.updateName(scanState);
                      Navigator.pop(context, null);
                    },
                    child: Text("Save")),
                RaisedButton(
                    onPressed: () {
                      textController.clear();
                    },
                    child: Text("Clear"))
              ])
        ],
      )),
    );
  }
}
