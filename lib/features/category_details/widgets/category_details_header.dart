import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/widgets/z_hero_header.dart';

/// Category header on the purple texture: back, title with
/// "148 items · delivered in 12 min", search.
class CategoryDetailsHeader extends StatelessWidget {
  final String title;
  final int itemCount;
  final bool loading;

  const CategoryDetailsHeader({
    super.key,
    required this.title,
    required this.itemCount,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) => ZHeroAppBar(
    title: title,
    // No "0 items" flash while loading.
    subtitle: loading
        ? null
        : '${'itemCount'.plural(itemCount)} · ${'deliveredInEta'.tr()}',
    showBack: true,
    onBack: () => context.pop(),
    actions: [
      IconButton(
        onPressed: () => context.push('/searchScreen'),
        icon: const Icon(Icons.search_rounded),
        tooltip: 'search'.tr(),
      ),
    ],
  );
}
