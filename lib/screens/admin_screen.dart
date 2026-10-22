import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/company_item.dart';
import '../models/document_item.dart';
import '../models/user_item.dart';
import '../theme/app_theme.dart';
import '../widgets/add_doc_modal.dart';
import '../widgets/admin_card.dart';
import '../widgets/document_list_tile.dart';
import '../widgets/edit_doc_modal.dart';
import '../widgets/options_panel.dart';

class AdminScreen extends StatefulWidget {
  final List<DocumentItem> docs;
  final ValueChanged<DocumentItem> onUpdate;
  final ValueChanged<String> onDelete;
  final VoidCallback onLogout;
  final bool isDarkMode;
  final ValueChanged<bool> onToggleDarkMode;
  final CompanyItem? company;
  final VoidCallback? onBackToCompanies;
  final UserItem? currentUser;
  final List<UserItem>? users;
  final VoidCallback? onOpenUserManagement;
  final ValueChanged<DocumentItem>? onAddDoc;

  const AdminScreen({
    super.key,
    required this.docs,
    required this.onUpdate,
    required this.onDelete,
    required this.onLogout,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    this.company,
    this.onBackToCompanies,
    this.currentUser,
    this.users,
    this.onOpenUserManagement,
    this.onAddDoc,
  });

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  DocumentItem? _editingDoc;
  bool _isAddingDoc = false;
  String _search = '';
  String _filterCat = 'Todos';
  SortKey _sortKey = SortKey.date;
  ViewMode _viewMode = ViewMode.grid;
  bool _isPanelOpen = false;

  List<DocumentItem> get _visibleDocs {
    final query = _search.toLowerCase().trim();
    final list = widget.docs.where((d) {
      final matchCat = _filterCat == 'Todos' || d.category == _filterCat;
      final matchSearch = query.isEmpty ||
          d.title.toLowerCase().contains(query) ||
          d.author.toLowerCase().contains(query) ||
          d.category.toLowerCase().contains(query);
      return matchCat && matchSearch;
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

  Widget _buildCategoryPill(String cat, bool isDark) {
    final isSelected = _filterCat == cat;
    return InkWell(
      onTap: () => setState(() => _filterCat = cat),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.indigo700
              : (isDark ? AppColors.stone800 : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.indigo700
                : (isDark ? AppColors.stone700 : AppColors.stone200),
          ),
        ),
        child: Text(
          cat,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.stone300 : AppColors.stone600),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final visible = _visibleDocs;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 768;
    final crossAxisCount = _calculateCrossAxisCount(size.width);

    return Scaffold(
      backgroundColor: isDark ? AppColors.stone950 : AppColors.stone50,
      body: Stack(
        children: [
          Column(
            children: [
              // Admin Top Header
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.stone900 : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.stone700 : AppColors.stone200,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: Row(
                      children: [
                        // Logo and Admin Tag
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.indigo600,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.description_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'DocVault',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                letterSpacing: -0.3,
                                color: isDark ? AppColors.stone100 : AppColors.stone900,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.indigo950
                                    : AppColors.indigo500.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'ADMIN',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.indigo400 : AppColors.indigo700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            if (widget.company != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.stone800 : AppColors.stone100,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isDark ? AppColors.stone700 : AppColors.stone300,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      widget.company!.icon,
                                      size: 12,
                                      color: widget.company!.accentColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.company!.name,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.stone300 : AppColors.stone700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(width: 16),

                        // Search Input
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 450),
                              child: SizedBox(
                                height: 38,
                                child: TextField(
                                  onChanged: (v) => setState(() => _search = v),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppColors.stone100 : AppColors.stone900,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Filtrar documentos…',
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      size: 18,
                                      color: isDark ? AppColors.stone400 : AppColors.stone400,
                                    ),
                                    suffixIcon: _search.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.close_rounded, size: 16),
                                            splashRadius: 14,
                                            onPressed: () => setState(() => _search = ''),
                                          )
                                        : null,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                                    filled: true,
                                    fillColor: isDark ? AppColors.stone800 : AppColors.stone50,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: isDark ? AppColors.stone600 : AppColors.stone200,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: AppColors.indigo600,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Bot�o Adicionar Documento (gerente e super gerente)
                        if (widget.currentUser != null &&
                            (widget.currentUser!.isGerente || widget.currentUser!.isSuperGerente)) ...[
                          ElevatedButton.icon(
                            onPressed: () => setState(() => _isAddingDoc = true),
                            icon: const Icon(Icons.upload_file_rounded, size: 15),
                            label: Text(isDesktop ? 'Adicionar Documento' : '+Doc'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.indigo600,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 14 : 10,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],

                        // Doc Counter Badge
                        if (isDesktop) ...[
                          Text(
                            '${visible.length} docs',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              color: AppColors.stone400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],

                        // Opções Button (opens OptionsPanel with user info and Sair)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => setState(() => _isPanelOpen = !_isPanelOpen),
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: _isPanelOpen
                                    ? AppColors.indigo700
                                    : (isDark ? AppColors.stone800 : Colors.white),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _isPanelOpen
                                      ? AppColors.indigo700
                                      : (isDark ? AppColors.stone600 : AppColors.stone200),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.tune_rounded,
                                    size: 15,
                                    color: _isPanelOpen
                                        ? Colors.white
                                        : (isDark ? AppColors.stone200 : AppColors.stone700),
                                  ),
                                  if (isDesktop) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      'Opções',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: _isPanelOpen
                                            ? Colors.white
                                            : (isDark ? AppColors.stone200 : AppColors.stone700),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(width: 4),
                                  AnimatedRotation(
                                    turns: _isPanelOpen ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 16,
                                      color: _isPanelOpen
                                          ? Colors.white
                                          : (isDark ? AppColors.stone400 : AppColors.stone500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Main Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1280),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Toolbar Header: Title & Individual Category Wrap
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gerenciar documentos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                  color: isDark ? AppColors.stone100 : AppColors.stone900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${widget.docs.length} documentos cadastrados · clique no lápis para editar',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.stone400 : AppColors.stone500,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Categories wrap individually so they never get cut off
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: kDocumentCategories
                                    .map((c) => _buildCategoryPill(c, isDark))
                                    .toList(),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // Card Grid or List
                          if (visible.isEmpty)
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
                                  ],
                                ),
                              ),
                            )
                          else if (_viewMode == ViewMode.grid)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: visible.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                mainAxisExtent: 295,
                              ),
                              itemBuilder: (context, index) {
                                final doc = visible[index];
                                return AdminCard(
                                  doc: doc,
                                  isDarkMode: isDark,
                                  onEdit: (selected) {
                                    setState(() => _editingDoc = selected);
                                  },
                                  onDelete: (id) {
                                    widget.onDelete(id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Documento excluído com sucesso.'),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: AppColors.stone800,
                                      ),
                                    );
                                  },
                                );
                              },
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: visible.length,
                              itemBuilder: (context, index) {
                                final doc = visible[index];
                                return DocumentListTile(
                                  doc: doc,
                                  isDarkMode: isDark,
                                  isAdmin: true,
                                  onTap: () {},
                                  onEdit: (selected) {
                                    setState(() => _editingDoc = selected);
                                  },
                                  onDelete: (id) {
                                    widget.onDelete(id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Documento excluído com sucesso.'),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: AppColors.stone800,
                                      ),
                                    );
                                  },
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
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _isPanelOpen = false),
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              top: 56,
              right: 16,
              child: OptionsPanel(
                isDarkMode: isDark,
                onToggleDarkMode: widget.onToggleDarkMode,
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
                isLoggedIn: true,
                onLogin: () {},
                onLogout: () {
                  setState(() => _isPanelOpen = false);
                  widget.onLogout();
                },
                onClose: () => setState(() => _isPanelOpen = false),
                company: widget.company,
                onBackToCompanies: widget.onBackToCompanies,
                currentUser: widget.currentUser,
                users: widget.users,
                onOpenUserManagement: () {
                  setState(() => _isPanelOpen = false);
                  widget.onOpenUserManagement?.call();
                },
              ),
            ),
          ],

          // Add Document Modal
          if (_isAddingDoc)
            AddDocModal(
              isDarkMode: isDark,
              onSave: (newDoc) {
                widget.onAddDoc?.call(newDoc);
              },
              onClose: () => setState(() => _isAddingDoc = false),
            ),

          // Edit Document Side Sheet / Modal
          if (_editingDoc != null)
            EditDocModal(
              doc: _editingDoc!,
              isDarkMode: isDark,
              onSave: (updated) {
                widget.onUpdate(updated);
              },
              onClose: () => setState(() => _editingDoc = null),
            ),
        ],
      ),
    );
  }
}
