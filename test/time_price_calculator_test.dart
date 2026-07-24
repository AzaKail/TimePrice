import 'package:flutter_test/flutter_test.dart';
import 'package:time_price/domain/time_price_calculator.dart';

void main() {
  const profile = WorkProfile(
    salary: 300000,
    workDays: 21,
    hoursPerDay: 8,
    currencyCode: '₸',
    schedule: WorkSchedule.standard,
  );

  test('рассчитывает доход за день, час и минуту', () {
    expect(profile.totalHours, 168);
    expect(profile.perDay, closeTo(14285.71, 0.01));
    expect(profile.perHour, closeTo(1785.71, 0.01));
    expect(profile.perMinute, closeTo(29.76, 0.01));
  });

  test('переводит цену покупки в рабочее время', () {
    final result = TimePriceCalculator.purchase(250000, profile);

    expect(result.totalHours, closeTo(140, 0.01));
    expect(result.fullDays, 17);
    expect(result.remainingHours, 4);
    expect(result.remainingMinutes, 0);
    expect(result.salaryShare, closeTo(83.33, 0.01));
  });

  test('считает только будни в календарном месяце', () {
    expect(TimePriceCalculator.weekdaysInMonth(DateTime(2024, 6)), 20);
  });
}
