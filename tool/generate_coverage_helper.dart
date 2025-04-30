// ignore_for_file: all
import 'dart:io';

void main() {
  final outputFile = File('test/coverage_helper_test.dart');
  final buffer = StringBuffer();

  buffer.writeln('// ignore_for_file: all');
  buffer.writeln('// coverage:ignore-file');
  buffer.writeln('// GENERATED FILE. DO NOT EDIT MANUALLY.\n');
  buffer.writeln('import \'package:flutter_test/flutter_test.dart\';');

  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('ERROR: lib/ directory not found.');
    exit(1);
  }

  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) =>
          file.path.endsWith('.dart') &&
          !file.path
              .endsWith('.g.dart') && // esclude file generati tipo freezed
          !file.path.contains('generated_plugin_registrant.dart'))
      .toList();

  for (final file in dartFiles) {
    final relativePath = file.path.replaceAll('\\', '/');
    final importPath = relativePath.substring('lib/'.length);
    buffer.writeln('import \'package:avis_donation_management/$importPath\';');
  }

  buffer.writeln('\nvoid main() {');
  buffer.writeln(
      '  test(\'dummy coverage test\', () { expect(true, isTrue); });');
  buffer.writeln('}');

  outputFile.writeAsStringSync(buffer.toString());
  print(
      'coverage_helper_test.dart generated with ${dartFiles.length} imports.');
}
