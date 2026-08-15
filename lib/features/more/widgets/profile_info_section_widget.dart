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
  const ProfileInfoSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Provider.of<LocalizationController>(context, listen: false).locale.languageCode == 'ar';
    final angel=(isArabic?90:100);
    return Consumer<ProfileController>(
        builder: (context,profile,_) {
          bool isGuestMode = !Provider.of<AuthController>(context, listen: false).isLoggedIn();
          return Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Stack(children: [

                PositionedDirectional(
                  top: -150,
                  end: -50,
                  child: Transform.flip(
                    flipX: isArabic,
                    child: Transform.rotate(
                      angle: angel * (math.pi / 180),
                      child: Image.asset(Images.backgroundBubble2, height: 350, width: 350,color: Theme.of(context).primaryColor,),
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: -180,
                  end: -100,
                  child: Transform.flip(
                    flipX: isArabic,
                    child: Transform.rotate(
                      angle: 45 * (math.pi / 180),
                      child: Image.asset(Images.backgroundBubble, color: Theme.of(context).primaryColor,height: 300, width: 300),
                    ),
                  ),
                ),

                PositionedDirectional(
                  top: 50,
                  end: 20,
                  child: InkWell(onTap: ()=> Provider.of<ThemeController>(context, listen: false).toggleTheme(),
                    child: Padding(padding: const EdgeInsets.all(8.0),
                        child: SizedBox(width: 40, child: Image.asset(Provider.of<ThemeController>(context).darkTheme ?
                        Images.sunnyDay: Images.theme, color: Provider.of<ThemeController>(context).darkTheme ? Colors.white: null))),
                  ),
                ),
                Column(
                  children: [
                    Padding(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 70.0,Dimensions.paddingSizeDefault, 30),
                        child: Row(children: [
                          InkWell(onTap: () {
                            if(isGuestMode) {
                              showModalBottomSheet(backgroundColor: Colors.transparent,context:context, builder: (_)=>  NotLoggedInBottomSheetWidget(fromPage: RouterHelper.profileScreen1));
                            } else {if(profile.userInfoModel != null) {
                              RouterHelper.getProfileScreen1Route(action: RouteAction.push);
                            }
                            }
                          },
                            child: ClipRRect(borderRadius: BorderRadius.circular(100),
                                child: Container(width: 70,height: 70,  decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  border: Provider.of<AuthController>(context, listen: false).isLoggedIn() ? null : Border.all(color: Colors.white, width: 3),
                                  shape: BoxShape.circle,),
                                  child: Provider.of<AuthController>(context, listen: false).isLoggedIn()?
                                  CustomImageWidget(image: '${profile.userInfoModel?.imageFullUrl?.path}', width: 70,height: 70,fit: BoxFit.cover,placeholder: Images.guestProfile):
                                  Image.asset(Images.guestProfile),)),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),

                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(!isGuestMode?
                            '${profile.userInfoModel?.fName??''} ${profile.userInfoModel?.lName??''}' : 'Guest',
                                style: textBold.copyWith(
                                    color: Theme.of(context).textTheme.bodyLarge!.color,
                                    fontSize: Dimensions.fontSizeExtraLarge)),

                            if(!isGuestMode)
                              Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(profile.userInfoModel?.phone??'', style: textRegular.copyWith( fontSize: Dimensions.fontSizeLarge,color: Theme.of(context).hintColor))),
                          ],)),

                        ])),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         child: InkWell(
                    //           onTap: () {
                    //             showModalBottomSheet(
                    //               context: context,
                    //               backgroundColor: Colors.transparent,
                    //               isScrollControlled: true,
                    //               builder: (context) => const SelectLanguageBottomSheetWidget(),
                    //             );
                    //           },
                    //           borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge),
                    //           child: Container(
                    //             padding: const EdgeInsets.symmetric(
                    //               horizontal: Dimensions.paddingSizeDefault,
                    //               vertical: Dimensions.paddingSizeDefault,
                    //             ),
                    //             decoration: BoxDecoration(
                    //                 border: Border.all(color: Colors.white.withAlpha(50)),
                    //                 borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge),
                    //                 color: Theme.of(context).cardColor
                    //             ),
                    //             child: Row(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 Icon(
                    //                   Icons.language,
                    //
                    //                   size: 20,
                    //                 ),
                    //                 const SizedBox(width: 8),
                    //                 Flexible(
                    //                   child: Text(
                    //                     getTranslated('language', context) ?? 'Language',
                    //                     style: textRegular.copyWith(
                    //
                    //                       fontSize: Dimensions.fontSizeDefault,
                    //                       fontWeight:FontWeight.w600,
                    //                     ),
                    //                     overflow: TextOverflow.ellipsis,
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //       const SizedBox(width: Dimensions.paddingSizeSmall),
                    //       Expanded(
                    //         child: InkWell(
                    //           onTap: () {
                    //             showModalBottomSheet(
                    //               context: context,
                    //               backgroundColor: Colors.transparent,
                    //               isScrollControlled: true,
                    //               builder: (context) => const SelectCurrencyBottomSheetWidget(),
                    //             );
                    //           },
                    //           borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge),
                    //           child: Container(
                    //
                    //             padding: const EdgeInsets.symmetric(
                    //               horizontal: Dimensions.paddingSizeDefault,
                    //               vertical: Dimensions.paddingSizeDefault,
                    //             ),
                    //             decoration: BoxDecoration(
                    //               color: Theme.of(context).cardColor,
                    //                 border: Border.all(color: Colors.white.withAlpha(50)),
                    //                 borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge),
                    //
                    //             ),
                    //             child: Row(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 Icon(
                    //                   Icons.currency_exchange,
                    //
                    //                   size: 20,
                    //                 ),
                    //                 const SizedBox(width: 8),
                    //                 Flexible(
                    //                   child: Text(
                    //                     getTranslated('currency', context) ?? 'Currency',
                    //                     style: textRegular.copyWith(
                    //
                    //                       fontSize: Dimensions.fontSizeDefault,
                    //                       fontWeight:FontWeight.w600,
                    //                     ),
                    //                     overflow: TextOverflow.ellipsis,
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),


              ]));
        });
  }
}
