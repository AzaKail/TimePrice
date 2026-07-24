import 'package:shared_preferences/shared_preferences.dart';

import '../domain/time_price_calculator.dart';

class SettingsStore {
  static const _salary = 'salary';
  static const _days = 'days';
  static const _hours = 'hours';
  static const _currency = 'currency';
  static const _schedule = 'schedule';

  Future<WorkProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final salary = prefs.getDouble(_salary);
    if (salary == null || salary <= 0) {
      return null;
    }
    final savedIndex = prefs.getInt(_schedule) ?? 0;
    final scheduleIndex = savedIndex < 0 || savedIndex >= WorkSchedule.values.length
        ? 0
        : savedIndex;
    return WorkProfile(
      salary: salary,
      workDays: prefs.getInt(_days) ?? 21,
      hoursPerDay: prefs.getDouble(_hours) ?? 8,
      currencyCode: prefs.getString(_currency) ?? '₸',
      schedule: WorkSchedule.values[scheduleIndex],
    );
  }

  Future<void> save(WorkProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setDouble(_salary, profile.salary),
      prefs.setInt(_days, profile.workDays),
      prefs.setDouble(_hours, profile.hoursPerDay),
      prefs.setString(_currency, profile.currencyCode),
      prefs.setInt(_schedule, profile.schedule.index),
    ]);
  }
}
