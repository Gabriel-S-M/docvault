import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'models/company_item.dart';
import 'models/user_item.dart';
import 'screens/company_selection_screen.dart';
import 'screens/doc_vault_admin_screen.dart';
import 'screens/doc_vault_screen.dart';
import 'screens/user_management_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  List<CompanyItem> _companies = [];
  List<UserItem> _users = [];
  bool _isLoading = true;

  CompanyItem? _selectedCompany;
  UserItem? _superAdminUser;
  bool _isDocVaultAdminOpen = false;
  bool _isSuperAdminUserManagementOpen = false;

  StreamSubscription<List<CompanyItem>>? _companiesSub;
  StreamSubscription<List<UserItem>>? _usersSub;

  @override
  void initState() {
    super.initState();
    _selectedCompany = widget.initialCompany;

    // Escuta empresas em tempo real do Firestore
    _companiesSub = FirestoreService().streamCompanies().listen(
      (companies) {
        if (!mounted) return;
        setState(() {
          _companies = companies;
          _isLoading = false;
          // Atualiza a referência da empresa selecionada se ela mudar
          if (_selectedCompany != null) {
            final index =
                companies.indexWhere((c) => c.id == _selectedCompany!.id);
            if (index != -1) {
              _selectedCompany = companies[index];
            }
          }
        });
      },
      onError: (e) {
        debugPrint('Erro ao sincronizar empresas: $e');
        if (mounted) setState(() => _isLoading = false);
      },
    );

    // Escuta usuários em tempo real do Firestore
    _usersSub = FirestoreService().streamUsers().listen(
      (users) {
        if (!mounted) return;
        setState(() {
          _users = users;
        });
      },
      onError: (e) {
        debugPrint('Erro ao sincronizar usuários: $e');
      },
    );
  }

  @override
  void dispose() {
    _companiesSub?.cancel();
    _usersSub?.cancel();
    super.dispose();
  }

  void _toggleDarkMode(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _handleAddCompany(CompanyItem company) async {
    try {
      await FirestoreService().addCompany(company);
    } catch (e) {
      debugPrint('Erro ao criar empresa no Firestore: $e');
    }
  }

  void _handleUpdateCompany(CompanyItem updated) async {
    try {
      await FirestoreService().updateCompany(updated);
    } catch (e) {
      debugPrint('Erro ao atualizar empresa no Firestore: $e');
    }
  }

  void _handleDeleteCompany(String companyId) async {
    try {
      await FirestoreService().deleteCompany(companyId);
      if (_selectedCompany?.id == companyId) {
        setState(() {
          _selectedCompany = null;
        });
      }
    } catch (e) {
      debugPrint('Erro ao excluir empresa no Firestore: $e');
    }
  }

  void _handleAddUser(UserItem user) async {
    try {
      if (user.password.isNotEmpty) {
        try {
          final cred =
              await AuthService().createAccount(user.email, user.password);
          final uid = cred.user?.uid;
          if (uid != null) {
            await FirestoreService().setUser(user.copyWith(id: uid));
            return;
          }
        } catch (authError) {
          debugPrint('Aviso ao registrar usuário no Auth: $authError');
        }
      }
      await FirestoreService().setUser(user);
    } catch (e) {
      debugPrint('Erro ao salvar usuário no Firestore: $e');
    }
  }

  void _handleUpdateUser(UserItem updated) async {
    try {
      await FirestoreService().updateUser(updated);
    } catch (e) {
      debugPrint('Erro ao atualizar usuário no Firestore: $e');
    }
  }

  void _handleDeleteUser(String userId) async {
    try {
      await FirestoreService().deleteUser(userId);
    } catch (e) {
      debugPrint('Erro ao excluir usuário no Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = _themeMode == ThemeMode.dark;

    Widget body;
    if (_isLoading) {
      body = Scaffold(
        backgroundColor:
            isDarkMode ? const Color(0xFF0C0A09) : const Color(0xFFFAFAF9),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_isSuperAdminUserManagementOpen && _superAdminUser != null) {
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
        onLogout: () async {
          await AuthService().signOut();
          setState(() {
            _isDocVaultAdminOpen = false;
            _superAdminUser = null;
          });
        },
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
