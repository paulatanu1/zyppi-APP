import 'package:freezed_annotation/freezed_annotation.dart';

part 'bill_breakdown.freezed.dart';

/// All money fields are int paise (CLAUDE.md).
@freezed
abstract class BillBreakdown with _$BillBreakdown {
  const factory BillBreakdown({
    required int itemTotalPaise,
    required int savingsPaise,
    required int deliveryFeePaise,
    required int handlingFeePaise,
    required int tipPaise,
    required int discountPaise,
    required int totalPaise,
  }) = _BillBreakdown;

  const BillBreakdown._();

  static const zero = BillBreakdown(
    itemTotalPaise: 0,
    savingsPaise: 0,
    deliveryFeePaise: 0,
    handlingFeePaise: 0,
    tipPaise: 0,
    discountPaise: 0,
    totalPaise: 0,
  );
}
