import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:webapp/logger.dart';

void toast(String msg, BuildContext context,
    {int seconds = 5, bool debugMode = true}) {
  showToast(msg,
      context: context,
      duration: Duration(seconds: seconds),
      animation: StyledToastAnimation.slideFromBottom,
      reverseAnimation: StyledToastAnimation.slideFromBottom
  );
  if (debugMode) logger.fine(msg);
}
