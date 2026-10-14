import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/company_item.dart';
import '../theme/app_theme.dart';
import '../widgets/company_form_modal.dart';

class DocVaultAdminScreen extends StatefulWidget {
  final List<CompanyItem> companies;
  final ValueChanged<CompanyItem> onAddCompany;
  final ValueChanged<CompanyItem> onUpdateCompany;
  final ValueChanged<String> onDeleteCompany;
  final VoidCallback onOpenUserManagement;
  final VoidCallback onLogout;
  final bool isDarkMode;
  final ValueChanged<bool> onToggleDarkMode;

  const DocVaultAdminScreen({
    super.key,
    required this.companies,
    required this.onAddCompany,
    required this.onUpdateCompany,
    required this.onDeleteCompany,
    required this.onOpenUserManagement,
    required this.onLogout,
    required this.isDarkMode,
    required this.onToggleDarkMode,
  });

  @override
  State<DocVaultAdminScreen> createState() => _DocVaultAdminScreenState();
}

class _DocVaultAdminScreenState extends State<DocVaultAdminScreen> {
  String _searchQuery = '';
  CompanyItem? _editingCompany;
  bool _isCreatingCompany = false;

  List<CompanyItem> get _filteredCompanies {
    final query = _searchQuery.toLowerCase().trim();
    if (query.isEmpty) return widget.companies;
    return widget.companies.where((comp) {
      return comp.name.toLowerCase().contains(query) ||
          comp.segment.toLowerCase().contains(query) ||
          comp.description.toLowerCase().contains(query);
    }).toList();
  }

  void _confirmDelete(CompanyItem company) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDarkMode ? AppColors.stone900 : Colors.white,
        title: Text(
          'Excluir Empresa',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: widget.isDarkMode ? AppColors.stone100 : AppColors.stone900,
          ),
        ),
        content: Text(
          'Tem certeza que deseja remover a empresa "${company.name}"? Todos os vínculos associados serão desativados.',
          style: TextStyle(
            fontSize: 13.5,
            color: widget.isDarkMode ? AppColors.stone300 : AppColors.stone700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDeleteCompany(company.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Empresa "${company.name}" excluída com sucesso.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.stone800,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final filtered = _filteredCompanies;
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: isDark ? AppColors.stone950 : AppColors.stone50,
      body: Stack(
        children: [
          Column(
            children: [
              // Top Bar
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
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo & System Tag
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.indigo600,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.shield_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'DocVault',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                color: isDark ? AppColors.stone100 : AppColors.stone900,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.indigo950
                                    : AppColors.indigo500.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'ADMIN GERAL DOCVAULT',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.indigo400
                                      : AppColors.indigo700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Action Buttons: Users Management + Theme Toggle + Logout
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: widget.onOpenUserManagement,
                              icon: const Icon(Icons.people_outline_rounded, size: 16),
                              label: Text(isDesktop ? 'Gerenciar Usuários' : 'Usuários'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? AppColors.indigo950
                                    : AppColors.indigo500.withValues(alpha: 0.12),
                                foregroundColor: isDark
                                    ? AppColors.indigo400
                                    : AppColors.indigo700,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: isDark
                                        ? AppColors.indigo800
                                        : AppColors.indigo500.withValues(alpha: 0.25),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            InkWell(
                              onTap: () => widget.onToggleDarkMode(!isDark),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.stone800 : AppColors.stone100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDark ? AppColors.stone700 : AppColors.stone200,
                                  ),
                                ),
                                child: Icon(
                                  isDark
                                      ? Icons.light_mode_outlined
                                      : Icons.dark_mode_outlined,
                                  size: 16,
                                  color: isDark ? AppColors.stone300 : AppColors.stone700,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            OutlinedButton.icon(
                              onPressed: widget.onLogout,
                              icon: const Icon(Icons.logout_rounded, size: 14),
                              label: const Text('Sair'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                side: BorderSide(
                                  color: isDark ? AppColors.stone700 : AppColors.stone300,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Gestão de Empresas',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.4,
                                        color: isDark
                                            ? AppColors.stone100
                                            : AppColors.stone900,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Crie, edite ou desative organizações conveniadas. (A alteração de PDFs é restrita aos gerentes de cada empresa)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? AppColors.stone400
                                            : AppColors.stone500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    setState(() => _isCreatingCompany = true),
                                icon: const Icon(Icons.add_business_rounded, size: 16),
                                label: const Text(
                                  'Nova Empresa',
                                  style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.indigo600,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Search Filter
                          SizedBox(
                            height: 40,
                            child: TextField(
                              onChanged: (v) => setState(() => _searchQuery = v),
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.stone100 : AppColors.stone900,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Filtrar empresas por nome ou segmento…',
                                prefixIcon:
                                    const Icon(Icons.search_rounded, size: 18),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.close_rounded, size: 16),
                                        splashRadius: 14,
                                        onPressed: () =>
                                            setState(() => _searchQuery = ''),
                                      )
                                    : null,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 0),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Cards Grid / List
                          if (filtered.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 60),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.stone900 : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.stone800
                                      : AppColors.stone200,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.domain_disabled_rounded,
                                    size: 40,
                                    color: isDark
                                        ? AppColors.stone600
                                        : AppColors.stone400,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Nenhuma empresa encontrada',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.stone300
                                          : AppColors.stone700,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                final company = filtered[index];
                                return _buildCompanyItemCard(
                                  company: company,
                                  isDark: isDark,
                                  onEdit: () =>
                                      setState(() => _editingCompany = company),
                                  onDelete: () => _confirmDelete(company),
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

          // Company Form Modal (Create / Edit)
          if (_isCreatingCompany || _editingCompany != null)
            CompanyFormModal(
              initialCompany: _editingCompany,
              onSave: (comp) {
                if (_editingCompany != null) {
                  widget.onUpdateCompany(comp);
                } else {
                  widget.onAddCompany(comp);
                }
                setState(() {
                  _isCreatingCompany = false;
                  _editingCompany = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Empresa "${comp.name}" ${_editingCompany != null ? 'atualizada' : 'cadastrada'} com sucesso!'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.stone800,
                  ),
                );
              },
              onClose: () {
                setState(() {
                  _isCreatingCompany = false;
                  _editingCompany = null;
                });
              },
              isDarkMode: isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildCompanyItemCard({
    required CompanyItem company,
    required bool isDark,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.stone900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.stone800 : AppColors.stone200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: company.accentColor.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: company.accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(company.icon, color: company.accentColor, size: 24),
          ),

          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      company.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.stone100 : AppColors.stone900,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.stone800 : AppColors.stone100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        company.segment.toUpperCase(),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.stone300
                              : AppColors.stone600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  company.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.stone400 : AppColors.stone600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 14,
                      color: isDark ? AppColors.stone500 : AppColors.stone400,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${company.documents.length} documentos cadastrados',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: isDark ? AppColors.stone400 : AppColors.stone500,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Icon(
                      Icons.admin_panel_settings_outlined,
                      size: 14,
                      color: isDark ? AppColors.stone500 : AppColors.stone400,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Admin: ${company.adminEmail}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: isDark ? AppColors.stone400 : AppColors.stone500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: const Text('Editar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  side: BorderSide(
                    color: isDark ? AppColors.stone700 : AppColors.stone300,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                tooltip: 'Excluir Empresa',
                splashRadius: 18,
                color: Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
