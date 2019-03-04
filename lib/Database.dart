import "dart:io";

import "package:code_scanner/ScanModel.dart";
import "package:path/path.dart";
import "package:path_provider/path_provider.dart";
import "package:sqflite/sqflite.dart";

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "qr.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Scan ("
          "id INTEGER PRIMARY KEY,"
          "code TEXT,"
          "name TEXT,"
          "datetime INTEGER,"
          "checked INTEGER"
          ")");
    });
  }

  newScan(Scan newScan) async {
    final db = await database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Scan");
    int id = table.first["id"];
    bool checked = false;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into Scan (id,code,name,datetime,checked)"
        " VALUES (?,?,?,?,?)",
        [id, newScan.code, "", newScan.datetime, checked]);
    return raw;
  }

  updateScan(Scan newScan) async {
    final db = await database;
    var res = await db.update("Scan", newScan.toMap(),
        where: "id = ?", whereArgs: [newScan.id]);
    return res;
  }

  checkById(List ids) async {
    final db = await database;
    String paramLen = "(" + ids[0].toString();
    for (int i = 1; i < ids.length; i++) {
      paramLen = paramLen + ", " + ids[i].toString();
    }
    paramLen = paramLen + ")";
    await db.rawQuery(
        "UPDATE Scan SET checked = CASE checked WHEN 0 THEN 1 ELSE 0 END WHERE id IN $paramLen");
  }

  checkScan(Scan scan) async {
    final db = await database;
    scan.checked = !scan.checked;
    var res = await db
        .update("Scan", scan.toMap(), where: "id = ?", whereArgs: [scan.id]);
    return res;
  }

  getScan(int id) async {
    final db = await database;
    var res = await db.query("Scan", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Scan.fromMap(res.first) : null;
  }

  Future<List<Scan>> getAllScans() async {
    final db = await database;
    var res = await db.query("Scan");
    List<Scan> list =
        res.isNotEmpty ? res.map((c) => Scan.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Scan>> getScansByid(List ids) async {
    final db = await database;
    var res = await db.query("Scan", where: "id = ?", whereArgs: ids);
    List<Scan> list =
        res.isNotEmpty ? res.map((c) => Scan.fromMap(c)).toList() : [];
    return list;
  }

  getCheckedCodes() async {
    final db = await database;
    var res = await db.rawQuery("SELECT code FROM Scan WHERE checked=1");
    List list = res.isNotEmpty ? res.map((c) => c['code']).toList() : [];

    return list;
  }

  getCheckedids(bool selected) async {
    final db = await database;

    int selectBool = selected ? 1 : 0;
    var res =
        await db.rawQuery("SELECT id FROM Scan WHERE checked=$selectBool");
    List list = res.isNotEmpty ? res.map((c) => c['id']).toList() : [];

    return list;
  }

  getCheckedScans() async {
    final db = await database;
    var res = await db.rawQuery("SELECT * FROM Scan WHERE checked=1");
    List list = res.isNotEmpty ? res.map((c) => Scan.fromMap(c)).toList() : [];

    return list;
  }

  deleteScan(int id) async {
    final db = await database;
    return db.delete("Scan", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete * from Scan");
  }

  Future<List<Scan>> queryScans(String query) async {
    final db = await database;
    List<Map> res = await db.rawQuery(
        "SELECT * FROM Scan WHERE code LIKE '%$query%' OR name LIKE '%$query%'");
    List<Scan> list =
        res.isNotEmpty ? res.map((c) => Scan.fromMap(c)).toList() : [];
    return list;
  }
}
