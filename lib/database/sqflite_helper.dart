import 'package:crud_example/model/users_model.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqfliteHelper {

  SqfliteHelper();

  static const DATABASE_NAME = 'usersCrud.db';
  Future<Database> database;

  Future<Database> _openDb() async {
    WidgetsFlutterBinding.ensureInitialized();

    return database = openDatabase(
      join(await getDatabasesPath(), DATABASE_NAME),
      onCreate: (db, version) {
        return db.execute('CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, age INTEGER, lastname TEXT, birthday TEXT, address TEXT)');
      }, version: 1,
    );
  }

  Future<void> insertUser(UserData users) async {
    final Database db = await _openDb();

    await db.insert(
      'users',
      users.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserData>> listUsers() async {
    final Database db = await _openDb();

    final List<Map<String, dynamic>> maps = await db.query('users');

    for (var n in maps) {
      print('___' + n['name']);
    }

    return List.generate(maps.length, (i) {
      return UserData(
        id: maps[i]['id'],
        name: maps[i]['name'],
        age: maps[i]['age'],
        last_name: maps[i]['lastname'],
        birthday: maps[i]['birthday'],
        address: maps[i]['address'],
      );
    });
  }

  Future<int> deleteUser(int id) async {
    final Database db = await _openDb();

    return await db.delete('users', where: "id = ?", whereArgs: [id],);
  }

  Future<void> deleteTableData() async {
    final Database db = await _openDb();
    await db.delete('users');
  }

}