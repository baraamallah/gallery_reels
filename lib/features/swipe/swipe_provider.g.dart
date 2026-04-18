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
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
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
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AssetPathEntity?, AssetPathEntity?>,
              AssetPathEntity?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(albums)
final albumsProvider = AlbumsProvider._();

final class AlbumsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AssetPathEntity>>,
          List<AssetPathEntity>,
          FutureOr<List<AssetPathEntity>>
        >
    with
        $FutureModifier<List<AssetPathEntity>>,
        $FutureProvider<List<AssetPathEntity>> {
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
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AssetPathEntity>> create(Ref ref) {
    return albums(ref);
  }
}

String _$albumsHash() => r'332eaf9512d1809887facefa7b0b6d2b84c050e1';

@ProviderFor(photoList)
final photoListProvider = PhotoListProvider._();

final class PhotoListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AssetEntity>>,
          List<AssetEntity>,
          FutureOr<List<AssetEntity>>
        >
    with
        $FutureModifier<List<AssetEntity>>,
        $FutureProvider<List<AssetEntity>> {
  PhotoListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'photoListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$photoListHash();

  @$internal
  @override
  $FutureProviderElement<List<AssetEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AssetEntity>> create(Ref ref) {
    return photoList(ref);
  }
}

String _$photoListHash() => r'b5be37637e975ec9bb3b94919884fc98bfa7a958';

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
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<SwipeAction>, List<SwipeAction>>,
              List<SwipeAction>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
