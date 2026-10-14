import 'package:flutter/material.dart';
import '../models/company_item.dart';
import '../theme/app_theme.dart';

class CompanyFormModal extends StatefulWidget {
  final CompanyItem? initialCompany;
  final ValueChanged<CompanyItem> onSave;
  final VoidCallback onClose;
  final bool isDarkMode;

  const CompanyFormModal({
    super.key,
    this.initialCompany,
    required this.onSave,
    required this.onClose,
    required this.isDarkMode,
  });

  @override
  State<CompanyFormModal> createState() => _CompanyFormModalState();
}

class _CompanyFormModalState extends State<CompanyFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _segmentController;
  late final TextEditingController _descController;
  late final TextEditingController _emailController;
  late final TextEditingController _passController;
  late final TextEditingController _adminNameController;

  late IconData _selectedIcon;
  late Color _selectedColor;

  static const List<Color> _colorOptions = [
    Color(0xFF4F46E5), // Indigo
    Color(0xFF0D9488), // Teal
    Color(0xFF7C3AED), // Violet
    Color(0xFFE11D48), // Rose
    Color(0xFFD97706), // Amber
    Color(0xFF2563EB), // Blue
    Color(0xFF059669), // Emerald
    Color(0xFF475569), // Slate
  ];

  static const List<IconData> _iconOptions = [
    Icons.business_rounded,
    Icons.code_rounded,
    Icons.local_shipping_rounded,
    Icons.account_balance_rounded,
    Icons.medical_services_rounded,
    Icons.shopping_bag_rounded,
    Icons.factory_rounded,
    Icons.lightbulb_rounded,
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.initialCompany;
    _nameController = TextEditingController(text: c?.name ?? '');
    _segmentController = TextEditingController(text: c?.segment ?? '');
    _descController = TextEditingController(text: c?.description ?? '');
    _emailController = TextEditingController(
      text: c?.adminEmail ?? 'admin@empresa.com',
    );
    _passController = TextEditingController(
      text: c?.adminPassword ?? '12345',
    );
    _adminNameController = TextEditingController(
      text: c?.adminName ?? 'Gerente',
    );
    _selectedIcon = c?.icon ?? _iconOptions.first;
    _selectedColor = c?.accentColor ?? _colorOptions.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _segmentController.dispose();
    _descController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _adminNameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.initialCompany != null;
    final id = isEditing
        ? widget.initialCompany!.id
        : _nameController.text
            .trim()
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]'), '-')
            .replaceAll(RegExp(r'-+'), '-')
            .replaceAll(RegExp(r'^-|-$'), '');

    final company = CompanyItem(
      id: id.isNotEmpty ? id : 'empresa-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      segment: _segmentController.text.trim(),
      description: _descController.text.trim(),
      icon: _selectedIcon,
      accentColor: _selectedColor,
      adminEmail: _emailController.text.trim(),
      adminPassword: _passController.text.trim(),
      adminName: _adminNameController.text.trim(),
      documents: widget.initialCompany?.documents ?? [],
    );

    widget.onSave(company);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final cardBg = isDark ? AppColors.stone900 : Colors.white;
    final borderColor = isDark ? AppColors.stone700 : AppColors.stone200;
    final isEditing = widget.initialCompany != null;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
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
                  // Modal Top Header
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
                                color: _selectedColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _selectedIcon,
                                color: _selectedColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isEditing ? 'Editar Empresa' : 'Cadastrar Nova Empresa',
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

                  // Scrollable Body
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          _buildLabel('Nome da Empresa', isDark),
                          TextFormField(
                            controller: _nameController,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: isDark ? AppColors.stone100 : AppColors.stone900,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Ex: Nexus Soluções Digitais',
                              isDense: true,
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Nome é obrigatório' : null,
                          ),

                          const SizedBox(height: 14),

                          // Segment
                          _buildLabel('Setor / Segmento de Atuação', isDark),
                          TextFormField(
                            controller: _segmentController,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: isDark ? AppColors.stone100 : AppColors.stone900,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Ex: Tecnologia & Software',
                              isDense: true,
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Segmento é obrigatório' : null,
                          ),

                          const SizedBox(height: 14),

                          // Description
                          _buildLabel('Descrição Institucional', isDark),
                          TextFormField(
                            controller: _descController,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: isDark ? AppColors.stone100 : AppColors.stone900,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Breve resumo das atividades da organização…',
                              isDense: true,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Descrição é obrigatória'
                                : null,
                          ),

                          const SizedBox(height: 18),

                          // Accent Color Picker
                          _buildLabel('Cor de Identidade da Marca', isDark),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _colorOptions.map((color) {
                              final isSelected = _selectedColor == color;
                              return InkWell(
                                onTap: () => setState(() => _selectedColor = color),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? (isDark ? Colors.white : Colors.black87)
                                          : Colors.transparent,
                                      width: 2.5,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 18),

                          // Icon Picker
                          _buildLabel('Ícone Representativo', isDark),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _iconOptions.map((icon) {
                              final isSelected = _selectedIcon == icon;
                              return InkWell(
                                onTap: () => setState(() => _selectedIcon = icon),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _selectedColor.withValues(alpha: 0.18)
                                        : (isDark ? AppColors.stone800 : AppColors.stone100),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? _selectedColor
                                          : (isDark ? AppColors.stone700 : AppColors.stone200),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Icon(
                                    icon,
                                    color: isSelected
                                        ? _selectedColor
                                        : (isDark ? AppColors.stone400 : AppColors.stone600),
                                    size: 20,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          Divider(
                            color: isDark ? AppColors.stone800 : AppColors.stone200,
                            height: 1,
                          ),

                          const SizedBox(height: 16),

                          // Admin Credentials
                          Text(
                            'ADMINISTRADOR INICIAL DA EMPRESA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: isDark ? AppColors.indigo400 : AppColors.indigo700,
                            ),
                          ),
                          const SizedBox(height: 12),

                          _buildLabel('Nome do Gerente', isDark),
                          TextFormField(
                            controller: _adminNameController,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: isDark ? AppColors.stone100 : AppColors.stone900,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Ex: Carlos Silva',
                              isDense: true,
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Nome é obrigatório' : null,
                          ),

                          const SizedBox(height: 12),

                          _buildLabel('E-mail do Administrador', isDark),
                          TextFormField(
                            controller: _emailController,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: isDark ? AppColors.stone100 : AppColors.stone900,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'admin@empresa.com',
                              isDense: true,
                            ),
                            validator: (v) => (v == null || !v.contains('@'))
                                ? 'E-mail válido é obrigatório'
                                : null,
                          ),

                          const SizedBox(height: 12),

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
                                ? 'Senha deve ter pelo menos 3 dígitos'
                                : null,
                          ),
                        ],
                      ),
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
                          child: Text(isEditing ? 'Salvar Alterações' : 'Criar Empresa'),
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
