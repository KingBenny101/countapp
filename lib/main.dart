import "package:countapp/models/counter_model.dart";
import "package:countapp/providers/counter_provider.dart";
import "package:countapp/screens/home_page.dart";
import "package:countapp/theme/theme_notifier.dart";
import "package:flutter/material.dart";
import "package:hive_ce_flutter/hive_flutter.dart";
import "package:provider/provider.dart";
import "package:toastification/toastification.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox("settings");

  Hive.registerAdapter(CounterAdapter());

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
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    themeNotifier.updateSystemUiOverlay();

    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return ToastificationWrapper(
          child: MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeNotifier.themeMode,
            home: const HomePage(),
          ),
        );
      },
    );
  }
}
