import 'package:sqflite/sqflite.dart';
import '../models/count_history.dart';
import 'database_helper.dart';

class CountHistoryRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Insert count history record
  Future<String> insertCountHistory(CountHistory countHistory) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'count_history',
      countHistory.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return countHistory.id;
  }

  // Get all count history for a specific Tasbeeh
  Future<List<CountHistory>> getCountHistoryByTasbeeh(String tasbeehId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'count_history',
      where: 'tasbeeh_id = ?',
      whereArgs: [tasbeehId],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return CountHistory.fromMap(maps[i]);
    });
  }

  // Get count history within date range
  Future<List<CountHistory>> getCountHistoryByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? tasbeehId,
  }) async {
    final db = await _databaseHelper.database;
    
    String whereClause = 'timestamp >= ? AND timestamp <= ?';
    List<dynamic> whereArgs = [
      startDate.toIso8601String(),
      endDate.toIso8601String(),
    ];

    if (tasbeehId != null) {
      whereClause += ' AND tasbeeh_id = ?';
      whereArgs.add(tasbeehId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'count_history',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return CountHistory.fromMap(maps[i]);
    });
  }

  // Get today's count history
  Future<List<CountHistory>> getTodayCountHistory({String? tasbeehId}) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getCountHistoryByDateRange(startOfDay, endOfDay, tasbeehId: tasbeehId);
  }

  // Get this week's count history
  Future<List<CountHistory>> getWeekCountHistory({String? tasbeehId}) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeek = startOfWeekDate.add(const Duration(days: 7));

    return getCountHistoryByDateRange(startOfWeekDate, endOfWeek, tasbeehId: tasbeehId);
  }

  // Get this month's count history
  Future<List<CountHistory>> getMonthCountHistory({String? tasbeehId}) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    return getCountHistoryByDateRange(startOfMonth, endOfMonth, tasbeehId: tasbeehId);
  }

  // Get this year's count history
  Future<List<CountHistory>> getYearCountHistory({String? tasbeehId}) async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year + 1, 1, 1);

    return getCountHistoryByDateRange(startOfYear, endOfYear, tasbeehId: tasbeehId);
  }

  // Get daily aggregated counts for a date range
  Future<Map<DateTime, int>> getDailyAggregatedCounts(
    DateTime startDate,
    DateTime endDate, {
    String? tasbeehId,
  }) async {
    final db = await _databaseHelper.database;
    
    String whereClause = 'timestamp >= ? AND timestamp <= ?';
    List<dynamic> whereArgs = [
      startDate.toIso8601String(),
      endDate.toIso8601String(),
    ];

    if (tasbeehId != null) {
      whereClause += ' AND tasbeeh_id = ?';
      whereArgs.add(tasbeehId);
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        DATE(timestamp) as date,
        SUM(count) as total_count
      FROM count_history 
      WHERE $whereClause
      GROUP BY DATE(timestamp)
      ORDER BY date
    ''', whereArgs);

    final Map<DateTime, int> result = {};
    for (final map in maps) {
      final date = DateTime.parse(map['date'] as String);
      final count = map['total_count'] as int;
      result[date] = count;
    }

    return result;
  }

  // Get total count for all time
  Future<int> getTotalAllTimeCount({String? tasbeehId}) async {
    final db = await _databaseHelper.database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (tasbeehId != null) {
      whereClause = 'WHERE tasbeeh_id = ?';
      whereArgs.add(tasbeehId);
    }

    final result = await db.rawQuery(
      'SELECT SUM(count) as total FROM count_history $whereClause',
      whereArgs,
    );
    
    return (result.first['total'] as int?) ?? 0;
  }

  // Get count distribution by Tasbeeh
  Future<Map<String, int>> getCountDistributionByTasbeeh() async {
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        t.name as tasbeeh_name,
        SUM(ch.count) as total_count
      FROM count_history ch
      JOIN tasbeehs t ON ch.tasbeeh_id = t.id
      GROUP BY ch.tasbeeh_id, t.name
      ORDER BY total_count DESC
    ''');

    final Map<String, int> result = {};
    for (final map in maps) {
      final name = map['tasbeeh_name'] as String;
      final count = map['total_count'] as int;
      result[name] = count;
    }

    return result;
  }

  // Delete count history for a specific Tasbeeh
  Future<int> deleteCountHistoryByTasbeeh(String tasbeehId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'count_history',
      where: 'tasbeeh_id = ?',
      whereArgs: [tasbeehId],
    );
  }

  // Delete count history older than specified days
  Future<int> deleteOldCountHistory(int daysToKeep) async {
    final db = await _databaseHelper.database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    
    return await db.delete(
      'count_history',
      where: 'timestamp < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  // Get count statistics for a specific period
  Future<Map<String, dynamic>> getCountStatistics({
    String? tasbeehId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _databaseHelper.database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (tasbeehId != null || startDate != null || endDate != null) {
      List<String> conditions = [];
      
      if (tasbeehId != null) {
        conditions.add('tasbeeh_id = ?');
        whereArgs.add(tasbeehId);
      }
      
      if (startDate != null) {
        conditions.add('timestamp >= ?');
        whereArgs.add(startDate.toIso8601String());
      }
      
      if (endDate != null) {
        conditions.add('timestamp <= ?');
        whereArgs.add(endDate.toIso8601String());
      }
      
      whereClause = 'WHERE ${conditions.join(' AND ')}';
    }

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_sessions,
        SUM(count) as total_count,
        AVG(count) as average_count,
        MIN(count) as min_count,
        MAX(count) as max_count
      FROM count_history $whereClause
    ''', whereArgs);

    final stats = result.first;
    return {
      'totalSessions': stats['total_sessions'] as int,
      'totalCount': stats['total_count'] as int? ?? 0,
      'averageCount': (stats['average_count'] as double?)?.round() ?? 0,
      'minCount': stats['min_count'] as int? ?? 0,
      'maxCount': stats['max_count'] as int? ?? 0,
    };
  }
}