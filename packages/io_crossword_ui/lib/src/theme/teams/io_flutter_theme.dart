import 'package:flutter/material.dart';
import 'package:io_crossword_ui/io_crossword_ui.dart';

/// The Flutter team theme for IO Crossword.
class IoFlutterTheme extends IoCrosswordTheme {
  @override
  ColorScheme get colorScheme => super.colorScheme.copyWith(
        primary: IoCrosswordColors.seedBlue,
      );

  @override
  IoColorScheme get ioColorScheme {
    return const IoColorScheme(
      primaryGradient: IoCrosswordColors.dashGradient,
    );
  }
}
