import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/core/payments/data/pending_payment_store.dart';

void main() {
  final start = DateTime(2026, 11, 9, 14);

  Future<PendingPaymentStore> storeWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return PendingPaymentStore(
      await SharedPreferences.getInstance(),
      now: () => start,
    );
  }

  test('is fresh until 15 minutes after it was saved', () async {
    final store = await storeWith({});
    await store.save('zTXN');

    final pending = store.read()!;
    expect(pending.txnid, 'zTXN');
    expect(pending.savedAt, start);
    expect(pending.isStale(start.add(const Duration(minutes: 14))), isFalse);
    expect(pending.isStale(start.add(const Duration(minutes: 15))), isTrue);
  });

  test('treats a txnid saved by an older version as stale', () async {
    final store = await storeWith({'pendingPayUTxnId': 'zOLD'});

    final pending = store.read()!;
    expect(pending.txnid, 'zOLD');
    expect(pending.savedAt, isNull);
    expect(pending.isStale(start), isTrue);
  });

  test('clear forgets the payment', () async {
    final store = await storeWith({});
    await store.save('zTXN');
    await store.clear();

    expect(store.read(), isNull);
  });
}
