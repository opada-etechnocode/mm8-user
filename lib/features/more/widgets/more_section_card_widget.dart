import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class MoreSectionCard extends StatelessWidget {
  final List<Widget> children;

  const MoreSectionCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeController>(context).darkTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: .06)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge),
        border: Border.all(
          color: Theme.of(context).hintColor.withValues(alpha: isDark ? .08 : .12),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withValues(alpha: .06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  indent: 70,
                  endIndent: Dimensions.paddingSizeDefault,
                  color: Theme.of(context).hintColor.withValues(alpha: .15),
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

class MoreSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const MoreSectionTitle({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeLarge,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
      ),
      child: Row(
        children: [

          const SizedBox(width: Dimensions.paddingSizeSmall),
          Text(
            title,
            style: textBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}

class MoreAuthButton extends StatelessWidget {
  final String title;
  final bool isLoggedIn;
  final VoidCallback onTap;

  const MoreAuthButton({
    super.key,
    required this.title,
    required this.isLoggedIn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: Material(
        color: isLoggedIn
            ? Theme.of(context).colorScheme.error.withValues(alpha: .08)
            : Theme.of(context).primaryColor.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeDefault,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
                  color: isLoggedIn
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: Dimensions.paddingSizeEight),
                Text(
                  title,
                  style: textMedium.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: isLoggedIn
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
