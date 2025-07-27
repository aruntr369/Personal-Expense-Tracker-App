import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../core/styles/app_colors.dart';

class CustomSubmitButton extends StatelessWidget {
  const CustomSubmitButton({
    super.key,
    this.buttonTitle,
    this.buttonWidget,
    this.onPressed,
    this.radius = 25,
    this.color = Palette.primary,
    this.buttonTitleColor = Colors.white,
    this.buttonTitleFontWeight = FontWeight.w600,
    this.buttonTitleFontSize = 16,
    this.buttonTitleStyle,
    this.height,
    this.isBusy = false,
    this.isBottomNavBar = false,
    this.left = 0,
    this.right = 0,
    this.leadingWidget,
    this.width,
  });
  final String? buttonTitle;
  final Widget? buttonWidget;
  final double radius;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? buttonTitleColor;
  final TextStyle? buttonTitleStyle;
  final FontWeight? buttonTitleFontWeight;
  final double? buttonTitleFontSize;
  final double? height;
  final bool isBusy;
  final bool isBottomNavBar;
  final Widget? leadingWidget;
  final double left;
  final double right;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          (isBottomNavBar)
              ? const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, -2),
                    blurRadius: 6,
                    color: Colors.black12,
                  ),
                ],
                color: Palette.scaffoldBackgroundColor,
              )
              : null,
      padding:
          (isBottomNavBar)
              ? EdgeInsets.symmetric(horizontal: 16, vertical: 16)
              : null,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(radius)),
        ),
        clipBehavior: Clip.hardEdge,
        width: width,
        height: height ?? 51,
        child: ElevatedButton(
          onPressed: (isBusy) ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: Visibility(
            visible: (!isBusy),
            replacement: submitButtonLoader(),
            child:
                buttonWidget ??
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: left, right: right),
                      child: leadingWidget ?? const SizedBox(),
                    ),
                    Text(
                      buttonTitle ?? '',
                      textAlign: TextAlign.center,
                      style: _setButtonTitleStyle(),
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
  }

  TextStyle _setButtonTitleStyle() {
    if (buttonTitleStyle == null) {
      return TextStyle(
        fontSize: buttonTitleFontSize,
        color: buttonTitleColor,
        fontWeight: buttonTitleFontWeight,
      );
    } else {
      return buttonTitleStyle!;
    }
  }
}

Widget submitButtonLoader({Color color = Colors.white, double? size}) {
  return SpinKitPulsingGrid(color: color, size: size ?? 20.0);
}
