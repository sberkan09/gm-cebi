import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_info.dart';
import 'features/flags.dart';
import 'providers.dart';
import 'ui/screens/dice_screen.dart';
import 'ui/screens/initiative_screen.dart';
import 'ui/screens/notes_screen.dart';
import 'ui/screens/search_screen.dart';
import 'ui/theme.dart';

class GmCebiApp extends ConsumerWidget {
  const GmCebiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(currentSettingsProvider);
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: settings.themeMode,
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeShell(),
    );
  }
}

/// Bottom navigation: everything one thumb away.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final ent = ref.watch(entitlementsProvider);
    Widget lockable(IconData icon, Feature f) =>
        ent.isLocked(f) ? Badge(label: const Icon(Icons.lock, size: 10), child: Icon(icon)) : Icon(icon);
    return Scaffold(
      body: IndexedStack(index: _index, children: const [
        SearchScreen(),
        DiceScreen(),
        InitiativeScreen(),
        NotesScreen(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.search), label: 'Ara'),
          const NavigationDestination(icon: Icon(Icons.casino_outlined), label: 'Zar'),
          NavigationDestination(icon: lockable(Icons.format_list_numbered, Feature.initiative), label: 'İnisiyatif'),
          NavigationDestination(icon: lockable(Icons.edit_note, Feature.sessionNotes), label: 'Notlar'),
        ],
      ),
    );
  }
}
