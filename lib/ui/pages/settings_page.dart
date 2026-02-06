import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/sudoku_provider.dart';
import '../../services/persistence_service.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  final Map<String, String> _languages = const {
    'pt': 'Português',
    'en': 'English',
    // Adicione outros idiomas aqui
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsTitle)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(AppLocalizations.of(context)!.settingsLanguage, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                DropdownButton<String>(
              value: settings.language,
              items: _languages.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  notifier.setLanguage(value);
                }
              },
            ),
              ],
            ),
            const SizedBox(height: 24),
            // Theme mode
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(AppLocalizations.of(context)!.settingsTheme, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                DropdownButton<ThemeMode>(
              value: settings.themeMode,
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(AppLocalizations.of(context)!.settingsThemeSystem),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(AppLocalizations.of(context)!.settingsThemeLight),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(AppLocalizations.of(context)!.settingsThemeDark),
                ),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  notifier.setThemeMode(mode);
                }
              },
            ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            // Undo stack limit
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(AppLocalizations.of(context)!.settingsUndoStack, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                DropdownButton<int>(
              value: settings.undoStackLimit,
              items: [5, 10, 20, 50, 100, 200].map((v) => DropdownMenuItem<int>(value: v, child: Text('$v'))).toList(),
              onChanged: (v) {
                if (v != null) {
                  notifier.setUndoStackLimit(v);
                }
              },
            ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            // Realtime error checking
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.settingsErrorChecking, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(AppLocalizations.of(context)!.settingsRealtimeErrors),
                ),
                Switch(
                  value: settings.realtimeErrorChecking,
                  onChanged: (value) {
                    notifier.setRealtimeErrorChecking(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            // Display options
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.settingsDisplay, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(AppLocalizations.of(context)!.settingsLargerNumbers),
                ),
                Switch(
                  value: settings.largerNumbers,
                  onChanged: (value) {
                    notifier.setLargerNumbers(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(AppLocalizations.of(context)!.settingsHighlightRowCol),
                ),
                Switch(
                  value: settings.highlightRowCol,
                  onChanged: (value) {
                    notifier.setHighlightRowCol(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            // Reset progress
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(AppLocalizations.of(context)!.settingsDeleteProgress, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton.icon(
              onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final loc = AppLocalizations.of(context)!;
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(loc.settingsDeleteConfirmTitle),
                        content: Text(loc.settingsDeleteConfirmContent),
                      actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(loc.actionCancel)),
                          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(loc.actionDelete)),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    final persistence = PersistenceService();
                    await persistence.clearAll();

                    // Notifica o provider do Sudoku para resetar estado em memória
                    try {
                      await ref.read(sudokuNotifierProvider.notifier).resetState();
                    } catch (_) {
                      // Se algo der errado, ignoramos — o importante é que o armazenamento foi limpo
                    }

                    // Invalida o provider que expõe os jogos para atualizar UIs reativas
                    try {
                      ref.invalidate(allGamesProvider);
                    } catch (_) {}

                    messenger.showSnackBar(SnackBar(content: Text(loc.actionProgressCleared)));
                  }
                },
              icon: const Icon(Icons.delete_forever),
              label: Text(AppLocalizations.of(context)!.actionDelete),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            // App version
            const SizedBox(height: 12),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snap) {
                if (!snap.hasData) return const SizedBox.shrink();
                final info = snap.data!;
                return Text(AppLocalizations.of(context)!.versionPrefix(info.buildNumber, info.version));
              },
            ),
          ],
        ),
        ),
      ),
    );
  }
}
