class CountHistory {
  final String id;
  final String tasbeehId;
  final int count;
  final DateTime timestamp;
  final int roundNumber;

  const CountHistory({
    required this.id,
    required this.tasbeehId,
    required this.count,
    required this.timestamp,
    this.roundNumber = 1,
  });

  // Create a copy with updated values
  CountHistory copyWith({
    String? id,
    String? tasbeehId,
    int? count,
    DateTime? timestamp,
    int? roundNumber,
  }) {
    return CountHistory(
      id: id ?? this.id,
      tasbeehId: tasbeehId ?? this.tasbeehId,
      count: count ?? this.count,
      timestamp: timestamp ?? this.timestamp,
      roundNumber: roundNumber ?? this.roundNumber,
    );
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tasbeeh_id': tasbeehId,
      'count': count,
      'timestamp': timestamp.toIso8601String(),
      'round_number': roundNumber,
    };
  }

  // Create from Map (database row)
  factory CountHistory.fromMap(Map<String, dynamic> map) {
    return CountHistory(
      id: map['id'] as String,
      tasbeehId: map['tasbeeh_id'] as String,
      count: map['count'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
      roundNumber: map['round_number'] as int? ?? 1,
    );
  }

  // Get date without time for grouping
  DateTime get dateOnly {
    return DateTime(timestamp.year, timestamp.month, timestamp.day);
  }

  // Check if this count event happened today
  bool get isToday {
    final now = DateTime.now();
    return dateOnly.isAtSameMomentAs(DateTime(now.year, now.month, now.day));
  }

  // Check if this count event happened this week
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return timestamp.isAfter(weekStartDate) || timestamp.isAtSameMomentAs(weekStartDate);
  }

  // Check if this count event happened this month
  bool get isThisMonth {
    final now = DateTime.now();
    return timestamp.year == now.year && timestamp.month == now.month;
  }

  // Check if this count event happened this year
  bool get isThisYear {
    final now = DateTime.now();
    return timestamp.year == now.year;
  }

  @override
  String toString() {
    return 'CountHistory{id: $id, tasbeehId: $tasbeehId, count: $count, timestamp: $timestamp, roundNumber: $roundNumber}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CountHistory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}