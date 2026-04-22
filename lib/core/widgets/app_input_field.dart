import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_text.dart';

class AppInputField extends StatelessWidget {
  final String? label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool obscure;
  final bool? obscureText;
  final Widget? prefixIcon;
  final Widget? prefix;
  final IconData? icon;
  final double iconSize;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final VoidCallback? onTap;
  final String? phoneCode;
  final VoidCallback? onPhoneCodeTap;

  const AppInputField({
    Key? key,
    this.label,
    required this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.obscure = false,
    this.obscureText,
    this.prefixIcon,
    this.prefix,
    this.icon,
    this.iconSize = 20,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.onTap,
    this.phoneCode,
    this.onPhoneCodeTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          AppText(
            label!,
            style: AppTextStyle.label,
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: enabled ? AppColors.slate50 : AppColors.slate100.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.slate200,
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText ?? (isPassword || obscure),
            validator: validator,
            onChanged: onChanged,
            enabled: enabled,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textColorPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textColorHint.withValues(alpha: 0.7),
              ),
              prefixIcon: (phoneCode != null || prefixIcon != null || icon != null)
                  ? Container(
                      padding: const EdgeInsets.only(left: 14, right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (phoneCode != null) ...[
                            GestureDetector(
                              onTap: onPhoneCodeTap,
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (icon != null) ...[
                                    Icon(icon, color: AppColors.primaryColor, size: iconSize),
                                    const SizedBox(width: 8),
                                  ],
                                  AppText(
                                    phoneCode!,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textColorPrimary,
                                  ),
                                  const Icon(Icons.arrow_drop_down, size: 20, color: AppColors.textColorSecondary),
                                  const SizedBox(width: 4),
                                  Container(
                                    height: 24,
                                    width: 1,
                                    color: AppColors.slate200,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ] else 
                            IconTheme(
                              data: IconThemeData(color: AppColors.primaryColor, size: iconSize),
                              child: prefixIcon ?? Icon(icon),
                            ),
                        ],
                      ),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(minWidth: 48),
              prefix: prefix,
              suffixIcon: suffixIcon != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: IconTheme(
                        data: const IconThemeData(color: AppColors.textColorHint, size: 20),
                        child: suffixIcon!,
                      ),
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(minWidth: 48),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(
                left: (prefixIcon != null || icon != null || prefix != null) ? 0 : 20,
                right: 20,
                top: 16,
                bottom: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
