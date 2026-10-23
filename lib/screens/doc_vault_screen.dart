import 'dart:async';
import 'package:flutter/material.dart';
import '../models/company_item.dart';
import '../models/document_item.dart';
import '../models/user_item.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/category_bar.dart';
import '../widgets/document_card.dart';
import '../widgets/document_list_tile.dart';
import '../widgets/options_panel.dart';
import '../widgets/pdf_modal.dart';
import 'admin_screen.dart';
import 'user_management_screen.dart';

class DocVaultScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onToggleDarkMode;
  final CompanyItem? company;
  final VoidCallback? onBackToCompanies;
  final List<UserItem>? users;
  final ValueChanged<UserItem>? onAddUser;
  final ValueChanged<UserItem>? onUpdateUser;
  final ValueChanged<String>? onDeleteUser;
  final List<CompanyItem>? companies;

  const DocVaultScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    this.company,
    this.onBackToCompanies,
    this.users,
    this.onAddUser,
    this.onUpdateUser,
    this.onDeleteUser,
    this.companies,
  });

  @override
  State<DocVaultScreen> createState() => _DocVaultScreenState();
}

class _DocVaultScreenState extends State<DocVaultScreen> {
  late List<DocumentItem> _docs;
  String _activeCategory = 'Todos';
  String _searchQuery = '';
  SortKey _sortKey = SortKey.date;
  ViewMode _viewMode = ViewMode.grid;
  bool _isPanelOpen = false;
  bool _isAdminMode = false;
  UserItem? _currentUser;
  bool _isUserManagementOpen = false;
  DocumentItem? _openDoc;
  StreamSubscription<List<DocumentItem>>? _docsSub;

  @override
  void initState() {
    super.initState();
    _docs = List.from(widget.company?.documents ?? []);
    if (widget.company != null) {
      _docsSub = FirestoreService()
          .streamDocuments(widget.company!.id)
          .listen((docs) {
        if (!mounted) return;
        setState(() {
          _docs = docs;
        });
      }, onError: (e) {
        debugPrint('Erro ao ouvir documentos: $e');
      });
    }
  }

  @override
  void dispose() {
    _docsSub?.cancel();
    super.dispose();
  }

  List<DocumentItem> get _filteredDocuments {
    final query = _searchQuery.toLowerCase().trim();

    final list = _docs.where((doc) {
      final matchesCategory =
          _activeCategory == 'Todos' || doc.category == _activeCategory;
      final matchesSearch = query.isEmpty ||
          doc.title.toLowerCase().contains(query) ||
          doc.author.toLowerCase().contains(query) ||
          doc.category.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    list.sort((a, b) {
      switch (_sortKey) {
        case SortKey.date:
          return b.date.compareTo(a.date);
        case SortKey.title:
          return a.title.compareTo(b.title);
        case SortKey.size:
          return b.sizeInMb.compareTo(a.sizeInMb);
        case SortKey.pages:
          return b.pages.compareTo(a.pages);
      }
    });

    return list;
  }

  int _calculateCrossAxisCount(double width) {
    if (width < 600) return 1;
    if (width < 960) return 2;
    if (width < 1280) return 3;
    return 4;
  }

  void _handleUpdateDoc(DocumentItem updated) async {
    setState(() {
      final index = _docs.indexWhere((d) => d.id == updated.id);
      if (index != -1) {
        _docs[index] = updated;
      }
    });

    if (widget.company != null) {
      try {
        await FirestoreService().updateDocument(widget.company!.id, updated);
      } catch (e) {
        debugPrint('Erro ao atualizar documento no Firestore: $e');
      }
    }
  }

  void _handleDeleteDoc(String id) async {
    setState(() {
      _docs.removeWhere((d) => d.id == id);
    });

    if (widget.company != null) {
      try {
        await FirestoreService().deleteDocument(widget.company!.id, id);
      } catch (e) {
        debugPrint('Erro ao excluir documento no Firestore: $e');
      }
    }
  }

  void _handleAddDoc(DocumentItem newDoc) async {
    if (widget.company != null) {
      try {
        final id = await FirestoreService().addDocument(widget.company!.id, newDoc);
        final saved = newDoc.copyWith(id: id);
        setState(() {
          _docs.insert(0, saved);
        });
      } catch (e) {
        debugPrint('Erro ao adicionar documento no Firestore: ');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    // If in User Management Mode:
    if (_isUserManagementOpen && _currentUser != null) {
      return UserManagementScreen(
        currentUser: _currentUser!,
        currentCompany: widget.company,
        users: widget.users ?? const [],
        companies: widget.companies ??
            (widget.company != null ? [widget.company!] : const []),
        onAddUser: (u) => widget.onAddUser?.call(u),
        onUpdateUser: (u) => widget.onUpdateUser?.call(u),
        onDeleteUser: (id) => widget.onDeleteUser?.call(id),
        onBack: () => setState(() => _isUserManagementOpen = false),
        isDarkMode: isDark,
        onToggleDarkMode: widget.onToggleDarkMode,
      );
    }

    // If in Admin Mode, show AdminScreen
    if (_isAdminMode) {
      return AdminScreen(
        docs: _docs,
        onUpdate: _handleUpdateDoc,
        onDelete: _handleDeleteDoc,
        onLogout: () => setState(() {
          _isAdminMode = false;
          _currentUser = null;
        }),
        isDarkMode: isDark,
        onToggleDarkMode: widget.onToggleDarkMode,
        company: widget.company,
        onBackToCompanies: widget.onBackToCompanies,
        currentUser: _currentUser,
        users: widget.users,
        onOpenUserManagement: () => setState(() => _isUserManagementOpen = true),
        onAddDoc: _handleAddDoc,
      );
    }

    final filtered = _filteredDocuments;
    final size = MediaQuery.of(context).size;
    final crossAxisCount = _calculateCrossAxisCount(size.width);

    return Scaffold(
      backgroundColor: isDark ? AppColors.stone950 : AppColors.stone50,
      body: Stack(
        children: [
          // Main Scrollable Area
          Column(
            children: [
              // Top Header
              AppHeader(
                searchQuery: _searchQuery,
                onSearchChanged: (val) => setState(() => _searchQuery = val),
                totalCount: filtered.length,
                isPanelOpen: _isPanelOpen,
                onTogglePanel: () => setState(() => _isPanelOpen = !_isPanelOpen),
                isDarkMode: isDark,
                company: widget.company,
                onBackToCompanies: widget.onBackToCompanies,
              ),

              // Sticky Category Bar
              CategoryBar(
                categories: kDocumentCategories,
                activeCategory: _activeCategory,
                onSelectCategory: (cat) => setState(() => _activeCategory = cat),
                isDarkMode: isDark,
              ),

              // Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1280),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Title
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              _activeCategory == 'Todos'
                                  ? 'Todos os documentos'
                                  : _activeCategory,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                color: isDark ? AppColors.stone100 : AppColors.stone900,
                              ),
                            ),
                          ),

                          // Empty State
                          if (filtered.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 80),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.find_in_page_outlined,
                                      size: 48,
                                      color: isDark ? AppColors.stone700 : AppColors.stone400,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Nenhum documento encontrado',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? AppColors.stone400 : AppColors.stone500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Tente ajustar seus termos de busca ou categoria.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.stone600 : AppColors.stone400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          // Grid Mode
                          else if (_viewMode == ViewMode.grid)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filtered.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                mainAxisExtent: 295,
                              ),
                              itemBuilder: (context, index) {
                                final doc = filtered[index];
                                return DocumentCard(
                                  doc: doc,
                                  isDarkMode: isDark,
                                  onTap: () => setState(() => _openDoc = doc),
                                );
                              },
                            )
                          // List Mode
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final doc = filtered[index];
                                return DocumentListTile(
                                  doc: doc,
                                  isDarkMode: isDark,
                                  onTap: () => setState(() => _openDoc = doc),
                                );
                              },
                            ),

                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Options Panel Overlay
          if (_isPanelOpen) ...[
            // Outside touch detector to close panel
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _isPanelOpen = false),
                child: Container(color: Colors.transparent),
              ),
            ),

            // Floating Panel anchored below Header
            Positioned(
              top: 56,
              right: 16,
              child: OptionsPanel(
                isDarkMode: isDark,
                onToggleDarkMode: (val) {
                  widget.onToggleDarkMode(val);
                },
                currentSortKey: _sortKey,
                onSortKeyChanged: (key) {
                  setState(() {
                    _sortKey = key;
                    _isPanelOpen = false;
                  });
                },
                currentViewMode: _viewMode,
                onViewModeChanged: (mode) {
                  setState(() {
                    _viewMode = mode;
                    _isPanelOpen = false;
                  });
                },
                isLoggedIn: _isAdminMode,
                users: widget.users,
                currentUser: _currentUser,
                onLoginUser: (user) {
                  setState(() {
                    _currentUser = user;
                  });
                },
                onLogin: () {
                  setState(() {
                    _isAdminMode = true;
                    _isPanelOpen = false;
                  });
                },
                onLogout: () {
                  setState(() {
                    _isAdminMode = false;
                    _currentUser = null;
                    _isPanelOpen = false;
                  });
                },
                onClose: () => setState(() => _isPanelOpen = false),
                company: widget.company,
                onBackToCompanies: widget.onBackToCompanies,
                onOpenUserManagement: () {
                  setState(() {
                    _isPanelOpen = false;
                    _isUserManagementOpen = true;
                  });
                },
              ),
            ),
          ],

          // Fullscreen PDF Viewer Modal
          if (_openDoc != null)
            PdfModal(
              doc: _openDoc!,
              isDarkMode: isDark,
              onClose: () => setState(() => _openDoc = null),
            ),
        ],
      ),
    );
  }
}
