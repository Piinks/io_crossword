import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_crossword_ui/io_crossword_ui.dart';

void main() {
  group('$IoAndroidTheme', () {
    test('themeData returns normally', () {
      expect(() => IoAndroidTheme().themeData, returnsNormally);
    });

    group('OutlinedButtonThemeData', () {
      final outlinedBorder =
          IoAndroidTheme().themeData.outlinedButtonTheme.style!.shape!;

      test('displays StadiumBorder with ${MaterialState.disabled}', () {
        expect(
          outlinedBorder.resolve({MaterialState.disabled}),
          equals(isA<StadiumBorder>()),
        );
      });

      test('displays GradientOutlinedBorder when there are no states', () {
        expect(
          outlinedBorder.resolve({}),
          equals(
            isA<GradientStadiumBorder>().having(
              (border) => border.gradient,
              'Android gradient',
              IoCrosswordColors.androidGradient,
            ),
          ),
        );
      });

      for (final state in MaterialState.values.toList()
        ..remove(MaterialState.disabled)) {
        test('displays GradientOutlinedBorder with $state', () {
          expect(
            outlinedBorder.resolve({state}),
            equals(
              isA<GradientStadiumBorder>().having(
                (border) => border.gradient,
                'Android gradient',
                IoCrosswordColors.androidGradient,
              ),
            ),
          );
        });
      }
    });
  });
}
