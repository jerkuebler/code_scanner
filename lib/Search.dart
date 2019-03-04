import 'package:code_scanner/ScanModel.dart';
import 'package:code_scanner/CardView.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScanSearchDelegate extends SearchDelegate {
  ScanSearchDelegate(this.bloc);

  final bloc;

  Widget listFuture() {
    return Column(children: <Widget>[
      //Build the results based on the searchResults stream in the searchBloc
      FutureBuilder(
          future: bloc.queryScans(query),
          builder: (context, AsyncSnapshot<List<Scan>> snapshot) {
            if (!snapshot.hasData) {
              return Align(
                alignment: Alignment.center,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.data.length == 0) {
              return Align(
                alignment: Alignment.center,
                child: Center(child: Text("No Results Found.")),
              );
            } else {
              var results = snapshot.data;
              var listLen = results.length;
              return Flexible(
                  child: ListView.builder(
                      itemCount: listLen,
                      itemBuilder: (context, index) {
                        Scan item = results[listLen - index - 1];
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
                                ),
                              ),
                            ));
                      }));
            }
          }),
    ]);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return listFuture();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return listFuture();
  }
}
