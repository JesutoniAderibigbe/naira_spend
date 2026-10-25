/// Rules for the Add expense form. Each returns an error message, or null
/// when the value is fine.
library;

import 'lagos_time.dart';
import 'money.dart';

const maxTitleLength = 60;

String? validateAmount(String text) {
  if (text.trim().isEmpty) return 'Enter an amount';
  final kobo = parseNairaToKobo(text);
  if (kobo == null) return 'Enter an amount like 2,500 or 1,250.50';
  if (kobo == 0) return 'Amount must be more than ₦0';
  return null;
}

String? validateTitle(String text) {
  final title = text.trim();
  if (title.isEmpty) return 'Say what you bought';
  if (title.length > maxTitleLength) {
    return 'Keep it under $maxTitleLength characters';
  }
  return null;
}

/// [day] is a Lagos day from [lagosDay]. It may not be after today.
String? validateDay(DateTime day, DateTime now) {
  if (day.isAfter(lagosDay(now))) return "The date can't be in the future";
  return null;
}
