import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    var content = file.readAsStringSync();
    if (content.contains('package:hash_code/')) {
      final updated = content.replaceAll('package:hash_code/', 'package:credit_debit/');
      file.writeAsStringSync(updated);
      print('Updated imports in: ${file.path}');
    }
  }
}
