import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:term_buddy/util/color_util.dart';

import 'log.dart';

extension DateTimeExtension on DateTime {
  String toFormattedString() {
    return '$day/$month/$year';
  }

  String format() {
    return DateFormat.yMd().format(this);
  }

  String formatWithTime() {
    return '${format()} ${DateFormat.Hm().format(this)}';
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String clearOuterSingleQuotes() {
    var temp = this;
    if (temp.startsWith("'") || temp.startsWith('"')) {
      temp = temp.substring(1);
    }
    if (temp.endsWith("'") || temp.endsWith('"')) {
      temp = temp.substring(0, temp.length - 1);
    }
    return this;
  }

  String cleanOuterQuotes({bool escaped = false}) {
    if (startsWith('"') && endsWith('"')) {
      return substring(1, length - 1);
    } else if (startsWith("'") && endsWith("'")) {
      return substring(1, length - 1);
    }
    if (escaped) {
      if (startsWith('\"') && endsWith('\"')) {
        return substring(1, length - 1);
      } else if (startsWith("\'") && endsWith("\'")) {
        return substring(1, length - 1);
      }
    }
    return this;
  }

  String cleanSurround(String surround) {
    if (startsWith(surround) && endsWith(surround)) {
      return substring(1, length - 1);
    }
    return this;
  }

  List<String> splitOnAnd() {
    final s = this;
    final parts = <String>[];
    var buffer = '';
    var inQuotes = false;

    for (var i = 0; i < s.length; i++) {
      final char = s[i];
      if (char == '"') {
        inQuotes = !inQuotes;
        buffer += char;
      } else if (char == '&' &&
          i < s.length - 1 &&
          s[i + 1] == '&' &&
          !inQuotes) {
        parts.add(buffer);
        buffer = '';
        i++;
      } else {
        buffer += char;
      }
    }

    if (buffer.isNotEmpty) {
      parts.add(buffer);
    }

    return parts.map((e) => e.trim()).toList();
  }

  String take(int count) {
    return substring(0, min(count, length));
  }

  String tr() {
    return this;
  }
}

extension IntExtension on int {
  String toFormattedString() {
    return NumberFormat.compact().format(this);
  }

  String minutesToFormattedString() {
    return '${(this / 60).floor()}:${(this % 60).floor().toString().padLeft(2, '0')}';
  }

  String toWeekday() {
    switch (this) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';

      default:
        return '';
    }
  }
}

extension ListUtil<T> on List<T> {
  T random() {
    final rng = Random();
    return this[rng.nextInt(length)];
  }

  T? get firstOrNull {
    if (isNotEmpty) {
      return first;
    } else {
      return null;
    }
  }
}

extension WidgetListUtil on List<Widget> {
  List<Widget> get addVerticalSpaceBetween {
    final result = <Widget>[];
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) {
        result.add(const SizedBox(height: 8));
      }
    }
    return result;
  }

  List<Widget> separatedBy(Widget separator) {
    final result = <Widget>[];
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) {
        result.add(separator);
      }
    }
    return result;
  }

  List<Widget> randomColors() {
    return map((e) => Container(color: randomCardColor(), child: e)).toList();
  }
}

extension ColorUtil on Color {
  Color withOpacity(double opacity) {
    return Color.fromRGBO(red, green, blue, opacity);
  }

  List<Color> whiteStep(int steps) {
   return lerpStep(Colors.white, steps);
  }

  List<Color> lerpStep(Color other, int steps) {
    final result = <Color>[];

    for (var i = 0; i < steps; i++) {
      final opacity = 1 - (i / steps);
      result.add(Color.lerp(this, other, opacity)!);
    }
    return result;
  }
}

extension SetUtil<T> on Set<T> {
  // removes the element if it is present and adds it if it is not present
  Set<T> toggle(T element) {
    if (contains(element)) {
      return this..remove(element);
    } else {
      return this..add(element);
    }
  }

  T? get firstOrNull {
    if (isNotEmpty) {
      return first;
    } else {
      return null;
    }
  }
}

extension MapUtil<K, V> on Map<K, V> {
  Map<K, V> addAllIfNotNull(Map<K, V> other) {
    if (other.isNotEmpty) {
      return this..addAll(other);
    } else {
      return this;
    }
  }

  Map<K, V> addIfNotNull(K key, V value) {
    if (value != null) {
      return this..[key] = value;
    } else {
      return this;
    }
  }

  void printEntries([String? tag]) {
    final loglines = entries.fold('', (value, element) {
      return '$value \n${element.key}: ${element.value}';
    });
    logger.i('Mapentries $length entries $tag: \n $loglines');
  }
}

extension HttpResponseExtension on http.Response {
  T parse<T>(T Function(dynamic) fromJson) {
    return fromJson(jsonDecode(body));
  }
}
