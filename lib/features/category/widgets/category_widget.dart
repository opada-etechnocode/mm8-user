import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:provider/provider.dart';

class CategoryWidget extends StatelessWidget {
  final CategoryModel category;
  final int index;
  final int length;
  final bool uniformPadding;
  const CategoryWidget({
    super.key,
    required this.category,
    required this.index,
    required this.length,
    this.uniformPadding = false,
  });

  @override
  Widget build(BuildContext context) {
    int homeLength = length >= 10 ? 10 : length;
    final isLtr = Provider.of<LocalizationController>(context, listen: false).isLtr;

    return Padding(
      padding: uniformPadding
          ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeTwelve)
          : EdgeInsets.only(
              left: isLtr
                  ? index == 0
                      ? Dimensions.homePagePadding
                      : Dimensions.paddingSizeTwelve
                  : 0,
              right: index + 1 == homeLength
                  ? Dimensions.paddingSizeSmall
                  : isLtr
                      ? 0
                      : Dimensions.homePagePadding,
            ),
      // LayoutBuilder gives us the REAL available height/width for this cell,
      // so the square image always fits no matter what rowHeight the parent picks.
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Square image: takes the available width (bounded) but never
              // forces the Column taller than it has room for.
              Flexible(
                flex: 4,
                child: AspectRatio(
                  aspectRatio: 1, // <-- always a perfect square
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withValues(alpha: .125),
                        width: .25,
                      ),
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                      color: Theme.of(context).primaryColor.withValues(alpha: .125),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                      child: CustomImageWidget(image: '${category.imageFullUrl?.path}'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              // Flexible + FittedBox: text never overflows the Column even if
              // the device font-scale is large or the row is short.
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    category.name ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}