// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nav_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NavTabNotifier)
final navTabProvider = NavTabNotifierProvider._();

final class NavTabNotifierProvider
    extends $NotifierProvider<NavTabNotifier, NavTab> {
  NavTabNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'navTabProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$navTabNotifierHash();

  @$internal
  @override
  NavTabNotifier create() => NavTabNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NavTab value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NavTab>(value),
    );
  }
}

String _$navTabNotifierHash() => r'6d6eb57630f03521b48cd379270e43c603a4d6a2';

abstract class _$NavTabNotifier extends $Notifier<NavTab> {
  NavTab build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<NavTab, NavTab>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<NavTab, NavTab>, NavTab, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
