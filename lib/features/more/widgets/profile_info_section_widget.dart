import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';

import '../../../localization/controllers/localization_controller.dart';
import '../../../localization/language_constrants.dart';
import '../../setting/widgets/select_currency_bottom_sheet_widget.dart';
import '../../setting/widgets/select_language_bottom_sheet_widget.dart';

class ProfileInfoSectionWidget extends StatelessWidget {
  final double expandedHeight;
  final double collapsedHeight;
  final double currentHeight;

  const ProfileInfoSectionWidget({
    super.key,
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.currentHeight,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic =
        Provider.of<LocalizationController>(context, listen: false).locale.languageCode == 'ar';
    final angel = (isArabic ? 90 : 100);
    final topPadding = MediaQuery.paddingOf(context).top;
    final expandRange = (expandedHeight - collapsedHeight).clamp(1.0, double.infinity);
    final expandRatio =
        ((currentHeight - collapsedHeight) / expandRange).clamp(0.0, 1.0);
    final stretchFactor =
        currentHeight > expandedHeight ? currentHeight / expandedHeight : 1.0;

    const collapsedAvatarSize = 28.0;
    const expandedAvatarSize = 66.0;
    final avatarSize =
        collapsedAvatarSize + ((expandedAvatarSize - collapsedAvatarSize) * expandRatio);

    final collapsedNameSize = Dimensions.fontSizeSmall;
    final expandedNameSize = Dimensions.fontSizeExtraLarge;
    final nameFontSize =
        collapsedNameSize + ((expandedNameSize - collapsedNameSize) * expandRatio);

    final themeIconSize = 22.0 + (8.0 * expandRatio);
    final themeIconPadding = 4.0 + (2.0 * expandRatio);

    final expandedRowTop = topPadding + 10;
    final collapsedRowTop = (currentHeight - avatarSize) / 2;
    final profileRowTop = collapsedRowTop + ((expandedRowTop - collapsedRowTop) * expandRatio);

    return Consumer<ProfileController>(
          builder: (context, profile, _) {
            final isGuestMode =
                !Provider.of<AuthController>(context, listen: false).isLoggedIn();
            final displayName = !isGuestMode
                ? '${profile.userInfoModel?.fName ?? ''} ${profile.userInfoModel?.lName ?? ''}'.trim()
                : 'Guest';

            return Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                fit: StackFit.expand,
                children: [
                  if (expandRatio > 0.85)
                    PositionedDirectional(
                      top: -150 * stretchFactor,
                      end: -50,
                      child: Opacity(
                        opacity: expandRatio,
                        child: Transform.scale(
                          scale: stretchFactor,
                          child: Transform.flip(
                            flipX: isArabic,
                            child: Transform.rotate(
                              angle: angel * (math.pi / 180),
                              child: Image.asset(
                                Images.backgroundBubble2,
                                height: 350,
                                width: 350,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (expandRatio > 0.85)
                    PositionedDirectional(
                      top: -180 * stretchFactor,
                      end: -100,
                      child: Opacity(
                        opacity: expandRatio,
                        child: Transform.scale(
                          scale: stretchFactor,
                          child: Transform.flip(
                            flipX: isArabic,
                            child: Transform.rotate(
                              angle: 45 * (math.pi / 180),
                              child: Image.asset(
                                Images.backgroundBubble,
                                color: Theme.of(context).primaryColor,
                                height: 300,
                                width: 300,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  PositionedDirectional(
                    top: profileRowTop,
                    start: Dimensions.paddingSizeDefault,
                    end: Dimensions.paddingSizeSmall,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            if (isGuestMode) {
                              showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (_) => NotLoggedInBottomSheetWidget(
                                  fromPage: RouterHelper.profileScreen1,
                                ),
                              );
                            } else if (profile.userInfoModel != null) {
                              RouterHelper.getProfileScreen1Route(action: RouteAction.push);
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                border: Provider.of<AuthController>(context, listen: false).isLoggedIn()
                                    ? null
                                    : Border.all(color: Colors.white, width: 3),
                                shape: BoxShape.circle,
                              ),
                              child: Provider.of<AuthController>(context, listen: false).isLoggedIn()
                                  ? CustomImageWidget(
                                      image: '${profile.userInfoModel?.imageFullUrl?.path}',
                                      width: avatarSize,
                                      height: avatarSize,
                                      fit: BoxFit.cover,
                                      placeholder: Images.guestProfile,
                                    )
                                  : Image.asset(Images.guestProfile),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: Dimensions.paddingSizeSmall +
                              (Dimensions.paddingSizeSmall * expandRatio),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textBold.copyWith(
                                  color: Theme.of(context).textTheme.bodyLarge!.color,
                                  fontSize: nameFontSize,
                                ),
                              ),


                             Align(
                                  alignment: AlignmentDirectional.topStart,
                                  heightFactor: expandRatio,
                                  child: Opacity(
                                    opacity: expandRatio,
                                    child: !isGuestMode
                                        ? Directionality(
                                            textDirection: TextDirection.ltr,
                                            child: Text(
                                              profile.userInfoModel?.phone ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: textRegular.copyWith(
                                                fontSize: Dimensions.fontSizeLarge,
                                                color: Theme.of(context).hintColor,
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ),

                            ],
                          ),
                        ),
                        Consumer<ThemeController>(
                          builder: (context, themeController, _) {
                            final isLightMode = !themeController.darkTheme;
                            final isCollapsed = expandRatio < 0.5;
                            final asset =
                                themeController.darkTheme ? Images.sunnyDay : Images.theme;

                            Widget iconImage;
                            if (isCollapsed && isLightMode) {
                              iconImage = ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Colors.black,
                                  BlendMode.srcIn,
                                ),
                                child: Image.asset(
                                  asset,
                                  width: themeIconSize,
                                  height: themeIconSize,
                                  fit: BoxFit.contain,
                                ),
                              );
                            } else {
                              iconImage = Image.asset(
                                asset,
                                width: themeIconSize,
                                height: themeIconSize,
                                fit: BoxFit.contain,
                                color: themeController.darkTheme ? Colors.white : null,
                                colorBlendMode:
                                    themeController.darkTheme ? BlendMode.srcIn : null,
                              );
                            }

                            return InkWell(
                              onTap: () => themeController.toggleTheme(),
                              child: Padding(
                                padding: EdgeInsets.all(themeIconPadding),
                                child: iconImage,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
  }
}
