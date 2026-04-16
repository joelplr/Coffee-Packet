import 'dart:io';

void main() async {
  final process = await Process.run('dart', ['analyze', 'lib/', '--format=machine']);
  final content = process.stdout.toString() + process.stderr.toString();
  final lines = content.split('\n').where((l) => l.startsWith('ERROR')).toList();
  for (var line in lines) {
    var parts = line.split('|');
    if (parts.length > 5) {
      if (parts[7].contains('AppTheme')) {
        var p = parts[3].split(r'\').last;
        // The message is "The getter '...' isn't defined for the type 'AppTheme'" 
        // We'll extract what comes between single quotes in the message
        var msg = parts[7];
        var getterMatch = RegExp(r"'(.*?)'").firstMatch(msg);
        var missingVariable = getterMatch != null ? getterMatch.group(1) : msg;
        print('$p:${parts[4]} -> AppTheme.$missingVariable');
      }
    }
  }
}
