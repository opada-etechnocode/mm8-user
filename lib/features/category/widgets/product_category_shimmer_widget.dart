import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ProductCategoryShimmerWidget extends StatelessWidget {
  const ProductCategoryShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final itemSize = ResponsiveHelper.isTab(context) ? 160.0 : 90.0;

    return ListView.builder(
      itemCount: 6,
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeSmall,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
            left: Dimensions.paddingSizeSmall,
            bottom: Dimensions.paddingSizeSmall,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(Dimensions.paddingSizeSmall),
              color: Theme.of(context).highlightColor,
              boxShadow: [
                BoxShadow(
                  color:
                      Theme.of(context).primaryColor.withValues(alpha: 0.075),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).cardColor,
              highlightColor: Colors.grey[300]!,
              enabled: true,
              child: SizedBox(
                height: itemSize,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: itemSize,
                      height: itemSize,
                      decoration: BoxDecoration(
                        color: Provider.of<ThemeController>(context).darkTheme
                            ? Theme.of(context)
                                .primaryColor
                                .withValues(alpha: .05)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(height: 12, width: 70, color: Colors.white),
                            const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall),
                            Container(
                              height: 14,
                              width: double.infinity,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 14,
                              width: 120,
                              color: Colors.white,
                            ),
                            const Spacer(),
                            Container(
                              height: 16,
                              width: 70,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
