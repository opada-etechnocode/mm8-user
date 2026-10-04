import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/rating_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/review/controllers/review_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/review/widgets/product_write_review_sheet.dart';
import 'package:flutter_sixvalley_ecommerce/features/review/widgets/review_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class ReviewSection extends StatelessWidget {
  final ProductDetailsController details;
  const ReviewSection({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark =
        Provider.of<ThemeController>(context, listen: false).darkTheme;
    final product = details.productDetailsModel;
    final average =
        double.tryParse(product?.averageReview ?? '0') ?? 0;

    final profile = Provider.of<ProfileController>(context, listen: false);
    final isLoggedIn =
        Provider.of<AuthController>(context, listen: false).isLoggedIn();
    final userId = profile.userInfoModel?.id;

    return Consumer<ReviewController>(
      builder: (context, reviewController, _) {
        final reviews = reviewController.reviewList;
        final reviewCount = reviews?.length ?? product?.reviewsCount ?? 0;
        final hasReviews = reviews != null && reviews.isNotEmpty;
        final alreadyReviewed = isLoggedIn &&
            reviewController.hasUserReviewed(
              userId: userId,
              productId: product?.id,
            );

        return Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          color: theme.cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      getTranslated('customer_reviews', context)!,
                      style: titilliumSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  if (product != null)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => ProductWriteReviewSheet.show(
                          context,
                          product: product,
                          productSlug: product.slug,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              colors: [
                                theme.primaryColor,
                                theme.primaryColor.withValues(alpha: 0.82),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor
                                    .withValues(alpha: 0.28),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  alreadyReviewed
                                      ? Icons.edit_rounded
                                      : Icons.rate_review_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  alreadyReviewed
                                      ? getTranslated('update_review', context)!
                                      : getTranslated('write_a_review', context)!,
                                  style: textBold.copyWith(
                                    color: Colors.white,
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeDefault,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            theme.highlightColor.withValues(alpha: 0.55),
                            theme.cardColor,
                          ]
                        : [
                            theme.primaryColor.withValues(alpha: 0.08),
                            theme.primaryColor.withValues(alpha: 0.02),
                          ],
                  ),
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      average.toStringAsFixed(1),
                      style: titilliumBold.copyWith(
                        fontSize: 36,
                        height: 1,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RatingBar(rating: average, size: 20),
                    const SizedBox(height: 8),
                    Text(
                      '${getTranslated('total', context)} $reviewCount ${getTranslated('reviews', context)}',
                      style: textRegular.copyWith(color: theme.hintColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              if (reviews == null)
                const ReviewShimmer()
              else if (!hasReviews)
                const _EmptyReviewsState()
              else ...[
                ...List.generate(
                  reviews.length > 3 ? 3 : reviews.length,
                  (index) => ReviewWidget(reviewModel: reviews[index]),
                ),
                if (reviews.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: InkWell(
                      onTap: () {
                        RouterHelper.getReviewRoute(
                          action: RouteAction.push,
                          reviewList: reviews,
                        );
                      },
                      child: Text(
                        getTranslated('view_more', context)!,
                        textAlign: TextAlign.center,
                        style: titilliumRegular.copyWith(
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _EmptyReviewsState extends StatelessWidget {
  const _EmptyReviewsState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.hintColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.primaryColor.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.rate_review_outlined,
              size: 34,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            getTranslated('no_review', context) ??
                getTranslated('be_first_to_review', context) ??
                '',
            textAlign: TextAlign.center,
            style: titilliumSemiBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            getTranslated('share_your_experience', context) ?? '',
            textAlign: TextAlign.center,
            style: textRegular.copyWith(
              color: theme.hintColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
