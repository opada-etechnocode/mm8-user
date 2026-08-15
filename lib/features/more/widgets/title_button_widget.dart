import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/controllers/notification_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class MenuButtonWidget extends StatelessWidget {
  final String image;
  final String? title;
  final Widget? navigateTo;
  final bool isNotification;
  final bool isProfile;
  final Function? onTap;

  const MenuButtonWidget({
    super.key,
    required this.image,
    required this.title,
    this.navigateTo,
    this.isNotification = false,
    this.isProfile = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap != null ? () => onTap!() : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: CustomAssetImageWidget(
                    image,
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                    color: primary,
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Text(
                  title ?? '',
                  style: textMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              if (isNotification &&
                  Provider.of<AuthController>(context, listen: false)
                      .isLoggedIn())
                Consumer<NotificationController>(
                  builder: (context, notificationController, _) {
                    return _Badge(
                      label: notificationController
                              .notificationModel?.newNotificationItem
                              .toString() ??
                          '0',
                    );
                  },
                )
              else if (isProfile)
                Consumer<ProfileController>(
                  builder: (context, profileProvider, _) {
                    return _Badge(
                      label: profileProvider.userInfoModel?.referCount
                              .toString() ??
                          '0',
                    );
                  },
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).hintColor,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: textRegular.copyWith(
          color: Theme.of(context).colorScheme.secondaryContainer,
          fontSize: Dimensions.fontSizeSmall,
        ),
      ),
    );
  }
}
