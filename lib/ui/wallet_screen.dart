import 'package:flutter/material.dart';
import '../domain/time_price_calculator.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({required this.profile, super.key});

  final WorkProfile profile;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            'Кошелек',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Здесь будет история ваших трат и доходов',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Скоро: ручное добавление траты')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Добавить операцию'),
          ),
        ],
      ),
    );
  }
}
