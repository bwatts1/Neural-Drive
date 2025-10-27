import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'reports.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE reports (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            date TEXT,
            price REAL
          )
        ''');
      },
    );
  }

  Future<int> insertReport(Map<String, dynamic> report) async {
    final db = await database;
    return await db.insert('reports', report);
  }

  Future<List<Map<String, dynamic>>> getReports() async {
    final db = await database;
    return await db.query('reports', orderBy: 'id DESC');
  }

  Future<int> updateReport(int id, Map<String, dynamic> report) async {
    final db = await database;
    return await db.update('reports', report, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteReport(int id) async {
    final db = await database;
    return await db.delete('reports', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> filterReports({
    String? keyword,
    double? minPrice,
    double? maxPrice,
    String? startDate,
    String? endDate,
  }) async {
    final db = await database;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (keyword != null && keyword.isNotEmpty) {
      whereClauses.add("name LIKE ?");
      whereArgs.add('%$keyword%');
    }
    if (minPrice != null) {
      whereClauses.add("price >= ?");
      whereArgs.add(minPrice);
    }
    if (maxPrice != null) {
      whereClauses.add("price <= ?");
      whereArgs.add(maxPrice);
    }
    if (startDate != null && startDate.isNotEmpty) {
      whereClauses.add("date >= ?");
      whereArgs.add(startDate);
    }
    if (endDate != null && endDate.isNotEmpty) {
      whereClauses.add("date <= ?");
      whereArgs.add(endDate);
    }

    return await db.query(
      'reports',
      where: whereClauses.isEmpty ? null : whereClauses.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'id DESC',
    );
  }
}