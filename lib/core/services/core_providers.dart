import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';
import '../../data/repositories/asset_content_repository.dart';
import '../../domain/repositories/content_repository.dart';

/// Singleton local database instance, shared across the whole app.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Content repository (currently backed by bundled JSON assets).
final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return AssetContentRepository();
});

/// Watches the single local-user progress row (creates it on first launch).
final userProgressStreamProvider = StreamProvider<UserProgressTableData>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.userProgressTable).watchSingle();
});

/// Current app language ('tg' | 'ru' | 'en'), persisted in local DB.
final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    // Default to Tajik; actual persisted value is loaded async and applied
    // via setLocale once the DB read completes (see SettingsScreen init).
    return const Locale('tg');
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    final db = ref.read(appDatabaseProvider);
    await (db.update(db.userProgressTable)).write(
      UserProgressTableCompanion(languageCode: Value(languageCode)),
    );
  }
}

/// Current theme mode, persisted in local DB.
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final db = ref.read(appDatabaseProvider);
    await (db.update(db.userProgressTable)).write(
      UserProgressTableCompanion(themeMode: Value(mode.name)),
    );
  }
}
