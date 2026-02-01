import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/emotion_record.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('moodlog.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // emotions 테이블 생성
    await db.execute('''
      CREATE TABLE emotions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        emotion_type TEXT NOT NULL,
        emotion_intensity INTEGER NOT NULL,
        content TEXT,
        music_url TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // settings 테이블 생성
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // 인덱스 생성 (성능 향상)
    await db.execute('CREATE INDEX idx_date ON emotions(date)');
  }

  // 기록 추가
  Future<int> insertEmotion(EmotionRecord record) async {
    final db = await database;
    return await db.insert('emotions', record.toMap());
  }

  // 모든 기록 조회
  Future<List<EmotionRecord>> getAllEmotions() async {
    final db = await database;
    final result = await db.query('emotions', orderBy: 'date DESC, time DESC');
    return result.map((map) => EmotionRecord.fromMap(map)).toList();
  }

  // 특정 날짜 기록 조회
  Future<EmotionRecord?> getEmotionByDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await db.query(
      'emotions',
      where: 'date = ?',
      whereArgs: [dateStr],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return EmotionRecord.fromMap(result.first);
  }

  // 기록 수정
  Future<int> updateEmotion(EmotionRecord record) async {
    final db = await database;
    return await db.update(
      'emotions',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // 기록 삭제
  Future<int> deleteEmotion(int id) async {
    final db = await database;
    return await db.delete('emotions', where: 'id = ?', whereArgs: [id]);
  }

  // 설정 저장
  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 설정 조회
  Future<String?> getSetting(String key) async {
    final db = await database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isEmpty) return null;
    return result.first['value'] as String;
  }

  // DB 닫기
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
