import 'package:flutter/material.dart';
import '../domain/time_price_calculator.dart';
import 'wallet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.profile,
    required this.onEdit,
    super.key,
  });

  final WorkProfile profile;
  final VoidCallback onEdit;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _price = TextEditingController();
  PurchaseTime? _purchase;
  int _currentView = 0;

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _calculate(_price.text);
    }
  }

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  double? _number(String value) =>
      double.tryParse(value.replaceAll(' ', '').replaceAll(',', '.'));

  void _calculate(String value) {
    final price = _number(value);
    setState(() => _purchase = price == null || price <= 0
        ? null
        : TimePriceCalculator.purchase(price, widget.profile));
  }

  String _money(double value) {
    final rounded = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < rounded.length; i++) {
      if (i > 0 && (rounded.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(rounded[i]);
    }
    return '$buffer ${widget.profile.currencyCode}';
  }

  String _time(PurchaseTime value) {
    final parts = <String>[];
    if (value.fullDays > 0) {
      parts.add('${value.fullDays} дн.');
    }
    if (value.remainingHours > 0) {
      parts.add('${value.remainingHours} ч.');
    }
    if (value.remainingMinutes > 0 || parts.isEmpty) {
      parts.add('${value.remainingMinutes} мин.');
    }
    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final isCalculator = _currentView == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(isCalculator ? 'Часы Жизни' : 'Кошелек',
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer_outlined, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      'Часы Жизни',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calculate_outlined),
              title: const Text('Калькулятор'),
              selected: isCalculator,
              onTap: () {
                setState(() => _currentView = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Кошелек'),
              selected: !isCalculator,
              onTap: () {
                setState(() => _currentView = 1);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.tune_rounded),
              title: const Text('Рабочий профиль'),
              onTap: () {
                Navigator.pop(context);
                widget.onEdit();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: isCalculator
            ? ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
                children: [
                  Text('Твоё рабочее время',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white60,
                          )),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _money(profile.perHour),
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const Text('стоит один час твоей работы',
                              style: TextStyle(color: Colors.white60)),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _Rate(
                                  value: _money(profile.perDay),
                                  label: 'за день',
                                ),
                              ),
                              Expanded(
                                child: _Rate(
                                  value:
                                      '${profile.perMinute.toStringAsFixed(1)} ${profile.currencyCode}',
                                  label: 'за минуту',
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          Text(
                            '${profile.workDays} дней · ${profile.totalHours.toStringAsFixed(profile.totalHours % 1 == 0 ? 0 : 1)} часов в месяц',
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('Сколько времени стоит покупка?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _price,
                    onChanged: _calculate,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Введите цену',
                      prefixIcon: const Icon(Icons.shopping_bag_outlined),
                      suffixText: profile.currencyCode,
                    ),
                  ),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _purchase == null
                        ? _EmptyResult(key: const ValueKey('empty'))
                        : _Result(
                            key: ValueKey(_purchase!.totalHours),
                            time: _time(_purchase!),
                            hours: _purchase!.totalHours,
                            salaryShare: _purchase!.salaryShare,
                            workWeeks: _purchase!.workWeeks,
                          ),
                  ),
                ],
              )
            : WalletScreen(profile: profile),
      ),
    );
  }
}

class _Rate extends StatelessWidget {
  const _Rate({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(color: Colors.white54)),
        ],
      );
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF15151C),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.schedule_rounded, color: Colors.white38),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Введи цену — результат появится сразу',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      );
}

class _Result extends StatelessWidget {
  const _Result({
    required this.time,
    required this.hours,
    required this.salaryShare,
    required this.workWeeks,
    super.key,
  });

  final String time;
  final double hours;
  final double salaryShare;
  final double workWeeks;

  @override
  Widget build(BuildContext context) => Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Эта покупка стоит',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 6),
              Text(
                time,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Text('твоей работы',
                  style: TextStyle(color: Colors.white70)),
              const Divider(height: 30),
              Wrap(
                spacing: 22,
                runSpacing: 12,
                children: [
                  _Fact(
                    value: '${hours.toStringAsFixed(1)} ч.',
                    label: 'всего',
                  ),
                  _Fact(
                    value: '${salaryShare.toStringAsFixed(1)}%',
                    label: 'зарплаты',
                  ),
                  _Fact(
                    value: '${workWeeks.toStringAsFixed(1)}',
                    label: 'раб. недели',
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class _Fact extends StatelessWidget {
  const _Fact({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: Colors.white60)),
        ],
      );
}
