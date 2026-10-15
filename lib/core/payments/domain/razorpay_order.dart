class RazorpayOrder {
  final String orderId;
  final int amountPaise;
  final String currency;
  final String keyId;

  const RazorpayOrder({
    required this.orderId,
    required this.amountPaise,
    required this.currency,
    required this.keyId,
  });
}
