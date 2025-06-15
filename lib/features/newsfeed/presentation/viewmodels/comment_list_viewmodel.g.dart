// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_list_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$commentListViewModelHash() =>
    r'3678c8854ffe7780f8fac8f0a62e48cf1000b737';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$CommentListViewModel
    extends BuildlessAutoDisposeAsyncNotifier<CommentListState> {
  late final String postId;

  FutureOr<CommentListState> build(String postId);
}

/// See also [CommentListViewModel].
@ProviderFor(CommentListViewModel)
const commentListViewModelProvider = CommentListViewModelFamily();

/// See also [CommentListViewModel].
class CommentListViewModelFamily extends Family<AsyncValue<CommentListState>> {
  /// See also [CommentListViewModel].
  const CommentListViewModelFamily();

  /// See also [CommentListViewModel].
  CommentListViewModelProvider call(String postId) {
    return CommentListViewModelProvider(postId);
  }

  @override
  CommentListViewModelProvider getProviderOverride(
    covariant CommentListViewModelProvider provider,
  ) {
    return call(provider.postId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'commentListViewModelProvider';
}

/// See also [CommentListViewModel].
class CommentListViewModelProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          CommentListViewModel,
          CommentListState
        > {
  /// See also [CommentListViewModel].
  CommentListViewModelProvider(String postId)
    : this._internal(
        () => CommentListViewModel()..postId = postId,
        from: commentListViewModelProvider,
        name: r'commentListViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$commentListViewModelHash,
        dependencies: CommentListViewModelFamily._dependencies,
        allTransitiveDependencies:
            CommentListViewModelFamily._allTransitiveDependencies,
        postId: postId,
      );

  CommentListViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postId,
  }) : super.internal();

  final String postId;

  @override
  FutureOr<CommentListState> runNotifierBuild(
    covariant CommentListViewModel notifier,
  ) {
    return notifier.build(postId);
  }

  @override
  Override overrideWith(CommentListViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: CommentListViewModelProvider._internal(
        () => create()..postId = postId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postId: postId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    CommentListViewModel,
    CommentListState
  >
  createElement() {
    return _CommentListViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommentListViewModelProvider && other.postId == postId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommentListViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<CommentListState> {
  /// The parameter `postId` of this provider.
  String get postId;
}

class _CommentListViewModelProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          CommentListViewModel,
          CommentListState
        >
    with CommentListViewModelRef {
  _CommentListViewModelProviderElement(super.provider);

  @override
  String get postId => (origin as CommentListViewModelProvider).postId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
