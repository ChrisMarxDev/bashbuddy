// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';

const kWhite = Color(0xFFFFFFFF);
const kBlack = Color(0xFF000000);
const whiteText = kWhite;
const whiteBackground = Color(0xFFFFFFFF);

const deactivateGrey = Colors.grey;

const summaryGrey = Color(0xFFd2d2d2);
const summaryNotScheduled = weakestGrey;
const weakestGrey = Color(0x99b2b2b2);
const weakGrey = Color(0xCCb2b2b2);
const chartGrey = Color(0xFFa2a2a2);

const darkSecondaryBackground = Color(0xFF0e0e0e);

// ACTUAL COLORS
const kWhiteOnPrimary = Color(0xFFFFFFFF);
const kInactiveGrey = Color(0xFFE0DDDC);
const kTextG1 = kGreyOriginal;
const kAshOriginal = Color(0xFF747C94);
const kAshLighten_1 = Color(0xFF82899F);
const kAshLighten_2 = Color(0xFF9197AA);
const kAshLighten_3 = Color(0xFF9FA4B5);
const kAshLighten_4 = Color(0xFFADB2BF);
const kCharcoalOriginal = Color(0xFF394B5B);
const kCharcoalLighten_1 = Color(0xFF4D5D6C);
const kCharcoalLighten_2 = Color(0xFF61707C);
const kCharcoalLighten_3 = Color(0xFF76828D);
const kCharcoalLighten_4 = Color(0xFF8A949E);
const kGreyOriginal = Color(0xFF353B3C);
const kGreyLighten_1 = Color(0xFF4A4F50);
const kGreyLighten_2 = Color(0xFF686D6E);
const kGreyLighten_3 = Color(0xFF878B8C);
const kGreyLighten_4 = Color(0xFFA6A9A9);
const kGreyLighten_5 = Color(0xFFC5C7C7);
const kGreyLighten_6 = Color(0xFFE4E5E5);
const kGreyLighten_7 = Color(0xFFF9F9F9);
const kDarkBackground = Color(0xFF353B3C);
// ACTUAL COLORS

const primary = Color(0xFF81D1D4);
const primaryMiddle = Color(0xFF0A8C91);
const primaryDark = Color(0xFF05444A);
const accentRed = Color(0xFFEA5E41);
const accentYellow = Color(0xFFF7CF42);

const paletteColor1 = Color(0xFFFFC107);
const paletteColor2 = Color(0xFF00BCD4);
const paletteColor3 = Color(0xFF8BC34A);
const paletteColor4 = Color(0xFF9C27B0);
const paletteColor5 = Color(0xFFFF9800);
const paletteColor6 = Color(0xFF009688);
const paletteColor7 = Color(0xFF3F51B5);
const paletteColor8 = Color(0xFF4CAF50);
const paletteColor9 = Color(0xFFF44336);

const backgroundYellow = Color(0xFFFFECC3);
const brown = Color(0xFFD1B799);

const kShadow = BoxShadow(
  color: Colors.black12,
  blurRadius: 4,
  spreadRadius: 4,
  offset: Offset(0, 2),
);

ThemeData themeData({required bool isDark}) {
  const primaryColor = primaryMiddle;
  final secondaryColor = isDark ? primary : primaryDark;

  // final primaryColorDark = primaryColor;
  // final secondaryColorDark = secondaryColor;

  const onPrimary = kWhiteOnPrimary;
  const onSecondary = kWhiteOnPrimary;

  // final mainTextColor = isDark ? whiteText : kTextG1;

  final textTheme = textThemeGenerator(
    dark: isDark,
  );

  final background = isDark ? kDarkBackground : kWhite;
  return ThemeData(
    splashFactory: InkRipple.splashFactory,
    // splashColor: Colors.white.withOpacity(0.3),
    inputDecorationTheme: InputDecorationTheme(
      border: inputBorder(),
      enabledBorder: inputBorder(),
      hintStyle:
          TextStyle(color: isDark ? weakestGrey : weakestGrey),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        side: MaterialStatePropertyAll(
          BorderSide(color: secondaryColor),
        ),
      ),
    ),

    colorScheme: isDark
        ? ColorScheme.dark(
            primary: primaryColor,
            onPrimary: onPrimary,
            secondary: secondaryColor,
            onSecondary: onSecondary,
            background: background,
          )
        : ColorScheme.light(
            onPrimary: onPrimary,
            primary: primaryColor,
            secondary: secondaryColor,
            onSecondary: onSecondary,
            background: background,
          ),
    appBarTheme: AppBarTheme(
      elevation: 0.5,
      foregroundColor: isDark ? kWhite : kTextG1,
      backgroundColor: background,
      centerTitle: true,
      // shape:  UnderlineInputBorder(borderSide: BorderSide(color: kGreyLighten_4)),
    ),
    fontFamily: 'OpenSans',
    // inputDecorationTheme: ,
    iconTheme: const IconThemeData(
      color: primaryColor,
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: isDark ? background : kWhite,
    ),
    disabledColor: kInactiveGrey,
    textTheme: textTheme,
    dialogTheme: dialogTheme(
      dark: isDark,
      textTheme: textTheme,
      secondaryColor: secondaryColor,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: background,
      selectedIconTheme: const IconThemeData(
        color: primaryColor,
      ),
      unselectedIconTheme: const IconThemeData(
        color: kGreyLighten_4,
      ),
    ),
    // dividerTheme: const DividerThemeData(color: ),
    scaffoldBackgroundColor: isDark ? kDarkBackground : whiteBackground,
    cardColor: isDark ? kDarkBackground : whiteBackground,

    cardTheme: CardTheme(
      color: isDark ? kDarkBackground : whiteBackground,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: Dimens.borderRadius,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        padding: const MaterialStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        foregroundColor: MaterialStateProperty.all(primaryColor),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(0),
        side: MaterialStateProperty.all(
          const BorderSide(
            style: BorderStyle.solid,
            color: primaryColor,
            width: 1,
          ),
        ),
        shape: MaterialStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: Dimens.borderRadius,
          ),
        ),
        foregroundColor: MaterialStateProperty.all(primaryColor),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        padding: const MaterialStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        elevation: MaterialStateProperty.all(0),
        shape: MaterialStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: Dimens.borderRadius,
          ),
        ),
        foregroundColor: MaterialStateProperty.all(whiteText),
        backgroundColor: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.disabled)) {
              return kInactiveGrey;
            }
            // if (states.contains(MaterialState.pressed)) {
            //   return kInactiveGrey;
            // }
            return primaryColor;
          },
        ),
      ),
    ),
  );
}

OutlineInputBorder inputBorder() {
  return const OutlineInputBorder(
    borderRadius: Dimens.borderRadius,
    borderSide: BorderSide(
      color: kGreyLighten_6,
      width: 1,
    ),
  );
}

DialogTheme dialogTheme({
  required bool dark,
  required TextTheme textTheme,
  required Color secondaryColor,
}) =>
    DialogTheme(
      // backgroundColor: dark ? blackBackground : white,
      elevation: 12,
      shape: const RoundedRectangleBorder(
        borderRadius: Dimens.borderRadius,
      ),
      contentTextStyle: textTheme.bodyMedium,
    );

TextTheme textThemeGenerator({
  required bool dark,
}) {
  // final mainTextColor = dark ? whiteText : blackText;
  final mainTextColor = dark ? whiteText : kTextG1;
  // final mainTextColorAlt = dark ? whiteText : kTextG1;
  const fontFamily = 'OpenSans';
  return TextTheme(
   bodyLarge: TextStyle(
      color: mainTextColor,
      fontFamily: fontFamily,
    ),
    bodyMedium: TextStyle(
      color: mainTextColor,
      fontFamily: fontFamily,
    ),
    bodySmall: TextStyle(
      color: mainTextColor,
      fontFamily: fontFamily,
    ),
    displayMedium: const TextStyle(
        fontWeight: FontWeight.w500, fontSize: 46, color: primaryDark),
    // titleLarge: TextStyle(
    //   fontWeight: FontWeight.normal,
    //   fontSize: 30,
    //   fontFamily: fontFamily,
    //   color: mainTextColor,
    // ),
labelMedium: const TextStyle(color: weakestGrey),
labelSmall: const TextStyle(color: weakestGrey),
    // overline: TextStyle(color: mainTextColor),
  );
}

class Dimens {
  static const double ratio05 = 0.5;
  static const double ratio075 = 0.75;
  static const double ratio125 = 1.25;
  static const double ratio2 = 2;

  static const double edgeRadius = 8;
  static const cornerRadius = Radius.circular(edgeRadius);
  static const borderRadius = BorderRadius.all(cornerRadius);
  static const double unit = 8;
  static const double unit2 = 16;
  static const double unit3 = 24;
  static const double contentMargin = unit3;
  static const double unit4 = 32;
  static const double unit6 = 48;
  static const double unit8 = 64;

  static const double bottomBarItemHeight = 52;

  static const double borderRadiusInput = 32;
  static const double borderRadiusInputCard = 24;
  static const double defaultIconSize = 32;
  static const double badgeIconSize = 32;
  static const double actionBarHeight = 64;
  static const double selectorButtonSize = 48;
  static const double checkBoxSize = 64;
  static const double checkBoxSizeBig = 96;
  static const double badgeWidth = 72;
  static const double actionBarBottomPadding = 64;
  static const double taskSelectorSize = 56;
  static const double onboardingSelectorRoutineSize = 92;

  static const double bottomNavBarRadius = 20;
}

class Animations {
  static const Duration baseDuration = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 700);
  static const Duration quickAnimation = Duration(milliseconds: 240);
  static const Duration waitDuration = Duration(milliseconds: 160);

  static const Curve baseCurve = Curves.easeIn;
}

extension ThemeExtensions on BuildContext {
  Color primary() {
    return Theme.of(this).colorScheme.primary;
  }

  ThemeData theme() {
    return Theme.of(this);
  }

  Color secondary() {
    return Theme.of(this).colorScheme.secondary;
  }

  TextTheme textTheme() {
    return Theme.of(this).textTheme;
  }

  ColorScheme colorScheme() {
    return Theme.of(this).colorScheme;
  }

  Color onPrimary() {
    return colorScheme().onPrimary;
  }

  Color mainTextColor() {
    return textTheme().bodyMedium!.color!;
  }

  Color weakTextColor() {
    return colorScheme().onPrimary;
  }

  bool isDark() {
    return theme().brightness != Brightness.light;
  }

  Color captionTextColor() {
    return isDark() ? kGreyLighten_4 : kGreyLighten_4;
  }

}

extension StyleExtension on TextStyle? {
  TextStyle? recolor(Color color) {
    return this?.copyWith(color: color);
  }
}

extension TextStyleExtension on TextStyle {
  TextStyle asBold() {
    return copyWith(fontWeight: FontWeight.w700);
  }

  TextStyle asExtraBold() {
    return copyWith(fontWeight: FontWeight.w800);
  }

  TextStyle asSemiBold() {
    return copyWith(fontWeight: FontWeight.w600);
  }

  TextStyle asPacifio() {
    return copyWith(fontFamily: 'Pacifico');
  }
}
