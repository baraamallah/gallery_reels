import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gallery_reels.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tags (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS photo_tags (
        photo_id TEXT NOT NULL,
        tag_id TEXT NOT NULL,
        tagged_at INTEGER NOT NULL,
        PRIMARY KEY (photo_id, tag_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS deleted_photos (
        photo_id TEXT PRIMARY KEY,
        filename TEXT,
        file_size INTEGER,
        deleted_at INTEGER NOT NULL,
        restored INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_stats (
        date TEXT PRIMARY KEY,
        reviewed INTEGER DEFAULT 0,
        deleted INTEGER DEFAULT 0,
        space_freed INTEGER DEFAULT 0
      )
    ''');

    // Insert default tags
    final defaultTags = [
      {'id': '1', 'name': 'Delete later', 'color': 0xFFf87171, 'created_at': DateTime.now().millisecondsSinceEpoch},
      {'id': '2', 'name': 'Favorites',    'color': 0xFF34d399, 'created_at': DateTime.now().millisecondsSinceEpoch},
      {'id': '3', 'name': 'Work',         'color': 0xFF60a5fa, 'created_at': DateTime.now().millisecondsSinceEpoch},
      {'id': '4', 'name': 'Memories',     'color': 0xFFa78bfa, 'created_at': DateTime.now().millisecondsSinceEpoch},
      {'id': '5', 'name': 'Family',       'color': 0xFFfb923c, 'created_at': DateTime.now().millisecondsSinceEpoch},
      {'id': '6', 'name': 'Friends',      'color': 0xFFf472b6, 'created_at': DateTime.now().millisecondsSinceEpoch},
      {'id': '7', 'name': 'Travel',       'color': 0xFF2dd4bf, 'created_at': DateTime.now().millisecondsSinceEpoch},
      {'id': '8', 'name': 'Unsorted',     'color': 0xFF9ca3af, 'created_at': DateTime.now().millisecondsSinceEpoch},
    ];

    for (var tag in defaultTags) {
      await db.insert('tags', tag);
    }
  }

  // Trash management
  Future<void> addToTrash(String photoId, String? filename, int? fileSize) async {
    final db = await instance.database;
    await db.insert(
      'deleted_photos',
      {
        'photo_id': photoId,
        'filename': filename,
        'file_size': fileSize,
        'deleted_at': DateTime.now().millisecondsSinceEpoch,
        'restored': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFromTrash(String photoId) async {
    final db = await instance.database;
    await db.delete(
      'deleted_photos',
      where: 'photo_id = ?',
      whereArgs: [photoId],
    );
  }

  Future<Set<String>> getTrashedPhotoIds() async {
    final db = await instance.database;
    final rows = await db.query('deleted_photos', columns: ['photo_id']);
    return rows.map((r) => r['photo_id'] as String).toSet();
  }

  Future<int> getTotalSpaceFreed() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT SUM(file_size) as total FROM deleted_photos WHERE restored = 0');
    return (result.first['total'] as int?) ?? 0;
  }

  // Stats queries
  Future<Map<String, dynamic>> getTodayStats() async {
    final db = await instance.database;
    final date = DateTime.now().toIso8601String().split('T')[0];
    final result = await db.query('daily_stats', where: 'date = ?', whereArgs: [date]);
    if (result.isNotEmpty) return result.first;
    
    // Create new stats entry for today
    final newStats = {'date': date, 'reviewed': 0, 'deleted': 0, 'space_freed': 0};
    await db.insert('daily_stats', newStats);
    return newStats;
  }

  Future<Map<String, dynamic>> getLifetimeStats() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT SUM(reviewed) as reviewed, SUM(deleted) as deleted, SUM(space_freed) as space_freed FROM daily_stats');
    if (result.isNotEmpty && result.first['reviewed'] != null) {
      return result.first;
    }
    return {'reviewed': 0, 'deleted': 0, 'space_freed': 0};
  }

  Future<void> updateStats({int? reviewed, int? deleted, int? spaceFreed}) async {
    final db = await instance.database;
    final date = DateTime.now().toIso8601String().split('T')[0];
    
    final stats = await getTodayStats();
    await db.update(
      'daily_stats',
      {
        'reviewed': (stats['reviewed'] as int) + (reviewed ?? 0),
        'deleted': (stats['deleted'] as int) + (deleted ?? 0),
        'space_freed': (stats['space_freed'] as int) + (spaceFreed ?? 0),
      },
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  // Tag management
  Future<void> tagPhoto(String photoId, String tagId) async {
    final db = await instance.database;
    await db.insert(
      'photo_tags',
      {
        'photo_id': photoId,
        'tag_id': tagId,
        'tagged_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> untagPhoto(String photoId, String tagId) async {
    final db = await instance.database;
    await db.delete(
      'photo_tags',
      where: 'photo_id = ? AND tag_id = ?',
      whereArgs: [photoId, tagId],
    );
  }

  Future<List<String>> getPhotoTags(String photoId) async {
    final db = await instance.database;
    final result = await db.query(
      'photo_tags',
      columns: ['tag_id'],
      where: 'photo_id = ?',
      whereArgs: [photoId],
    );
    return result.map((r) => r['tag_id'] as String).toList();
  }

  Future<List<String>> getPhotosByTag(String tagId) async {
    final db = await instance.database;
    final result = await db.query(
      'photo_tags',
      columns: ['photo_id'],
      where: 'tag_id = ?',
      orderBy: 'tagged_at DESC',
    );
    return result.map((r) => r['photo_id'] as String).toList();
  }
}
