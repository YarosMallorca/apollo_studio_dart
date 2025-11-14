import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

// Decompress
Uint8List fromCompressedBase64(String input) {
  bool inCompressed = false;
  bool readingChar = true;
  late int compressedChar;
  final count = StringBuffer();
  final res = StringBuffer();

  for (var rune in input.runes) {
    final c = rune;

    if (c == '{'.codeUnitAt(0)) {
      inCompressed = true;
      readingChar = true;
      continue;
    }

    if (c == '}'.codeUnitAt(0)) {
      // Decode the base64-64 number
      int numCount = 0;
      final cnt = count.toString();

      for (int i = cnt.length - 1; i >= 0; i--) {
        final digit = cnt.codeUnitAt(i) - 48;
        numCount |= (digit << (6 * (cnt.length - i - 1)));
      }

      for (int i = 0; i < numCount; i++) {
        res.writeCharCode(compressedChar);
      }

      count.clear();
      inCompressed = false;
      readingChar = false;
      continue;
    }

    if (inCompressed) {
      if (readingChar) {
        compressedChar = c;
        readingChar = false;
      } else {
        count.writeCharCode(c);
      }
    } else {
      res.writeCharCode(c);
    }
  }

  // Now convert the expanded Base64 to bytes
  return Uint8List.fromList(base64Decode(res.toString()));
}

// Compress
String toCompressedBase64(String input) {
  final arr = input.split('');
  List<_Seq> data = [];

  String? current;
  for (var c in arr) {
    if (c == current) {
      data.last.n++;
    } else {
      current = c;
      data.add(_Seq(c, 1));
    }
  }

  final out = StringBuffer();

  for (final t in data) {
    int n = t.n;
    final log = (n > 1) ? (log64(n) + 1) : 1;

    if (3 + log < n) {
      // Output compressed block
      final chars = <String>[];

      while (n > 0) {
        chars.add(String.fromCharCode((n % 64) + 48));
        n >>= 6;
      }

      out.write('{');
      out.write(t.c);
      out.writeAll(chars.reversed);
      out.write('}');
    } else {
      // Write repeated chars normally
      out.write(t.c * t.n);
    }
  }

  return out.toString();
}

class _Seq {
  String c;
  int n;
  _Seq(this.c, this.n);
}

int log64(int n) => (math.log(n) / math.log(64)).floor();
