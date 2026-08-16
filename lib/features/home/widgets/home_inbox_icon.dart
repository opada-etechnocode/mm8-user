import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/chat/controllers/chat_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class HomeInboxIconWidget extends StatelessWidget {
  const HomeInboxIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, chatController, _) {
        final bool isLoggedIn =
            Provider.of<AuthController>(context, listen: false).isLoggedIn();
        final int count = chatController.vendorUnreadMessageCount;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () =>
                RouterHelper.getInboxScreenRoute(action: RouteAction.push),
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
        );
      },
    );
  }
}
