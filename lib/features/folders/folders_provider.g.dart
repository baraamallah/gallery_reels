// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(taggedPhotos)
final taggedPhotosProvider = TaggedPhotosFamily._();

final class TaggedPhotosProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AssetEntity>>,
          List<AssetEntity>,
          FutureOr<List<AssetEntity>>
        >
    with
        $FutureModifier<List<AssetEntity>>,
        $FutureProvider<List<AssetEntity>> {
  TaggedPhotosProvider._({
    required TaggedPhotosFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'taggedPhotosProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taggedPhotosHash();

  @override
  String toString() {
    return r'taggedPhotosProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<AssetEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AssetEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return taggedPhotos(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TaggedPhotosProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taggedPhotosHash() => r'b8b1c1a2d992d46dcc0e40612e41a3cc7e2b086c';

final class TaggedPhotosFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<AssetEntity>>, String> {
  TaggedPhotosFamily._()
    : super(
        retry: null,
        name: r'taggedPhotosProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TaggedPhotosProvider call(String tagId) =>
      TaggedPhotosProvider._(argument: tagId, from: this);

  @override
  String toString() => r'taggedPhotosProvider';
}
