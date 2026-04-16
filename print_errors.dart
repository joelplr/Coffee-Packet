import 'dart:io';

void main() async {
  final content = await File('build.log').readAsString();
  var lines = content.split('\n');
  for (var l in lines) {
    if (l.contains('Error:')) {
      print(l);
    }
  }
}
