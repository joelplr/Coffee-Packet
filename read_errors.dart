import 'dart:io';

void main() async {
  final content = await File('error_messages.txt').readAsString();
  var lines = content.split('\n');
  for (var l in lines) {
    if (l.isNotEmpty) {
      // Just print the filename and the actual string that caused error to avoid wide lines
      var splits = l.split('::');
      var pathParts = l.split(' -> ')[0].split(r'\').last;
      var msg = l.split(' -> ')[1];
      print('$pathParts -> $msg');
    }
  }
}
