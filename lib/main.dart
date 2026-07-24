import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'data/settings_store.dart';
import 'domain/time_price_calculator.dart';
import 'ui/home_screen.dart';
import 'ui/setup_screen.dart';
import 'ui/mini_calculator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TimePriceApp());
}

class TimePriceApp extends StatefulWidget {
  const TimePriceApp({super.key});

  @override
  State<TimePriceApp> createState() => _TimePriceAppState();
}

class _TimePriceAppState extends State<TimePriceApp> {
  final _store = SettingsStore();
  WorkProfile? _profile;
  var _loading = true;
  bool _showMiniCalc = false;

  @override
  void initState() {
    super.initState();
    _load();
    _checkInitialUri();
  }

  Future<void> _checkInitialUri() async {
    final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (uri?.host == 'calc') {
      setState(() => _showMiniCalc = true);
    }
  }

  Future<void> _load() async {
    final profile = await _store.load();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  Future<void> _save(WorkProfile profile) async {
    await _store.save(profile);
    if (mounted) {
      setState(() => _profile = profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF7867E6);
    return MaterialApp(
      title: 'Часы Жизни',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
          surface: const Color(0xFF121218),
        ),
        scaffoldBackgroundColor: const Color(0xFF0C0C11),
        cardTheme: const CardThemeData(
          color: Color(0xFF17171F),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1B1B24),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: _loading
          ? const _Splash()
          : _profile == null
              ? SetupScreen(onSaved: _save)
              : _showMiniCalc
                  ? MiniCalculator(profile: _profile!)
                  : Builder(
                      builder: (navigatorContext) => HomeScreen(
                        profile: _profile!,
                        onEdit: () => Navigator.of(navigatorContext).push(
                          MaterialPageRoute<void>(
                            builder: (setupContext) => SetupScreen(
                              initialProfile: _profile,
                              onSaved: (value) async {
                                await _save(value);
                                if (setupContext.mounted) {
                                  Navigator.of(setupContext).pop();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}
