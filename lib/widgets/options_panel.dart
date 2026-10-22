import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/company_item.dart';
import '../models/document_item.dart';
import '../models/user_item.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class OptionsPanel extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onToggleDarkMode;
  final SortKey currentSortKey;
  final ValueChanged<SortKey> onSortKeyChanged;
  final ViewMode currentViewMode;
  final ValueChanged<ViewMode> onViewModeChanged;
  final bool isLoggedIn;
  final VoidCallback onLogin;
  final VoidCallback onLogout;
  final VoidCallback onClose;
  final CompanyItem? company;
  final VoidCallback? onBackToCompanies;
  final List<UserItem>? users;
  final UserItem? currentUser;
  final ValueChanged<UserItem>? onLoginUser;
  final VoidCallback? onOpenUserManagement;

  const OptionsPanel({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    required this.currentSortKey,
    required this.onSortKeyChanged,
    required this.currentViewMode,
    required this.onViewModeChanged,
    required this.isLoggedIn,
    required this.onLogin,
    required this.onLogout,
    required this.onClose,
    this.company,
    this.onBackToCompanies,
    this.users,
    this.currentUser,
    this.onLoginUser,
    this.onOpenUserManagement,
  });

  @override
  State<OptionsPanel> createState() => _OptionsPanelState();
}

class _OptionsPanelState extends State<OptionsPanel> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(
      text: widget.company?.adminEmail ?? 'teste@teste.com',
    );
    _passwordController = TextEditingController(
      text: widget.company?.adminPassword ?? '12345',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _errorMessage = 'Por favor, preencha o e-mail e a senha.');
      return;
    }

    try {
      final cred = await AuthService().signIn(email, pass);
      final uid = cred.user?.uid;
      var user = uid != null ? await FirestoreService().getUserById(uid) : null;
      user ??= await FirestoreService().getUserByEmail(email);

      if (user != null) {
        if (user.isSuperAdmin || widget.company == null || user.companyId == widget.company?.id) {
          if (!mounted) return;
          setState(() => _errorMessage = null);
          widget.onLoginUser?.call(user);
          widget.onLogin();
          widget.onClose();
          return;
        } else {
          if (!mounted) return;
          setState(() {
            _errorMessage = 'Este usuário não possui permissão nesta empresa.';
          });
          return;
        }
      }
    } catch (_) {}

    // Fallback se encontrar em widget.users
    final userList = widget.users ?? const [];
    final matches = userList.where(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    ).toList();

    if (matches.isNotEmpty) {
      final user = matches.first;
      if (user.isSuperAdmin || widget.company == null || user.companyId == widget.company?.id) {
        if (!mounted) return;
        setState(() => _errorMessage = null);
        widget.onLoginUser?.call(user);
        widget.onLogin();
        widget.onClose();
        return;
      }
    }

    if (!mounted) return;
    setState(() {
      _errorMessage = 'E-mail ou senha incorretos.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final cardBg = isDark ? AppColors.stone900 : Colors.white;
    final borderColor = isDark ? AppColors.stone700 : AppColors.stone200;
    final dividerColor = isDark ? AppColors.stone700 : AppColors.stone100;

    return Container(
      width: 290,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section 1: CONTA / LOGIN ADMIN
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CONTA',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: AppColors.stone400,
                      ),
                    ),
                    if (!widget.isLoggedIn)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.indigo500.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Admin',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.indigo600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (widget.isLoggedIn)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: AppColors.indigo700,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                (widget.currentUser?.name.isNotEmpty == true
                                        ? widget.currentUser!.name[0]
                                        : (widget.company?.adminName.isNotEmpty == true
                                            ? widget.company!.adminName[0]
                                            : 'A'))
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.currentUser?.name ?? widget.company?.adminName ?? 'Teste',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.stone100 : AppColors.stone900,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  widget.currentUser?.isSuperGerente == true
                                      ? 'Super Gerente'
                                      : (widget.currentUser?.isSuperAdmin == true
                                          ? 'Super Admin'
                                          : 'Administrador'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.indigo400 : AppColors.indigo600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (widget.currentUser?.isSuperGerente == true ||
                          widget.currentUser?.isSuperAdmin == true) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 34,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              widget.onClose();
                              widget.onOpenUserManagement?.call();
                            },
                            icon: const Icon(Icons.people_outline_rounded, size: 15),
                            label: const Text(
                              'Gerenciar Usuários',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.indigo700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 34,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              widget.onLogout();
                              widget.onClose();
                            },
                            icon: const Icon(
                              Icons.logout_rounded,
                              size: 14,
                              color: Colors.redAccent,
                            ),
                            label: const Text(
                              'Sair da conta',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark ? AppColors.stone700 : AppColors.stone200,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 36,
                          child: TextField(
                            controller: _emailController,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.stone100 : AppColors.stone900,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'E-mail (${widget.company?.adminEmail ?? "teste@teste.com"})',
                              filled: true,
                              fillColor: isDark ? AppColors.stone800 : Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                              isDense: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.stone600 : AppColors.stone200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.indigo600),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 36,
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.stone100 : AppColors.stone900,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Senha (${widget.company?.adminPassword ?? "12345"})',
                              filled: true,
                              fillColor: isDark ? AppColors.stone800 : Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                              isDense: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.stone600 : AppColors.stone200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.indigo600),
                              ),
                            ),
                          ),
                        ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 10.5, color: Colors.redAccent),
                        ),
                      ],
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 34,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.indigo700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'Entrar no Painel Admin',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (widget.onBackToCompanies != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        widget.onClose();
                        widget.onBackToCompanies!();
                      },
                      icon: Icon(
                        Icons.swap_horiz_rounded,
                        size: 15,
                        color: isDark ? AppColors.stone300 : AppColors.stone700,
                      ),
                      label: Text(
                        'Trocar Empresa',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.stone200 : AppColors.stone800,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? AppColors.stone700 : AppColors.stone200,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Divider(color: dividerColor, height: 1),

          // Section 2: APARÊNCIA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'APARÊNCIA',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppColors.stone400,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.dark_mode_outlined,
                          size: 16,
                          color: isDark ? AppColors.stone300 : AppColors.stone500,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Modo escuro',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.stone200 : AppColors.stone800,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: widget.isDarkMode,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.indigo600,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: isDark ? AppColors.stone700 : AppColors.stone300,
                      onChanged: widget.onToggleDarkMode,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(color: dividerColor, height: 1),

          // Section 3: VISUALIZAÇÃO (Sort options)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VISUALIZAÇÃO',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppColors.stone400,
                  ),
                ),
                const SizedBox(height: 6),
                ...SortKey.values.map((sortKey) {
                  final isSelected = widget.currentSortKey == sortKey;
                  return InkWell(
                    onTap: () {
                      widget.onSortKeyChanged(sortKey);
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            sortKey.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected
                                  ? (isDark ? AppColors.indigo400 : AppColors.indigo700)
                                  : (isDark ? AppColors.stone300 : AppColors.stone700),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: isDark ? AppColors.indigo400 : AppColors.indigo700,
                            )
                          else
                            Text(
                              '→',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.stone400,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          Divider(color: dividerColor, height: 1),

          // Section 4: EXIBIÇÃO (Grid / List)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXIBIÇÃO',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppColors.stone400,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildViewModeButton(
                        label: 'Grade',
                        icon: Icons.grid_view_rounded,
                        mode: ViewMode.grid,
                        isSelected: widget.currentViewMode == ViewMode.grid,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildViewModeButton(
                        label: 'Lista',
                        icon: Icons.view_list_rounded,
                        mode: ViewMode.list,
                        isSelected: widget.currentViewMode == ViewMode.list,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeButton({
    required String label,
    required IconData icon,
    required ViewMode mode,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => widget.onViewModeChanged(mode),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.indigo950 : AppColors.stone100)
              : (isDark ? AppColors.stone800 : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.indigo600
                : (isDark ? AppColors.stone700 : AppColors.stone200),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? (isDark ? AppColors.indigo400 : AppColors.indigo700)
                  : (isDark ? AppColors.stone400 : AppColors.stone600),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? AppColors.indigo400 : AppColors.indigo700)
                    : (isDark ? AppColors.stone400 : AppColors.stone600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
