import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// 数据库服务 - SQLite 初始化和基础操作
class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;

  DatabaseService._();

  /// 单例模式
  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  /// 获取数据库实例
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gogozzz.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// 创建表
  Future<void> _onCreate(Database db, int version) async {
    // 创建打卡记录表
    await db.execute('''
      CREATE TABLE sleep_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        time TEXT NOT NULL,
        level INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 创建日期索引
    await db.execute(
      'CREATE INDEX idx_sleep_records_date ON sleep_records(date)',
    );

    // 创建用户设置表
    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY,
        normal_time TEXT NOT NULL DEFAULT '23:00',
        updated_at TEXT NOT NULL
      )
    ''');

    // 初始化默认设置
    await db.insert('user_settings', {
      'id': 1,
      'normal_time': '23:00',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
