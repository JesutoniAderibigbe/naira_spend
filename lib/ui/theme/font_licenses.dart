import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Adds the SIL OFL licences of the bundled fonts to the app's licence page.
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (family, file) in [
      ('Sora', 'assets/fonts/OFL-Sora.txt'),
      ('Manrope', 'assets/fonts/OFL-Manrope.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks([
        family,
      ], await rootBundle.loadString(file));
    }
  });
}
