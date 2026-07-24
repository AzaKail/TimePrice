import 'package:flutter/material.dart';
import '../domain/time_price_calculator.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({
    required this.onSaved,
    this.initialProfile,
    super.key,
  });

  final WorkProfile? initialProfile;
  final Future<void> Function(WorkProfile profile) onSaved;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late final TextEditingController _salary;
  late final TextEditingController _days;
  late final TextEditingController _hours;
  late WorkSchedule _schedule;
  late String _currency;
  var _saving = false;

  static const _monthNames = [
    'январь', 'февраль', 'март', 'апрель', 'май', 'июнь',
    'июль', 'август', 'сентябрь', 'октябрь', 'ноябрь', 'декабрь',
  ];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialProfile;
    _salary = TextEditingController(
      text: initial == null ? '' : initial.salary.toStringAsFixed(0),
    );
    _days = TextEditingController(text: '${initial?.workDays ?? 21}');
    _hours = TextEditingController(
      text: (initial?.hoursPerDay ?? 8).toStringAsFixed(0),
    );
    _schedule = initial?.schedule ?? WorkSchedule.standard;
    _currency = initial?.currencyCode ?? '₸';
  }

  @override
  void dispose() {
    _salary.dispose();
    _days.dispose();
    _hours.dispose();
    super.dispose();
  }

  void _applySchedule(WorkSchedule schedule) {
    setState(() {
      _schedule = schedule;
      if (schedule == WorkSchedule.standard) {
        _days.text = '21';
        _hours.text = '8';
      } else if (schedule == WorkSchedule.previousMonth) {
        final month = TimePriceCalculator.previousMonth();
        _days.text = '${TimePriceCalculator.weekdaysInMonth(month)}';
        _hours.text = '8';
      }
    });
  }

  double? _number(String value) =>
      double.tryParse(value.replaceAll(' ', '').replaceAll(',', '.'));

  Future<void> _submit() async {
    final salary = _number(_salary.text);
    final days = int.tryParse(_days.text);
    final hours = _number(_hours.text);
    if (salary == null || salary <= 0 || days == null || days <= 0 ||
        hours == null || hours <= 0 || hours > 24) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Проверь зарплату, дни и часы')),
      );
      return;
    }
    setState(() => _saving = true);
    await widget.onSaved(
      WorkProfile(
        salary: salary,
        workDays: days,
        hoursPerDay: hours,
        currencyCode: _currency,
        schedule: _schedule,
      ),
    );
    if (mounted) {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final previous = TimePriceCalculator.previousMonth();
    return Scaffold(
      appBar: widget.initialProfile == null
          ? null
          : AppBar(title: const Text('Рабочий профиль')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
          children: [
            if (widget.initialProfile == null) ...[
              Text(
                'Часы Жизни',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Узнай, сколько твоего времени стоит любая покупка.',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white70,
                      height: 1.25,
                    ),
              ),
              const SizedBox(height: 32),
            ],
            Text('Зарплата за месяц',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _salary,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: '300 000',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 86,
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    items: const ['₸', '₽', r'$', '€']
                        .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _currency = value ?? '₸'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text('Рабочий график',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _ScheduleTile(
              selected: _schedule == WorkSchedule.standard,
              title: 'Обычный · 21 × 8',
              subtitle: 'Быстрый приблизительный расчёт',
              onTap: () => _applySchedule(WorkSchedule.standard),
            ),
            const SizedBox(height: 10),
            _ScheduleTile(
              selected: _schedule == WorkSchedule.previousMonth,
              title: 'Реальный месяц',
              subtitle:
                  '${_monthNames[previous.month - 1]} · ${TimePriceCalculator.weekdaysInMonth(previous)} будних дней',
              onTap: () => _applySchedule(WorkSchedule.previousMonth),
            ),
            const SizedBox(height: 10),
            _ScheduleTile(
              selected: _schedule == WorkSchedule.custom,
              title: 'Свой график',
              subtitle: 'Для смен и нестандартного режима',
              onTap: () => _applySchedule(WorkSchedule.custom),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _days,
                    enabled: _schedule == WorkSchedule.custom,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Рабочих дней',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _hours,
                    enabled: _schedule != WorkSchedule.standard,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Часов в день',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            FilledButton(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: _saving
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Сохранить и продолжить'),
            ),
            const SizedBox(height: 14),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 16, color: Colors.white54),
                SizedBox(width: 6),
                Text(
                  'Данные остаются только на устройстве',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected
            ? Theme.of(context).colorScheme.primaryContainer
            : const Color(0xFF17171F),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(subtitle,
                          style: const TextStyle(color: Colors.white60)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
