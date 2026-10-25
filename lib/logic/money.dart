/// The only place money is formatted or parsed. Money is always an int of
/// kobo (100 kobo = 1 naira).
library;

/// Formats [kobo] as naira: `₦2,500` for whole naira, `₦1,250.50` otherwise.
/// Negative amounts get a leading minus: `-₦500`.
String formatNaira(int kobo) {
  final sign = kobo < 0 ? '-' : '';
  final abs = kobo.abs();
  final naira = _groupThousands(abs ~/ 100);
  final remainder = abs % 100;
  final fraction = remainder == 0
      ? ''
      : '.${remainder.toString().padLeft(2, '0')}';
  return '$sign₦$naira$fraction';
}

/// Parses user input such as `2500`, `2,500`, `₦2,500.5` or `1250.50` into
/// kobo. Returns null if the text is not a valid non-negative amount with at
/// most two decimal places.
int? parseNairaToKobo(String input) {
  var text = input.trim().replaceAll(' ', '');
  if (text.startsWith('₦')) text = text.substring(1);
  if (!_plain.hasMatch(text) && !_grouped.hasMatch(text)) return null;

  final [whole, ...rest] = text.replaceAll(',', '').split('.');
  if (whole.length > _maxNairaDigits) return null;
  final fraction = rest.isEmpty ? '00' : rest.single.padRight(2, '0');
  return int.parse(whole) * 100 + int.parse(fraction);
}

/// Tidies what the user is typing in an amount field: keeps digits and one
/// decimal point, at most two decimal places, drops leading zeros and groups
/// thousands, e.g. `"2500"` → `"2,500"` and `"01250.505"` → `"1,250.50"`.
String formatNairaInput(String input) {
  final cleaned = input.replaceAll(RegExp(r'[^0-9.]'), '');
  if (cleaned.isEmpty) return '';
  final dot = cleaned.indexOf('.');
  var whole = dot == -1 ? cleaned : cleaned.substring(0, dot);
  var fraction = dot == -1
      ? null
      : cleaned.substring(dot + 1).replaceAll('.', '');
  whole = whole.replaceFirst(RegExp(r'^0+(?=\d)'), '');
  if (whole.isEmpty && fraction != null) whole = '0';
  if (whole.length > _maxNairaDigits) {
    whole = whole.substring(0, _maxNairaDigits);
  }
  if (fraction != null && fraction.length > 2) {
    fraction = fraction.substring(0, 2);
  }
  final grouped = whole.isEmpty ? '' : _groupThousands(int.parse(whole));
  return fraction == null ? grouped : '$grouped.$fraction';
}

final _plain = RegExp(r'^\d+(\.\d{1,2})?$');
final _grouped = RegExp(r'^\d{1,3}(,\d{3})+(\.\d{1,2})?$');

/// Keeps `naira * 100` well inside a 64-bit int and inside JavaScript's safe
/// integer range on web.
const _maxNairaDigits = 13;

String _groupThousands(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
