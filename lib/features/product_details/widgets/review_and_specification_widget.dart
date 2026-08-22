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

  bool _hasReviews(ReviewController reviewController) {
    final listCount = reviewController.reviewList?.length ?? 0;
    final productCount = reviewsCount ?? 0;
    final rating = averageReview ?? 0;
    return listCount > 0 || productCount > 0 || rating > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductDetailsController, ReviewController>(
      builder: (context, productDetailsController, reviewController, _) {
        if (!_hasReviews(reviewController)) {
          if (productDetailsController.isReviewSelected) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              productDetailsController.selectReviewSection(false);
            });
          }
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => productDetailsController.selectReviewSection(false),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeSmall,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                        color: !productDetailsController.isReviewSelected
                            ? (Provider.of<ThemeController>(context, listen: false).darkTheme
                                ? Theme.of(context).hintColor.withValues(alpha: .25)
                                : Theme.of(context).primaryColor.withValues(alpha: .05))
                            : Colors.transparent,
                      ),
                      child: Text(
                        '${getTranslated('specification', context)}',
                        style: textMedium.copyWith(
                          color: Provider.of<ThemeController>(context, listen: false).darkTheme
                              ? Theme.of(context).hintColor
                              : (!productDetailsController.isReviewSelected
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).hintColor),
                        ),
                      ),
                    ),
                    if (!productDetailsController.isReviewSelected)
                      Container(width: 40, height: 2, color: Theme.of(context).primaryColor),
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              InkWell(
                onTap: () => productDetailsController.selectReviewSection(true),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeSmall,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                            color: productDetailsController.isReviewSelected
                                ? (Provider.of<ThemeController>(context, listen: false).darkTheme
                                    ? Theme.of(context).hintColor.withValues(alpha: .25)
                                    : Theme.of(context).primaryColor.withValues(alpha: .05))
                                : Colors.transparent,
                          ),
                          child: Text(
                            '${getTranslated('reviews', context)}',
                            style: textMedium.copyWith(
                              color: Provider.of<ThemeController>(context, listen: false).darkTheme
                                  ? Theme.of(context).hintColor
                                  : (productDetailsController.isReviewSelected
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).hintColor),
                            ),
                          ),
                        ),
                        if (productDetailsController.isReviewSelected)
                          Container(width: 40, height: 2, color: Theme.of(context).primaryColor),
                      ],
                    ),
                    Positioned(
                      top: -10,
                      right: -10,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                              color: Theme.of(context).primaryColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeExtraSmall,
                                horizontal: Dimensions.paddingSizeSmall,
                              ),
                              child: Text(
                                '${reviewController.reviewList != null ? reviewController.reviewList!.length : (reviewsCount ?? 0)}',
                                style: textBold.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
