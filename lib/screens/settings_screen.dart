import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:amenities_kenya/providers/locale_provider.dart';
import 'package:amenities_kenya/providers/theme_provider.dart';
import 'package:amenities_kenya/services/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final fontSize = ref.watch(preferencesServiceProvider).getFontSize();

    return Scaffold(
      appBar: AppBar(title: Text(translations.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text(translations.theme),
            subtitle: Text(themeMode.toString().split('.').last),
            onTap: () => _showThemeDialog(context, ref),
          ),
          ListTile(
            title: Text(translations.language),
            subtitle: Text(locale.languageCode == 'en' ? 'English' : 'Swahili'),
            onTap: () => _showLanguageDialog(context, ref),
          ),
          ListTile(
            title: Text(translations.fontSize),
            subtitle: Text(fontSize.toString()),
            onTap: () => _showFontSizeDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        final translations = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(translations.theme),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(translations.lightMode),
                onTap: () {
                  ref.read(themeProvider.notifier).setTheme(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(translations.darkMode),
                onTap: () {
                  ref.read(themeProvider.notifier).setTheme(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(translations.systemMode),
                onTap: () {
                  ref.read(themeProvider.notifier).setTheme(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        final translations = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(translations.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Swahili'),
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(const Locale('sw'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showFontSizeDialog(BuildContext context, WidgetRef ref) async {
    double newFontSize = await ref.read(preferencesServiceProvider).getFontSize();
    showDialog(
      context: context,
      builder: (context) {
        final translations = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(translations.fontSize),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: newFontSize,
                    min: 12.0,
                    max: 24.0,
                    divisions: 6,
                    label: newFontSize.toString(),
                    onChanged: (value) {
                      setState(() {
                        newFontSize = value;
                      });
                    },
                  ),
                  Text('${newFontSize.toStringAsFixed(1)}'),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(translations.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(preferencesServiceProvider).setFontSize(newFontSize);
                Navigator.pop(context);
              },
              child: Text(translations.save),
            ),
          ],
        );
      },
    );
  }
}