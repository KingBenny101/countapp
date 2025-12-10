import "package:countapp/counters/tap_counter.dart";
import "package:countapp/models/counter_model.dart";
import "package:countapp/providers/counter_provider.dart";
import "package:countapp/screens/about_page.dart";
import "package:countapp/screens/guide_page.dart";
import "package:countapp/screens/home_page.dart";
import "package:countapp/screens/options_page.dart";
import "package:countapp/screens/update_page.dart";
import "package:countapp/theme/theme_notifier.dart";
import "package:countapp/utils/constants.dart";
import "package:countapp/utils/migration.dart";
import "package:flutter/material.dart";
import "package:hive_ce_flutter/hive_flutter.dart";
import "package:provider/provider.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox(AppConstants.settingsBox);

  // Register old adapter for migration
  Hive.registerAdapter(CounterAdapter());

  // Register new adapters
  Hive.registerAdapter(TapCounterAdapter());
  Hive.registerAdapter(TapDirectionAdapter());

  // Perform migration if needed
  await CounterMigration.migrateIfNeeded();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => CounterProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        themeNotifier.updateSystemUiOverlay();
        return MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeNotifier.themeMode,
          home: const HomePage(),
          routes: {
            "/updates": (context) => const UpdatePage(),
            "/options": (context) => const OptionsPage(),
            "/guide": (context) => const GuidePage(),
            "/about": (context) => const AboutPage(),
          },
        );
      },
    );
  }
}
