import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// One onboarding step: illustration, headline (prefix + brand-coloured
/// highlight), subtext and two floating chips. All strings are keys.
class _Step {
  const _Step({
    required this.image,
    required this.headlinePrefix,
    required this.headlineHighlight,
    required this.subtext,
    required this.topChip,
    required this.bottomChip,
  });

  final String image;
  final String headlinePrefix, headlineHighlight, subtext;
  final _ChipData topChip, bottomChip;
}

class _ChipData {
  const _ChipData(this.icon, this.label, {this.success = false});
  final IconData icon;
  final String label;

  /// Green tick-in-a-circle style (as "Fresh, quality checked" in the PNG).
  final bool success;
}

const _steps = [
  _Step(
    image: 'assets/images/Splash-1.png',
    headlinePrefix: 'onboardingHeadlinePrefix',
    headlineHighlight: 'onboardingHeadlineHighlight',
    subtext: 'onboardingSubtext',
    topChip: _ChipData(Icons.bolt_rounded, 'deliveryChipLabel'),
    bottomChip: _ChipData(
      Icons.check_rounded,
      'qualityChipLabel',
      success: true,
    ),
  ),
  _Step(
    image: 'assets/images/Splash-2.png',
    headlinePrefix: 'onboarding2HeadlinePrefix',
    headlineHighlight: 'onboarding2HeadlineHighlight',
    subtext: 'onboarding2Subtext',
    topChip: _ChipData(Icons.route_rounded, 'onboarding2Chip1'),
    bottomChip: _ChipData(
      Icons.support_agent_rounded,
      'onboarding2Chip2',
      success: true,
    ),
  ),
  _Step(
    image: 'assets/images/Splash-3.png',
    headlinePrefix: 'onboarding3HeadlinePrefix',
    headlineHighlight: 'onboarding3HeadlineHighlight',
    subtext: 'onboarding3Subtext',
    topChip: _ChipData(Icons.storefront_rounded, 'onboarding3Chip1'),
    bottomChip: _ChipData(Icons.payments_rounded, 'payCod', success: true),
  ),
];

/// docs/screens/light/01-onboarding.png, as a three-step carousel: logo +
/// Skip, a swipeable hero (the illustration and its chips move at different
/// speeds for depth), a headline + subtext that cross-fade per step, an
/// animated step indicator, "Get started" and a "Log in" link.
class SliderScreen extends StatefulWidget {
  const SliderScreen({super.key});

  @override
  State<SliderScreen> createState() => _SliderScreenState();
}

class _SliderScreenState extends State<SliderScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final text = Theme.of(context).textTheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final step = _steps[_currentPage];

    return Scaffold(
      backgroundColor: z.bg,
      body: SafeArea(
        // Fills the screen normally; scrolls when large text doesn't fit.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              ZSpace.x4,
              ZSpace.x4,
              ZSpace.x4,
              ZSpace.x6,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - ZSpace.x4 - ZSpace.x6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ZEntrance(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const _Logo(),
                            TextButton(
                              onPressed: () => context.push('/loginScreen'),
                              child: Text(
                                'skip'.tr(),
                                style: text.labelLarge!.copyWith(color: z.ink2),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: ZSpace.x3),
                      ZEntrance(
                        index: 1,
                        child: SizedBox(
                          // About half the screen, as in 01-onboarding.png.
                          height: (constraints.maxHeight * .5).clamp(
                            220.0,
                            440.0,
                          ),
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _steps.length,
                            onPageChanged: (index) =>
                                setState(() => _currentPage = index),
                            itemBuilder: (context, index) => _Hero(
                              step: _steps[index],
                              index: index,
                              controller: _pageController,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: ZSpace.x6),
                      ZEntrance(
                        index: 2,
                        child: AnimatedSwitcher(
                          duration: reduceMotion ? Duration.zero : ZMotion.ui,
                          switchInCurve: ZMotion.standard,
                          switchOutCurve: ZMotion.standard,
                          layoutBuilder: (current, previous) => Stack(
                            alignment: Alignment.topLeft,
                            children: [...previous, ?current],
                          ),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween(
                                    begin: const Offset(0, .08),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                          child: Column(
                            key: ValueKey(_currentPage),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text.rich follows the system text size
                              // (RichText doesn't); the 31 pt headline stops
                              // growing at 1.3× so the page fits.
                              MediaQuery.withClampedTextScaling(
                                maxScaleFactor: 1.3,
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${step.headlinePrefix.tr()} ',
                                      ),
                                      TextSpan(
                                        text: step.headlineHighlight.tr(),
                                        style: TextStyle(color: z.brandText),
                                      ),
                                    ],
                                  ),
                                  style: text.displaySmall!.copyWith(
                                    color: z.ink,
                                  ),
                                ),
                              ),
                              const SizedBox(height: ZSpace.x2),
                              Text(
                                step.subtext.tr(),
                                style: text.bodyLarge!.copyWith(color: z.ink2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  ZEntrance(
                    index: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: ZSpace.x6),
                        Semantics(
                          label: '${_currentPage + 1} / ${_steps.length}',
                          child: Row(
                            children: [
                              for (var i = 0; i < _steps.length; i++) ...[
                                if (i > 0) const SizedBox(width: ZSpace.x1),
                                AnimatedContainer(
                                  duration: reduceMotion
                                      ? Duration.zero
                                      : ZMotion.ui,
                                  curve: ZMotion.emphasized,
                                  width: i == _currentPage ? 26 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: i == _currentPage
                                        ? z.brand
                                        : z.line2,
                                    borderRadius: ZRadius.all(ZRadius.chip),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: ZSpace.x4),
                        SizedBox(
                          width: double.infinity,
                          height: ZSize.button,
                          child: ElevatedButton(
                            onPressed: () => context.push('/loginScreen'),
                            child: Text('getStart'.tr()),
                          ),
                        ),
                        const SizedBox(height: ZSpace.x2),
                        Center(
                          child: TextButton(
                            onPressed: () => context.push('/loginScreen'),
                            child: Text.rich(
                              TextSpan(
                                text: '${'alreadyHaveAccount'.tr()} ',
                                style: text.labelLarge!.copyWith(color: z.ink2),
                                children: [
                                  TextSpan(
                                    text: 'login'.tr(),
                                    style: TextStyle(color: z.brandText),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The Z mark + "Zyppi" wordmark (the onboarding header).
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Zyppi',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/brand/zyppi_mark.png', height: 28),
          const SizedBox(width: ZSpace.x2),
          Text(
            'Zyppi',
            style: Theme.of(context).textTheme.titleLarge!
                .copyWith(color: context.z.ink),
          ),
        ],
      ),
    );
  }
}

/// One page of the hero. While swiping, the illustration drifts slower than
/// the page and the chips faster, so the card reads as layered. Driven by
/// the user's finger, so it stays on with reduced motion.
class _Hero extends StatelessWidget {
  const _Hero({
    required this.step,
    required this.index,
    required this.controller,
  });

  final _Step step;
  final int index;
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final page = controller.hasClients && controller.position.haveDimensions
            ? controller.page ?? index.toDouble()
            : index.toDouble();
        // -1 … 1: how far this page is from the centre.
        final delta = (page - index).clamp(-1.0, 1.0);
        final chipScale = 1 - .12 * delta.abs();

        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: z.blueSoft,
                  borderRadius: ZRadius.all(ZRadius.illo),
                ),
                clipBehavior: Clip.antiAlias,
                child: Transform.translate(
                  offset: Offset(delta * 90, 0),
                  child: Center(
                    child: ZLoop(
                      kind: ZLoopKind.bob,
                      child: Image.asset(
                        step.image,
                        width: 260,
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              top: 20,
              child: Transform.translate(
                offset: Offset(delta * -60, 0),
                child: Transform.scale(
                  scale: chipScale,
                  child: _FloatChip(data: step.topChip),
                ),
              ),
            ),
            Positioned(
              right: 14,
              bottom: 24,
              child: Transform.translate(
                offset: Offset(delta * -110, 0),
                child: Transform.scale(
                  scale: chipScale,
                  child: _FloatChip(data: step.bottomChip),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FloatChip extends StatelessWidget {
  const _FloatChip({required this.data});

  final _ChipData data;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ZSpace.x3,
        vertical: ZSpace.x2,
      ),
      decoration: BoxDecoration(
        color: z.surface,
        borderRadius: ZRadius.all(ZRadius.input),
        boxShadow: [
          BoxShadow(
            color: z.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (data.success)
            Container(
              padding: const EdgeInsets.all(ZSpace.x1),
              decoration: BoxDecoration(
                color: z.okSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(data.icon, size: 14, color: z.ok),
            )
          else
            Icon(data.icon, size: 18, color: z.brandText),
          const SizedBox(width: ZSpace.x1),
          Text(
            data.label.tr(),
            style: Theme.of(context).textTheme.labelLarge!
                .copyWith(color: z.ink),
          ),
        ],
      ),
    );
  }
}
