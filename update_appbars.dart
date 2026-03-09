import 'dart:io';

void main() {
  final libDir = Directory('lib');
  final files = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  final appBarRegex = RegExp(r'(appBar:\s*AppBar\s*\((?:[^)(]+|\((?:[^)(]+|\([^)(]*\))*\))*\))', dotAll: true);

  for (final file in files) {
    if (!file.path.contains('screens') && !file.path.contains('page')) continue;

    var content = file.readAsStringSync();
    var original = content;

    content = content.replaceAllMapped(appBarRegex, (match) {
      String inner = match.group(1)!;

      inner = inner.replaceAll('backgroundColor: Colors.white', 'backgroundColor: Colors.transparent');
      inner = inner.replaceAll('foregroundColor: Colors.black', 'foregroundColor: AppColors.primaryColor');
      inner = inner.replaceAll('foregroundColor: Colors.black87', 'foregroundColor: AppColors.primaryColor');
      inner = inner.replaceAll('color: Colors.black', 'color: AppColors.primaryColor');
      inner = inner.replaceAll('color: Colors.black87', 'color: AppColors.primaryColor');

      return inner;
    });

    if (content != original) {
      if (content.contains('AppColors.primaryColor') && !content.contains('app_colors.dart')) {
        content = "import 'package:credit_debit/core/theme/app_colors.dart';\n" + content;
      }
      file.writeAsStringSync(content);
      print('Updated ${file.path}');
    }
  }
}
