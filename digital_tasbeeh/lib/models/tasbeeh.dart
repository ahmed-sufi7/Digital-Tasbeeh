class Tasbeeh {
  final String id;
  final String name;
  final int? targetCount; // null for unlimited
  final int currentCount;
  final int roundNumber;
  final DateTime createdAt;
  final DateTime lastUsedAt;
  final bool isDefault;

  const Tasbeeh({
    required this.id,
    required this.name,
    this.targetCount,
    this.currentCount = 0,
    this.roundNumber = 1,
    required this.createdAt,
    required this.lastUsedAt,
    this.isDefault = false,
  });

  // Create a copy with updated values
  Tasbeeh copyWith({
    String? id,
    String? name,
    int? targetCount,
    int? currentCount,
    int? roundNumber,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    bool? isDefault,
  }) {
    return Tasbeeh(
      id: id ?? this.id,
      name: name ?? this.name,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      roundNumber: roundNumber ?? this.roundNumber,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_count': targetCount,
      'current_count': currentCount,
      'round_number': roundNumber,
      'created_at': createdAt.toIso8601String(),
      'last_used_at': lastUsedAt.toIso8601String(),
      'is_default': isDefault ? 1 : 0,
    };
  }

  // Create from Map (database row)
  factory Tasbeeh.fromMap(Map<String, dynamic> map) {
    return Tasbeeh(
      id: map['id'] as String,
      name: map['name'] as String,
      targetCount: map['target_count'] as int?,
      currentCount: map['current_count'] as int? ?? 0,
      roundNumber: map['round_number'] as int? ?? 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastUsedAt: DateTime.parse(map['last_used_at'] as String),
      isDefault: (map['is_default'] as int?) == 1,
    );
  }

  // Check if this is an unlimited Tasbeeh
  bool get isUnlimited => targetCount == null;

  // Check if target is reached
  bool get isTargetReached => targetCount != null && currentCount >= targetCount!;

  // Get progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (isUnlimited) return 0.0;
    return targetCount! > 0 ? (currentCount / targetCount!).clamp(0.0, 1.0) : 0.0;
  }

  @override
  String toString() {
    return 'Tasbeeh{id: $id, name: $name, targetCount: $targetCount, currentCount: $currentCount, roundNumber: $roundNumber, isDefault: $isDefault}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tasbeeh && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}