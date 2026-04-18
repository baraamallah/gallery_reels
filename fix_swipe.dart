import 'dart:io';

void main() {
  final file = File('lib/features/swipe/swipe_screen.dart');
  var content = file.readAsStringSync();

  // Make the bottom row buttons functional
  // Delete action
  content = content.replaceAll(
    'onPressed: () {\n                                // Delegate logic to CardStack if possible or refactor to provider\n                                // For now, just trigger haptics\n                                HapticHelper.medium();\n                              }',
    'onPressed: () async {\n                                HapticHelper.medium();\n                                final currentAssets = photoListAsync.valueOrNull ?? [];\n                                final currentIndex = ref.read(swipeIndexProvider);\n                                if (currentIndex < currentAssets.length) {\n                                  final asset = currentAssets[currentIndex];\n                                  \n                                  final action = SwipeAction(asset: asset, direction: SwipeDirection.left, timestamp: DateTime.now());\n                                  ref.read(undoStackProvider.notifier).push(action);\n                                  \n                                  final file = await asset.file;\n                                  final size = await file?.length() ?? 0;\n                                  await DatabaseService.instance.addToTrash(asset.id, asset.title, size);\n                                  await DatabaseService.instance.updateStats(deleted: 1, spaceFreed: size, reviewed: 1);\n                                  \n                                  ref.read(swipeIndexProvider.notifier).next();\n                                }\n                              }'
  );

  // Keep action
  content = content.replaceAll(
    'onPressed: () {\n                                HapticHelper.medium();\n                              }',
    'onPressed: () async {\n                                HapticHelper.medium();\n                                final currentAssets = photoListAsync.valueOrNull ?? [];\n                                final currentIndex = ref.read(swipeIndexProvider);\n                                if (currentIndex < currentAssets.length) {\n                                  final asset = currentAssets[currentIndex];\n                                  \n                                  final action = SwipeAction(asset: asset, direction: SwipeDirection.right, timestamp: DateTime.now());\n                                  ref.read(undoStackProvider.notifier).push(action);\n                                  \n                                  await DatabaseService.instance.updateStats(reviewed: 1);\n                                  ref.read(swipeIndexProvider.notifier).next();\n                                }\n                              }'
  );

  file.writeAsStringSync(content);
}
