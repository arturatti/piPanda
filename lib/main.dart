import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syllables_apk/screens/home_screen.dart';
import 'package:syllables_apk/state/providers.dart';
import 'package:syllables_apk/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: SyllablesApp()));
}

class SyllablesApp extends StatelessWidget {
  const SyllablesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'piPanda',
      theme: AppTheme.light(),
      home: const _AppRoot(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _AppRoot extends ConsumerStatefulWidget {
  const _AppRoot();

  @override
  ConsumerState<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<_AppRoot> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bgm = ref.read(bgmServiceProvider);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        bgm.pauseForLifecycle();
        break;
      case AppLifecycleState.resumed:
        bgm.resumeAfterLifecycle();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(bgmServiceProvider);
    final words = ref.watch(wordsProvider);
    return words.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Ошибка загрузки словаря:\n$e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (_) => const HomeScreen(),
    );
  }
}
