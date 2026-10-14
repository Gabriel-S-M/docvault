import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/company_item.dart';
import '../models/user_item.dart';
import '../theme/app_theme.dart';
import '../widgets/user_form_modal.dart';

class UserManagementScreen extends StatefulWidget {
  final UserItem currentUser;
  final CompanyItem? currentCompany; // Available if opened by Super Gerente
  final List<UserItem> users;
  final List<CompanyItem> companies;
  final ValueChanged<UserItem> onAddUser;
  final ValueChanged<UserItem> onUpdateUser;
  final ValueChanged<String> onDeleteUser;
  final VoidCallback onBack;
  final bool isDarkMode;
  final ValueChanged<bool> onToggleDarkMode;

  const UserManagementScreen({
    super.key,
    required this.currentUser,
    this.currentCompany,
    required this.users,
    required this.companies,
    required this.onAddUser,
    required this.onUpdateUser,
    required this.onDeleteUser,
    required this.onBack,
    required this.isDarkMode,
    required this.onToggleDarkMode,
  });

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _searchQuery = '';
  UserItem? _editingUser;
  bool _isCreating = false;

  List<UserItem> get _visibleUsers {
    final query = _searchQuery.toLowerCase().trim();
    List<UserItem> list;

    if (widget.currentUser.isSuperGerente) {
      // Super Gerente only sees users of their own company
      final compId = widget.currentCompany?.id ?? widget.currentUser.companyId;
      list = widget.users.where((u) => u.companyId == compId).toList();
    } else {
      // Super Admin sees all users
      list = List.from(widget.users);
    }

    if (query.isNotEmpty) {
      list = list.where((u) {
        return u.name.toLowerCase().contains(query) ||
            u.email.toLowerCase().contains(query) ||
            u.role.label.toLowerCase().contains(query);
      }).toList();
    }

    return list;
  }

  bool _canEditUser(UserItem targetUser) {
    if (widget.currentUser.isSuperAdmin) {
      return true; // Super Admin can edit anyone
    }
    if (widget.currentUser.isSuperGerente) {
      // Super Gerente can only edit normal gerentes of their company
      return targetUser.isGerente &&
          targetUser.companyId == widget.currentUser.companyId;
    }
    return false;
  }

  bool _canDeleteUser(UserItem targetUser) {
    if (targetUser.id == widget.currentUser.id) {
      return false; // Cannot delete self
    }
    if (widget.currentUser.isSuperAdmin) {
      return true;
    }
    if (widget.currentUser.isSuperGerente) {
      return targetUser.isGerente &&
          targetUser.companyId == widget.currentUser.companyId;
    }
    return false;
  }

  void _confirmDelete(UserItem user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDarkMode ? AppColors.stone900 : Colors.white,
        title: Text(
          'Excluir Usuário',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: widget.isDarkMode ? AppColors.stone100 : AppColors.stone900,
          ),
        ),
        content: Text(
          'Tem certeza que deseja remover o acesso de "${user.name}" (${user.email})?',
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
              widget.onDeleteUser(user.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Usuário "${user.name}" excluído com sucesso.'),
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
    final visible = _visibleUsers;
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
                        // Left: Back button & Title
                        Row(
                          children: [
                            InkWell(
                              onTap: widget.onBack,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.stone800 : AppColors.stone100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDark ? AppColors.stone700 : AppColors.stone200,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.arrow_back_rounded,
                                      size: 16,
                                      color: isDark ? AppColors.stone300 : AppColors.stone700,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Voltar',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.stone300 : AppColors.stone700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Gerenciamento de Usuários',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.3,
                                        color: isDark ? AppColors.stone100 : AppColors.stone900,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.indigo950
                                            : AppColors.indigo500.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        widget.currentUser.isSuperAdmin
                                            ? 'ACESSO GLOBAL'
                                            : (widget.currentCompany?.name.toUpperCase() ??
                                                'EMPRESA'),
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? AppColors.indigo400
                                              : AppColors.indigo700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  widget.currentUser.isSuperAdmin
                                      ? 'Controle de Super Admins, Super Gerentes e Gerentes de Empresas'
                                      : 'Gestão dos Gerentes autorizados a gerenciar documentos da empresa',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark ? AppColors.stone400 : AppColors.stone500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Right: Theme Toggle
                        InkWell(
                          onTap: () => widget.onToggleDarkMode(!isDark),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
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
                      ],
                    ),
                  ),
                ),
              ),

              // Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Actions Bar: Search + New User Button
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: TextField(
                                    onChanged: (v) => setState(() => _searchQuery = v),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? AppColors.stone100 : AppColors.stone900,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Buscar usuário por nome, e-mail ou cargo…',
                                      prefixIcon: const Icon(Icons.search_rounded, size: 18),
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
                              ),
                              const SizedBox(width: 14),
                              ElevatedButton.icon(
                                onPressed: () => setState(() => _isCreating = true),
                                icon: const Icon(Icons.person_add_rounded, size: 16),
                                label: const Text(
                                  'Novo Usuário',
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

                          const SizedBox(height: 24),

                          // Header count
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${visible.length} ${visible.length == 1 ? 'usuário cadastrado' : 'usuários cadastrados'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.stone400 : AppColors.stone600,
                                ),
                              ),
                              if (widget.currentUser.isSuperGerente)
                                Text(
                                  'Restrito à empresa: ${widget.currentCompany?.name ?? ""}',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    color: AppColors.stone400,
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Users List
                          if (visible.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 60),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.stone900 : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? AppColors.stone800 : AppColors.stone200,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.people_outline_rounded,
                                    size: 40,
                                    color: isDark ? AppColors.stone600 : AppColors.stone400,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Nenhum usuário encontrado',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.stone300 : AppColors.stone700,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: visible.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final user = visible[index];
                                final comp = widget.companies.cast<CompanyItem?>().firstWhere(
                                      (c) => c?.id == user.companyId,
                                      orElse: () => null,
                                    );
                                final canEdit = _canEditUser(user);
                                final canDelete = _canDeleteUser(user);

                                return _buildUserTile(
                                  user: user,
                                  company: comp,
                                  canEdit: canEdit,
                                  canDelete: canDelete,
                                  isDark: isDark,
                                  isDesktop: isDesktop,
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

          // User Form Modal (Create / Edit)
          if (_isCreating || _editingUser != null)
            UserFormModal(
              currentUser: widget.currentUser,
              initialUser: _editingUser,
              companies: widget.companies,
              fixedCompany: widget.currentCompany,
              onSave: (user) {
                if (_editingUser != null) {
                  widget.onUpdateUser(user);
                } else {
                  widget.onAddUser(user);
                }
                setState(() {
                  _isCreating = false;
                  _editingUser = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Usuário "${user.name}" ${_editingUser != null ? 'atualizado' : 'cadastrado'} com sucesso!'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.stone800,
                  ),
                );
              },
              onClose: () {
                setState(() {
                  _isCreating = false;
                  _editingUser = null;
                });
              },
              isDarkMode: isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildUserTile({
    required UserItem user,
    required CompanyItem? company,
    required bool canEdit,
    required bool canDelete,
    required bool isDark,
    required bool isDesktop,
  }) {
    Color roleBadgeColor;
    Color roleTextColor;

    switch (user.role) {
      case UserRole.superAdmin:
        roleBadgeColor = AppColors.indigo600.withValues(alpha: 0.15);
        roleTextColor = isDark ? AppColors.indigo400 : AppColors.indigo700;
        break;
      case UserRole.superGerente:
        roleBadgeColor = Colors.purple.withValues(alpha: 0.15);
        roleTextColor = isDark ? Colors.purpleAccent : Colors.purple.shade700;
        break;
      case UserRole.gerente:
        roleBadgeColor = Colors.teal.withValues(alpha: 0.15);
        roleTextColor = isDark ? Colors.tealAccent : Colors.teal.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.stone900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.stone800 : AppColors.stone200,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? AppColors.stone800 : AppColors.stone100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.stone100 : AppColors.stone800,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // User details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.stone100 : AppColors.stone900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleBadgeColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user.role.label,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: roleTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? AppColors.stone400 : AppColors.stone600,
                      ),
                    ),
                    if (company != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '·',
                        style: TextStyle(
                          color: isDark ? AppColors.stone600 : AppColors.stone300,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(company.icon, size: 12, color: company.accentColor),
                      const SizedBox(width: 4),
                      Text(
                        company.name,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.stone300 : AppColors.stone700,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canEdit)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: 'Editar usuário',
                  splashRadius: 18,
                  color: isDark ? AppColors.stone300 : AppColors.stone700,
                  onPressed: () => setState(() => _editingUser = user),
                ),
              if (canDelete)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  tooltip: 'Excluir usuário',
                  splashRadius: 18,
                  color: Colors.redAccent,
                  onPressed: () => _confirmDelete(user),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
