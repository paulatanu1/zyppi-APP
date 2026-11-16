import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/marketplace/domain/offer.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_commerce.dart';

/// Every seller of this pack size where the customer shops, in the order
/// the marketplace ranks them (price, ratings, reliability, stock). The
/// customer picks who to buy from.
Future<void> showSellersSheet(
  BuildContext context, {
  required List<Offer> offers,
  required String? selectedId,
  required ValueChanged<Offer> onPick,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: ZRadius.sheetTop),
    builder: (sheetContext) => SellersSheet(
      offers: offers,
      selectedId: selectedId,
      onPick: (o) {
        Navigator.pop(sheetContext);
        onPick(o);
      },
    ),
  );
}

class SellersSheet extends StatelessWidget {
  const SellersSheet({
    super.key,
    required this.offers,
    required this.selectedId,
    required this.onPick,
  });

  final List<Offer> offers;
  final String? selectedId;
  final ValueChanged<Offer> onPick;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ZSpace.screen,
                ZSpace.x5,
                ZSpace.screen,
                ZSpace.x1,
              ),
              child: Text('chooseSeller'.tr(), style: t.titleLarge),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ZSpace.screen),
              child: Text('sellersRankedBy'.tr(), style: t.bodySmall),
            ),
            const SizedBox(height: ZSpace.x3),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(
                  ZSpace.screen,
                  0,
                  ZSpace.screen,
                  ZSpace.x4,
                ),
                itemCount: offers.length,
                separatorBuilder: (_, _) => const SizedBox(height: ZSpace.x2),
                itemBuilder: (context, i) {
                  final o = offers[i];
                  final selected = o.id == selectedId;
                  final off = o.mrpPaise > o.pricePaise
                      ? (((o.mrpPaise - o.pricePaise) * 100) / o.mrpPaise)
                            .round()
                      : null;
                  return Semantics(
                    selected: selected,
                    button: true,
                    child: Material(
                      color: selected ? z.brandSoft : z.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: ZRadius.all(ZRadius.tile),
                        side: BorderSide(
                          color: selected ? z.brand : z.line,
                          width: 1.5,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: ZRadius.all(ZRadius.tile),
                        onTap: o.inStock ? () => onPick(o) : null,
                        child: Padding(
                          padding: const EdgeInsets.all(ZSpace.x3),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: ZSpace.x2,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          o.isZyppi ? 'Zyppi' : o.sellerName,
                                          style: t.labelLarge,
                                        ),
                                        if (i == 0 && o.inStock)
                                          _Tag(
                                            'bestMatch'.tr(),
                                            color: z.brandText,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      o.ratingCount > 0
                                          ? 'sellerRating'.tr(
                                              args: [
                                                o.sellerRating.toStringAsFixed(
                                                  1,
                                                ),
                                                '${o.ratingCount}',
                                              ],
                                            )
                                          : 'newSeller'.tr(),
                                      style: t.bodySmall,
                                    ),
                                    if (!o.inStock)
                                      Text(
                                        'outOfStock'.tr(),
                                        style: t.bodySmall!.copyWith(
                                          color: z.danger,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    rupees(o.pricePaise),
                                    style: t.titleMedium,
                                  ),
                                  if (off != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(rupees(o.mrpPaise), style: t.mrp),
                                        const SizedBox(width: ZSpace.x1),
                                        ZOffBadge(off),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(width: ZSpace.x2),
                              Icon(
                                selected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                color: selected ? z.brand : z.ink3,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, {required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ZSpace.x2, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: ZRadius.all(ZRadius.badge),
      ),
      child: Text(label, style: t.labelSmall!.copyWith(color: color)),
    );
  }
}
