import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/paginated_list_view_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/widgets/product_category_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/widgets/product_category_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key,this.fromDashboard=false});
 final bool fromDashboard;
  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ScrollController _productScrollController = ScrollController();

  @override
  void dispose() {
    _productScrollController.dispose();
    super.dispose();
  }

  bool _hasSubCategories(CategoryModel category) {
    return category.subCategories?.isNotEmpty ?? false;
  }

  void _loadProductsForCategory(CategoryModel category, ProductController productController) {
    if (_hasSubCategories(category)) {
      return;
    }

    productController.initBrandOrCategoryProductList(
      isBrand: false,
      id: category.id,
      offset: 1,
      isUpdate: true,
    );
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initCategoryData());
  }

  void _initCategoryData() {
    final categoryController = Provider.of<CategoryController>(context, listen: false);
    final productController = Provider.of<ProductController>(context, listen: false);

    if (categoryController.categoryList.isEmpty) {
      categoryController.getCategoryList(true).then((_) {
        if (!mounted || categoryController.categoryList.isEmpty) return;
        _loadSelectedCategoryProducts(categoryController, productController);
      });
      return;
    }

    _loadSelectedCategoryProducts(categoryController, productController);
  }

  void _loadSelectedCategoryProducts(
    CategoryController categoryController,
    ProductController productController,
  ) {
    final selectedIndex = categoryController.categorySelectedIndex ?? 0;
    categoryController.onChangeSelectedIndex(selectedIndex, isUpdate: false);
    _loadProductsForCategory(
      categoryController.categoryList[selectedIndex],
      productController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('CATEGORY', context),isBackButtonExist: !widget.fromDashboard,),
      body: Consumer<CategoryController>(
        builder: (context, categoryProvider, child) {
          return categoryProvider.categoryList.isNotEmpty ?
          Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

            Expanded(flex: 3, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeEight),
              decoration: BoxDecoration(
                color: Theme.of(context).highlightColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    offset: const Offset(1, -1),
                    spreadRadius: 0,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: categoryProvider.categoryList.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  CategoryModel category = categoryProvider.categoryList[index];
                  return InkWell(
                    onTap: () {
                      categoryProvider.onChangeSelectedIndex(index);
                      _loadProductsForCategory(
                        categoryProvider.categoryList[index],
                        Provider.of<ProductController>(context, listen: false),
                      );
                    },
                    child: CategoryItem(
                      title: category.name,
                      icon: category.imageFullUrl?.path,
                      isSelected: categoryProvider.categorySelectedIndex == index,
                    ),
                  );
                },
              ),
            )),

            Expanded(flex: 7, child: Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      offset: const Offset(0, 1),
                      spreadRadius: 0,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Material(
                  color: Theme.of(context).highlightColor,
                  child: _buildCategoryContent(context, categoryProvider),
                ),
              ),
            )),

          ]) : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)));
        },
      ),
    );
  }

  Widget _buildCategoryContent(BuildContext context, CategoryController categoryProvider) {
    final selectedCategory = categoryProvider.categoryList[categoryProvider.categorySelectedIndex!];

    if (!_hasSubCategories(selectedCategory)) {
      return _buildProductList(context, selectedCategory.id);
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraExtraSmall),
      itemCount: selectedCategory.subCategories!.length + 1,
      itemBuilder: (context, index) {
        late SubCategory subCategory;
        if (index != 0) {
          subCategory = selectedCategory.subCategories![index - 1];
        }
        if (index == 0) {
          return ListTile(
            tileColor: Theme.of(context).highlightColor,
            visualDensity: const VisualDensity(vertical: -4),
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Text(
                ((selectedCategory.subCategories?.length ?? 0) > 1)
                    ? getTranslated('all_products', context)!
                    : getTranslated('view_all_products', context)!,
                style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            onTap: () {
              RouterHelper.getBrandCategoryRoute(
                isBrand: false,
                id: selectedCategory.id,
                name: selectedCategory.name,
                categoryModel: selectedCategory,
                isAllProduct: true,
              );
            },
          );
        } else if (subCategory.subSubCategories?.isNotEmpty ?? false) {
          return ExpansionTile(
            backgroundColor: Theme.of(context).highlightColor,
            collapsedBackgroundColor: Theme.of(context).highlightColor,
            visualDensity: const VisualDensity(vertical: -4),
            tilePadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            iconColor: Theme.of(context).textTheme.bodyLarge?.color,
            shape: const Border(),
            key: Key('${categoryProvider.categorySelectedIndex}$index'),
            title: Text(
              subCategory.name ?? '',
              style: textBold.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: Dimensions.fontSizeSmall,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            children: _getSubSubCategories(context, subCategory),
          );
        } else {
          return ListTile(
            tileColor: Theme.of(context).highlightColor,
            title: Text(
              subCategory.name ?? '',
              style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            contentPadding: const EdgeInsets.only(
              left: Dimensions.paddingSizeDefault,
              right: Dimensions.paddingSizeDefault,
            ),
            trailing: Icon(Icons.navigate_next, color: Theme.of(context).textTheme.bodyLarge!.color),
            onTap: () {
              RouterHelper.getBrandCategoryRoute(
                action: RouteAction.push,
                isBrand: false,
                id: subCategory.id,
                name: selectedCategory.name,
                categoryModel: selectedCategory,
              );
            },
          );
        }
      },
      separatorBuilder: (context, index) => Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: Divider(
          color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.10),
          thickness: 1,
        ),
      ),
    );
  }

  Widget _buildProductList(BuildContext context, int? categoryId) {
    return Consumer<ProductController>(
      builder: (context, productController, _) {
        final products = productController.brandOrCategoryProductList?.products;

        if (productController.brandOrCategoryProductList == null) {
          return Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: const ProductCategoryShimmerWidget(),
          );
        }

        if (products == null || products.isEmpty) {
          return const NoInternetOrDataScreenWidget(
            isNoInternet: false,
            icon: Images.noProduct,
            message: 'no_product_found',
          );
        }

        return PaginatedListView(
          scrollController: _productScrollController,
          onPaginate: (offset) async {
            await productController.initBrandOrCategoryProductList(
              isBrand: false,
              id: categoryId,
              offset: offset ?? 1,
            );
          },
          limit: productController.brandOrCategoryProductList?.limit,
          totalSize: productController.brandOrCategoryProductList?.totalSize,
          offset: productController.brandOrCategoryProductList?.offset,
          itemView: Expanded(
            child: ListView.builder(
              controller: _productScrollController,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductCategoryWidget(
                  productModel: products[index],
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<Widget> _getSubSubCategories(BuildContext context, SubCategory subCategory) {

    List<Widget> subSubCategories = [];
    subSubCategories.add(ListTile(
      tileColor: Theme.of(context).highlightColor,
      visualDensity: const VisualDensity(vertical: -4),
      title: Row(children: [
        const SizedBox(width: Dimensions.paddingSizeSmall),
    
        Flexible(child: Text(getTranslated('all_products', context)!, style: textRegular.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.80)
        ), maxLines: 2, overflow: TextOverflow.ellipsis)),
      ]),
      onTap: () {
        RouterHelper.getBrandCategoryRoute(
          action: RouteAction.push,
          isBrand: false,
          id: subCategory.id,
          name: subCategory.name,
          subCategory: subCategory,
          isAllProduct: true,
        );
      },
    ));
    for(int index=0; index < subCategory.subSubCategories!.length; index++) {
      subSubCategories.add(ListTile(
        tileColor: Theme.of(context).highlightColor,
        visualDensity: const VisualDensity(vertical: -4),
        title: Row(children: [

          const SizedBox(width: Dimensions.paddingSizeSmall),

          Flexible(
            child: Text(subCategory.subSubCategories![index].name!, style: textRegular.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.80),
              fontSize: Dimensions.fontSizeSmall,
            ), maxLines: 2, overflow: TextOverflow.ellipsis),
          ),

        ]),
        onTap: () {
          RouterHelper.getBrandCategoryRoute(
            action: RouteAction.push,
            isBrand: false,
            id: subCategory.subSubCategories![index].id,
            name: subCategory.name,
            subCategory: subCategory,
          );
        },
      ));
    }
    return subSubCategories;
  }
}

class CategoryItem extends StatelessWidget {
  final String? title;
  final String? icon;
  final bool isSelected;
  const CategoryItem({super.key, required this.title, required this.icon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeSmall,
        horizontal: Dimensions.paddingSizeExtraSmall,
      ),
      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
        color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Theme.of(context).hintColor.withValues(alpha: 0.07),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: CustomImageWidget(fit: BoxFit.cover, image: '$icon', height: 40, width: 40),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
            title ?? '',
            maxLines: 2,
            style: textBold.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              height: 1.1,
              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
