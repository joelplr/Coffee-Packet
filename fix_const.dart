import 'dart:io';

void main() async {
  final dir = Directory('lib');
  
  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = await entity.readAsString();
      bool changed = false;

      // Fix `const BoxDecoration(` and other common const usages that now have `context`
      if (content.contains('const BoxDecoration')) {
        content = content.replaceAllMapped(RegExp(r'const\s+BoxDecoration\([^)]*context\.theme'), (m) => m[0]!.replaceFirst('const ', ''));
        changed = true;
      }
      if (content.contains('const Icon') ) {
        content = content.replaceAllMapped(RegExp(r'const\s+Icon\([^)]*context\.theme'), (m) => m[0]!.replaceFirst('const ', ''));
        changed = true;
      }
      if (content.contains('const Divider')) {
        content = content.replaceAllMapped(RegExp(r'const\s+Divider\([^)]*context\.theme'), (m) => m[0]!.replaceFirst('const ', ''));
        changed = true;
      }
      if (content.contains('const TextStyle')) {
        content = content.replaceAllMapped(RegExp(r'const\s+TextStyle\([^)]*context\.theme'), (m) => m[0]!.replaceFirst('const ', ''));
        changed = true;
      }
      // specifically `const BorderSide`
      if (content.contains('const BorderSide')) {
        content = content.replaceAllMapped(RegExp(r'const\s+BorderSide\([^)]*context\.theme'), (m) => m[0]!.replaceFirst('const ', ''));
        changed = true;
      }

      if (changed) {
        await entity.writeAsString(content);
        print('Fixed const in ${entity.path}');
      }
    }
  }
}
