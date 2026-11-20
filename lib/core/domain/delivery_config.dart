import 'package:freezed_annotation/freezed_annotation.dart';

part 'delivery_config.freezed.dart';

/// `config/delivery` (functions/src/orders/delivery_config.ts): the
/// delivery fee, the item total that makes delivery free, the minimum
/// order and the handling fee. Integer paise; 0 means "free" / "no
/// minimum" / "no handling fee". quoteOrder
/// enforces the same rule server-side, so this only drives what the app
/// shows (bill, free-delivery progress bar, checkout button).
@freezed
abstract class DeliveryConfig with _$DeliveryConfig {
  const factory DeliveryConfig({
    @Default(0) int feePaise,
    @Default(0) int freeAbovePaise,
    @Default(0) int minOrderPaise,
    @Default(DeliveryConfig.defaultHandlingFeePaise) int handlingFeePaise,
  }) = _DeliveryConfig;

  const DeliveryConfig._();

  /// Until the admin sets one (same default as DEFAULT_HANDLING_FEE_PAISE).
  static const defaultHandlingFeePaise = 500;

  /// Before the config loads, or if it is missing: free delivery, no
  /// minimum, the default handling fee (the server's behaviour for a
  /// missing doc too).
  static const free = DeliveryConfig();

  /// Delivery fee for [itemTotalPaise].
  int feeFor(int itemTotalPaise) =>
      freeAbovePaise == 0 || itemTotalPaise >= freeAbovePaise ? 0 : feePaise;

  /// Whether a delivery fee can apply at all (else there is no
  /// free-delivery goal to show).
  bool get hasFreeDeliveryGoal => feePaise > 0 && freeAbovePaise > 0;

  /// Paise still to add for free delivery (0 once unlocked).
  int remainingForFree(int itemTotalPaise) => hasFreeDeliveryGoal
      ? (freeAbovePaise - itemTotalPaise).clamp(0, freeAbovePaise)
      : 0;

  /// Paise still to add before the order can be placed (0 once met).
  int remainingForMinimum(int itemTotalPaise) =>
      (minOrderPaise - itemTotalPaise).clamp(0, minOrderPaise);
}
