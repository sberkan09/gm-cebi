import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      home: const PhonePortrait(child: HomeShell()),
    );
  }
}

/// Screens with a shortest side under this many dp are phones.
const tabletShortestSide = 600.0;

/// The orientations the app takes on a screen of [size] (dp), for
/// [SystemChrome.setPreferredOrientations], where an empty list means every
/// orientation. Phones are portrait only: in landscape the lists are a strip
/// between the bars and the keyboard leaves no room to type a note. Tablets
/// rotate freely. Null while the size is not known (before the first frame).
List<DeviceOrientation>? orientationsFor(Size size) {
  if (size.isEmpty) return null;
  return size.shortestSide < tabletShortestSide ? const [DeviceOrientation.portraitUp] : const [];
}

/// Keeps a phone in portrait (see [orientationsFor]); on iOS the Info.plist
/// says the same, so an iPhone does not start sideways either.
class PhonePortrait extends StatefulWidget {
  const PhonePortrait({super.key, required this.child});

  final Widget child;

  @override
  State<PhonePortrait> createState() => _PhonePortraitState();
}

class _PhonePortraitState extends State<PhonePortrait> with WidgetsBindingObserver {
  /// What the system was last told.
  List<DeviceOrientation>? _orientations;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // After the first frame: the size of the view is known by then.
    WidgetsBinding.instance.addPostFrameCallback((_) => _apply());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The size changed: a foldable was opened or closed, or a tablet's window
  /// was resized. (A phone kept in portrait never gets here by turning.)
  @override
  void didChangeMetrics() => _apply();

  void _apply() {
    if (!mounted) return;
    final view = View.of(context);
    final wanted = orientationsFor(view.physicalSize / view.devicePixelRatio);
    if (wanted == null || listEquals(wanted, _orientations)) return;
    _orientations = wanted;
    SystemChrome.setPreferredOrientations(wanted);
  }

  @override
  Widget build(BuildContext context) => widget.child;
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
