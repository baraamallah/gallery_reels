import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../shared/models/swipe_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_settings.dart';
import '../../core/database.dart';
import '../../core/log_service.dart';

part 'swipe_provider.g.dart';

@riverpod
class SwipeIndex extends _$SwipeIndex {
  @override
  int build() {
    // Watch only the index-specific provider to avoid rebuilding on every setting change
    return ref.watch(lastSwipeIndexProvider);
  }

  void next() {
    state = state + 1;
    _persist();
  }

  void previous() {
    state = state > 0 ? state - 1 : 0;
    _persist();
  }

  void reset() {
    state = 0;
    _persist();
  }

  void jumpTo(int index) {
    state = index;
    _persist();
  }

  Future<void> _persist() async {
    await ref.read(appSettingsProvider.notifier).setLastSwipeIndex(state);
  }
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

  try {
    // 1. Get in-app favorites from DB (Primary Source)
    final favoriteIds = await DatabaseService.instance.getPhotosByTag('2');
    LogService.instance.info('Found ${favoriteIds.length} favorited IDs in database');
    
    if (favoriteIds.isNotEmpty) {
      // Resolve IDs in batches to be efficient
      final List<AssetEntity?> inAppAssets = await Future.wait(
        favoriteIds.map((id) => AssetEntity.fromId(id))
      );
      
      final List<String> failedIds = [];
      for (int i = 0; i < inAppAssets.length; i++) {
        final asset = inAppAssets[i];
        if (asset != null) {
          favorites.add(asset);
          processedIds.add(asset.id);
        } else {
          failedIds.add(favoriteIds[i]);
        }
      }

      if (failedIds.isNotEmpty) {
        LogService.instance.warn('${failedIds.length} assets failed resolution by ID. Attempting deep scan fallback...');
        // Fallback: Scan "All" album for these IDs specifically
        final List<AssetPathEntity> allAlbums = await PhotoManager.getAssetPathList(type: RequestType.common);
        AssetPathEntity? allAlbum;
        for (final album in allAlbums) {
          if (album.isAll) {
            allAlbum = album;
            break;
          }
        }

        if (allAlbum != null) {
          final count = await allAlbum.assetCountAsync;
          // Deep scan up to 10k items for missing favorites
          final take = count > 10000 ? 10000 : count;
          final scanAssets = await allAlbum.getAssetListRange(start: 0, end: take);
          final failedSet = failedIds.toSet();
          
          for (final a in scanAssets) {
            if (failedSet.contains(a.id) && !processedIds.contains(a.id)) {
              favorites.add(a);
              processedIds.add(a.id);
              LogService.instance.info('Recovered asset ${a.id} via deep scan');
            }
          }
        }
      }
      LogService.instance.info('Successfully resolved ${processedIds.length} out of ${favoriteIds.length} assets from database');
    }

    // 2. Include system favorites (OS-level synchronization)
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(type: RequestType.common);
    
    // Check for "Favorites" album
    AssetPathEntity? systemFavAlbum;
    for (final album in albums) {
      final name = album.name.toLowerCase();
      if (name == 'favorites' || name == 'favourites' || album.name == '收藏' || album.name == 'Favoritos') {
        systemFavAlbum = album;
        break;
      }
    }

    if (systemFavAlbum != null) {
      final count = await systemFavAlbum.assetCountAsync;
      final assets = await systemFavAlbum.getAssetListRange(start: 0, end: count);
      for (final a in assets) {
        if (!processedIds.contains(a.id)) {
          favorites.add(a);
          processedIds.add(a.id);
        }
      }
    }

    // Fallback: Always check if a.isFavorite is true in the recent items of "All" album
    for (final album in albums) {
      if (album.isAll) {
        final count = await album.assetCountAsync;
        final take = count > 2000 ? 2000 : count;
        final assets = await album.getAssetListRange(start: 0, end: take);
        for (final a in assets) {
          if (a.isFavorite && !processedIds.contains(a.id)) {
            favorites.add(a);
            processedIds.add(a.id);
          }
        }
        break;
      }
    }
  } catch (e, s) {
    LogService.instance.error('Error loading favorites: $e', e, s);
  }

  // Sort by creation date (newest first)
  favorites.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));
  return favorites;
}

final lastSwipeIndexProvider = Provider<int>((ref) {
  return ref.watch(appSettingsProvider).lastSwipeIndex;
});

final _fetchConfigProvider = Provider.family<({
  MediaMode mediaMode,
  SortMode sortMode,
  List<String> includedIds,
  int? minSize,
  int? maxSize,
  DateTime? startDate,
  DateTime? endDate,
  int loadLimit,
}), bool>((ref, isEditor) {
  final s = ref.watch(appSettingsProvider);
  if (isEditor) {
    return (
      mediaMode: s.mediaMode,
      sortMode: s.sortMode,
      includedIds: s.includedAlbumIds,
      minSize: s.minSizeEditor,
      maxSize: null,
      startDate: null,
      endDate: null,
      loadLimit: s.loadLimit,
    );
  } else {
    return (
      mediaMode: s.reelsMediaMode,
      sortMode: s.reelsSortMode,
      includedIds: s.reelsIncludedAlbumIds,
      minSize: s.minSizeReels,
      maxSize: s.maxSizeReels,
      startDate: s.reelsStartDate,
      endDate: s.reelsEndDate,
      loadLimit: s.loadLimit,
    );
  }
});

Future<List<AssetEntity>> _fetchAssets(Ref ref, {required bool isEditor}) async {
  if (kIsWeb) return [];
  
  // Watch the granular config provider. Since it returns a Record, 
  // this will only re-run if the actual filter values change.
  final config = ref.watch(_fetchConfigProvider(isEditor));

  final PermissionState ps = await PhotoManager.requestPermissionExtend();
  if (!ps.isAuth && ps != PermissionState.limited) return [];

  final type = _requestTypeFor(config.mediaMode);

  // If editor and an album is explicitly selected in Folders tab, use that.
  if (isEditor) {
    final selectedAlbum = ref.watch(selectedAlbumProvider);
    if (selectedAlbum != null) {
      final count = await selectedAlbum.assetCountAsync;
      final assets = await selectedAlbum.getAssetListRange(start: 0, end: count);
      return await _filterAndSort(assets, config.sortMode, config.minSize, config.maxSize, config.startDate, config.endDate);
    }
  }

  final List<AssetPathEntity> all = await PhotoManager.getAssetPathList(type: type);
  if (all.isEmpty) return [];

  final selectedIds = config.includedIds.toSet();
  final albumsFiltered = selectedIds.isEmpty ? all : all.where((a) => selectedIds.contains(a.id)).toList();
  if (albumsFiltered.isEmpty) return [];

  final List<AssetEntity> combined = [];
  for (final album in albumsFiltered) {
    final count = await album.assetCountAsync;
    // Use user-defined load limit for better performance ("importing in parts")
    final take = count > config.loadLimit ? config.loadLimit : count;
    if (take <= 0) continue;
    combined.addAll(await album.getAssetListRange(start: 0, end: take));
  }

  return await _filterAndSort(combined, config.sortMode, config.minSize, config.maxSize, config.startDate, config.endDate);
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
