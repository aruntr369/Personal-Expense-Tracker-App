import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/styles/app_colors.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    this.mainPadding,
    this.label,
    this.hintText,
    this.hintTextStyle,
    this.labelTextStyle,
    this.contentPadding,
    this.mandatory = false,
    this.error = false,
    this.customBorder,
    this.enabledBorder,
    this.disableBorder,
    this.prefixIcon,
    this.prefix,
    this.suffixIconPadding,
    this.suffixIcon,
    this.controller,
    this.readOnly = false,
    this.removePadding = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines,
    this.maxLength,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onSaved,
    this.onTap,
    this.autoValidateMode,
    this.suffixIconConstraints,
    this.action,
    this.prefixCallback,
    this.initialValue,
    this.focusNode,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.isDense = false,
  });

  final EdgeInsetsGeometry? mainPadding;
  final EdgeInsets? contentPadding;
  final String? label;
  final String? hintText;
  final TextStyle? hintTextStyle;
  final TextStyle? labelTextStyle;
  final bool mandatory;
  final bool error;
  final bool removePadding;
  final InputBorder? customBorder;
  final InputBorder? enabledBorder;
  final InputBorder? disableBorder;

  final BoxConstraints? suffixIconConstraints;
  final TextInputAction? action;
  final VoidCallback? prefixCallback;
  final FocusNode? focusNode;

  final Widget? prefixIcon;
  final Widget? prefix;
  final EdgeInsetsGeometry? suffixIconPadding;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final bool readOnly;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String? value)? validator;
  final void Function(String value)? onChanged;
  final void Function(String value)? onFieldSubmitted;
  final void Function(String? value)? onSaved;
  final AutovalidateMode? autoValidateMode;
  final void Function()? onTap;
  final String? initialValue;
  final bool isDense;
  final EdgeInsets scrollPadding;

  @override
  Widget build(BuildContext context) {
    InputBorder border = OutlineInputBorder(
      borderSide: BorderSide(color: error ? Colors.red : Palette.borderGrey),
      borderRadius: BorderRadius.circular(10),
    );
    InputBorder focusedBorder = OutlineInputBorder(
      borderSide: BorderSide(color: error ? Colors.red : Palette.borderGrey2),
      borderRadius: BorderRadius.circular(10),
    );

    final textScaler = MediaQuery.textScalerOf(context);

    return Container(
      padding: mainPadding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label == null
              ? const SizedBox()
              : Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: RichText(
                  textScaler: textScaler,
                  text: TextSpan(
                    text: label,
                    style:
                        labelTextStyle ??
                        TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          color: Palette.black,
                        ),
                    children:
                        mandatory
                            ? [
                              const TextSpan(
                                text: '*',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ]
                            : [],
                  ),
                ),
              ),
          TextFormField(
            scrollPadding: scrollPadding,
            focusNode: focusNode,
            onTap: onTap,
            autovalidateMode:
                autoValidateMode ?? AutovalidateMode.onUserInteraction,
            textInputAction: action,
            decoration: InputDecoration(
              fillColor: Palette.white,
              alignLabelWithHint: false,
              filled: true,
              errorMaxLines: 2,
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: Palette.black,
              ),
              contentPadding:
                  removePadding
                      ? EdgeInsets.symmetric(horizontal: 4, vertical: 2)
                      : contentPadding,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              isDense: true,
              border: customBorder ?? border,
              enabledBorder: enabledBorder ?? border,
              disabledBorder: disableBorder ?? border,
              focusedBorder: focusedBorder,
              hintText: hintText,
              hintStyle:
                  hintTextStyle ??
                  TextStyle(
                    fontSize: 14,
                    color: Palette.borderGrey,
                    fontWeight: FontWeight.w300,
                  ),
              prefixIcon: setupPrefixIcon(),
              prefix: prefix,
              prefixIconConstraints: const BoxConstraints(),
              suffixIcon: Padding(
                padding: suffixIconPadding ?? EdgeInsets.zero,
                child: suffixIcon,
              ),
              suffixIconConstraints:
                  suffixIconConstraints ?? const BoxConstraints(),
            ),
            style: TextStyle(
              color: Palette.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            maxLines: maxLines ?? 1,
            maxLength: maxLength,
            readOnly: readOnly,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            inputFormatters: inputFormatters,
            validator: validator,
            onChanged: onChanged,
            onFieldSubmitted: onFieldSubmitted,
            onSaved: onSaved,
            initialValue: initialValue,
            controller: controller,
          ),
        ],
      ),
    );
  }

  Widget? setupPrefixIcon() {
    if (prefixIcon == null) {
      return null;
    } else {
      return GestureDetector(onTap: prefixCallback, child: prefixIcon);
    }
  }
}
