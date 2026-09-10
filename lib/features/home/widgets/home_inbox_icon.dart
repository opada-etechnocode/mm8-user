import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/chat/controllers/chat_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class HomeInboxIconWidget extends StatelessWidget {
  const HomeInboxIconWidget({super.key});

  void _openInHouseSupportChat(BuildContext context) {
    if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => const NotLoggedInBottomSheetWidget(
          fromPage: RouterHelper.dashboardScreen,
        ),
      );
      return;
    }

    Provider.of<ChatController>(context, listen: false).setUserTypeIndex(context, 1);
    RouterHelper.getChatScreenRoute(
      action: RouteAction.push,
      id: 1,
      name: 'MM8',
      userType: 1,
      image: '',
      isShopOnVacation: false,
      isShopTemporaryClosed: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, chatController, _) {
        final bool isLoggedIn =
            Provider.of<AuthController>(context, listen: false).isLoggedIn();
        final int count = chatController.vendorUnreadMessageCount;
        final hint =
            getTranslated('contact_support_24h_hint', context) ??
            'تواصل فوراً مع الدعم خدمة 24 ساعة';

        return Tooltip(
          message: hint,
          preferBelow: true,
          waitDuration: const Duration(milliseconds: 200),
          showDuration: const Duration(seconds: 3),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          textStyle: textRegular.copyWith(
            color: Colors.white,
            fontSize: Dimensions.fontSizeSmall,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
            vertical: Dimensions.paddingSizeExtraSmall,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openInHouseSupportChat(context),
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      Images.chats,
                      height: 20,
                      width: 20,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    if (isLoggedIn && count > 0)
                      Positioned(
                        top: 5,
                        right: 3,
                        child: CircleAvatar(
                          radius: ResponsiveHelper.isTab(context) ? 10 : 8,
                          backgroundColor: Theme.of(context).colorScheme.error,
                          child: Text(
                            count > 99 ? '99+' : count.toString(),
                            style: titilliumSemiBold.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              fontSize: count > 99
                                  ? 8
                                  : Dimensions.fontSizeExtraSmall,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
