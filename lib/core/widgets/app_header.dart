import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_colors.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? rightWidget;
  final VoidCallback? onBack;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;

  const AppHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.rightWidget,
    this.onBack,
    this.showBackButton = true,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool showLead = showBackButton && Navigator.of(context).canPop();

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: preferredSize.height,
      leadingWidth: showLead ? 56 : 16,
      leading: showLead
          ? Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onBack ?? () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: const Icon(Iconsax.arrow_left, size: 20, color: AppColors.textColorPrimary),
                  ),
                ),
              ),
            )
          : const SizedBox(),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
              letterSpacing: -0.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textColorSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ],
      ),
      actions: (trailing != null || rightWidget != null) ? [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: trailing ?? rightWidget!,
        )
      ] : null,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        72.0 + (subtitle != null ? 22.0 : 0) + (bottom != null ? bottom!.preferredSize.height : 0),
      );
}
