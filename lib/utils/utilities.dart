import 'package:flutter/material.dart';

class Utilities {
  static bool isKeyboardShowing() {
    if (WidgetsBinding.instance != null) {
      return WidgetsBinding.instance!.window.viewInsets.bottom > 0;
    } else {
      return false;
    }
  }

  static closeKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}
