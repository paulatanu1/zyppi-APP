import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/explore/application/explore_provider.dart';

/// Every category, as tiles matching Home's "Shop by category" grid.
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exploreState = ref.watch(exploreNotifier);
    final t = Theme.of(context).textTheme;

    final Widget body;
    if (exploreState.error != null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('somethingWentWrong'.tr(), style: t.bodyMedium),
            const SizedBox(height: ZSpace.x3),
            SizedBox(
              width: 160,
              child: PrimaryButton(
                buttonTitle: 'retry'.tr(),
                action: () => ref.read(exploreNotifier.notifier).retry(),
              ),
            ),
          ],
        ),
      );
    } else if (!exploreState.loading && exploreState.categories.isEmpty) {
      body = Center(
        child: Text(
          'noCategories'.tr(),
          textAlign: TextAlign.center,
          style: t.bodyMedium,
        ),
      );
    } else {
      body = GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: ZSpace.x4),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: ZSpace.x3,
          mainAxisSpacing: ZSpace.x4,
          mainAxisExtent: ZCategoryTile.height(context),
        ),
        itemCount: exploreState.loading ? 8 : exploreState.categories.length,
        itemBuilder: (context, index) {
          if (exploreState.loading) {
            return const Column(
              children: [
                ZSkeleton(height: ZSize.categoryTile, radius: ZRadius.tile),
                SizedBox(height: ZSpace.x2),
                ZSkeleton(height: 12),
              ],
            );
          }
          final category = exploreState.categories[index];
          return ZCategoryTile(
            label: category.name,
            image: CatalogImage(image: category.image, fit: BoxFit.contain),
            color: AppColors.fromHex(category.colorHex),
            onTap: () => context.push(
              '/categoryDetailsScreen?categoryId=${category.id}',
            ),
          );
        },
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            ZSpace.screen,
            ZSpace.x3,
            ZSpace.screen,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('findProducts'.tr(), style: t.titleLarge),
              const SizedBox(height: ZSpace.x3),
              // Opens the real search screen; nothing is typed here.
              ZSearchBar(
                hint: 'searchStore'.tr(),
                onTap: () => context.push('/searchScreen'),
              ),
              const SizedBox(height: ZSpace.x4),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}
