import 'dart:io';

void main() async {
  final dir = Directory('lib');
  final regex = RegExp(r'AppTheme\.(background|surface|surfaceLight|surfaceLighter|border|textPrimary|textSecondary|textMuted|accent|accentLight|accentDark|success|warning|error|info)');
  
  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart') && !entity.path.contains('app_theme.dart')) {
      String content = await entity.readAsString();
      if (content.contains('AppTheme.')) {
        content = content.replaceAllMapped(regex, (match) {
          return 'context.theme.${match.group(1)}';
        });
        await entity.writeAsString(content);
        print('Updated ${entity.path}');
      }
    }
  }
}
