import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_text.dart';



/*class AppInputField extends StatefulWidget {
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
  final bool isRequired;

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
    this.isRequired = false,
  }) : super(key: key);

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  String? _errorText;
  final _formFieldKey = GlobalKey<FormFieldState>();
  final FocusNode _focusNode = FocusNode();

  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    widget.controller?.addListener(_onTextChanged);

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_formFieldKey.currentState != null) {
      final isValid = _formFieldKey.currentState!.validate();

      if (!isValid && widget.validator != null) {
        final error = widget.validator!(widget.controller?.text);

        if (mounted && error != _errorText) {
          setState(() {
            _errorText = error;
          });
        }
      } else if (isValid && _errorText != null) {
        if (mounted) {
          setState(() {
            _errorText = null;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _isFocused
        ? AppColors.primaryColor
        : (_errorText != null ? Colors.red : AppColors.slate200);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        *//*if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textColorPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],*//*
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              text: widget.label!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textColorPrimary,
              ),
              children: widget.isRequired
                  ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]
                  : [],
            ),
          ),
          const SizedBox(height: 8),
        ],

        /// 🔥 Input Box
        ClipRRect(
            borderRadius: BorderRadius.circular(16),
            // child: AnimatedContainer(
            *//*duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: widget.enabled
                  ? AppColors.slate50
                  : AppColors.slate100.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
            ),*//*
            child: TextFormField(
              focusNode: _focusNode,
              controller: widget.controller,
              obscureText:
              widget.obscureText ?? (widget.isPassword || widget.obscure),

              validator: (value) {
                if (widget.validator != null) {
                  final error = widget.validator!(value);

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && error != _errorText) {
                      setState(() {
                        _errorText = error;
                      });
                    }
                  });

                  return error;
                }
                return null;
              },

              decoration: InputDecoration(
                hintText: widget.hint,

                filled: true,
                fillColor: widget.enabled
                    ? AppColors.slate50
                    : AppColors.slate100.withValues(alpha: 0.5),

                /// 🔥 NORMAL BORDER
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.slate200,
                    width: 1.5,
                  ),
                ),

                /// 🔥 FOCUS BORDER
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 1.5,
                  ),
                ),

                /// 🔴 ERROR BORDER
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 1.5,
                  ),
                ),

                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 1.5,
                  ),
                ),

                prefixIcon: widget.prefixIcon ?? (widget.icon != null ? Icon(widget.icon) : null),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),

                contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

                errorStyle: const TextStyle(height: 0, fontSize: 0),
              ),
            )
        ),
        // ),

        /// 🔴 Custom Error
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 16,
                  color: Colors.red,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _errorText!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}



import 'package:flutter/material.dart';
import '../theme/app_colors.dart';*/





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
  final bool isRequired;


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
    this.isRequired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // if (label != null) ...[
        //   AppText(
        //     label!,
        //     style: AppTextStyle.label,
        //   ),
        //   const SizedBox(height: 8),
        // ],


        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label!,
              style: const TextStyle(
                //fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textColorPrimary,
              ),
              children: isRequired
                  ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]
                  : [],
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