import '../../core/app_colors.dart';
import '../../core/app_theme.dart';

import 'package:flutter/material.dart';

abstract final class InstructorUi {
  static const Color primary = AppColors.primaryBlue;
  static const Color primaryDark = AppColors.primaryBlue;
  static const Color accent = AppColors.green;
  static const Color background = AppColors.background;
  static const Color surface = Colors.white;
  static const Color text = AppColors.darkText;
  static const Color muted = AppColors.secondaryText;
  static const Color border = AppColors.inputBorder;

  static ThemeData theme(BuildContext context) => AppTheme.light;
}

Widget instructorScaffold({
  required BuildContext context,
  Color? backgroundColor,
  PreferredSizeWidget? appBar,
  Widget? body,
  Widget? floatingActionButton,
  FloatingActionButtonLocation? floatingActionButtonLocation,
  Widget? bottomNavigationBar,
  Widget? bottomSheet,
  bool? resizeToAvoidBottomInset,
  bool primary = true,
  bool extendBody = false,
  bool extendBodyBehindAppBar = false,
}) {
  return Theme(
    data: InstructorUi.theme(context),
    child: Scaffold(
      backgroundColor: backgroundColor ?? InstructorUi.background,
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      primary: primary,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    ),
  );
}
