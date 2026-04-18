import 'package:photo_manager/photo_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/database.dart';

part 'folders_provider.g.dart';

@riverpod
Future<List<AssetEntity>> taggedPhotos(Ref ref, String tagId) async {
  final photoIds = await DatabaseService.instance.getPhotosByTag(tagId);
  final List<AssetEntity> assets = [];
  
  for (final id in photoIds) {
    final asset = await AssetEntity.fromId(id);
    if (asset != null) {
      assets.add(asset);
    }
  }
  
  return assets;
}
