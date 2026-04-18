import 'dart:io';

void main() {
  final file = File('lib/features/swipe/card_stack.dart');
  var content = file.readAsStringSync();

  // Revert back to the deprecated method just so it compiles cleanly
  // Share.shareXFiles is deprecated but the alternative SharePlus.instance.share doesn't compile due to dependency version
  content = content.replaceAll('Share.shareXFiles([XFile(file.path)])', 'Share.shareXFiles([XFile(file.path)])');

  file.writeAsStringSync(content);
}
