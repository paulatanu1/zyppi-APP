/// A PayU payment the server has opened for the caller's cart: everything
/// CheckoutPro needs to start, priced and keyed server-side.
class PaymentOrder {
  /// PayU's transaction id; also the server's paymentIntents doc id.
  final String txnid;

  /// PayU merchant key (not secret on its own — the salt stays server-side).
  final String key;

  /// Rupee amount as PayU expects it, e.g. `"477.00"`.
  final String amount;
  final String productInfo;
  final String firstName;
  final String email;
  final String phone;

  /// CheckoutPro environment: `"0"` production, `"1"` test.
  final String environment;

  /// The server-computed amount the customer is charged.
  final int amountPaise;

  const PaymentOrder({
    required this.txnid,
    required this.key,
    required this.amount,
    required this.productInfo,
    required this.firstName,
    required this.email,
    required this.phone,
    required this.environment,
    required this.amountPaise,
  });
}
