
import 'package:photo_manager/photo_manager.dart';
import '../../shared/models/swipe_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'swipe_provider.g.dart';

@riverpod
class SwipeIndex extends _$SwipeIndex {
  @override
  int build() => 0;

  void next() => state = state + 1;
  void previous() => state = state > 0 ? state - 1 : 0;
  void reset() => state = 0;
}

@riverpod
class SelectedAlbum extends _$SelectedAlbum {
  @override
  AssetPathEntity? build() => null;
  
  void setAlbum(AssetPathEntity? album) => state = album;
}

@riverpod
Future<List<AssetPathEntity>> albums(Ref ref) async {
  final PermissionState state = await PhotoManager.requestPermissionExtend();
  if (!state.isAuth && state != PermissionState.limited) {
    return [];
  }
  return await PhotoManager.getAssetPathList(type: RequestType.image);
}

@riverpod
Future<List<AssetEntity>> photoList(Ref ref) async {
  final PermissionState state = await PhotoManager.requestPermissionExtend();
  if (!state.isAuth && state != PermissionState.limited) {
    return [];
  }

  final selectedAlbum = ref.watch(selectedAlbumProvider);
  if (selectedAlbum != null) {
    final count = await selectedAlbum.assetCountAsync;
    return await selectedAlbum.getAssetListRange(start: 0, end: count > 1000 ? 1000 : count);
  }

  final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
    type: RequestType.image,
    onlyAll: true,
  );
  
  if (albums.isEmpty) return [];
  
  final count = await albums.first.assetCountAsync;
  return await albums.first.getAssetListRange(start: 0, end: count > 1000 ? 1000 : count);
}

@riverpod
class UndoStack extends _$UndoStack {
  @override
  List<SwipeAction> build() => [];

  void push(SwipeAction action) {
    state = [...state, action];
    if (state.length > 10) {
      state = state.sublist(state.length - 10);
    }
  }

  SwipeAction? pop() {
    if (state.isEmpty) return null;
    final last = state.last;
    state = state.sublist(0, state.length - 1);
    return last;
  }
}
