import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:while_app/resources/components/message/models/chat_user.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  static Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'chat_database.db');

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE chat_users(
          id TEXT PRIMARY KEY,
          image TEXT,
          about TEXT,
          name TEXT,
          createdAt TEXT,
          isOnline INTEGER,
          lastActive TEXT,
          email TEXT,
          pushToken TEXT,
          dateOfBirth TEXT,
          gender TEXT,
          phoneNumber TEXT,
          place TEXT,
          profession TEXT,
          designation TEXT,
          follower INTEGER,
          following INTEGER
        )
      ''');
    });
  }

  static Future<void> insertUser(ChatUser user) async {
    final Database db = await database;
    await db.insert('chat_users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<ChatUser>> getAllUsers() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('chat_users');
    if (maps.isEmpty) {
      return [ChatUser.empty()];
    }
    return List.generate(maps.length, (i) {
      return ChatUser.fromJson(maps[i]);
    });
  }
}
