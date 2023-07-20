import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:term_buddy/util/extensions.dart';

import '../themes.dart';

const kGreenOriginal = Color(0xFF6FA16E);
const kGreenLighten_1 = Color(0xFF7EAB7D);
const kGreenLighten_2 = Color(0xFF8CB48C);
const kGreenLighten_3 = Color(0xFF9BBE9A);
const kGreenLighten_4 = Color(0xFFAAC7A9);
const kTurquoiseOriginal = Color(0xFF63A9A3);
const kTurquoiseLighten_1 = Color(0xFF72B2AD);
const kTurquoiseLighten_2 = Color(0xFF82BAB6);
const kTurquoiseLighten_3 = Color(0xFF92C3BF);
const kTurquoiseLighten_4 = Color(0xFFA2CCC9);
const kVioletOriginal = Color(0xFF9A89C8);
const kVioletLighten_1 = Color(0xFFA495CD);
const kVioletLighten_2 = Color(0xFFAEA1D3);
const kVioletLighten_3 = Color(0xFFB9ADD9);
const kVioletLighten_4 = Color(0xFFC3B9DE);
const kBlueOriginal = Color(0xFF4775AB);
const kBlueLighten_1 = Color(0xFF5A83B4);
const kBlueLighten_2 = Color(0xFF6D91BC);
const kBlueLighten_3 = Color(0xFF7F9FC5);
const kBlueLighten_4 = Color(0xFF92ADCD);
const kOrangeOriginal = Color(0xFFDF863B);
const kOrangeLighten_1 = Color(0xFFE2924F);
const kOrangeLighten_2 = Color(0xFFE69F63);
const kOrangeLighten_3 = Color(0xFFE9AB77);
const kOrangeLighten_4 = Color(0xFFECB78B);
const kRedOriginal = Color(0xFFC95841);
const kRedLighten_1 = Color(0xFFCF6954);
const kRedLighten_2 = Color(0xFFD47A68);
const kRedLighten_3 = Color(0xFFDA8B7B);
const kRedLighten_4 = Color(0xFFDF9C8E);
const kBraunOriginal = Color(0xFF92614D);
const kBraunLighten_1 = Color(0xFF9D715F);
const kBraunLighten_2 = Color(0xFFA88171);
const kBraunLighten_3 = Color(0xFFB39183);
const kBraunLighten_4 = Color(0xFFBEA196);
const kPinkOriginal = Color(0xFFD37690);
const kPinkLighten_1 = Color(0xFFD8849B);
const kPinkLighten_2 = Color(0xFFDC92A6);
const kPinkLighten_3 = Color(0xFFE1A0B2);
const kPinkLighten_4 = Color(0xFFE5AEBD);
const kYellowOriginal = Color(0xFFEBBD65);
const kYellowLighten_1 = Color(0xFFEDC474);
const kYellowLighten_2 = Color(0xFFEFCA84);
const kYellowLighten_3 = Color(0xFFF1D194);
const kYellowLighten_4 = Color(0xFFF3D8A4);
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

const paletteColors = [
  primary,
  primaryMiddle,
  primaryDark,
  accentRed,
  accentYellow,
  paletteColor1,
  paletteColor2,
  paletteColor3,
  paletteColor4,
  paletteColor5,
  paletteColor6,
  paletteColor7,
  paletteColor8,
  paletteColor9,
];

const primaryColors = [
  primary,
  primaryMiddle,
  primaryDark,
];

const allColors = [
  kGreenOriginal,
  kGreenLighten_1,
  kGreenLighten_2,
  kGreenLighten_3,
  kGreenLighten_4,
  kTurquoiseOriginal,
  kTurquoiseLighten_1,
  kTurquoiseLighten_2,
  kTurquoiseLighten_3,
  kTurquoiseLighten_4,
  kVioletOriginal,
  kVioletLighten_1,
  kVioletLighten_2,
  kVioletLighten_3,
  kVioletLighten_4,
  kBlueOriginal,
  kBlueLighten_1,
  kBlueLighten_2,
  kBlueLighten_3,
  kBlueLighten_4,
  kOrangeOriginal,
  kOrangeLighten_1,
  kOrangeLighten_2,
  kOrangeLighten_3,
  kOrangeLighten_4,
  kRedOriginal,
  kRedLighten_1,
  kRedLighten_2,
  kRedLighten_3,
  kRedLighten_4,
  kBraunOriginal,
  kBraunLighten_1,
  kBraunLighten_2,
  kBraunLighten_3,
  kBraunLighten_4,
  kPinkOriginal,
  kPinkLighten_1,
  kPinkLighten_2,
  kPinkLighten_3,
  kPinkLighten_4,
  kYellowOriginal,
  kYellowLighten_1,
  kYellowLighten_2,
  kYellowLighten_3,
  kYellowLighten_4,
  kAshOriginal,
  kAshLighten_1,
  kAshLighten_2,
  kAshLighten_3,
  kAshLighten_4,
  kCharcoalOriginal,
  kCharcoalLighten_1,
  kCharcoalLighten_2,
  kCharcoalLighten_3,
  kCharcoalLighten_4,
  kGreyOriginal,
  kGreyLighten_1,
  kGreyLighten_2,
  kGreyLighten_3,
  kGreyLighten_4,
  kGreyLighten_5,
  kGreyLighten_6,
  kGreyLighten_7,
];

Color randomCardColor() {
  return paletteColors.random();
}

class RandomColorFactory {
  RandomColorFactory([List<Color> colors = paletteColors])
      : colors = [...colors];

  final List<Color> colors;
  final List<Color> _usedColors = [];
  Color? holdOverColor;

  Color next() {
    if (colors.isEmpty) {
      holdOverColor = _usedColors.last;
      _usedColors.removeLast();
      colors.addAll(_usedColors);
      _usedColors.clear();
    } else if (holdOverColor != null) {
      colors.add(holdOverColor!);
      holdOverColor = null;
    }
    final color = colors.random();
    _usedColors.add(color);
    colors.remove(color);
    return color;
  }
}

class SequentialColorFactory {
  SequentialColorFactory([List<Color> colors = paletteColors])
      : colors = [...colors];

  final List<Color> colors;
  final List<Color> _usedColors = [];
  Color? holdOverColor;

  Color next() {
    if (colors.isEmpty) {
      holdOverColor = _usedColors.last;
      _usedColors.removeLast();
      colors.addAll(_usedColors);
      _usedColors.clear();
    } else if (holdOverColor != null) {
      colors.add(holdOverColor!);
      holdOverColor = null;
    }
    final color = colors.first;
    _usedColors.add(color);
    colors.remove(color);
    return color;
  }
}
