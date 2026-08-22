import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class CategoryShimmerWidget extends StatelessWidget {
  final double? rowHeight;
  final bool useGrid;

  const CategoryShimmerWidget({
    super.key,
    this.rowHeight,
    this.useGrid = false,
  });

  Widget _buildShimmerTile(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).cardColor,
      highlightColor: Colors.grey[300]!,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Container(
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 4,
          crossAxisSpacing: Dimensions.paddingSizeSmall,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) => _buildShimmerTile(context),
      ),
    );
  }

  Widget _buildShimmerRow(BuildContext context) {
    return SizedBox(
      height: rowHeight ?? 100,
      child: ListView.builder(
        itemCount: 4,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeTwelve),
            child: Container(
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Provider.of<ThemeController>(context).darkTheme
                    ? Theme.of(context).primaryColor.withValues(alpha: .05)
                    : Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Shimmer.fromColors(
                baseColor: Theme.of(context).cardColor,
                highlightColor: Colors.grey[300]!,
                enabled: true,
                child: Column(
                  children: [
                    Container(
                      height: 70,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Container(
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      color: Theme.of(context).cardColor,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (useGrid) {
      return _buildGridShimmer(context);
    }

    final height = rowHeight ?? 100;
    return SizedBox(
      height: height * 2 + Dimensions.paddingSizeSmall,
      child: Column(
        children: [
          _buildShimmerRow(context),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          _buildShimmerRow(context),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],
      ),
    );
  }
}
