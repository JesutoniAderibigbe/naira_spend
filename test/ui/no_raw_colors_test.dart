import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Colours come from the theme. Only lib/ui/theme/ may define them.
void main() {
  test('no raw colour values outside lib/ui/theme', () {
    final rawColor = RegExp(
      r'Color\(\s*0x|Color\.from(ARGB|RGBO)\(|\bColors\.(?!transparent\b)\w+',
    );
    final offenders = <String>[];

    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.replaceAll(r'\', '/').contains('lib/ui/theme/'));

    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trimLeft();
        if (line.startsWith('//')) continue;
        if (rawColor.hasMatch(line)) {
          offenders.add('${file.path}:${i + 1}: ${line.trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Use Theme.of(context).colorScheme or a theme extension instead:\n'
          '${offenders.join('\n')}',
    );
  });
}
