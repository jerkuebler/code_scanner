import 'package:code_scanner/ScanModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScanSearchDelegate extends SearchDelegate {
  ScanSearchDelegate(this.bloc);

  final bloc;

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
    if (query.length < 3) {
      return Align(
          alignment: Alignment.center,
          child: Center(
            child: Text(
              "Search term must be longer than two letters.",
            ),
          ));
    }

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
              return Flexible(
                  child: ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        var result = results[index];
                        DateTime itemDate = DateTime.fromMillisecondsSinceEpoch(
                            result.datetime);
                        String formattedDate =
                            DateFormat('kk:mm:ss EEE d MMM').format(itemDate);
                        return Card(
                          child: Dismissible(
                            key: UniqueKey(),
                            background: Container(color: Colors.red),
                            onDismissed: (direction) {
                              bloc.delete(result.id);
                            },
                            child: ListTile(
                              title: Text(result.code),
                              subtitle: Text(formattedDate),
                            ),
                          ),
                        );
                      }));
            }
          }),
    ]);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
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
              return Flexible(
                  child: ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        var result = results[index];
                        DateTime itemDate = DateTime.fromMillisecondsSinceEpoch(
                            result.datetime);
                        String formattedDate =
                            DateFormat('kk:mm:ss EEE d MMM').format(itemDate);
                        return Card(
                          child: Dismissible(
                            key: UniqueKey(),
                            background: Container(color: Colors.red),
                            onDismissed: (direction) {
                              bloc.delete(result.id);
                            },
                            child: ListTile(
                              title: Text(result.code),
                              subtitle: Text(formattedDate),
                            ),
                          ),
                        );
                      }));
            }
          }),
    ]);
  }
}
