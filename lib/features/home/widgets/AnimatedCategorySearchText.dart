import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';

class AnimatedCategorySearchText extends StatefulWidget {
  const AnimatedCategorySearchText({Key? key}) : super(key: key);

  @override
  State<AnimatedCategorySearchText> createState() => _AnimatedCategorySearchTextState();
}

class _AnimatedCategorySearchTextState extends State<AnimatedCategorySearchText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );



    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.4),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      await _controller.forward();
      if (mounted) {
        setState(() {
          final categoryController = Provider.of<CategoryController>(context, listen: false);
          if (categoryController.categoryList.isNotEmpty) {
            _currentIndex = (_currentIndex + 1) % categoryController.categoryList.length;
          }
        });
        await _controller.reverse();
        if (mounted) {
          _startAnimation();
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryController>(
      builder: (context, categoryController, child) {
        if (categoryController.categoryList.isEmpty) {
          return Text(
            'Search products...',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 15,
              fontFamily: 'Cairo'
            ),
          );
        }

        final categoryName = categoryController.categoryList[_currentIndex].name ?? 'Products';

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimation,
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${getTranslated("Searchـfor", context)!} ",
                      style: TextStyle(
                        color: Colors.grey[500],
                          fontFamily: 'Cairo'

                      ),
                    ),
                    TextSpan(
                      text: categoryName,
                      style:  TextStyle(
                          color: Colors.grey[500],
                          fontFamily: 'Cairo'
                      ),
                    ),
                  ],
                ),
              ),
            );

          },
        );
      },
    );
  }
}