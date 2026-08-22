import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/latest_product/latest_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/product_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class RelatedProductWidget extends StatelessWidget {
  const RelatedProductWidget({super.key});

  static const double _compactCardHeight = 92;
  static const double _rowSpacing = Dimensions.paddingSizeEight;
  static const double _horizontalPadding = Dimensions.paddingSizeDefault;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, prodProvider, child) {
        final itemCount = prodProvider.relatedProductList?.length ?? 0;
        final hasTwoRows = itemCount > 5;
        final crossAxisCount = hasTwoRows ? 2 : 1;
        final gridHeight = hasTwoRows
            ? _compactCardHeight * 2 + _rowSpacing
            : _compactCardHeight;

        return Column(children: [
          prodProvider.relatedProductList != null ? prodProvider.relatedProductList!.isNotEmpty ?

          Padding(
            padding: const EdgeInsetsDirectional.only(start: _horizontalPadding),
            child: SizedBox(
            height: gridHeight,
            child: GridView.builder(
              clipBehavior: Clip.none,
              itemCount: itemCount,
              scrollDirection: Axis.horizontal,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: _rowSpacing,
                mainAxisSpacing: Dimensions.paddingSizeExtraSmall,
                childAspectRatio: 0.42,
              ),
              itemBuilder: (context, index) {
                return LatestProductWidget(
                  productModel: prodProvider.relatedProductList![index],
                  compact: true,
                );
              },
            ),
          ),
          )

              :  const SizedBox() :
          ProductShimmer(isHomePage: false, isEnabled: Provider.of<ProductController>(context).relatedProductList == null),
        ]);
      },
    );
  }
}
