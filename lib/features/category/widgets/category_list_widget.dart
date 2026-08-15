import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/title_row_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/widgets/category_widget.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';

import 'category_shimmer_widget.dart';

class CategoryListWidget extends StatelessWidget {
  final bool isHomePage;
  const CategoryListWidget({super.key, required this.isHomePage});

  static const double viewportFraction = 0.26;

  static double rowHeight(BuildContext context) {
    final itemWidth = MediaQuery.of(context).size.width * viewportFraction;
    const horizontalPadding = Dimensions.paddingSizeSmall * 2;
    final imageSize = itemWidth - horizontalPadding;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final textHeight = Dimensions.fontSizeDefault * textScale * 1.3;
    return imageSize + Dimensions.paddingSizeExtraSmall + textHeight + 2;
  }

  List<List<CategoryModel>> _splitIntoTwoRows(List<CategoryModel> categories) {
    if (categories.isEmpty) {
      return [[], []];
    }

    final splitIndex = (categories.length / 2).ceil();
    return [
      categories.sublist(0, splitIndex),
      categories.sublist(splitIndex),
    ];
  }

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
        final rowHeight = CategoryListWidget.rowHeight(context);
        final categories = categoryProvider.categoryList;
        final rows = _splitIntoTwoRows(categories);
        final hasSecondRow = rows[1].isNotEmpty;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeExtraExtraSmall,
              ),
              child: TitleRowWidget(
                title: getTranslated('CATEGORY', context),
                onTap: () {
                  if (categories.isNotEmpty) {
                    RouterHelper.getCategoryScreenRoute(action: RouteAction.push);
                  }
                },
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            if (categories.isNotEmpty)
              SizedBox(
                height: hasSecondRow
                    ? rowHeight * 2 + Dimensions.paddingSizeSmall
                    : rowHeight,
                child: _SynchronizedCategoryRows(
                  firstRow: rows[0],
                  secondRow: hasSecondRow ? rows[1] : const [],
                  rowHeight: rowHeight,
                  totalCount: categories.length,
                  firstRowStartIndex: 0,
                  secondRowStartIndex: rows[0].length,
                  onCategoryTap: (category) =>
                      _openCategoryProducts(context, category),
                ),
              )
            else
              CategoryShimmerWidget(rowHeight: rowHeight),
          ],
        );
      },
    );
  }
}

class _SynchronizedCategoryRows extends StatefulWidget {
  final List<CategoryModel> firstRow;
  final List<CategoryModel> secondRow;
  final double rowHeight;
  final int totalCount;
  final int firstRowStartIndex;
  final int secondRowStartIndex;
  final ValueChanged<CategoryModel> onCategoryTap;

  const _SynchronizedCategoryRows({
    required this.firstRow,
    required this.secondRow,
    required this.rowHeight,
    required this.totalCount,
    required this.firstRowStartIndex,
    required this.secondRowStartIndex,
    required this.onCategoryTap,
  });

  @override
  State<_SynchronizedCategoryRows> createState() =>
      _SynchronizedCategoryRowsState();
}

class _SynchronizedCategoryRowsState extends State<_SynchronizedCategoryRows> {
  static const Duration _autoPlayInterval = Duration(seconds: 4);
  static const Duration _animationDuration = Duration(milliseconds: 800);
  static const int _loopMultiplier = 1000;

  PageController? _firstController;
  PageController? _secondController;
  Timer? _autoPlayTimer;
  bool _isUserInteracting = false;
  bool _isAutoAdvancing = false;

  bool get _canAutoPlayFirst => widget.firstRow.length > 1;
  bool get _canAutoPlaySecond => widget.secondRow.length > 1;
  bool get _canAutoPlay => _canAutoPlayFirst || _canAutoPlaySecond;

  int _virtualItemCount(int count) =>
      count <= 1 ? count : count * _loopMultiplier;

  int _initialVirtualPage(int count) =>
      count <= 1 ? 0 : count * (_loopMultiplier ~/ 2);

  @override
  void initState() {
    super.initState();
    _initControllers();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant _SynchronizedCategoryRows oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.firstRow.length != widget.firstRow.length ||
        oldWidget.secondRow.length != widget.secondRow.length) {
      _disposeControllers();
      _initControllers();
      _restartAutoPlay();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _disposeControllers();
    super.dispose();
  }

  void _initControllers() {
    _firstController = PageController(
      viewportFraction: CategoryListWidget.viewportFraction,
      initialPage: _initialVirtualPage(widget.firstRow.length),
    );
    if (widget.secondRow.isNotEmpty) {
      _secondController = PageController(
        viewportFraction: CategoryListWidget.viewportFraction,
        initialPage: _initialVirtualPage(widget.secondRow.length),
      );
    }
  }

  void _disposeControllers() {
    _firstController?.dispose();
    _secondController?.dispose();
    _firstController = null;
    _secondController = null;
  }

  void _recenterIfNeeded(PageController controller, int page, int itemCount) {
    if (itemCount <= 1 || !controller.hasClients) return;

    final centerBlock = _initialVirtualPage(itemCount);
    final lowerBound = itemCount * 100;
    final upperBound = itemCount * (_loopMultiplier - 100);

    if (page < lowerBound || page > upperBound) {
      final realIndex = page % itemCount;
      controller.jumpToPage(centerBlock + realIndex);
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (!_canAutoPlay) return;

    _autoPlayTimer = Timer.periodic(_autoPlayInterval, (_) {
      if (!mounted || _isUserInteracting) return;
      _advanceBothRows();
    });
  }

  void _restartAutoPlay() {
    _autoPlayTimer?.cancel();
    _startAutoPlay();
  }

  Future<void> _advanceBothRows() async {
    if (!mounted) return;

    _isAutoAdvancing = true;

    final futures = <Future<void>>[];

    if (_canAutoPlayFirst && _firstController?.hasClients == true) {
      futures.add(
        _firstController!.nextPage(
          duration: _animationDuration,
          curve: Curves.easeInOut,
        ),
      );
    }

    if (_canAutoPlaySecond && _secondController?.hasClients == true) {
      futures.add(
        _secondController!.nextPage(
          duration: _animationDuration,
          curve: Curves.easeInOut,
        ),
      );
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }

    if (mounted) {
      _isAutoAdvancing = false;
    }
  }

  void _pauseAutoPlay() {
    _isUserInteracting = true;
    _autoPlayTimer?.cancel();
  }

  void _resumeAutoPlayLater() {
    Future.delayed(_autoPlayInterval, () {
      if (!mounted) return;
      _isUserInteracting = false;
      _startAutoPlay();
    });
  }

  void _onManualPageChange() {
    _pauseAutoPlay();
    _resumeAutoPlayLater();
  }

  Widget _buildRow({
    required List<CategoryModel> rowCategories,
    required PageController? controller,
    required int startIndex,
  }) {
    if (rowCategories.isEmpty || controller == null) {
      return const SizedBox.shrink();
    }

    final itemCount = rowCategories.length;
    final virtualCount = _virtualItemCount(itemCount);

    return SizedBox(
      height: widget.rowHeight,
      child: PageView.builder(
        controller: controller,
        padEnds: false,
        itemCount: virtualCount,
        onPageChanged: (index) {
          _recenterIfNeeded(controller, index, itemCount);
          if (!_isAutoAdvancing) {
            _onManualPageChange();
          }
        },
        itemBuilder: (context, index) {
          final realIndex = itemCount == 0 ? 0 : index % itemCount;
          final category = rowCategories[realIndex];
          return SizedBox(
            height: widget.rowHeight,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () => widget.onCategoryTap(category),
                child: CategoryWidget(
                  category: category,
                  index: startIndex + realIndex,
                  length: widget.totalCount,
                  uniformPadding: true,
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
    return Listener(
      onPointerDown: (_) => _pauseAutoPlay(),
      onPointerUp: (_) => _resumeAutoPlayLater(),
      onPointerCancel: (_) => _resumeAutoPlayLater(),
      child: Column(
        children: [
          _buildRow(
            rowCategories: widget.firstRow,
            controller: _firstController,
            startIndex: widget.firstRowStartIndex,
          ),
          if (widget.secondRow.isNotEmpty) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            _buildRow(
              rowCategories: widget.secondRow,
              controller: _secondController,
              startIndex: widget.secondRowStartIndex,
            ),
          ],
        ],
      ),
    );
  }
}
