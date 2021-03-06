import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_basecomponent/Util.dart';

class StandardAppBar extends PreferredSize {
  final String text;
  final double fontSize;
  final double height;
  final Color backgroundColor;
  final Color fontColor;
  final Color backIconColor;
  final List<Widget> trailingActions;

  @override
  Size get preferredSize => Size.fromHeight(52);

  const StandardAppBar(
      {Key key,
      @required this.text,
      this.fontColor,
      this.backgroundColor,
      this.fontSize,
      this.height,
      this.backIconColor,
      this.trailingActions});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: this.height != null
          ? Size.fromHeight(Util.responsiveSize(context, this.height))
          : Size.fromHeight(Util.responsiveSize(context, 52)),
      child: PlatformAppBar(
        leading: Navigator.of(context).canPop() ? Material(
          color: Colors.transparent,
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: backIconColor ?? Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ): SizedBox(),
        trailingActions: this.trailingActions ?? [],
        backgroundColor: this.backgroundColor ?? Colors.white,
        title: Text(
          this.text,
          style: TextStyle(
              fontSize: this.fontSize ?? Util.responsiveSize(context, 20),
              color: this.fontColor ?? Colors.black),
        ),
      ),
    );
  }
}
