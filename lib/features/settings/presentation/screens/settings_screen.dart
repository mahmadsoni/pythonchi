import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/services/core_providers.dart';
import '../../../../core/theme/app_colors.dart';

const _secureStorage = FlutterSecureStorage();
const _aiApiKeyStorageKey = 'anthropic_api_key';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  String? _apiKeyMasked;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final key = await _secureStorage.read(key: _aiApiKeyStorageKey);
    if (!mounted) return;
    setState(() {
      _apiKeyMasked = (key != null && key.isNotEmpty)
          ? '••••••••${key.substring(key.length > 4 ? key.length - 4 : 0)}'
          : null;
    });
  }

  Future<void> _editApiKey() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('AI API калид'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Барои истифодаи AI Assistant (шарҳи код, ислоҳ, тавлиди санҷиш), калиди API-и Anthropic-ро ворид кунед. Ин калид танҳо дар дастгоҳи шумо, дар хотираи рамзгузошташуда нигоҳ дошта мешавад.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'sk-ant-...'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Бекор кардан')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Нигоҳ доштан'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await _secureStorage.write(key: _aiApiKeyStorageKey, value: result);
      _loadApiKey();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Танзимот')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabel('Забон'),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  value: 'tg',
                  groupValue: locale.languageCode,
                  title: const Text('Тоҷикӣ'),
                  onChanged: (v) => ref.read(localeProvider.notifier).setLocale(v!),
                ),
                RadioListTile<String>(
                  value: 'ru',
                  groupValue: locale.languageCode,
                  title: const Text('Русский'),
                  onChanged: (v) => ref.read(localeProvider.notifier).setLocale(v!),
                ),
                RadioListTile<String>(
                  value: 'en',
                  groupValue: locale.languageCode,
                  title: const Text('English'),
                  onChanged: (v) => ref.read(localeProvider.notifier).setLocale(v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel('Мавзӯъ'),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: themeMode,
                  title: const Text('Мисли системаи дастгоҳ'),
                  onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  title: const Text('Равшан'),
                  onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  title: const Text('Торик'),
                  onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel('Огоҳиномаҳо'),
          Card(
            child: SwitchListTile(
              title: const Text('Ёдоварии рӯзонаи омӯзиш'),
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel('AI'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.key_rounded),
              title: const Text('AI API калид'),
              subtitle: Text(_apiKeyMasked ?? 'Танзим нашудааст'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _editApiKey,
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel('Дар бораи барнома'),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Pythonchi — барномаи омӯзиши Python аз сифр то сатҳи касбӣ. Бо ишқ барои омӯзандагони тоҷикзабон сохта шудааст.',
                style: TextStyle(fontSize: 13, color: AppColors.lightOnSurfaceMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.lightOnSurfaceMuted),
      ),
    );
  }
}
