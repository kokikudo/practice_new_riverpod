import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../main.dart';

// SharedPreferences で使用するテーマ保存ようのキー
const _themePrefsKey = 'selectedThemeKey';

final themeSelectorProvider =
    StateNotifierProvider<ThemeSelectorNotifier, ThemeMode>(
        (ref) => ThemeSelectorNotifier(ref.read));

class ThemeSelectorNotifier extends StateNotifier<ThemeMode> {
  ThemeSelectorNotifier(this._read) : super(ThemeMode.system) {
    // `SharedPreferences` を使用して、記憶しているテーマがあれば取得して反映する。
    final themeIndex = _prefs.getInt(_themePrefsKey);
    if (themeIndex == null) {
      return;
    }
    final themeMode = ThemeMode.values.firstWhere(
      (e) => e.index == themeIndex,
      orElse: () => ThemeMode.system,
    );
    state = themeMode;
  }

  final Reader _read;

  // 選択したテーマを保存するためのローカル保存領域
  late final _prefs = _read(sharedPreferencesProvider);

  // テーマの変更と保存を行う
  Future<void> changeAndSave(ThemeMode theme) async {
    await _prefs.setInt(_themePrefsKey, theme.index);
    state = theme;
  }
}

class SettingThemeScreen extends ConsumerWidget {
  const SettingThemeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSelector = ref.watch(themeSelectorProvider.notifier);
    final currentThemeMode = ref.watch(themeSelectorProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting Theme'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: ThemeMode.values.length,
        itemBuilder: (_, index) {
          final themeMode = ThemeMode.values[index];
          return RadioListTile<ThemeMode>(
            value: themeMode,
            groupValue: currentThemeMode,
            onChanged: (newTheme) => themeSelector.changeAndSave(newTheme!),
            subtitle: Text(themeMode.subtitle),
            title: Text(describeEnum(themeMode)),
            secondary: Icon(themeMode.iconData),
          );
        },
      ),
    );
  }
}

extension ThemeModeExt on ThemeMode {
  String get subtitle {
    switch (this) {
      case ThemeMode.system:
        return '端末のシステム設定に追従します';
      case ThemeMode.light:
        return '明るいテーマです';
      case ThemeMode.dark:
        return '暗いテーマです';
    }
  }

  IconData get iconData {
    switch (this) {
      case ThemeMode.system:
        return Icons.autorenew;
      case ThemeMode.light:
        return Icons.wb_sunny;
      case ThemeMode.dark:
        return Icons.nightlife;
    }
  }
}
