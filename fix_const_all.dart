import 'dart:io';

void main() async {
  final dir = Directory('lib');
  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart') && !entity.path.contains('app_theme.dart') && !entity.path.contains('main.dart')) {
      String content = await entity.readAsString();
      if (content.contains('context.theme')) {
        // Remove ALL `const ` inside the file since it's full of them and we don't know which parents are broken.
        content = content.replaceAll(RegExp(r'\bconst\s+(?=[A-Z])'), '');
        
        // Ensure static consts in classes remain
        content = content.replaceAll(RegExp(r'static\s+Color'), 'static const Color');
        
        // Write the file back
        await entity.writeAsString(content);
        print('Stripped consts from ${entity.path}');
      }
    }
  }
}
