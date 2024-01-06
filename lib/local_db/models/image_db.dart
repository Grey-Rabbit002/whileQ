// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:while_app/resources/components/message/models/chat_user.dart';

// class DBHelper {
//   static Database? _database;

//   static Future<Database> get database async {
//     if (_database != null) {
//       return _database!;
//     }

//     _database = await initDatabase();
//     return _database!;
//   }

//   static Future<Database> initDatabase() async {
//     String path = join(await getDatabasesPath(), 'chat_database.db');

//     return await openDatabase(path, version: 1, onCreate: (db, version) async {
//       await db.execute('''
//         CREATE TABLE chat_users(
//           id TEXT PRIMARY KEY,
//           image TEXT,
//           about TEXT,
//           name TEXT,
//           createdAt TEXT,
//           isOnline INTEGER,
//           lastActive TEXT,
//           email TEXT,
//           pushToken TEXT,
//           dateOfBirth TEXT,
//           gender TEXT,
//           phoneNumber TEXT,
//           place TEXT,
//           profession TEXT,
//           designation TEXT,
//           follower INTEGER,
//           following INTEGER
//         )
//       ''');
//     });
//   }

//   static Future<void> insertUser(ChatUser user) async {
//     final Database db = await database;
//     await db.insert('chat_users', user.toMap(),
//         conflictAlgorithm: ConflictAlgorithm.replace);
//   }
//   static Future<void> updateUser(ChatUser user) async {
//     final Database db = await database;
//     await db.update(
//       'chat_users',
//       user.toMap(),
//       where: 'id = ?',
//       whereArgs: [user.id],
//     );
//   }

//   // Function to delete a user from the database
//   static Future<void> deleteUser(String userId) async {
//     final Database db = await database;
//     await db.delete(
//       'chat_users',
//       where: 'id = ?',
//       whereArgs: [userId],
//     );
//   }

//   // Function to delete all users from the database
//   static Future<void> deleteAllUsers() async {
//     final Database db = await database;
//     await db.delete('chat_users');
//   }

//   // Function to fetch a specific user from the database
//   static Future<ChatUser?> getUser(String userId) async {
//     final Database db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'chat_users',
//       where: 'id = ?',
//       whereArgs: [userId],
//     );

//     if (maps.isEmpty) {
//       return null;
//     }

//     return ChatUser.fromJson(maps.first);
//   }

//   static Future<List<ChatUser>> getAllUsers() async {
//     final Database db = await database;
//     final List<Map<String, dynamic>> maps = await db.query('chat_users');
//     if (maps.isEmpty) {
//       return [];
//     }
//     return List.generate(maps.length, (i) {
//       return ChatUser.fromJson(maps[i]);
//     });
//   }
//   static Future<void> updateUsers(List<ChatUser> users) async {
//     final Database db = await database;

//     // Loop through the list of users and update each one
//     for (var user in users) {
//       await db.update(
//         'chat_users',
//         user.toMap(),
//         where: 'id = ?',
//         whereArgs: [user.id],
//       );
//     }
//   }
// }
