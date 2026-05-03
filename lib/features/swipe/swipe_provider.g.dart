// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swipe_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SwipeIndex)
final swipeIndexProvider = SwipeIndexProvider._();

final class SwipeIndexProvider extends $NotifierProvider<SwipeIndex, int> {
  SwipeIndexProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'swipeIndexProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$swipeIndexHash();

  @$internal
  @override
  SwipeIndex create() => SwipeIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$swipeIndexHash() => r'9053a7a7bfdabb4271dfd8be706e550e7ec8a9e8';

abstract class _$SwipeIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element = ref.element
        as $ClassProviderElement<AnyNotifier<int, int>, int, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SelectedAlbum)
final selectedAlbumProvider = SelectedAlbumProvider._();

final class SelectedAlbumProvider
    extends $NotifierProvider<SelectedAlbum, AssetPathEntity?> {
  SelectedAlbumProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedAlbumProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedAlbumHash();

  @$internal
  @override
  SelectedAlbum create() => SelectedAlbum();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssetPathEntity? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssetPathEntity?>(value),
    );
  }
}

String _$selectedAlbumHash() => r'0b76ee90ce301e45da3564795c2b316ddcdf2aa0';

abstract class _$SelectedAlbum extends $Notifier<AssetPathEntity?> {
  AssetPathEntity? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AssetPathEntity?, AssetPathEntity?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AssetPathEntity?, AssetPathEntity?>,
        AssetPathEntity?,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Albums list used by the Editor (filtered by Editor's mediaMode).

@ProviderFor(albums)
final albumsProvider = AlbumsProvider._();

/// Albums list used by the Editor (filtered by Editor's mediaMode).

final class AlbumsProvider extends $FunctionalProvider<
        AsyncValue<List<AssetPathEntity>>,
        List<AssetPathEntity>,
        FutureOr<List<AssetPathEntity>>>
    with
        $FutureModifier<List<AssetPathEntity>>,
        $FutureProvider<List<AssetPathEntity>> {
  /// Albums list used by the Editor (filtered by Editor's mediaMode).
  AlbumsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'albumsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$albumsHash();

  @$internal
  @override
  $FutureProviderElement<List<AssetPathEntity>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<AssetPathEntity>> create(Ref ref) {
    return albums(ref);
  }
}

String _$albumsHash() => r'f2daaff8a70c04657ad19954faa615c1716fc2c2';

/// Albums list used exclusively by the Reels settings (filtered by Reels' own mediaMode).

@ProviderFor(reelsAlbums)
final reelsAlbumsProvider = ReelsAlbumsProvider._();

/// Albums list used exclusively by the Reels settings (filtered by Reels' own mediaMode).

final class ReelsAlbumsProvider extends $FunctionalProvider<
        AsyncValue<List<AssetPathEntity>>,
        List<AssetPathEntity>,
        FutureOr<List<AssetPathEntity>>>
    with
        $FutureModifier<List<AssetPathEntity>>,
        $FutureProvider<List<AssetPathEntity>> {
  /// Albums list used exclusively by the Reels settings (filtered by Reels' own mediaMode).
  ReelsAlbumsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'reelsAlbumsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$reelsAlbumsHash();

  @$internal
  @override
  $FutureProviderElement<List<AssetPathEntity>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<AssetPathEntity>> create(Ref ref) {
    return reelsAlbums(ref);
  }
}

String _$reelsAlbumsHash() => r'22a149e2404808eb5e965bfcf856255db1291b7f';

@ProviderFor(editorAssetList)
final editorAssetListProvider = EditorAssetListProvider._();

final class EditorAssetListProvider extends $FunctionalProvider<
        AsyncValue<List<AssetEntity>>,
        List<AssetEntity>,
        FutureOr<List<AssetEntity>>>
    with
        $FutureModifier<List<AssetEntity>>,
        $FutureProvider<List<AssetEntity>> {
  EditorAssetListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'editorAssetListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$editorAssetListHash();

  @$internal
  @override
  $FutureProviderElement<List<AssetEntity>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<AssetEntity>> create(Ref ref) {
    return editorAssetList(ref);
  }
}

String _$editorAssetListHash() => r'fa3a43d3786f546baa64f4cf8ad112f1d69ec831';

@ProviderFor(reelsAssetList)
final reelsAssetListProvider = ReelsAssetListProvider._();

final class ReelsAssetListProvider extends $FunctionalProvider<
        AsyncValue<List<AssetEntity>>,
        List<AssetEntity>,
        FutureOr<List<AssetEntity>>>
    with
        $FutureModifier<List<AssetEntity>>,
        $FutureProvider<List<AssetEntity>> {
  ReelsAssetListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'reelsAssetListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$reelsAssetListHash();

  @$internal
  @override
  $FutureProviderElement<List<AssetEntity>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<AssetEntity>> create(Ref ref) {
    return reelsAssetList(ref);
  }
}

String _$reelsAssetListHash() => r'cdb59546d1da6d4db49fc4e6dc15346be02a760d';

@ProviderFor(favoriteAssetList)
final favoriteAssetListProvider = FavoriteAssetListProvider._();

final class FavoriteAssetListProvider extends $FunctionalProvider<
        AsyncValue<List<AssetEntity>>,
        List<AssetEntity>,
        FutureOr<List<AssetEntity>>>
    with
        $FutureModifier<List<AssetEntity>>,
        $FutureProvider<List<AssetEntity>> {
  FavoriteAssetListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'favoriteAssetListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$favoriteAssetListHash();

  @$internal
  @override
  $FutureProviderElement<List<AssetEntity>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<AssetEntity>> create(Ref ref) {
    return favoriteAssetList(ref);
  }
}

String _$favoriteAssetListHash() => r'6246ee06f7c4c5095d86daf42869364261c71467';

@ProviderFor(UndoStack)
final undoStackProvider = UndoStackProvider._();

final class UndoStackProvider
    extends $NotifierProvider<UndoStack, List<SwipeAction>> {
  UndoStackProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'undoStackProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$undoStackHash();

  @$internal
  @override
  UndoStack create() => UndoStack();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SwipeAction> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SwipeAction>>(value),
    );
  }
}

String _$undoStackHash() => r'a617405b7146723ed4d9272b1a15e0fedac20efb';

abstract class _$UndoStack extends $Notifier<List<SwipeAction>> {
  List<SwipeAction> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<SwipeAction>, List<SwipeAction>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<SwipeAction>, List<SwipeAction>>,
        List<SwipeAction>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
