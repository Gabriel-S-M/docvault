import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/document_item.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_card.dart';
import '../widgets/edit_doc_modal.dart';

class AdminScreen extends StatefulWidget {
  final List<DocumentItem> docs;
  final ValueChanged<DocumentItem> onUpdate;
  final ValueChanged<int> onDelete;
  final VoidCallback onLogout;
  final bool isDarkMode;

  const AdminScreen({
    super.key,
    required this.docs,
    required this.onUpdate,
    required this.onDelete,
    required this.onLogout,
    required this.isDarkMode,
  });

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  DocumentItem? _editingDoc;
  String _search = '';
  String _filterCat = 'Todos';

  List<DocumentItem> get _visibleDocs {
    final query = _search.toLowerCase().trim();
    return widget.docs.where((d) {
      final matchCat = _filterCat == 'Todos' || d.category == _filterCat;
      final matchSearch = query.isEmpty ||
          d.title.toLowerCase().contains(query) ||
          d.author.toLowerCase().contains(query) ||
          d.category.toLowerCase().contains(query);
      return matchCat && matchSearch;
    }).toList();
  }

  int _calculateCrossAxisCount(double width) {
    if (width < 600) return 1;
    if (width < 960) return 2;
    if (width < 1280) return 3;
    return 4;
  }

  Widget _buildCategoryPill(String cat, bool isDark) {
    final isSelected = _filterCat == cat;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: () => setState(() => _filterCat = cat),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.stone400 : AppColors.stone600),
            ),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                          ],
                        ),

                        const SizedBox(width: 16),

                        // Search Input
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 380),
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

                        // User profile + Logout
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: AppColors.indigo700,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  'A',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            if (size.width >= 700) ...[
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Teste',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.stone200 : AppColors.stone800,
                                    ),
                                  ),
                                  Text(
                                    'Administrador',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.stone400,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                            ],
                            OutlinedButton.icon(
                              onPressed: widget.onLogout,
                              icon: const Icon(Icons.logout_rounded, size: 14),
                              label: const Text('Sair'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark ? AppColors.stone400 : AppColors.stone600,
                                side: BorderSide(
                                  color: isDark ? AppColors.stone600 : AppColors.stone200,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
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
                          // Toolbar Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
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
                                    const SizedBox(height: 2),
                                    Text(
                                      '${widget.docs.length} documentos cadastrados · clique no lápis para editar',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? AppColors.stone400 : AppColors.stone500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Filter Pills for Desktop
                              if (size.width >= 800)
                                Flexible(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: kDocumentCategories
                                          .map((c) => _buildCategoryPill(c, isDark))
                                          .toList(),
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          // Mobile Filter categories row
                          if (size.width < 800) ...[
                            const SizedBox(height: 14),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: kDocumentCategories
                                    .map((c) => _buildCategoryPill(c, isDark))
                                    .toList(),
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Card Grid
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
                          else
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
