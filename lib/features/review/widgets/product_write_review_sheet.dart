import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/review/controllers/review_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/review/domain/models/review_body.dart';
import 'package:flutter_sixvalley_ecommerce/features/review/domain/models/review_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class ProductWriteReviewSheet {
  static Future<void> show(
    BuildContext context, {
    required ProductDetailsModel product,
    required String? productSlug,
  }) async {
    final auth = Provider.of<AuthController>(context, listen: false);
    if (!auth.isLoggedIn()) {
      RouterHelper.getLoginRoute(action: RouteAction.push);
      return;
    }

    final profile = Provider.of<ProfileController>(context, listen: false);
    if (profile.userInfoModel == null) {
      await profile.getUserInfo(context);
    }
    final reviewController =
        Provider.of<ReviewController>(context, listen: false);
    await reviewController.hasUserReviewedProduct(
      productSlug: productSlug ?? product.slug,
      userId: profile.userInfoModel?.id,
      productId: product.id,
      context: context,
    );
    if (!context.mounted) return;

    final existingReview = reviewController.findUserReview(
      userId: profile.userInfoModel?.id,
      productId: product.id,
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductWriteReviewSheet(
        product: product,
        productSlug: productSlug,
        existingReview: existingReview,
      ),
    );
  }
}

class _ProductWriteReviewSheet extends StatefulWidget {
  final ProductDetailsModel product;
  final String? productSlug;
  final ReviewModel? existingReview;

  const _ProductWriteReviewSheet({
    required this.product,
    required this.productSlug,
    this.existingReview,
  });

  @override
  State<_ProductWriteReviewSheet> createState() =>
      _ProductWriteReviewSheetState();
}

class _ProductWriteReviewSheetState extends State<_ProductWriteReviewSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  bool get _isEdit => widget.existingReview != null;

  static const List<String> _ratingKeys = [
    'rating_label_poor',
    'rating_label_fair',
    'rating_label_good',
    'rating_label_great',
    'rating_label_excellent',
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingReview;
    if (existing?.comment != null) {
      _commentController.text = existing!.comment!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final reviewController =
          Provider.of<ReviewController>(context, listen: false);
      reviewController.removeData();
      reviewController.initReviewImage();
      if (existing?.rating != null) {
        reviewController.setRating(existing!.rating!);
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  Future<void> _submit(ReviewController reviewController) async {
    if (widget.product.id == null) {
      reviewController.setErrorText(getTranslated('write_a_review', context));
      return;
    }
    if (reviewController.rating == 0) {
      reviewController.setErrorText(getTranslated('add_a_rating', context));
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      reviewController.setErrorText(getTranslated('write_a_review', context));
      return;
    }

    reviewController.setErrorText('');
    final body = ReviewBody(
      id: widget.existingReview?.id?.toString(),
      productId: widget.product.id.toString(),
      rating: reviewController.rating.toString(),
      comment: _commentController.text.trim(),
    );

    final result = await reviewController.submitReview(
      body,
      reviewController.reviewImages,
      _isEdit,
    );

    if (!mounted) return;
    if (result.isSuccess) {
      if (widget.productSlug != null) {
        await reviewController.getReviewList(widget.productSlug, context);
      }
      if (!mounted) return;
      Navigator.pop(context);
      showCustomSnackBarWidget(
        result.message,
        context,
        snackBarType: SnackBarType.success,
      );
    } else {
      reviewController.setErrorText(result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;
    final primary = theme.primaryColor;
    final imageUrl = widget.product.thumbnailFullUrl?.path ?? '';
    final maxHeight = (media.size.height - keyboard) * 0.92;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: maxHeight.clamp(280.0, media.size.height),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.hintColor.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Expanded(
                  child: Consumer<ReviewController>(
                    builder: (context, reviewController, _) {
                      final rating = reviewController.rating;
                      final label = rating > 0
                          ? (getTranslated(_ratingKeys[rating - 1], context) ??
                              '')
                          : (getTranslated('tap_stars_to_rate', context) ?? '');

                      return SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    getTranslated(
                                      _isEdit
                                          ? 'update_review'
                                          : 'write_a_review',
                                      context,
                                    )!,
                                    style: titilliumBold.copyWith(
                                      fontSize: Dimensions.fontSizeExtraLarge,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.close_rounded,
                                      color: theme.hintColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    primary.withValues(alpha: 0.12),
                                    primary.withValues(alpha: 0.04),
                                    theme.cardColor,
                                  ],
                                ),
                                border: Border.all(
                                  color: primary.withValues(alpha: 0.12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: CustomImageWidget(
                                      image: imageUrl,
                                      height: 56,
                                      width: 56,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      widget.product.name ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: textMedium.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color:
                                            theme.textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              getTranslated('rate_the_quality', context) ?? '',
                              textAlign: TextAlign.center,
                              style: textMedium.copyWith(
                                color: theme.hintColor,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                final selected = rating >= index + 1;
                                return IconButton(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2),
                                  constraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                  onPressed: () {
                                    reviewController.setRating(index + 1);
                                  },
                                  icon: Icon(
                                    selected
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    size: 36,
                                    color: selected
                                        ? const Color(0xFFE8A317)
                                        : theme.hintColor
                                            .withValues(alpha: 0.35),
                                  ),
                                );
                              }),
                            ),
                            Text(
                              label,
                              textAlign: TextAlign.center,
                              style: titilliumSemiBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: primary,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              getTranslated('have_thoughts_to_share', context)!,
                              style: textMedium.copyWith(
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _commentController,
                              focusNode: _commentFocus,
                              maxLines: 4,
                              minLines: 3,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              style: textRegular.copyWith(
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                              decoration: InputDecoration(
                                hintText: getTranslated(
                                    'write_your_experience_here', context),
                                hintStyle: textRegular.copyWith(
                                  color:
                                      theme.hintColor.withValues(alpha: 0.7),
                                ),
                                filled: true,
                                fillColor: theme.cardColor,
                                contentPadding: const EdgeInsets.all(16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide(
                                    color: theme.hintColor
                                        .withValues(alpha: 0.15),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide(
                                    color: theme.hintColor
                                        .withValues(alpha: 0.15),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide:
                                      BorderSide(color: primary, width: 1.4),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              getTranslated('add_photos_optional', context) ??
                                  '',
                              style: textMedium.copyWith(
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 78,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    reviewController.reviewImages.length + 1,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 10),
                                itemBuilder: (context, index) {
                                  if (index ==
                                      reviewController.reviewImages.length) {
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        _commentFocus.unfocus();
                                        reviewController.pickImage(
                                          false,
                                          fromReview: true,
                                        );
                                      },
                                      child: DottedBorder(
                                        options: RoundedRectDottedBorderOptions(
                                          strokeWidth: 1.5,
                                          dashPattern: const [7, 5],
                                          color: theme.hintColor
                                              .withValues(alpha: 0.55),
                                          radius: const Radius.circular(16),
                                        ),
                                        child: SizedBox(
                                          width: 78,
                                          height: 78,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add_a_photo_outlined,
                                                  color: primary, size: 22),
                                              const SizedBox(height: 4),
                                              Text(
                                                getTranslated(
                                                        'photo', context) ??
                                                    'Photo',
                                                style: textRegular.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeExtraSmall,
                                                  color: theme.hintColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.file(
                                          File(reviewController
                                              .reviewImages[index].path),
                                          width: 78,
                                          height: 78,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: InkWell(
                                          onTap: () =>
                                              reviewController.removeImage(
                                            index,
                                            fromReview: true,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: theme.cardColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.close_rounded,
                                              size: 16,
                                              color: theme.hintColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            if (reviewController.errorText != null &&
                                reviewController.errorText!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                reviewController.errorText!,
                                style: textRegular.copyWith(
                                  color: theme.colorScheme.error,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            CustomButton(
                              isLoading: reviewController.isLoading,
                              buttonText: _isEdit
                                  ? getTranslated('update_review', context)
                                  : (getTranslated('submit_review', context) ??
                                      getTranslated('submit', context)),
                              onTap: () {
                                _commentFocus.unfocus();
                                _submit(reviewController);
                              },
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

