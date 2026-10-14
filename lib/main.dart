import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'models/company_item.dart';
import 'screens/company_selection_screen.dart';
import 'screens/doc_vault_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  final CompanyItem? initialCompany;

  const MainApp({
    super.key,
    this.initialCompany,
  });

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.light;
  CompanyItem? _selectedCompany;

  @override
  void initState() {
    super.initState();
    _selectedCompany = widget.initialCompany;
  }

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
      home: _selectedCompany == null
          ? CompanySelectionScreen(
              companies: kMockCompanies,
              onSelectCompany: (company) {
                setState(() {
                  _selectedCompany = company;
                });
              },
              isDarkMode: isDarkMode,
              onToggleDarkMode: _toggleDarkMode,
            )
          : DocVaultScreen(
              company: _selectedCompany!,
              onBackToCompanies: () {
                setState(() {
                  _selectedCompany = null;
                });
              },
              isDarkMode: isDarkMode,
              onToggleDarkMode: _toggleDarkMode,
            ),
    );
  }
}
