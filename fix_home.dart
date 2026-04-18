import 'dart:io';

void main() {
  final file = File('lib/features/home/home_screen.dart');
  var content = file.readAsStringSync();

  // Make the bento cards tap to go to FoldersScreen (the real data one)
  content = content.replaceAll(
    'return Container(',
    'return GestureDetector(onTap: () { Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FoldersScreen())); }, child: Container('
  );

  content = content.replaceAll(
    '\n    ).animate().fadeIn(delay: delay.ms).scale(begin: const Offset(0.95, 0.95));\n  }',
    '\n    )).animate().fadeIn(delay: delay.ms).scale(begin: const Offset(0.95, 0.95));\n  }'
  );

  file.writeAsStringSync(content);
}
