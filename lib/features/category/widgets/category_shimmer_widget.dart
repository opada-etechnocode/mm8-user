import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class CategoryShimmerWidget extends StatelessWidget {
  final double? rowHeight;
  const CategoryShimmerWidget({super.key, this.rowHeight});

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
