import 'dart:convert';

class UnmetafyEncoding extends Encoding {
  @override
  Converter<List<int>, String> get decoder {
    return _UnmetafyDecoder();
  }

  @override
  Converter<String, List<int>> get encoder {
    return _UnmetafyEncoder();
  }

  @override
  // TODO: implement name
  String get name => 'unmetafy';
}

class _UnmetafyDecoder extends Converter<List<int>, String> {
  @override
  String convert(List<int> input) {
    return unmetafy(String.fromCharCodes(input));
  }
}

class _UnmetafyEncoder extends Converter<String, List<int>> {
  @override
  List<int> convert(String input) {
    return unmetafy(input).codeUnits;
  }
}

String unmetafy(String s) {
  String p;
  String t;

  // for (p = s; p != null && p != Meta; p++) {}
  // for (t = p; (t = p++) != null) {
  //   if (t++ == Meta) {
  //     t[-1] = p++ ^ 32;
  //   }
  // }
  return s;
}

class CustomDecoder extends Converter<List<int>, String> {
  const CustomDecoder({bool allowMalformed = false})
      : super();

  @override
  String convert(List<int> codeUnits, [int start = 0, int? end]) {
    return unmetafy(String.fromCharCodes(codeUnits));
  }
}

class CustomEncoding extends Encoding {
  const CustomEncoding();

  @override
  Converter<List<int>, String> get decoder {
    return const CustomDecoder();
  }

  @override
  Converter<String, List<int>> get encoder {
    return const Utf8Encoder();
  }

  @override
  String get name => 'custom';
}