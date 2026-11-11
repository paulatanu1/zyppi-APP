import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/features/search/application/search_provider.dart';
import 'package:zippy/core/data/search_suggestions_provider.dart';
import 'package:zippy/features/search/data/recent_searches.dart';
import 'package:zippy/features/search/widgets/product_list_row.dart';

/// docs/screens/light/08-search.png. Before typing: recent searches (this
/// device) and "Try searching" suggestions. Left out: trending tiles and
/// "See all N results" (every result is already listed).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  // Owned by the State so it survives rebuilds and is disposed; starts
  // from the provider's query so the box and the results always agree.
  late final searchController = TextEditingController(
    text: ref.read(searchProvider).query,
  );

  late final _recent = ref.read(recentSearchesProvider.notifier);

  /// Latest query that found something: saved as a recent search when the
  /// user leaves (or submits), so half-typed prefixes aren't remembered.
  String? _lastFound;

  @override
  void dispose() {
    final found = _lastFound;
    if (found != null) _recent.add(found);
    searchController.dispose();
    super.dispose();
  }

  void _useSuggestion(String query) {
    searchController
      ..text = query
      ..selection = TextSelection.collapsed(offset: query.length);
    ref.read(searchProvider.notifier).search(query);
    FocusScope.of(context).unfocus();
  }

  void _clear() {
    searchController.clear();
    ref.read(searchProvider.notifier).search('');
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final state = ref.watch(searchProvider);
    ref.listen(searchProvider, (_, next) {
      if (!next.loading && next.results.isNotEmpty) {
        _lastFound = next.query.trim();
      }
    });
    final notifier = ref.read(searchProvider.notifier);
    // A product with no variant can't be shown or added; dropping it here
    // (not in the list builder) keeps the dividers even.
    final results = state.results.where((p) => p.variants.isNotEmpty).toList();

    final Widget body;
    if (state.error != null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('somethingWentWrong'.tr(), style: t.bodyMedium),
            const SizedBox(height: ZSpace.x3),
            FilledButton(onPressed: notifier.retry, child: Text('retry'.tr())),
          ],
        ),
      );
    } else if (state.loading && results.isEmpty) {
      body = ListView(
        padding: const EdgeInsets.all(ZSpace.screen),
        children: [
          for (var i = 0; i < 5; i++) ...[
            const Row(
              children: [
                ZSkeleton(
                  width: ZSize.input,
                  height: ZSize.input,
                  radius: ZRadius.tile,
                ),
                SizedBox(width: ZSpace.x3),
                Expanded(child: ZSkeleton(height: 16)),
                SizedBox(width: ZSpace.x6),
                ZSkeleton(
                  width: 70,
                  height: ZSize.addButton,
                  radius: ZRadius.control,
                ),
              ],
            ),
            const SizedBox(height: ZSpace.x6),
          ],
        ],
      );
    } else if (state.query.trim().isEmpty) {
      body = _IdleSuggestions(onPick: _useSuggestion);
    } else if (results.isEmpty) {
      body = _Message(
        icon: Icons.search_off_rounded,
        text: 'noProductsFound'.tr(),
      );
    } else {
      body = ListView.separated(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          ZSpace.screen,
          ZSpace.x4,
          ZSpace.screen,
          ZSpace.x6,
        ),
        itemCount: results.length + 1,
        separatorBuilder: (context, index) => index == 0
            ? const SizedBox.shrink()
            : Divider(height: 1, color: z.line),
        itemBuilder: (context, index) => index == 0
            ? Text(
                'resultsFor'.tr(args: [state.query.trim()]).toUpperCase(),
                style: t.labelSmall!.copyWith(
                  color: z.ink3,
                  letterSpacing: 1.1,
                ),
              )
            : ProductListRow(product: results[index - 1], query: state.query),
      );
    }

    return Scaffold(
      backgroundColor: z.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(
                ZSpace.x1,
                ZSpace.x2,
                ZSpace.screen,
                ZSpace.x3,
              ),
              decoration: BoxDecoration(
                color: z.surface,
                border: Border(bottom: BorderSide(color: z.line)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ),
                    tooltip: 'back'.tr(),
                  ),
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: searchController,
                      builder: (context, value, _) => TextField(
                        controller: searchController,
                        autofocus: value.text.isEmpty,
                        onChanged: notifier.search,
                        onSubmitted: _recent.add,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'searchStoreHint'.tr(),
                          isDense: true,
                          prefixIcon: Icon(Icons.search_rounded, color: z.ink3),
                          suffixIcon: value.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: _clear,
                                  tooltip: 'clearSearch'.tr(),
                                  icon: Icon(
                                    Icons.cancel_outlined,
                                    color: z.ink3,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ZSpace.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: z.ink3),
            const SizedBox(height: ZSpace.x3),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!
                  .copyWith(color: z.ink2),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown before typing: recent searches (with Clear) and "Try searching"
/// chips; the plain hint when there are neither.
class _IdleSuggestions extends ConsumerWidget {
  const _IdleSuggestions({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final recent = ref.watch(recentSearchesProvider);
    final suggestions = ref.watch(searchSuggestionsProvider).value ?? const [];

    if (recent.isEmpty && suggestions.isEmpty) {
      return _Message(icon: Icons.search_rounded, text: 'searchIdleHint'.tr());
    }

    Widget heading(String text, {Widget? trailing}) => Padding(
      padding: const EdgeInsets.only(bottom: ZSpace.x2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: t.labelSmall!.copyWith(color: z.ink3, letterSpacing: 1.1),
            ),
          ),
          ?trailing,
        ],
      ),
    );

    Widget chips(List<String> items, IconData icon) => Wrap(
      spacing: ZSpace.x2,
      runSpacing: ZSpace.x2,
      children: [
        for (final (i, item) in items.indexed)
          ZEntrance(
            index: i,
            child: ZChip(label: item, icon: icon, onTap: () => onPick(item)),
          ),
      ],
    );

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(ZSpace.screen),
      children: [
        if (recent.isNotEmpty) ...[
          heading(
            'recentSearches'.tr(),
            trailing: TextButton(
              onPressed: ref.read(recentSearchesProvider.notifier).clear,
              child: Text('clearRecentSearches'.tr()),
            ),
          ),
          chips(recent, Icons.history_rounded),
          const SizedBox(height: ZSpace.x6),
        ],
        if (suggestions.isNotEmpty) ...[
          heading('trySearching'.tr()),
          chips(suggestions, Icons.trending_up_rounded),
        ],
      ],
    );
  }
}
