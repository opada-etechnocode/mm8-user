import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/onboarding/controllers/onboarding_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

import '../../../../helper/route_healper.dart';

class OnBoardingScreen extends StatefulWidget {
  final Color indicatorColor;
  final Color selectedIndicatorColor;

  const OnBoardingScreen({
    super.key,
    this.indicatorColor = Colors.grey,
    this.selectedIndicatorColor = Colors.black,
  });

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final onboardingController =
          Provider.of<OnBoardingController>(context, listen: false);
      if (onboardingController.onBoardingList.isEmpty) {
        onboardingController.getOnBoardingList();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() {
    Provider.of<SplashController>(context, listen: false).disableIntro();
    Provider.of<AuthController>(context, listen: false).getGuestIdUrl();
    RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Selector<OnBoardingController, int>(
        selector: (_, controller) => controller.onBoardingList.length,
        builder: (context, itemCount, child) {
          final items =
              Provider.of<OnBoardingController>(context, listen: false).onBoardingList;

          if (items.isEmpty) {
            return const SizedBox.expand(
              child: ColoredBox(color: Colors.black),
            );
          }

          final lastIndex = items.length - 1;

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: items.length,
                  onPageChanged: (index) {
                    Provider.of<OnBoardingController>(context, listen: false)
                        .changeSelectIndex(index);
                  },
                  itemBuilder: (context, index) {
                    return SizedBox.expand(
                      child: Image.asset(
                        items[index].imageUrl,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                left: 30,
                right: 30,
                bottom: 40,
                child: Selector<OnBoardingController, int>(
                  selector: (_, controller) => controller.selectedIndex,
                  builder: (context, selectedIndex, _) {
                    final currentIndex = selectedIndex.clamp(0, lastIndex);
                    final isLastPage = currentIndex == lastIndex;
                    final isSecondPage = currentIndex == 1;
                    final backgroundColor = isSecondPage
                        ? Colors.white
                        : Color(0xff014456);
                    final textColor = isSecondPage
                        ? Color(0xff014456)
                        : Colors.white;
                    final buttonText = isLastPage
                        ? (getTranslated('GET_STARTED', context) ?? 'Get Started')
                        : (getTranslated('NEXT', context) ?? 'Next');

                    return Material(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        onTap: () {
                          if (isLastPage) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              buttonText,
                              style: titilliumSemiBold.copyWith(
                                color: textColor,
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
