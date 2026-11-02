class PaymentOrder {
  final String merchantOrderId;
  final String orderId;
  final String token;
  final String merchantId;

  /// The server-computed amount the customer is charged.
  final int amountPaise;

  const PaymentOrder({
    required this.merchantOrderId,
    required this.orderId,
    required this.token,
    required this.merchantId,
    required this.amountPaise,
  });
}
