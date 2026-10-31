import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';

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
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.xxl,
            AppSpacing.xxl,
            AppSpacing.huge,
          ),
          child: Column(
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
                      style: AppTypography.label.copyWith(
                        color: context.colors.muted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),
              Expanded(
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
                            color: context.colors.blueSoft,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Center(
                            child: Image.asset(
                              _heroImages[index],
                              width: 260,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        top: 20,
                        child: _FloatChip(
                          icon: Icons.bolt,
                          iconColor: context.colors.accent,
                          label: 'deliveryChipLabel'.tr(),
                        ),
                      ),
                      Positioned(
                        right: 14,
                        bottom: 24,
                        child: _FloatChip(
                          icon: Icons.check_circle,
                          iconColor: context.colors.green,
                          label: 'qualityChipLabel'.tr(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.huge),
              RichText(
                text: TextSpan(
                  style: AppTypography.display.copyWith(
                    color: context.colors.ink,
                  ),
                  children: [
                    TextSpan(text: '${'onboardingHeadlinePrefix'.tr()} '),
                    TextSpan(
                      text: 'onboardingHeadlineHighlight'.tr(),
                      style: TextStyle(color: context.colors.primaryText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'onboardingSubtext'.tr(),
                style: AppTypography.body.copyWith(color: context.colors.muted),
              ),
              const Spacer(),
              Row(
                children: [
                  for (var i = 0; i < _heroImages.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.xs),
                    Container(
                      width: i == _currentPage ? 26 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _currentPage
                            ? context.colors.primary
                            : context.colors.lineAlt,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                height: AppSizes.button,
                child: ElevatedButton(
                  onPressed: () => context.push('/loginScreen'),
                  child: Text('getStart'.tr()),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/loginScreen'),
                  child: Text.rich(
                    TextSpan(
                      text: '${'alreadyHaveAccount'.tr()} ',
                      style: AppTypography.label.copyWith(
                        color: context.colors.muted,
                      ),
                      children: [
                        TextSpan(
                          text: 'login'.tr(),
                          style: TextStyle(color: context.colors.primaryText),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _FloatChip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.input),
        boxShadow: [BoxShadow(color: context.colors.shadow, blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.label.copyWith(color: context.colors.ink),
          ),
        ],
      ),
    );
  }
}
