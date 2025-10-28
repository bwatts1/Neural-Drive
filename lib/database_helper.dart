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
      version: 5, // 🔼 bump version to trigger upgrade
      onCreate: (db, version) async {
        // Reports table (✅ includes vehicle_id now)
        await db.execute('''
          CREATE TABLE reports (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            vehicle_id INTEGER,
            name TEXT,
            date TEXT,
            reminder TEXT,
            price REAL,
            FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE SET NULL
          )
        ''');

        // Users table
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT
          )
        ''');

        // Vehicles table
        await db.execute('''
          CREATE TABLE vehicles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            name TEXT,
            make TEXT,
            model TEXT,
            year TEXT,
            FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE reports ADD COLUMN reminder TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT UNIQUE,
              password TEXT
            )
          ''');
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS vehicles (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              userId INTEGER,
              name TEXT,
              make TEXT,
              model TEXT,
              year TEXT,
              FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
            )
          ''');
        }
        if (oldVersion < 5) {
          // ✅ Add missing vehicle_id column to reports
          await db.execute('ALTER TABLE reports ADD COLUMN vehicle_id INTEGER');
        }
      },
    );
  }

  // ========== REPORT FUNCTIONS ==========
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

  // ========== USER FUNCTIONS ==========
  Future<int> registerUser(String username, String password) async {
    final db = await database;
    try {
      return await db.insert('users', {
        'username': username,
        'password': password,
      });
    } catch (e) {
      // Username already exists
      return -1;
    }
  }

  Future<Map<String, dynamic>?> loginUser(
      String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  // ========== VEHICLE FUNCTIONS ==========
  Future<int> insertVehicle(Map<String, dynamic> vehicle) async {
    final db = await database;
    return await db.insert('vehicles', vehicle);
  }

  Future<List<Map<String, dynamic>>> getUserVehicles(int userId) async {
    final db = await database;
    return await db.query(
      'vehicles',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }

  Future<int> updateVehicle(int id, Map<String, dynamic> vehicle) async {
    final db = await database;
    return await db.update('vehicles', vehicle, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteVehicle(int id) async {
    final db = await database;
    return await db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getVehicles() async {
    final db = await database;
    return await db.query('vehicles');
  }
}
