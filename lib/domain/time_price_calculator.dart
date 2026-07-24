enum WorkSchedule { standard, previousMonth, custom }

class WorkProfile {
  const WorkProfile({
    required this.salary,
    required this.workDays,
    required this.hoursPerDay,
    required this.currencyCode,
    required this.schedule,
  });

  final double salary;
  final int workDays;
  final double hoursPerDay;
  final String currencyCode;
  final WorkSchedule schedule;

  double get totalHours => workDays * hoursPerDay;
  double get perHour => salary / totalHours;
  double get perDay => salary / workDays;
  double get perMinute => perHour / 60;
}

class PurchaseTime {
  const PurchaseTime({
    required this.totalHours,
    required this.fullDays,
    required this.remainingHours,
    required this.remainingMinutes,
    required this.salaryShare,
    required this.workWeeks,
  });

  final double totalHours;
  final int fullDays;
  final int remainingHours;
  final int remainingMinutes;
  final double salaryShare;
  final double workWeeks;
}

class TimePriceCalculator {
  static PurchaseTime purchase(double price, WorkProfile profile) {
    final totalHours = price / profile.perHour;
    final totalMinutes = (totalHours * 60).round();

    final days = totalMinutes ~/ (profile.hoursPerDay * 60);
    final minutesAfterDays = totalMinutes % (profile.hoursPerDay * 60).toInt();

    final hours = minutesAfterDays ~/ 60;
    final minutes = minutesAfterDays % 60;

    return PurchaseTime(
      totalHours: totalHours,
      fullDays: days,
      remainingHours: hours,
      remainingMinutes: minutes,
      salaryShare: (price / profile.salary) * 100,
      workWeeks: totalHours / 40,
    );
  }

  static DateTime previousMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month - 1);
  }

  static int weekdaysInMonth(DateTime date) {
    final lastDay = DateTime(date.year, date.month + 1, 0).day;
    var weekdays = 0;
    for (var i = 1; i <= lastDay; i++) {
      final day = DateTime(date.year, date.month, i).weekday;
      if (day != DateTime.saturday && day != DateTime.sunday) {
        weekdays++;
      }
    }
    return weekdays;
  }
}
