import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppInputField extends StatelessWidget {
  final String? label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool obscure;
  final bool? obscureText;
  final Widget? prefixIcon;
  final IconData? icon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final VoidCallback? onTap;

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
    this.icon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textColorPrimary,
            ),
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
              prefixIcon: (prefixIcon != null || icon != null)
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: IconTheme(
                        data: const IconThemeData(color: AppColors.primaryColor, size: 20),
                        child: prefixIcon ?? Icon(icon),
                      ),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(minWidth: 48),
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
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              errorStyle: const TextStyle(height: 0, fontSize: 0), // Hide default error
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),
        // Custom error message outside container
        if (validator != null)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller ?? TextEditingController(),
            builder: (context, value, child) {
              final error = validator!(value.text);
              if (error != null && value.text.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 14,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          error,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }
}
