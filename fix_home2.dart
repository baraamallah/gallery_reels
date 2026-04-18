import 'dart:io';

void main() {
  final file = File('lib/features/home/home_screen.dart');
  var content = file.readAsStringSync();

  // Revert the naive replacement that broke syntax
  content = content.replaceAll('return GestureDetector(onTap: () { Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FoldersScreen())); }, child: Container(', 'return Container(');
  content = content.replaceAll(')).animate().fadeIn(delay: delay.ms).scale(begin: const Offset(0.95, 0.95));', ').animate().fadeIn(delay: delay.ms).scale(begin: const Offset(0.95, 0.95));');

  file.writeAsStringSync(content);
}
