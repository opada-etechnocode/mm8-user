import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class ProductCategoryNameWidget extends StatelessWidget {
  final Product product;
  final int maxLines;
  final TextStyle? style;

  const ProductCategoryNameWidget({
    super.key,
    required this.product,
    this.maxLines = 1,
    this.style,
  });

  String? _resolveCategoryName(BuildContext context) {
    final categoryName = product.categoryDisplayName;
    if (categoryName != null && categoryName.trim().isNotEmpty) {
      return categoryName;
    }

    final categoryId = product.categoryId;
    if (categoryId == null) {
      return null;
    }

    final categories = Provider.of<CategoryController>(context, listen: false).categoryList;
    for (final category in categories) {
      if (category.id == categoryId && category.name != null && category.name!.trim().isNotEmpty) {
        return category.name;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final categoryName = _resolveCategoryName(context);
    if (categoryName == null || categoryName.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      categoryName,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: style ??
          textRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).hintColor,
          ),
    );
  }
}
