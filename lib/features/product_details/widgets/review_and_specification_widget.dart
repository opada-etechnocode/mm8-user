import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/review/controllers/review_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class ReviewAndSpecificationSectionWidget extends StatelessWidget {
  final double? averageReview;
  final int? reviewsCount;

  const ReviewAndSpecificationSectionWidget({
    super.key,
    this.averageReview,
    this.reviewsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductDetailsController, ReviewController>(
      builder: (context, productDetailsController, reviewController, _) {
        final theme = Theme.of(context);
        final isDark =
            Provider.of<ThemeController>(context, listen: false).darkTheme;
        final isReview = productDetailsController.isReviewSelected;
        final count = reviewController.reviewList != null
            ? reviewController.reviewList!.length
            : (reviewsCount ?? 0);

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeSmall,
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeDefault,
          ),
          child: Container(
            height: 52,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? theme.highlightColor.withValues(alpha: 0.55)
                  : theme.hintColor.withValues(alpha: 0.08),
              border: Border.all(
                color: theme.hintColor.withValues(alpha: isDark ? 0.12 : 0.08),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tabWidth = constraints.maxWidth / 2;

                return Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      alignment: isReview
                          ? AlignmentDirectional.centerEnd
                          : AlignmentDirectional.centerStart,
                      child: Container(
                        width: tabWidth,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: theme.cardColor,
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _SegmentTab(
                            label: getTranslated('specification', context)!,
                            icon: Icons.description_outlined,
                            selected: !isReview,
                            onTap: () => productDetailsController
                                .selectReviewSection(false),
                          ),
                        ),
                        Expanded(
                          child: _SegmentTab(
                            label: getTranslated('reviews', context)!,
                            icon: Icons.star_rate_rounded,
                            selected: isReview,
                            badgeCount: count,
                            onTap: () => productDetailsController
                                .selectReviewSection(true),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final int? badgeCount;

  const _SegmentTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.primaryColor;
    final inactiveColor = theme.hintColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: (selected ? textBold : textMedium).copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: selected ? activeColor : inactiveColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? activeColor.withValues(alpha: 0.12)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: selected ? activeColor : inactiveColor,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (badgeCount != null) ...[
                  const SizedBox(width: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: selected
                          ? activeColor
                          : inactiveColor.withValues(alpha: 0.18),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: textBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: selected ? Colors.white : inactiveColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
