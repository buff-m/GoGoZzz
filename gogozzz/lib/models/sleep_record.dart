/// 打卡记录模型
class SleepRecord {
  final int? id;
  final String date; // yyyy-MM-dd
  final String time; // HH:mm
  final int level; // 1-7
  final String createdAt; // ISO8601

  SleepRecord({
    this.id,
    required this.date,
    required this.time,
    required this.level,
    required this.createdAt,
  });

  /// 从 Map 创建实例
  factory SleepRecord.fromMap(Map<String, dynamic> map) {
    return SleepRecord(
      id: map['id'] as int?,
      date: map['date'] as String,
      time: map['time'] as String,
      level: map['level'] as int,
      createdAt: map['created_at'] as String,
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'time': time,
      'level': level,
      'created_at': createdAt,
    };
  }

  /// 创建副本
  SleepRecord copyWith({
    int? id,
    String? date,
    String? time,
    int? level,
    String? createdAt,
  }) {
    return SleepRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'SleepRecord(id: $id, date: $date, time: $time, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SleepRecord && other.date == date;
  }

  @override
  int get hashCode => date.hashCode;
}
