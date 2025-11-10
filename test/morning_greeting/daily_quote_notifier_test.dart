import 'dart:math';

import 'package:adhd_0_1/src/features/morning_greeting/domain/daily_quote_notifier.dart';
import 'package:adhd_0_1/src/features/morning_greeting/domain/tip_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'picks unseen quotes before repeating and records history order',
    () async {
      final notifier = DailyQuoteNotifier.instance;
      final prefs = await SharedPreferences.getInstance();

      final first = await notifier.debugPickQuote(random: _FixedRandom([0]));
      expect(first, _normalizedQuote(0));

      expect(prefs.getStringList('daily_quote_history_v1'), ['0']);

      final second = await notifier.debugPickQuote(random: _FixedRandom([0]));
      expect(second, _normalizedQuote(1));

      expect(prefs.getStringList('daily_quote_history_v1'), ['1', '0']);
    },
  );

  test('falls back to recent window once all quotes are seen', () async {
    final notifier = DailyQuoteNotifier.instance;
    final total = tipOfTheDay.length;
    SharedPreferences.setMockInitialValues({
      'daily_quote_history_v1': List<String>.generate(
        total,
        (index) => (total - 1 - index).toString(),
      ),
    });
    final prefs = await SharedPreferences.getInstance();

    final quote = await notifier.debugPickQuote(random: _FixedRandom([0]));
    expect(quote, _normalizedQuote(0));

    final history = prefs.getStringList('daily_quote_history_v1');
    expect(history, isNotNull);
    expect(history!.first, '0');
    final expectedLength = total > 100 ? 100 : total;
    expect(history.length, expectedLength);
    if (expectedLength > 1) {
      expect(history[1], (total - 1).toString());
    }
  });
}

String _normalizedQuote(int index) =>
    tipOfTheDay[index].replaceAll('"', '').trim();

class _FixedRandom implements Random {
  _FixedRandom(List<int> sequence)
    : _values = List<int>.from(sequence),
      _index = 0;

  final List<int> _values;
  int _index;

  @override
  int nextInt(int max) {
    if (_index >= _values.length) {
      return 0;
    }
    final value = _values[_index++];
    if (value >= max) {
      throw StateError('Requested $value but max is $max.');
    }
    return value;
  }

  @override
  double nextDouble() =>
      throw UnsupportedError('nextDouble is not used in deterministic tests');

  @override
  bool nextBool() =>
      throw UnsupportedError('nextBool is not used in deterministic tests');
}
