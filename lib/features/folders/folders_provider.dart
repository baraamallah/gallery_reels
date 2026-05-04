import 'package:photo_manager/photo_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/database.dart';

part 'folders_provider.g.dart';

@riverpod
Future<List<AssetEntity>> taggedPhotos(Ref ref, String tagId) async {
  final photoIds = await DatabaseService.instance.getPhotosByTag(tagId);
  
  final assetFutures = photoIds.map((id) => AssetEntity.fromId(id));
  final results = await Future.wait(assetFutures);
  
  return results.whereType<AssetEntity>().toList();
}
