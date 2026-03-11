import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sleep_record.dart';
import '../models/monthly_stats.dart';
import '../repositories/sleep_repository.dart';
import '../services/sleep_service.dart';
import '../utils/date_utils.dart';
import 'settings_provider.dart';

/// 打卡状态
class SleepState {
  final SleepRecord? todayRecord;
  final List<SleepRecord> recentRecords;
  final bool isClocking;
  final String? error;
  final DateTime lastUpdated;

  SleepState({
    this.todayRecord,
    this.recentRecords = const [],
    this.isClocking = false,
    this.error,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  SleepState copyWith({
    SleepRecord? todayRecord,
    List<SleepRecord>? recentRecords,
    bool? isClocking,
    String? error,
    bool clearTodayRecord = false,
  }) {
    return SleepState(
      todayRecord: clearTodayRecord ? null : (todayRecord ?? this.todayRecord),
      recentRecords: recentRecords ?? this.recentRecords,
      isClocking: isClocking ?? this.isClocking,
      error: error,
      lastUpdated: DateTime.now(),
    );
  }
}

/// 打卡状态管理
class SleepNotifier extends StateNotifier<SleepState> {
  final SleepService _service;

  SleepNotifier(this._service) : super(SleepState()) {
    loadTodayRecord();
    loadRecentRecords(7);
  }

  /// 打卡
  Future<void> clockIn() async {
    state = state.copyWith(isClocking: true, error: null);
    try {
      final record = await _service.clockIn();
      state = state.copyWith(
        todayRecord: record,
        isClocking: false,
      );
      // 刷新最近记录
      await loadRecentRecords(7);
    } catch (e) {
      state = state.copyWith(
        isClocking: false,
        error: e.toString(),
      );
    }
  }

  /// 加载今日记录
  Future<void> loadTodayRecord() async {
    try {
      final record = await _service.getTodayRecord();
      state = state.copyWith(
        todayRecord: record,
        clearTodayRecord: record == null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 加载最近N天记录
  Future<void> loadRecentRecords(int days) async {
    try {
      final records = await _service.getRecentRecords(days);
      state = state.copyWith(recentRecords: records);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 补卡
  Future<bool> addMakeupRecord({
    required String date,
    required String time,
  }) async {
    state = state.copyWith(isClocking: true, error: null);
    try {
      final record = await _service.addMakeupRecord(date: date, time: time);

      // 如果补的是今天，更新 todayRecord
      final today = AppDateUtils.getBelongDateString();
      state = state.copyWith(
        todayRecord: date == today ? record : state.todayRecord,
        isClocking: false,
      );

      // 刷新最近记录
      await loadRecentRecords(7);
      return true;
    } catch (e) {
      state = state.copyWith(isClocking: false, error: e.toString());
      return false;
    }
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 打卡仓库 Provider
final sleepRepositoryProvider = Provider<SleepRepository>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return SleepRepository(dbService);
});

/// 打卡服务 Provider
final sleepServiceProvider = Provider<SleepService>((ref) {
  final sleepRepo = ref.watch(sleepRepositoryProvider);
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return SleepService(sleepRepo, settingsRepo);
});

/// 打卡 Provider
final sleepProvider =
    StateNotifierProvider<SleepNotifier, SleepState>((ref) {
  final service = ref.watch(sleepServiceProvider);
  return SleepNotifier(service);
});

/// 今日记录 Provider（派生）
final todayRecordProvider = Provider<SleepRecord?>((ref) {
  final sleepState = ref.watch(sleepProvider);
  return sleepState.todayRecord;
});

/// 最近7天记录 Provider（派生）
final recentRecordsProvider = Provider<List<SleepRecord>>((ref) {
  final sleepState = ref.watch(sleepProvider);
  return sleepState.recentRecords;
});

/// 月度记录 Provider（日历用，加载当月所有记录）
final monthlyRecordsProvider =
    FutureProvider.family<List<SleepRecord>, (int, int)>((ref, params) async {
  final (year, month) = params;
  final repository = ref.watch(sleepRepositoryProvider);
  final firstDate = '$year-${month.toString().padLeft(2, '0')}-01';
  final lastDayDt = DateTime(year, month + 1, 0);
  final lastDate =
      '$year-${month.toString().padLeft(2, '0')}-${lastDayDt.day.toString().padLeft(2, '0')}';
  return await repository.getByDateRange(firstDate, lastDate);
});

/// 月度统计 Provider
final monthlyStatsProvider =
    FutureProvider.family<MonthlyStats, (int, int)>((ref, params) async {
  final (year, month) = params;
  final repository = ref.watch(sleepRepositoryProvider);
  final normalTime = ref.watch(normalTimeProvider);
  return await repository.getMonthlyStats(year, month, normalTime: normalTime);
});
