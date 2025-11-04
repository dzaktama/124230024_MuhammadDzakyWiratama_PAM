
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static sql.Database? _database;

  DatabaseHelper._internal();

  Future<sql.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<sql.Database> _initDB() async {
    String path = join(await sql.getDatabasesPath(), 'hafalan.db');
    return await sql.openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(sql.Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        email TEXT,
        passwordHash TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE hafalan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idHafalan INTEGER,
        namaHafalan TEXT,
        tipeHafalan TEXT,
        tanggalMulai TEXT,
        tanggalSelesai TEXT
      )
    ''');
  }
}