import 'package:flutter/material.dart';
import '../domain/time_price_calculator.dart';

class MiniCalculator extends StatefulWidget {
  const MiniCalculator({required this.profile, super.key});

  final WorkProfile profile;

  @override
  State<MiniCalculator> createState() => _MiniCalculatorState();
}

class _MiniCalculatorState extends State<MiniCalculator> {
  String _input = '';
  PurchaseTime? _result;

  void _onKeyTap(String key) {
    setState(() {
      if (key == 'back') {
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
        }
      } else if (key == '.') {
        if (!_input.contains('.')) {
          _input += '.';
        }
      } else {
        if (_input.length < 12) {
          _input += key;
        }
      }

      final price = double.tryParse(_input);
      _result = price == null || price <= 0
          ? null
          : TimePriceCalculator.purchase(price, widget.profile);
    });
  }

  String _formatTime(PurchaseTime value) {
    final parts = <String>[];
    if (value.fullDays > 0) parts.add('${value.fullDays}д');
    if (value.remainingHours > 0) parts.add('${value.remainingHours}ч');
    if (value.remainingMinutes > 0 || parts.isEmpty) {
      parts.add('${value.remainingMinutes}м');
    }
    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.black54),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Material(
                color: const Color(0xFF17171F),
                borderRadius: BorderRadius.circular(32),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _input.isEmpty ? '0' : _input,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  widget.profile.currencyCode,
                                  style: const TextStyle(color: Colors.white38),
                                ),
                              ],
                            ),
                          ),
                          if (_result != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                _formatTime(_result!),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _CustomKeyboard(onTap: _onKeyTap),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomKeyboard extends StatelessWidget {
  const _CustomKeyboard({required this.onTap});
  final Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', 'back'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: row.map((key) {
              final isBack = key == 'back';
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Material(
                    color: isBack ? Colors.white10 : const Color(0xFF23232D),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => onTap(key),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 60,
                        alignment: Alignment.center,
                        child: isBack
                            ? const Icon(Icons.backspace_outlined, color: Colors.white70)
                            : Text(
                                key,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
