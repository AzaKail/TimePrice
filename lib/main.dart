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
    _initApp();
  }

  Future<void> _initApp() async {
    print('DEBUG: Начало инициализации...');
    try {
      final profile = await _store.load();
      print('DEBUG: Профиль загружен: ${profile != null}');
      
      Uri? initialUri;
      try {
        initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget().timeout(
          const Duration(milliseconds: 500),
          onTimeout: () => null,
        );
      } catch (e) {
        print('DEBUG: Ошибка виджета: $e');
      }

      if (mounted) {
        setState(() {
          _profile = profile;
          _showMiniCalc = initialUri?.host == 'calc';
          _loading = false;
        });
      }
    } catch (e) {
      print('DEBUG: Глобальная ошибка инициализации: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _save(WorkProfile profile) async {
    print('DEBUG: Сохранение профиля...');
    try {
      await _store.save(profile);
      print('DEBUG: Сохранено успешно');
      if (mounted) {
        setState(() => _profile = profile);
      }
    } catch (e) {
      print('DEBUG: Ошибка сохранения: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Часы Жизни',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7867E6),
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
