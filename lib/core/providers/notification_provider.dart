import 'package:expense_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  static const _enabledKey = 'reminder_enabled';
  static const _hourKey = 'reminder_hour';
  static const _minuteKey = 'reminder_minute';
  static const _lastLoggedKey = 'reminder_last_logged_date';

  bool _enabled = false;
  TimeOfDay _time = const TimeOfDay(hour: 21, minute: 0);
  String? _lastLoggedDate;
  Future<void> _syncing = Future.value();

  bool get enabled => _enabled;
  TimeOfDay get time => _time;

  NotificationProvider() {
    _load();
  }

  String _todayString() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  bool get _loggedToday => _lastLoggedDate == _todayString();

  // Runs one schedule at a time so overlapping calls can't interleave.
  Future<void> _schedule() {
    _syncing = _syncing.catchError((_) {}).then((_) {
      return NotificationService.instance.scheduleDailyReminder(
        hour: _time.hour,
        minute: _time.minute,
        skipToday: _loggedToday,
      );
    });
    return _syncing;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool(_enabledKey) ?? false;
      _time = TimeOfDay(
        hour: prefs.getInt(_hourKey) ?? 21,
        minute: prefs.getInt(_minuteKey) ?? 0,
      );
      _lastLoggedDate = prefs.getString(_lastLoggedKey);
      notifyListeners();
      if (_enabled) await _schedule();
    } catch (e) {
      debugPrint('Error loading reminder settings: $e');
    }
  }

  /// Returns false if the user denied the notification permission.
  Future<bool> setEnabled(bool value) async {
    if (value) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) return false;
      _enabled = true;
      await _schedule();
    } else {
      _enabled = false;
      await NotificationService.instance.cancelDailyReminder();
    }
    notifyListeners();
    await _save();
    return true;
  }

  Future<void> setTime(TimeOfDay newTime) async {
    _time = newTime;
    notifyListeners();
    if (_enabled) await _schedule();
    await _save();
  }

  /// Call after the user successfully adds an expense.
  Future<void> markLoggedToday() async {
    _lastLoggedDate = _todayString();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastLoggedKey, _lastLoggedDate!);
    } catch (e) {
      debugPrint('Error saving last logged date: $e');
    }
    if (_enabled) await _schedule();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, _enabled);
      await prefs.setInt(_hourKey, _time.hour);
      await prefs.setInt(_minuteKey, _time.minute);
    } catch (e) {
      debugPrint('Error saving reminder settings: $e');
    }
  }
}
