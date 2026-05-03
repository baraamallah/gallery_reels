import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'log_service.dart';

enum DeleteMode {
  systemTrash,
  inAppTrash,
  permanent,
}

enum MediaMode {
  photosAndVideos,
  photosOnly,
  videosOnly,
}

enum SortMode {
  newestFirst,
  oldestFirst,
  largestFirst,
  smallestFirst,
}

@immutable
class AppSettings {
  final ThemeMode themeMode;
  final DeleteMode deleteMode;

  // Editor (Swipe) Settings
  final MediaMode mediaMode;
  final SortMode sortMode;
  final List<String> includedAlbumIds;
  final int? minSizeEditor; // in bytes

  // Reels (Slideshow) Settings
  final MediaMode reelsMediaMode;
  final SortMode reelsSortMode;
  final List<String> reelsIncludedAlbumIds;
  final int? minSizeReels;
  final int? maxSizeReels; // in bytes — new
  final DateTime? reelsStartDate; // new
  final DateTime? reelsEndDate;   // new

  const AppSettings({
    required this.themeMode,
    required this.deleteMode,
    required this.mediaMode,
    required this.sortMode,
    required this.includedAlbumIds,
    this.minSizeEditor,
    required this.reelsMediaMode,
    required this.reelsSortMode,
    required this.reelsIncludedAlbumIds,
    this.minSizeReels,
    this.maxSizeReels,
    this.reelsStartDate,
    this.reelsEndDate,
  });

  factory AppSettings.defaults() => const AppSettings(
        themeMode: ThemeMode.system,
        deleteMode: DeleteMode.inAppTrash,
        mediaMode: MediaMode.photosAndVideos,
        sortMode: SortMode.newestFirst,
        includedAlbumIds: <String>[],
        minSizeEditor: null,
        reelsMediaMode: MediaMode.photosAndVideos,
        reelsSortMode: SortMode.newestFirst,
        reelsIncludedAlbumIds: <String>[],
        minSizeReels: null,
        maxSizeReels: null,
        reelsStartDate: null,
        reelsEndDate: null,
      );

  AppSettings copyWith({
    ThemeMode? themeMode,
    DeleteMode? deleteMode,
    MediaMode? mediaMode,
    SortMode? sortMode,
    List<String>? includedAlbumIds,
    Object? minSizeEditor = _sentinel,
    MediaMode? reelsMediaMode,
    SortMode? reelsSortMode,
    List<String>? reelsIncludedAlbumIds,
    Object? minSizeReels = _sentinel,
    Object? maxSizeReels = _sentinel,
    Object? reelsStartDate = _sentinel,
    Object? reelsEndDate = _sentinel,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      deleteMode: deleteMode ?? this.deleteMode,
      mediaMode: mediaMode ?? this.mediaMode,
      sortMode: sortMode ?? this.sortMode,
      includedAlbumIds: includedAlbumIds ?? this.includedAlbumIds,
      minSizeEditor: minSizeEditor == _sentinel ? this.minSizeEditor : minSizeEditor as int?,
      reelsMediaMode: reelsMediaMode ?? this.reelsMediaMode,
      reelsSortMode: reelsSortMode ?? this.reelsSortMode,
      reelsIncludedAlbumIds: reelsIncludedAlbumIds ?? this.reelsIncludedAlbumIds,
      minSizeReels: minSizeReels == _sentinel ? this.minSizeReels : minSizeReels as int?,
      maxSizeReels: maxSizeReels == _sentinel ? this.maxSizeReels : maxSizeReels as int?,
      reelsStartDate: reelsStartDate == _sentinel ? this.reelsStartDate : reelsStartDate as DateTime?,
      reelsEndDate: reelsEndDate == _sentinel ? this.reelsEndDate : reelsEndDate as DateTime?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.name,
      'deleteMode': deleteMode.name,
      'mediaMode': mediaMode.name,
      'sortMode': sortMode.name,
      'includedAlbumIds': includedAlbumIds,
      'minSizeEditor': minSizeEditor,
      'reelsMediaMode': reelsMediaMode.name,
      'reelsSortMode': reelsSortMode.name,
      'reelsIncludedAlbumIds': reelsIncludedAlbumIds,
      'minSizeReels': minSizeReels,
      'maxSizeReels': maxSizeReels,
      'reelsStartDate': reelsStartDate?.millisecondsSinceEpoch,
      'reelsEndDate': reelsEndDate?.millisecondsSinceEpoch,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    ThemeMode parseThemeMode(String? v) {
      switch (v) {
        case 'light': return ThemeMode.light;
        case 'dark': return ThemeMode.dark;
        default: return ThemeMode.system;
      }
    }

    DeleteMode parseDeleteMode(String? v) {
      switch (v) {
        case 'inAppTrash': return DeleteMode.inAppTrash;
        case 'permanent': return DeleteMode.permanent;
        default: return DeleteMode.systemTrash;
      }
    }

    MediaMode parseMediaMode(String? v) {
      switch (v) {
        case 'photosOnly': return MediaMode.photosOnly;
        case 'videosOnly': return MediaMode.videosOnly;
        default: return MediaMode.photosAndVideos;
      }
    }

    SortMode parseSortMode(String? v) {
      switch (v) {
        case 'oldestFirst': return SortMode.oldestFirst;
        case 'largestFirst': return SortMode.largestFirst;
        case 'smallestFirst': return SortMode.smallestFirst;
        default: return SortMode.newestFirst;
      }
    }

    DateTime? parseDate(dynamic v) {
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return null;
    }

    return AppSettings(
      themeMode: parseThemeMode(map['themeMode'] as String?),
      deleteMode: parseDeleteMode(map['deleteMode'] as String?),
      mediaMode: parseMediaMode(map['mediaMode'] as String?),
      sortMode: parseSortMode(map['sortMode'] as String?),
      includedAlbumIds: (map['includedAlbumIds'] as List?)?.whereType<String>().toList() ?? [],
      minSizeEditor: map['minSizeEditor'] as int?,
      reelsMediaMode: parseMediaMode(map['reelsMediaMode'] as String?),
      reelsSortMode: parseSortMode(map['reelsSortMode'] as String?),
      reelsIncludedAlbumIds: (map['reelsIncludedAlbumIds'] as List?)?.whereType<String>().toList() ?? [],
      minSizeReels: map['minSizeReels'] as int?,
      maxSizeReels: map['maxSizeReels'] as int?,
      reelsStartDate: parseDate(map['reelsStartDate']),
      reelsEndDate: parseDate(map['reelsEndDate']),
    );
  }
}

// Sentinel for nullable copyWith fields
const _sentinel = Object();

final appSettingsProvider = NotifierProvider<AppSettingsController, AppSettings>(
  AppSettingsController.new,
);

class AppSettingsController extends Notifier<AppSettings> {
  static const _storage = FlutterSecureStorage();
  static const _key = 'app_settings_v1';
  bool _loaded = false;

  @override
  AppSettings build() {
    _loadOnce();
    return AppSettings.defaults();
  }

  Future<void> _loadOnce() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null || raw.trim().isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;
      state = AppSettings.fromMap(decoded);
    } catch (_) {
      // Ignore corrupted settings.
    }
  }

  Future<void> _persist() async {
    final raw = jsonEncode(state.toMap());
    await _storage.write(key: _key, value: raw);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    LogService.instance.info('Setting ThemeMode: ${mode.name}');
    state = state.copyWith(themeMode: mode);
    await _persist();
  }

  Future<void> setDeleteMode(DeleteMode mode) async {
    LogService.instance.info('Setting DeleteMode: ${mode.name}');
    state = state.copyWith(deleteMode: mode);
    await _persist();
  }

  Future<void> setMediaMode(MediaMode mode) async {
    LogService.instance.info('Setting MediaMode: ${mode.name}');
    state = state.copyWith(mediaMode: mode);
    await _persist();
  }

  Future<void> setSortMode(SortMode mode) async {
    LogService.instance.info('Setting SortMode: ${mode.name}');
    state = state.copyWith(sortMode: mode);
    await _persist();
  }

  Future<void> setMinSizeEditor(int? size) async {
    LogService.instance.info('Setting MinSizeEditor: $size');
    state = state.copyWith(minSizeEditor: size);
    await _persist();
  }

  Future<void> setIncludedAlbums(List<String> ids) async {
    LogService.instance.info('Setting IncludedAlbums: ${ids.length} albums');
    state = state.copyWith(includedAlbumIds: ids);
    await _persist();
  }

  // Reels Settings
  Future<void> setReelsMediaMode(MediaMode mode) async {
    state = state.copyWith(reelsMediaMode: mode);
    await _persist();
  }

  Future<void> setReelsSortMode(SortMode mode) async {
    state = state.copyWith(reelsSortMode: mode);
    await _persist();
  }

  Future<void> setReelsMinSize(int? size) async {
    state = state.copyWith(minSizeReels: size);
    await _persist();
  }

  Future<void> setReelsMaxSize(int? size) async {
    state = state.copyWith(maxSizeReels: size);
    await _persist();
  }

  Future<void> setReelsStartDate(DateTime? date) async {
    state = state.copyWith(reelsStartDate: date);
    await _persist();
  }

  Future<void> setReelsEndDate(DateTime? date) async {
    state = state.copyWith(reelsEndDate: date);
    await _persist();
  }

  Future<void> setReelsIncludedAlbums(List<String> ids) async {
    state = state.copyWith(reelsIncludedAlbumIds: ids);
    await _persist();
  }
}
