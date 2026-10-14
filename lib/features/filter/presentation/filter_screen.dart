import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/filter/widgets/filter_header.dart';
import 'package:zippy/features/filter/widgets/filter_item.dart';

/// Filter by category (real data). Brand faceting is skipped — there's
/// no brand field in the catalog data model yet.
class FilterScreen extends ConsumerStatefulWidget {
  const FilterScreen({super.key});

  @override
  ConsumerState<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends ConsumerState<FilterScreen> {
  final Set<String> _selectedCategoryIds = {};

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(
      FutureProvider(
        (ref) => ref.read(catalogRepositoryProvider).fetchCategories(),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: FilterHeader(onCrossIconClicked: () => context.pop()),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.backgroundAlt,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.sheetTop),
                    topRight: Radius.circular(AppRadius.sheetTop),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('categories'.tr(), style: AppTypography.titleMedium),
                      const SizedBox(height: AppSpacing.lg),
                      Expanded(
                        child: categoriesAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (error, stackTrace) => Text(
                            'somethingWentWrong'.tr(),
                            style: AppTypography.bodyMedium,
                          ),
                          data: (categories) => ListView.builder(
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];

                              return FilterItem(
                                label: category.name,
                                value: _selectedCategoryIds.contains(
                                  category.id,
                                ),
                                onCheckBoxChanged: (checked) => setState(() {
                                  if (checked == true) {
                                    _selectedCategoryIds.add(category.id);
                                  } else {
                                    _selectedCategoryIds.remove(category.id);
                                  }
                                }),
                              );
                            },
                          ),
                        ),
                      ),
                      PrimaryButton(
                        buttonTitle: 'applyFilter'.tr(),
                        action: () => context.pop(_selectedCategoryIds),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
