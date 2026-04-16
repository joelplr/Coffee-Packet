import 'dart:io';

void main() async {
  final process = await Process.run('dart', ['analyze', 'lib/', '--format=machine']);
  final content = process.stdout.toString() + process.stderr.toString();
  final lines = content.split('\n').where((l) => l.startsWith('ERROR')).toList();
  
  for (var line in lines) {
    var parts = line.split('|');
    if (parts.length > 5 && parts[7].contains("Undefined name 'context'")) {
       var filePath = parts[3];
       var lineNum = int.parse(parts[4]) - 1; // 0-indexed
       
       var file = File(filePath);
       var fileLines = await file.readAsLines();
       // Replace context.theme with AppTheme on that line
       fileLines[lineNum] = fileLines[lineNum].replaceAll('context.theme', 'AppTheme');
       await file.writeAsString(fileLines.join('\n'));
       print('Fixed $filePath:$lineNum');
    }
  }
}
