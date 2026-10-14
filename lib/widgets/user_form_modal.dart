import 'package:flutter/material.dart';
import '../models/company_item.dart';
import '../models/user_item.dart';
import '../theme/app_theme.dart';

class UserFormModal extends StatefulWidget {
  final UserItem currentUser; // Who is creating/editing
  final UserItem? initialUser; // User being edited, or null for new user
  final List<CompanyItem> companies;
  final CompanyItem? fixedCompany; // If accessed by Super Gerente
  final ValueChanged<UserItem> onSave;
  final VoidCallback onClose;
  final bool isDarkMode;

  const UserFormModal({
    super.key,
    required this.currentUser,
    this.initialUser,
    required this.companies,
    this.fixedCompany,
    required this.onSave,
    required this.onClose,
    required this.isDarkMode,
  });

  @override
  State<UserFormModal> createState() => _UserFormModalState();
}

class _UserFormModalState extends State<UserFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passController;

  late UserRole _selectedRole;
  String? _selectedCompanyId;

  @override
  void initState() {
    super.initState();
    final u = widget.initialUser;
    _nameController = TextEditingController(text: u?.name ?? '');
    _emailController = TextEditingController(text: u?.email ?? '');
    _passController = TextEditingController(text: u?.password ?? '');

    if (widget.currentUser.isSuperGerente) {
      _selectedRole = UserRole.gerente;
      _selectedCompanyId = widget.fixedCompany?.id ?? widget.currentUser.companyId;
    } else {
      _selectedRole = u?.role ?? UserRole.gerente;
      _selectedCompanyId = u?.companyId ??
          (widget.companies.isNotEmpty ? widget.companies.first.id : null);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.initialUser != null;
    final id = isEditing
        ? widget.initialUser!.id
        : 'user-${DateTime.now().millisecondsSinceEpoch}';

    final user = UserItem(
      id: id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passController.text.trim(),
      role: _selectedRole,
      companyId: _selectedRole == UserRole.superAdmin ? null : _selectedCompanyId,
    );

    widget.onSave(user);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final cardBg = isDark ? AppColors.stone900 : Colors.white;
    final borderColor = isDark ? AppColors.stone700 : AppColors.stone200;
    final isEditing = widget.initialUser != null;
    final canChangeRole = widget.currentUser.isSuperAdmin;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.18),
                blurRadius: 32,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 16, 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.indigo600.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.person_outline_rounded,
                                color: AppColors.indigo600,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isEditing ? 'Editar Usuário' : 'Novo Usuário',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.stone100 : AppColors.stone900,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: widget.onClose,
                          icon: const Icon(Icons.close_rounded, size: 20),
                          splashRadius: 18,
                          color: isDark ? AppColors.stone400 : AppColors.stone600,
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    color: isDark ? AppColors.stone800 : AppColors.stone200,
                    height: 1,
                  ),

                  // Body
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        _buildLabel('Nome Completo', isDark),
                        TextFormField(
                          controller: _nameController,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: isDark ? AppColors.stone100 : AppColors.stone900,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Ex: Mariana Silva',
                            isDense: true,
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Nome é obrigatório' : null,
                        ),

                        const SizedBox(height: 14),

                        // Email
                        _buildLabel('E-mail de Acesso', isDark),
                        TextFormField(
                          controller: _emailController,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: isDark ? AppColors.stone100 : AppColors.stone900,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'usuario@empresa.com',
                            isDense: true,
                          ),
                          validator: (v) => (v == null || !v.contains('@'))
                              ? 'E-mail válido é obrigatório'
                              : null,
                        ),

                        const SizedBox(height: 14),

                        // Password
                        _buildLabel('Senha de Acesso', isDark),
                        TextFormField(
                          controller: _passController,
                          obscureText: true,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: isDark ? AppColors.stone100 : AppColors.stone900,
                          ),
                          decoration: const InputDecoration(
                            hintText: '••••••••',
                            isDense: true,
                          ),
                          validator: (v) => (v == null || v.trim().length < 3)
                              ? 'Senha deve conter pelo menos 3 caracteres'
                              : null,
                        ),

                        const SizedBox(height: 14),

                        // Role Selection (Only changeable by Super Admin)
                        _buildLabel('Papel / Nível de Acesso', isDark),
                        if (canChangeRole)
                          DropdownButtonFormField<UserRole>(
                            initialValue: _selectedRole,
                            dropdownColor: isDark ? AppColors.stone900 : Colors.white,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: isDark ? AppColors.stone100 : AppColors.stone900,
                            ),
                            decoration: const InputDecoration(isDense: true),
                            items: UserRole.values.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role.label),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedRole = val;
                                  if (val == UserRole.superAdmin) {
                                    _selectedCompanyId = null;
                                  } else if (_selectedCompanyId == null &&
                                      widget.companies.isNotEmpty) {
                                    _selectedCompanyId = widget.companies.first.id;
                                  }
                                });
                              }
                            },
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.stone800 : AppColors.stone100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? AppColors.stone700 : AppColors.stone200,
                              ),
                            ),
                            child: Text(
                              'Gerente (restrito à empresa)',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: isDark ? AppColors.stone300 : AppColors.stone700,
                              ),
                            ),
                          ),

                        // Company Selection (if applicable and if Super Admin)
                        if (_selectedRole != UserRole.superAdmin) ...[
                          const SizedBox(height: 14),
                          _buildLabel('Empresa Vinculada', isDark),
                          if (widget.currentUser.isSuperAdmin)
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCompanyId,
                              dropdownColor: isDark ? AppColors.stone900 : Colors.white,
                              style: TextStyle(
                                fontSize: 13.5,
                                color: isDark ? AppColors.stone100 : AppColors.stone900,
                              ),
                              decoration: const InputDecoration(isDense: true),
                              items: widget.companies.map((comp) {
                                return DropdownMenuItem(
                                  value: comp.id,
                                  child: Row(
                                    children: [
                                      Icon(comp.icon, size: 16, color: comp.accentColor),
                                      const SizedBox(width: 8),
                                      Text(comp.name),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedCompanyId = val);
                                }
                              },
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Selecione uma empresa'
                                  : null,
                            )
                          else
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.stone800 : AppColors.stone100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? AppColors.stone700 : AppColors.stone200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  if (widget.fixedCompany != null) ...[
                                    Icon(
                                      widget.fixedCompany!.icon,
                                      size: 16,
                                      color: widget.fixedCompany!.accentColor,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    widget.fixedCompany?.name ??
                                        widget.currentUser.companyId ??
                                        '',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: isDark ? AppColors.stone300 : AppColors.stone700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),

                  Divider(
                    color: isDark ? AppColors.stone800 : AppColors.stone200,
                    height: 1,
                  ),

                  // Footer Actions
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: widget.onClose,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark ? AppColors.stone700 : AppColors.stone300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.indigo600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(isEditing ? 'Salvar Usuário' : 'Criar Usuário'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.stone300 : AppColors.stone700,
        ),
      ),
    );
  }
}
