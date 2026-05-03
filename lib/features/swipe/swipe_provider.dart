import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../shared/models/swipe_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/app_settings.dart';
import '../../core/database.dart';

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

/// Albums list used by the Editor (filtered by Editor's mediaMode).
@riverpod
Future<List<AssetPathEntity>> albums(Ref ref) async {
  if (kIsWeb) return [];
  final settings = ref.watch(appSettingsProvider);
  final PermissionState ps = await PhotoManager.requestPermissionExtend();
  if (!ps.isAuth && ps != PermissionState.limited) return [];
  final type = _requestTypeFor(settings.mediaMode);
  return await PhotoManager.getAssetPathList(type: type);
}

/// Albums list used exclusively by the Reels settings (filtered by Reels' own mediaMode).
@riverpod
Future<List<AssetPathEntity>> reelsAlbums(Ref ref) async {
  if (kIsWeb) return [];
  final settings = ref.watch(appSettingsProvider);
  final PermissionState ps = await PhotoManager.requestPermissionExtend();
  if (!ps.isAuth && ps != PermissionState.limited) return [];
  final type = _requestTypeFor(settings.reelsMediaMode);
  return await PhotoManager.getAssetPathList(type: type);
}

@riverpod
Future<List<AssetEntity>> editorAssetList(Ref ref) async {
  return _fetchAssets(ref, isEditor: true);
}

@riverpod
Future<List<AssetEntity>> reelsAssetList(Ref ref) async {
  return _fetchAssets(ref, isEditor: false);
}

@riverpod
Future<List<AssetEntity>> favoriteAssetList(Ref ref) async {
  if (kIsWeb) return [];
  final PermissionState ps = await PhotoManager.requestPermissionExtend();
  if (!ps.isAuth && ps != PermissionState.limited) return [];

  final List<AssetEntity> favorites = [];
  final Set<String> processedIds = {};

  // 1. Get in-app favorites from DB
  final favoriteIds = await DatabaseService.instance.getPhotosByTag('2');
  for (final id in favoriteIds) {
    final asset = await AssetEntity.fromId(id);
    if (asset != null) {
      favorites.add(asset);
      processedIds.add(asset.id);
    }
  }

  // 2. Also include system favorites (OS-level)
  final List<AssetPathEntity> all = await PhotoManager.getAssetPathList(type: RequestType.common);
  for (final album in all) {
    if (album.isAll) {
      final count = await album.assetCountAsync;
      // Fetch in batches to be efficient
      for (int i = 0; i < count; i += 1000) {
        final assets = await album.getAssetListRange(start: i, end: i + 1000);
        for (final a in assets) {
          if (a.isFavorite && !processedIds.contains(a.id)) {
            favorites.add(a);
            processedIds.add(a.id);
          }
        }
      }
      break;
    }
  }

  favorites.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));
  return favorites;
}

Future<List<AssetEntity>> _fetchAssets(Ref ref, {required bool isEditor}) async {
  if (kIsWeb) return [];
  final settings = ref.watch(appSettingsProvider);
  final PermissionState ps = await PhotoManager.requestPermissionExtend();
  if (!ps.isAuth && ps != PermissionState.limited) return [];

  final mediaMode = isEditor ? settings.mediaMode : settings.reelsMediaMode;
  final sortMode = isEditor ? settings.sortMode : settings.reelsSortMode;
  final includedIds = isEditor ? settings.includedAlbumIds : settings.reelsIncludedAlbumIds;
  final minSize = isEditor ? settings.minSizeEditor : settings.minSizeReels;
  final maxSize = isEditor ? null : settings.maxSizeReels;
  final startDate = isEditor ? null : settings.reelsStartDate;
  final endDate = isEditor ? null : settings.reelsEndDate;

  final type = _requestTypeFor(mediaMode);

  // If editor and an album is explicitly selected in Folders tab, use that.
  if (isEditor) {
    final selectedAlbum = ref.watch(selectedAlbumProvider);
    if (selectedAlbum != null) {
      final count = await selectedAlbum.assetCountAsync;
      final assets = await selectedAlbum.getAssetListRange(start: 0, end: count);
      return await _filterAndSort(assets, sortMode, minSize, maxSize, startDate, endDate);
    }
  }

  final List<AssetPathEntity> all = await PhotoManager.getAssetPathList(type: type);
  if (all.isEmpty) return [];

  final selectedIds = includedIds.toSet();
  final albumsFiltered = selectedIds.isEmpty ? all : all.where((a) => selectedIds.contains(a.id)).toList();
  if (albumsFiltered.isEmpty) return [];

  final List<AssetEntity> combined = [];
  for (final album in albumsFiltered) {
    final count = await album.assetCountAsync;
    final take = count > 5000 ? 5000 : count;
    if (take <= 0) continue;
    combined.addAll(await album.getAssetListRange(start: 0, end: take));
  }

  return await _filterAndSort(combined, sortMode, minSize, maxSize, startDate, endDate);
}

Future<List<AssetEntity>> _filterAndSort(
  List<AssetEntity> assets,
  SortMode sort,
  int? minSize,
  int? maxSize,
  DateTime? startDate,
  DateTime? endDate,
) async {
  List<AssetEntity> filtered = assets;

  // 1. Filter out items that are in the in-app trash (fast)
  final trashedIds = await DatabaseService.instance.getTrashedPhotoIds();
  if (trashedIds.isNotEmpty) {
    filtered = filtered.where((a) => !trashedIds.contains(a.id)).toList();
  }

  // 2. Date range filter (fast — no IO needed)
  if (startDate != null) {
    filtered = filtered.where((a) => a.createDateTime.isAfter(startDate) || a.createDateTime.isAtSameMomentAs(startDate)).toList();
  }
  if (endDate != null) {
    final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    filtered = filtered.where((a) => a.createDateTime.isBefore(endOfDay) || a.createDateTime.isAtSameMomentAs(endOfDay)).toList();
  }

  // 3. Size filters (Parallel IO — much faster)
  if (minSize != null || maxSize != null || sort == SortMode.largestFirst || sort == SortMode.smallestFirst) {
    final sizes = <String, int>{};
    
    for (var i = 0; i < filtered.length; i += 50) {
      final end = (i + 50 < filtered.length) ? i + 50 : filtered.length;
      final batch = filtered.sublist(i, end);
      
      await Future.wait(batch.map((a) async {
        final f = await a.file;
        if (f != null) {
          final s = f.lengthSync();
          sizes[a.id] = s;
        }
      }));
    }

    if (minSize != null || maxSize != null) {
      filtered = filtered.where((a) {
        final size = sizes[a.id] ?? 0;
        if (minSize != null && size < minSize) return false;
        if (maxSize != null && size > maxSize) return false;
        return true;
      }).toList();
    }

    // 4. Sort with cached sizes
    switch (sort) {
      case SortMode.newestFirst:
        filtered.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));
        break;
      case SortMode.oldestFirst:
        filtered.sort((a, b) => a.createDateTime.compareTo(b.createDateTime));
        break;
      case SortMode.largestFirst:
        filtered.sort((a, b) => (sizes[b.id] ?? 0).compareTo(sizes[a.id] ?? 0));
        break;
      case SortMode.smallestFirst:
        filtered.sort((a, b) => (sizes[a.id] ?? 0).compareTo(sizes[b.id] ?? 0));
        break;
    }
  } else {
    // Sort without size data
    switch (sort) {
      case SortMode.newestFirst:
        filtered.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));
        break;
      case SortMode.oldestFirst:
        filtered.sort((a, b) => a.createDateTime.compareTo(b.createDateTime));
        break;
      default:
        break;
    }
  }

  return filtered;
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

RequestType _requestTypeFor(MediaMode mode) {
  switch (mode) {
    case MediaMode.photosOnly:
      return RequestType.image;
    case MediaMode.videosOnly:
      return RequestType.video;
    case MediaMode.photosAndVideos:
      return RequestType.common;
  }
}
