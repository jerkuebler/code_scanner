import 'dart:convert';

Scan scanFromJson(String str) {
  final jsonData = json.decode(str);
  return Scan.fromMap(jsonData);
}

String scanToJson(Scan data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Scan {
  int id;
  String code;
  String name;
  int datetime;
  bool checked;

  Scan({
    this.id,
    this.code,
    this.name,
    this.datetime,
    this.checked,
  });

  factory Scan.fromMap(Map<String, dynamic> json) => new Scan(
        id: json["id"],
        code: json["code"],
        name: json["name"],
        datetime: json["datetime"],
        checked: json["checked"] == 1,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "code": code,
        "name": name,
        "datetime": datetime,
        "checked": checked,
      };

  List<String> toList() {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(datetime);

    return <String>[
      "\"$code\"",
      name,
      date.toString(),
    ];
  }
}
