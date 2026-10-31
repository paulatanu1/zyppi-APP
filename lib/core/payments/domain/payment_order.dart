class PaymentOrder {
  final String merchantOrderId;
  final String orderId;
  final String token;
  final String merchantId;

  const PaymentOrder({
    required this.merchantOrderId,
    required this.orderId,
    required this.token,
    required this.merchantId,
  });
}
