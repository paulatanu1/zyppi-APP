import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

const _heroImages = [
  'assets/images/Splash-1.png',
  'assets/images/Splash-2.png',
  'assets/images/Splash-3.png',
  'assets/images/Splash-4.png',
];

/// Based on docs/mockups (v2) Onboarding.dc.html, extended to swipe through
/// `_heroImages`: logo + Skip, a swipeable hero illustration with floating
/// info chips, a headline + subtext, a step indicator bound to the current
/// page, "Get started" and a "Log in" link.
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
    return Scaffold(
      backgroundColor: context.z.bg,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset('assets/icons/appLogo.png', height: 34),
                          TextButton(
                            onPressed: () => context.push('/loginScreen'),
                            child: Text(
                              'skip'.tr(),
                              style: Theme.of(context).textTheme.labelLarge!
                                  .copyWith(color: context.z.ink2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: ZSpace.x3),
                      SizedBox(
                        // About half the screen, as in 01-onboarding.png.
                        height: (constraints.maxHeight * .5).clamp(
                          220.0,
                          440.0,
                        ),
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _heroImages.length,
                          onPageChanged: (index) =>
                              setState(() => _currentPage = index),
                          itemBuilder: (context, index) => Stack(
                            children: [
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: context.z.blueSoft,
                                    borderRadius: ZRadius.all(ZRadius.illo),
                                  ),
                                  child: Center(
                                    child: ZLoop(
                                      kind: ZLoopKind.bob,
                                      child: Image.asset(
                                        _heroImages[index],
                                        width: 260,
                                        fit: BoxFit.contain,
                                        excludeFromSemantics: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 14,
                                top: 20,
                                child: _FloatChip(
                                  icon: Icons.bolt_rounded,
                                  iconColor: context.z.brandText,
                                  label: 'deliveryChipLabel'.tr(),
                                ),
                              ),
                              Positioned(
                                right: 14,
                                bottom: 24,
                                child: _FloatChip(
                                  icon: Icons.check_rounded,
                                  iconColor: context.z.ok,
                                  iconBackground: context.z.okSoft,
                                  label: 'qualityChipLabel'.tr(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: ZSpace.x6),
                      // Text.rich follows the system text size (RichText doesn't);
                      // the 31 pt headline stops growing at 1.3× so the page fits.
                      MediaQuery.withClampedTextScaling(
                        maxScaleFactor: 1.3,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${'onboardingHeadlinePrefix'.tr()} ',
                              ),
                              TextSpan(
                                text: 'onboardingHeadlineHighlight'.tr(),
                                style: TextStyle(color: context.z.brandText),
                              ),
                            ],
                          ),
                          style: Theme.of(context).textTheme.displaySmall!
                              .copyWith(color: context.z.ink),
                        ),
                      ),
                      const SizedBox(height: ZSpace.x2),
                      Text(
                        'onboardingSubtext'.tr(),
                        style: Theme.of(context).textTheme.bodyLarge!
                            .copyWith(color: context.z.ink2),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: ZSpace.x6),
                      Row(
                        children: [
                          for (var i = 0; i < _heroImages.length; i++) ...[
                            if (i > 0) const SizedBox(width: ZSpace.x1),
                            Container(
                              width: i == _currentPage ? 26 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: i == _currentPage
                                    ? context.z.brand
                                    : context.z.line2,
                                borderRadius: BorderRadius.circular(
                                  ZRadius.chip,
                                ),
                              ),
                            ),
                          ],
                        ],
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
                              style: Theme.of(context).textTheme.labelLarge!
                                  .copyWith(color: context.z.ink2),
                              children: [
                                TextSpan(
                                  text: 'login'.tr(),
                                  style: TextStyle(color: context.z.brandText),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _FloatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color? iconBackground;
  final String label;

  const _FloatChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ZSpace.x3,
        vertical: ZSpace.x2,
      ),
      decoration: BoxDecoration(
        color: context.z.surface,
        borderRadius: BorderRadius.circular(ZRadius.input),
        boxShadow: [
          BoxShadow(
            color: context.z.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconBackground == null)
            Icon(icon, size: 18, color: iconColor)
          else
            Container(
              padding: const EdgeInsets.all(ZSpace.x1),
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: iconColor),
            ),
          const SizedBox(width: ZSpace.x1),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge!
                .copyWith(color: context.z.ink),
          ),
        ],
      ),
    );
  }
}
