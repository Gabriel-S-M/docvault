import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'models/company_item.dart';
import 'models/user_item.dart';
import 'screens/company_selection_screen.dart';
import 'screens/doc_vault_admin_screen.dart';
import 'screens/doc_vault_screen.dart';
import 'screens/user_management_screen.dart';
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
  late List<CompanyItem> _companies;
  late List<UserItem> _users;

  CompanyItem? _selectedCompany;
  UserItem? _superAdminUser;
  bool _isDocVaultAdminOpen = false;
  bool _isSuperAdminUserManagementOpen = false;

  @override
  void initState() {
    super.initState();
    _companies = List.from(kMockCompanies);
    _users = List.from(kMockUsers);
    _selectedCompany = widget.initialCompany;
  }

  void _toggleDarkMode(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _handleAddCompany(CompanyItem company) {
    setState(() {
      _companies.add(company);
    });
  }

  void _handleUpdateCompany(CompanyItem updated) {
    setState(() {
      final index = _companies.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        _companies[index] = updated;
      }
      if (_selectedCompany?.id == updated.id) {
        _selectedCompany = updated;
      }
    });
  }

  void _handleDeleteCompany(String companyId) {
    setState(() {
      _companies.removeWhere((c) => c.id == companyId);
      if (_selectedCompany?.id == companyId) {
        _selectedCompany = null;
      }
    });
  }

  void _handleAddUser(UserItem user) {
    setState(() {
      _users.add(user);
    });
  }

  void _handleUpdateUser(UserItem updated) {
    setState(() {
      final index = _users.indexWhere((u) => u.id == updated.id);
      if (index != -1) {
        _users[index] = updated;
      }
    });
  }

  void _handleDeleteUser(String userId) {
    setState(() {
      _users.removeWhere((u) => u.id == userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = _themeMode == ThemeMode.dark;

    Widget body;
    if (_isSuperAdminUserManagementOpen && _superAdminUser != null) {
      body = UserManagementScreen(
        currentUser: _superAdminUser!,
        users: _users,
        companies: _companies,
        onAddUser: _handleAddUser,
        onUpdateUser: _handleUpdateUser,
        onDeleteUser: _handleDeleteUser,
        onBack: () => setState(() => _isSuperAdminUserManagementOpen = false),
        isDarkMode: isDarkMode,
        onToggleDarkMode: _toggleDarkMode,
      );
    } else if (_isDocVaultAdminOpen) {
      body = DocVaultAdminScreen(
        companies: _companies,
        onAddCompany: _handleAddCompany,
        onUpdateCompany: _handleUpdateCompany,
        onDeleteCompany: _handleDeleteCompany,
        onOpenUserManagement: () =>
            setState(() => _isSuperAdminUserManagementOpen = true),
        onLogout: () => setState(() {
          _isDocVaultAdminOpen = false;
          _superAdminUser = null;
        }),
        isDarkMode: isDarkMode,
        onToggleDarkMode: _toggleDarkMode,
      );
    } else if (_selectedCompany != null) {
      body = DocVaultScreen(
        company: _selectedCompany!,
        companies: _companies,
        users: _users,
        onAddUser: _handleAddUser,
        onUpdateUser: _handleUpdateUser,
        onDeleteUser: _handleDeleteUser,
        onBackToCompanies: () {
          setState(() {
            _selectedCompany = null;
          });
        },
        isDarkMode: isDarkMode,
        onToggleDarkMode: _toggleDarkMode,
      );
    } else {
      body = CompanySelectionScreen(
        companies: _companies,
        users: _users,
        onSelectCompany: (company) {
          setState(() {
            _selectedCompany = company;
          });
        },
        onSuperAdminLogin: (user) {
          setState(() {
            _superAdminUser = user;
            _isDocVaultAdminOpen = true;
          });
        },
        isDarkMode: isDarkMode,
        onToggleDarkMode: _toggleDarkMode,
      );
    }

    return MaterialApp(
      title: 'DocVault',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      home: body,
    );
  }
}
