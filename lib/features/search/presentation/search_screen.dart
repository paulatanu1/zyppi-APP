import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/common_header.dart';
import 'package:zippy/core/common_widgets/item_card.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/common_widgets/text_form_field.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/search/application/search_provider.dart';

class SearchScreen extends ConsumerWidget {
  SearchScreen({super.key});

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              CommonHeader(),
              const SizedBox(height: 12),
              TextformField(
                prefixIcon: true,
                textFormFieldController: searchController,
                labelText: 'searchStoreHint'.tr(),
                onChanged: notifier.search,
              ),
              const SizedBox(height: 12),
              if (state.error != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'somethingWentWrong'.tr(),
                          style: AppTypography.bodyMedium,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 160,
                          child: PrimaryButton(
                            buttonTitle: 'retry'.tr(),
                            action: notifier.retry,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (state.query.isNotEmpty && state.results.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'noProductsFound'.tr(),
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                )
              else if (state.query.isNotEmpty)
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: state.results.length,
                    itemBuilder: (context, index) {
                      final product = state.results[index];
                      final variant = product.variants.isNotEmpty
                          ? product.variants.first
                          : null;

                      return ItemCard(
                        productName: product.name,
                        quantity: variant?.label ?? '',
                        pricePaise: variant?.pricePaise,
                        mrpPaise: variant?.mrpPaise,
                        imagePath: product.image,
                        onClicked: () => context.push(
                          '/productDetailsScreen?productId=${product.id}',
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
