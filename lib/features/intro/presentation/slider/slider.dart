import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';

/// docs/mockups/Onboarding.dc.html.
class SliderScreen extends StatefulWidget {
  const SliderScreen({super.key});

  @override
  State<SliderScreen> createState() => _SliderScreenState();
}

class _SliderScreenState extends State<SliderScreen> {
  int currentStep = 0;

  final List<String> images = [
    'assets/images/Splash-1.png',
    'assets/images/Splash-2.png',
    'assets/images/Splash-3.png',
    'assets/images/Splash-4.png',
  ];
  late final List<String> titles = [
    'perfectPick'.tr(),
    'pickupProducts'.tr(),
    'doorstepDelivery'.tr(),
    'getYourOrder'.tr(),
  ];
  late final List<String> descriptions = [
    'perfectPickDescription'.tr(),
    'pickupProductsDescription'.tr(),
    'doorstepDeliveryDescription'.tr(),
    'getYourOrderDescription'.tr(),
  ];

  void _next() {
    if (currentStep < titles.length - 1) {
      setState(() => currentStep++);
    } else {
      context.push('/loginScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = currentStep == titles.length - 1;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.huge,
            AppSpacing.xxl,
            AppSpacing.huge,
            AppSpacing.giant,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Zyppi',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/loginScreen'),
                    child: Text(
                      'skip'.tr(),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.onPrimaryMuted,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDark,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Image.asset(
                          images[currentStep],
                          key: ValueKey<int>(currentStep),
                          width: 160,
                          height: 160,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  key: ValueKey<int>(currentStep),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titles[currentStep],
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      descriptions[currentStep],
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.onPrimaryMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.huge),
              Row(
                children: List.generate(titles.length, (index) {
                  final selected = index == currentStep;

                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: selected ? 24 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accent
                            : const Color(0xFFF07BBE),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                height: AppSizes.button,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.ink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.input),
                    ),
                  ),
                  onPressed: _next,
                  child: Text(
                    isLast ? 'getStart'.tr() : 'next'.tr(),
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.ink,
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
