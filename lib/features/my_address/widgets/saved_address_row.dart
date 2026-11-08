import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/domain/address.dart';
import 'package:zippy/core/utils/address_label.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// docs/mockups/Location.dc.html's `.saved` row.
class SavedAddressRow extends StatelessWidget {
  final Address address;

  /// e.g. My Address's edit/delete menu.
  final Widget? trailing;

  const SavedAddressRow({super.key, required this.address, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ZSpace.x2),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.z.brandSoft,
              borderRadius: BorderRadius.circular(ZRadius.input),
            ),
            child: Icon(
              address.label.toLowerCase() == 'work'
                  ? Icons.work_outline
                  : Icons.home_outlined,
              color: context.z.brand,
            ),
          ),
          const SizedBox(width: ZSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      addressLabelText(address.label),
                      style: Theme.of(context).textTheme.bodyMedium!
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: ZSpace.x2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ZSpace.x2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.z.brandSoft,
                          borderRadius: BorderRadius.circular(ZRadius.input),
                        ),
                        child: Text(
                          'defaultAddress'.tr(),
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: context.z.brand,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  [
                    address.line1,
                    address.area,
                  ].where((s) => s.isNotEmpty).join(', '),
                  style: Theme.of(context).textTheme.bodySmall!
                      .copyWith(color: context.z.ink2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
