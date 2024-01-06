import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Required for Uint8List
Database? _database;
List wholeDataList = [];

class DBHelper {
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'local.db');

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
      CREATE TABLE LocalTable(
        userId INTEGER PRIMARY KEY,
        DummyData JSON NOT NULL
      )
    ''');
    });
  }

  Future addDataLocally({id, wholeData}) async {
    final db = await database;
    await db.insert("LocalTable", {"DummyData": wholeData});
    await readAllData();
    return "Data added to local";
  }

  Future readAllData() async {
    final db = await database;
    final result = await db.query("LocalTable");
    wholeDataList = result;
    return "successfully read the local data";
  }

  Future<void> printAllData() async {
  final db = await database;
  final result = await db.query("LocalTable");

  print("LocalTable Data:");

  for (var row in result) {
    print("userId: ${row['userId']}, DummyData: ${row['DummyData']}");
  }
}
}
