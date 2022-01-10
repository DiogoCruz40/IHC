import 'package:flutter/material.dart';

import '../constants/color_constants.dart';

class LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Center(
        child: CircularProgressIndicator(
          color: ColorConstants.themeColor,
        ),
      ),
      color: Colors.white.withOpacity(0.8),
    );
  }
}
