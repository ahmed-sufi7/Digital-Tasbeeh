import 'package:sqflite/sqflite.dart';
import '../models/tasbeeh.dart';
import 'database_helper.dart';

class TasbeehRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Get all Tasbeehs
  Future<List<Tasbeeh>> getAllTasbeehs() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasbeehs',
      orderBy: 'is_default DESC, last_used_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Tasbeeh.fromMap(maps[i]);
    });
  }

  // Get Tasbeeh by ID
  Future<Tasbeeh?> getTasbeehById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasbeehs',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Tasbeeh.fromMap(maps.first);
    }
    return null;
  }

  // Get default Tasbeeh
  Future<Tasbeeh?> getDefaultTasbeeh() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasbeehs',
      where: 'is_default = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Tasbeeh.fromMap(maps.first);
    }
    
    // If no default found, return the first Tasbeeh
    final allTasbeehs = await getAllTasbeehs();
    return allTasbeehs.isNotEmpty ? allTasbeehs.first : null;
  }

  // Insert new Tasbeeh
  Future<String> insertTasbeeh(Tasbeeh tasbeeh) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'tasbeehs',
      tasbeeh.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return tasbeeh.id;
  }

  // Update existing Tasbeeh
  Future<int> updateTasbeeh(Tasbeeh tasbeeh) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'tasbeehs',
      tasbeeh.toMap(),
      where: 'id = ?',
      whereArgs: [tasbeeh.id],
    );
  }

  // Update Tasbeeh count and round
  Future<int> updateTasbeehCount(String id, int newCount, int newRound) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'tasbeehs',
      {
        'current_count': newCount,
        'round_number': newRound,
        'last_used_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update last used timestamp
  Future<int> updateLastUsed(String id) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'tasbeehs',
      {'last_used_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete Tasbeeh (only if not default)
  Future<int> deleteTasbeeh(String id) async {
    final db = await _databaseHelper.database;
    
    // Check if it's a default Tasbeeh
    final tasbeeh = await getTasbeehById(id);
    if (tasbeeh?.isDefault == true) {
      throw Exception('Cannot delete default Tasbeeh');
    }

    // Delete associated count history first
    await db.delete(
      'count_history',
      where: 'tasbeeh_id = ?',
      whereArgs: [id],
    );

    // Delete the Tasbeeh
    return await db.delete(
      'tasbeehs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Reset Tasbeeh count
  Future<int> resetTasbeehCount(String id) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'tasbeehs',
      {
        'current_count': 0,
        'round_number': 1,
        'last_used_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get Tasbeehs with count greater than zero
  Future<List<Tasbeeh>> getActiveTasbeehs() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasbeehs',
      where: 'current_count > ?',
      whereArgs: [0],
      orderBy: 'last_used_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Tasbeeh.fromMap(maps[i]);
    });
  }

  // Search Tasbeehs by name
  Future<List<Tasbeeh>> searchTasbeehs(String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasbeehs',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'is_default DESC, name ASC',
    );

    return List.generate(maps.length, (i) {
      return Tasbeeh.fromMap(maps[i]);
    });
  }

  // Get total count across all Tasbeehs
  Future<int> getTotalCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(current_count) as total FROM tasbeehs',
    );
    
    return (result.first['total'] as int?) ?? 0;
  }

  // Check if Tasbeeh name exists (for validation)
  Future<bool> tasbeehNameExists(String name, {String? excludeId}) async {
    final db = await _databaseHelper.database;
    
    String whereClause = 'LOWER(name) = ?';
    List<dynamic> whereArgs = [name.toLowerCase()];
    
    if (excludeId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeId);
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'tasbeehs',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return maps.isNotEmpty;
  }
}