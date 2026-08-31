import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/doc_vault_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleDarkMode(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = _themeMode == ThemeMode.dark;

    return MaterialApp(
      title: 'DocVault',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      home: DocVaultScreen(
        isDarkMode: isDarkMode,
        onToggleDarkMode: _toggleDarkMode,
      ),
    );
  }
}
