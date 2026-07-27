import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/services/core_providers.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PythonchiApp()));
}

class PythonchiApp extends ConsumerStatefulWidget {
  const PythonchiApp({super.key});

  @override
  ConsumerState<PythonchiApp> createState() => _PythonchiAppState();
}

class _PythonchiAppState extends ConsumerState<PythonchiApp> {
  bool _syncedFromDb = false;

  @override
  Widget build(BuildContext context) {
    // One-time sync: apply the persisted language/theme (saved in the local
    // database) to the in-memory notifiers as soon as the DB row loads.
    // Guarded by _syncedFromDb so we don't fight the user's live choices
    // made afterwards in Settings.
    ref.listen(userProgressStreamProvider, (previous, next) {
      if (_syncedFromDb) return;
      next.whenData((progress) {
        _syncedFromDb = true;
        ref.read(localeProvider.notifier).state = Locale(progress.languageCode);
        ref.read(themeModeProvider.notifier).state = ThemeMode.values.firstWhere(
          (m) => m.name == progress.themeMode,
          orElse: () => ThemeMode.system,
        );
      });
    });

    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Pythonchi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: AppRouter.router,
    );
  }
}
