import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:reader_tracker/models/book.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _databaseName =
      'book_database.db';

  static const int _databaseVersion = 1;

  static const String _tableName = 'books';

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance =
      DatabaseHelper._privateConstructor();

  static Database? _database;

  // ============================================================
  // Database changes notifier
  // ============================================================

  final ValueNotifier<int> changes =
      ValueNotifier<int>(0);

  void _notifyChanges() {
    changes.value++;
  }

  // ============================================================
  // Database
  // ============================================================

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(
      await getDatabasesPath(),
      _databaseName,
    );

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // ============================================================
  // Create table
  // ============================================================

  Future<void> _onCreate(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        authors TEXT NOT NULL,
        favorite INTEGER DEFAULT 0,
        publisher TEXT,
        publishedDate TEXT,
        description TEXT,
        industryIdentifiers TEXT,
        pageCount INTEGER,
        language TEXT,
        imageLinks TEXT,
        previewLink TEXT,
        infoLink TEXT
      )
    ''');
  }

  // ============================================================
  // Insert book
  // ============================================================

  Future<int> insert(Book book) async {
    final db = await database;

    final result = await db.insert(
      _tableName,
      book.toJson(),
      conflictAlgorithm:
          ConflictAlgorithm.ignore,
    );

    if (result > 0) {
      _notifyChanges();
    }

    return result;
  }

  // ============================================================
  // Get all saved books
  // ============================================================

  Future<List<Book>> readAllBooks() async {
    final db = await database;

    final books = await db.query(
      _tableName,
      orderBy: 'rowid DESC',
    );

    return books
        .map(
          (bookData) =>
              Book.fromJsonDatabase(bookData),
        )
        .toList();
  }

  // ============================================================
  // Update favorite
  // ============================================================

  Future<int> toggleFavoriteStatus(
    String id,
    bool isFavorite,
  ) async {
    final db = await database;

    final result = await db.update(
      _tableName,
      {
        'favorite': isFavorite ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result > 0) {
      _notifyChanges();
    }

    return result;
  }

  // ============================================================
  // Delete book
  // ============================================================

  Future<int> deleteBook(String id) async {
    final db = await database;

    final result = await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result > 0) {
      _notifyChanges();
    }

    return result;
  }

  // ============================================================
  // Get favorites
  // ============================================================

  Future<List<Book>> getFavorites() async {
    final db = await database;

    final favBooks = await db.query(
      _tableName,
      where: 'favorite = ?',
      whereArgs: [1],
      orderBy: 'rowid DESC',
    );

    return favBooks
        .map(
          (bookData) =>
              Book.fromJsonDatabase(bookData),
        )
        .toList();
  }

  // ============================================================
  // Check favorite status
  // ============================================================

  Future<bool> isBookFavorite(
    String id,
  ) async {
    final db = await database;

    final result = await db.query(
      _tableName,
      columns: ['favorite'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return false;
    }

    return result.first['favorite'] == 1;
  }
}