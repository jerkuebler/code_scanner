import 'dart:async';

import 'package:code_scanner/Database.dart';
import 'package:code_scanner/ScanModel.dart';

class ScansBloc {
  ScansBloc() {
    DBProvider _ = DBProvider.db;
  }

  Future<List<Scan>> getScans() async {
    List<Scan> scanList = await DBProvider.db.getAllScans();
    return scanList;
  }

  queryScans(String query) {
    return DBProvider.db.queryScans(query);
  }

  delete(int id) {
    DBProvider.db.deleteScan(id);
  }

  add(Scan scan) {
    DBProvider.db.newScan(scan);
  }

  updateName(Scan scan) {
    DBProvider.db.updateScan(scan);
  }

  getCheckedIds(bool selected) async {
    return DBProvider.db.getCheckedids(selected);
  }

  getCheckedCodes() async {
    return DBProvider.db.getCheckedCodes();
  }

  getCheckedScans() async {
    return DBProvider.db.getCheckedScans();
  }

  checkIds(List ids) {
    DBProvider.db.checkById(ids);
  }

  check(Scan scan) {
    DBProvider.db.checkScan(scan);
  }

  checkAll(selected) async {
    List unchecked = await getCheckedIds(selected);
    checkIds(unchecked);
  }
}
