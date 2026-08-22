import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/widgets/category_widget.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';

import 'category_shimmer_widget.dart';

class CategoryListWidget extends StatelessWidget {
  final bool isHomePage;
  const CategoryListWidget({super.key, required this.isHomePage});

  static const int _gridColumns = 3;
  static const double _gridAspectRatio = 0.9;
  static const double _gridRowSpacing = 4;

  void _openCategoryProducts(BuildContext context, CategoryModel category) {
    if (category.id == null) return;

    RouterHelper.getBrandCategoryRoute(
      action: RouteAction.push,
      isBrand: false,
      id: category.id,
      name: category.name,
      image: category.imageFullUrl?.path,
      categoryModel: category,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryController>(
      builder: (context, categoryProvider, child) {
        final categories = categoryProvider.categoryList;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeSmall,
                Dimensions.paddingSizeDefault,0
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      getTranslated('CATEGORY', context)!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  if (categories.isNotEmpty)
                    InkWell(
                      onTap: () {
                        RouterHelper.getCategoryScreenRoute(action: RouteAction.push);
                      },
                      child: Text(
                        getTranslated('VIEW_ALL', context)!,
                        style: titilliumRegular.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (categories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.homePagePadding,
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsetsGeometry.directional(top: 10),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _gridColumns,
                    mainAxisSpacing: _gridRowSpacing,
                    crossAxisSpacing: Dimensions.paddingSizeSmall,
                    childAspectRatio: _gridAspectRatio,
                  ),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () => _openCategoryProducts(context, category),
                        child: CategoryWidget(
                          category: category,
                          index: index,
                          length: categories.length,
                          uniformPadding: true,
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              const CategoryShimmerWidget(useGrid: true),
          ],
        );
      },
    );
  }
}
