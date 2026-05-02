import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

@immutable
class Transaction {
  const Transaction({
    required this.id,
    required this.label,
    required this.amount,
    required this.when,
    required this.kind,
  });

  final String id;
  final String label;

  /// Amount in cents. Negative for debits, positive for credits.
  final int amount;

  final DateTime when;
  final TransactionKind kind;
}

enum TransactionKind { debit, credit, transfer }

@immutable
class WalletCard {
  const WalletCard({
    required this.label,
    required this.lastFour,
    required this.spent,
    required this.limit,
  });

  final String label;
  final String lastFour;
  final int spent;
  final int limit;

  double get utilization => limit == 0 ? 0 : spent / limit;
}

/// Single source of fake live data the demo binds to. A real app would
/// replace this with a domain layer; the boundary is the same shape
/// (ValueListenable / Stream) that MosaicLiveSource accepts directly.
class WalletData {
  WalletData() {
    _seed();
  }

  final ValueNotifier<int> balance = ValueNotifier<int>(0);
  final ValueNotifier<List<Transaction>> transactions =
      ValueNotifier<List<Transaction>>(const []);
  final ValueNotifier<List<WalletCard>> cards = ValueNotifier<List<WalletCard>>(
    const [],
  );
  final ValueNotifier<int> weeklySpend = ValueNotifier<int>(0);

  Timer? _ticker;
  final Random _rng = Random(42);

  void start() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 5), (_) => _tick());
  }

  void dispose() {
    _ticker?.cancel();
    balance.dispose();
    transactions.dispose();
    cards.dispose();
    weeklySpend.dispose();
  }

  void _seed() {
    final now = DateTime(2026, 5, 2, 14, 30);
    balance.value = 1245000; // KES 12,450.00
    transactions.value = <Transaction>[
      Transaction(
        id: 'tx_001',
        label: 'Java House',
        amount: -45000,
        when: now.subtract(const Duration(hours: 2)),
        kind: TransactionKind.debit,
      ),
      Transaction(
        id: 'tx_002',
        label: 'Salary — Acme Co.',
        amount: 850000,
        when: now.subtract(const Duration(days: 1)),
        kind: TransactionKind.credit,
      ),
      Transaction(
        id: 'tx_003',
        label: 'Uber',
        amount: -28000,
        when: now.subtract(const Duration(days: 1, hours: 6)),
        kind: TransactionKind.debit,
      ),
      Transaction(
        id: 'tx_004',
        label: 'Naivas Supermarket',
        amount: -312000,
        when: now.subtract(const Duration(days: 2)),
        kind: TransactionKind.debit,
      ),
    ];
    cards.value = const <WalletCard>[
      WalletCard(
        label: 'Daily',
        lastFour: '4421',
        spent: 320000,
        limit: 500000,
      ),
      WalletCard(
        label: 'Travel',
        lastFour: '9988',
        spent: 12500,
        limit: 200000,
      ),
    ];
    weeklySpend.value = 487000;
  }

  void _tick() {
    final merchants = <String>[
      'Starbucks',
      'Uber',
      'Java House',
      'Naivas',
      'Bolt',
      'Carrefour',
      'Pizza Inn',
    ];
    final amount = -(2000 + _rng.nextInt(60000));
    final tx = Transaction(
      id: 'tx_${DateTime.now().microsecondsSinceEpoch}',
      label: merchants[_rng.nextInt(merchants.length)],
      amount: amount,
      when: DateTime.now(),
      kind: TransactionKind.debit,
    );
    balance.value = balance.value + amount;
    weeklySpend.value = weeklySpend.value - amount;
    final next = <Transaction>[tx, ...transactions.value];
    transactions.value = next.length > 8 ? next.sublist(0, 8) : next;
  }
}
